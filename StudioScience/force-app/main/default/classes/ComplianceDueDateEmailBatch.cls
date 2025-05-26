global class ComplianceDueDateEmailBatch implements Database.Batchable<sObject>, Schedulable{ 
    
    global String query;

    global ComplianceDueDateEmailBatch(){

    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String pricePostingRTName = ComplianceConstants.RECORDTYPE_PRICE_POSTING;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();       
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();     
        Id pricePostingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(pricePostingRTName).getRecordTypeId();     
        query = 'SELECT Id, RecordType.Name, Owner.Email, Parent.Owner.Email, OwnerId, Due_Date__c, Posting_Date__c, Submitted_Compliance__c FROM Case WHERE ' + 
        '(RecordTypeId = \'' + complianceSubCaseRecordTypeId + '\' AND Due_Date__c = NEXT_N_DAYS:7 AND Submitted_Compliance__c = false AND IsClosed = false AND status!=\'Waiting for Posting\') ' +
        'OR '+
        '(RecordTypeId = \'' + pricePostingRecordTypeId + '\' AND Posting_Date__c = NEXT_N_DAYS:7 AND IsClosed = false) ' +
        'OR '+
        '(RecordTypeId = \'' + brandRegistrationRecordTypeId + '\' AND Submitted_Compliance__c = false AND Due_Date__c < TODAY AND IsClosed = false AND Status!=\'Waiting for Kickoff\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        String emailServiceAddress = ComplianceConstants.EMAIL_SERVICE_ADDRESS;
        /*List<Contact> archiveContactList = [SELECT Id FROM Contact WHERE Name = 'Beam Suntory Archive' LIMIT 1];
        Contact archiveContact;
        if(archiveContactList.size() > 0){
            archiveContact = archiveContactList[0];
        }*/

        BusinessHours bh = [Select Id, TimeZoneSidKey, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, 
                                                        TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, 
                                                        ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime,
                                                        SaturdayStartTime, SaturdayEndTime 
                                                        From BusinessHours Where IsDefault = TRUE];

        Boolean isTodayBusinessDay = isDateBusinessDay(bh, System.today());
        Date nextBusinessDay = getNextBusinessDay(bh, System.today());

        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String pricePostingRTName = ComplianceConstants.RECORDTYPE_PRICE_POSTING;

        String brandRegistrationSubCasePastDueTemplateName = ComplianceConstants.BRAND_REG_PAST_DUE_TEMPLATE_API_NAME;
        String subCase1DayReminderTemplateName = ComplianceConstants.BRAND_REG_SUB_CASE_1_DAY_REMINDER;
        String pricePosting1DayReminderTemplateName = ComplianceConstants.PRICE_POSTING_1_DAY_REMINDER;


        List<Case> brandRegList = new List<Case>();
        List<Case> subCaseList = new List<Case>();
        List<Case> pricePostingList = new List<Case>();
        for(Case currCase: scope){
            if((currCase.RecordType.Name).equals(brandRegistrationRTName)){
                brandRegList.add(currCase);
            } else if((currCase.RecordType.Name).equals(subCaseRTName)){
                if(currCase.Due_Date__c > System.today() && currCase.Due_Date__c <= nextBusinessDay){
                    subCaseList.add(currCase);
                }
            } else if((currCase.RecordType.Name).equals(pricePostingRTName)){
                if(currCase.Posting_Date__c > System.today() && currCase.Posting_Date__c <= nextBusinessDay){
                    pricePostingList.add(currCase);
                }
            }
        }

        String brandRegTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:brandRegistrationSubCasePastDueTemplateName].Id;
        String subCaseTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:subCase1DayReminderTemplateName].Id;
        String pricePostingTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:pricePosting1DayReminderTemplateName].Id;

        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();

        for(Case currCase: brandRegList){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(brandRegTemplateId, ComplianceConstants.SYSTEM_EMAIL_USER_ID, currCase.Id);
            
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(currCase.OwnerId);

            mail.setToAddresses(new List<String>{emailServiceAddress});
            mail.setWhatId(currCase.Id);
            allMails.add(mail);
        }

        for(Case currCase: subCaseList){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(subCaseTemplateId, ComplianceConstants.SYSTEM_EMAIL_USER_ID, currCase.Id);
            
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(currCase.OwnerId);


            mail.setToAddresses(new List<String>{emailServiceAddress});
            mail.setWhatId(currCase.Id);
            allMails.add(mail);
        }

        for(Case currCase: pricePostingList){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(pricePostingTemplateId, ComplianceConstants.SYSTEM_EMAIL_USER_ID, currCase.Id);
            
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(currCase.OwnerId);
            mail.setToAddresses(new List<String>{emailServiceAddress});
            mail.setWhatId(currCase.Id);
            allMails.add(mail);
        }

        Messaging.sendEmail(allMails);
    }

    global void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.INFO, 'The Compliance Email job has completed.');
    }

    global void execute(SchedulableContext SC) {
        Id batchInstanceId = Database.executeBatch(new ComplianceDueDateEmailBatch());
    }

    public static Boolean isDateBusinessDay(BusinessHours bh, Date d){
        DateTime dt = DateTime.newInstance(d, bh.MondayStartTime);
        return BusinessHours.isWithin(bh.Id, dt);
    }

    public static Date getNextBusinessDay(BusinessHours bh, Date d){
        DateTime dt = DateTime.newInstance(d, bh.MondayEndTime);
        return BusinessHours.nextStartDate(bh.Id, dt).date();   
    }
}