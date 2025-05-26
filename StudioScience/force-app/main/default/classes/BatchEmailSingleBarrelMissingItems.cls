global class BatchEmailSingleBarrelMissingItems implements Database.Batchable<sObject>, Database.Stateful {

    String query;
    Set<Id> caseRtIds = SBP_Constants.caseSingleBarrelRtIds;
    List<String> cancelledStatus = new list<String>{'Canceled','Cancelled - Kit Not Selected','Cancelled-Allocation'}; // Condition Added (SR_183328).
    public Set<Id> usersIdsThatRecievedEmails = new Set<Id>();
    public Set<Id> uniqueContactIdSet = new Set<Id>(); // Added for INC_183534 - Single Barrel - Automated Email Missing PO
    
    global BatchEmailSingleBarrelMissingItems(String query, Set<Id> caseRtIds) {
        this.query = query;
        this.caseRtIds = caseRtIds;
    }
    global BatchEmailSingleBarrelMissingItems() {

        query = 'select Id '
                + ', Purchase_Order_Uploaded__c'
                + ', Bottle_Text_Entered__c'
                + ', POS_Items_Selected__c'
                + ', Barrel_Selected__c'
                + ', Missing_Items__c'
                + ', Missing_PO__c'
                + ', ContactId'
                + ', Brand__c'
                + ', CcEmail__c'
                + ', Submitter__c'
                + ', Submitter__r.Name'
                + ', Status'
                + ', RecordTypeId FROM Case where Case.RecordTypeId IN :caseRtIds'
                + '  AND Status NOT IN:cancelledStatus'
                + '  AND IsClosed = false';
               
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, List<String>> contactToCcemailMap = new Map<Id, List<String>>();
        Set<Id> userIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Custom_Exception_Logs__c> errors = new List<Custom_Exception_Logs__c>();

        for (Case c : scope) {
            // filter out maker's mark orders that aren't ready for a PO
            if (c.Brand__c == 'Makers Mark' && c.Status != SBP_Constants.PENDING_PURCHASE_ORDER && (!c.Bottle_Text_Entered__c || !c.POS_Items_Selected__c || !c.Barrel_Selected__c)) {
                continue;
            }
            if (c.ContactId != null && !uniqueContactIdSet.contains(c.ContactId) && c.Missing_PO__c == True) {
                if (!contactToCcemailMap.containsKey(c.ContactId)) {
                    contactToCcemailMap.put(c.ContactId, new List<String>());
                }

                if (String.isNotBlank(c.CcEmail__c)) {
                    // are there multiple email addresses
                    if (c.CcEmail__c.contains(',')) {
                        for (String email : c.CcEmail__c.split(',')) {
                            if (Pattern.matches('^([0-9a-zA-Z+_.-]*[0-9a-zA-Z]+[@][0-9a-zA-Z+_.-]+\\.[0-9a-zA-Z+_.-]*)$', email)) {
                                contactToCcemailMap.get(c.ContactId).add(email);
                            } else {
                                errors.add(CreateExceptionLog.createExceptionLog('BatchEmailSingleBarrelMissingItems', 'execute', 'Case has invalid email in "CcEmail__c" field: ' + c, 'Warning', false));
                            }
                        }
                    } else {
                        if (Pattern.matches('^([0-9a-zA-Z+_.-]*[0-9a-zA-Z]+[@][0-9a-zA-Z+_.-]+\\.[0-9a-zA-Z+_.-]*)$', c.CcEmail__c)) {
                            contactToCcemailMap.get(c.ContactId).add(c.CcEmail__c);
                        } else {
                            errors.add(CreateExceptionLog.createExceptionLog('BatchEmailSingleBarrelMissingItems', 'execute', 'Case has invalid email in "CcEmail__c" field: ' + c, 'Warning', false));

                        }
                    }
                }
            }

            if (c.Submitter__c != null && !usersIdsThatRecievedEmails.contains(c.Submitter__c) && c.Missing_Items__c==True) {
                userIds.add(c.Submitter__c);
            }
        }
        usersIdsThatRecievedEmails.addAll(userIds);
        uniqueContactIdSet.addAll(contactToCcemailMap.keySet() );
        if(uniqueContactIdSet.size()>0){ // Added the condition check to stop empty email template triggering 4/30
           List<Messaging.SingleEmailMessage> missingPurchaseOrderEmails = SBP_EmailUtility.missingPurchaseOrderEmail('Missing_Purchase_Orders', contactToCcemailMap);
           emails.addAll(missingPurchaseOrderEmails);
        }
        if(userIds.size()>0){  // Added the condition check to stop empty email template triggering 4/30
            List<Messaging.SingleEmailMessage> allMissingItems = SBP_EmailUtility.sendMissingItemEmail(userIds, 'All_Missing_Items');
            emails.addAll(allMissingItems);
        }
        Messaging.reserveSingleEmailCapacity(emails.size());
        //System.debug(emails);

        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails, true);

        for (Messaging.SendEmailResult result : emailResults) {
            System.debug('Email result ' + result.IsSuccess());
            if (result.IsSuccess()) {
                System.debug('Email Success ' + result);
            } else {
                    for (Database.Error err : result.getErrors()) {
                        errors.add(CreateExceptionLog.createExceptionLog('BatchEmailSingleBarrelMissingItems', 'execute', 'An error occured while sending single barrel emails:' + err, 'Warning', false));
                }
            }
        }
            if (!errors.isEmpty()) {
                insert errors;
            }
        
    }

    global void finish(Database.BatchableContext BC) {

    }

}