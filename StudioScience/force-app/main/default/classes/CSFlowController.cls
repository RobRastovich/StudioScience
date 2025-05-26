public class CSFlowController {
    public Flow.Interview.Form_Selection_Master_Flow myFlow {get; set;}
    public List<Attachment> newAttachments {get; set; }
    public ID returnId;
    public String recordTypeName {get; set;}
    public String militaryPriority {get; set;}
    public Boolean recordCreated {get; set;}
    private final Integer NUM_OF_ATTACHMENTS = 10;
    public String currentUserlanguage {get; set;}
    public ID flowID {get; set;}
    public Boolean emailEntryScreen {get; set;}
    public Boolean finalScreen {get; set;}
    public String AccessGroup {get; set;}
    public List<FeedItem> lfi {get; set;}
    public User u {get; set;}
    public String acctId {get; set;}
    public Case c = new Case();
    public Id caseId;

    public CSFlowController() {
        if (myFlow != null) {
            flowID = myFlow.RecordIDMaster;
            emailEntryScreen = myFlow.EmailEntryScreen;
            finalScreen = myFlow.finalScreen;
        }

        newAttachments = new List<Attachment>();
        for (Integer i = 0; i < NUM_OF_ATTACHMENTS; i++) {
            newAttachments.add(new Attachment());
        }
        currentUserLanguage = userinfo.getLanguage();
        u = [select Access_Group__c, Email from User where Id = :userinfo.getUserId() Limit 1];

        acctId = Apexpages.currentPage().getParameters().get('acctId');
        lfi = new List<FeedItem>();
    }

    public String getUserProfile() {
        Profile p = [select Name from Profile where Id = :userinfo.getProfileId() Limit 1];
        recordTypeName = p.Name;
        return recordTypeName;
    }

    public String getuserAccessGroup() {

        System.debug('User Access Group: ' + u.Access_Group__c);
        AccessGroup = u.Access_Group__c;
        return AccessGroup;
    }

    public String getMilitaryPriorityCurrentUser() {
        User p1 = [select name, profileId, Profile.Name, Military__c from User where Id = :userinfo.getUserId()];
        System.debug(p1.Profile.Name);
        if (p1.Profile.Name == 'Company Employee') {
            militaryPriority = p1.Military__c;
            return militaryPriority;
        } else {
            User currentUser = [select contactID from User where id = :userinfo.getUserId()];
            List<Contact> c = [select accountId from Contact where id = :currentUser.contactID ];
            system.debug('contact size:::' + c.size());
            if (c.size() > 0) {
                Account a = [select Name, Military__c from Account where id = : c[0].AccountId];
                if (a.military__c == null) {
                    militaryPriority = 'null';
                    return militaryPriority;
                } else {
                    militaryPriority = a.Military__c;
                    return militaryPriority;
                }
            } else {
                militaryPriority = 'null';
                return militaryPriority;
            }
        }
    }

    public void addMore() {
        newAttachments = new List<Attachment>();
        for (Integer i = 0; i < NUM_OF_ATTACHMENTS; i++) {
            newAttachments.add(new Attachment());
        }
    }

    public void setCaseId() {
        if (myFlow != null) {
            if (String.isNotBlank(myFlow.RecordIDMaster)) {
                caseId = Id.valueOf(myFlow.RecordIDMaster);
            }
        } else if (flowID != null ) {
            caseId = flowID;
        }
    }

    /*    public List<Attachment> getAtts() {
            if(myFlow != null) {
                List<Attachment> currentAttachments = [select Name, BodyLength, ContentType  from Attachment where parentId = :myFlow.RecordIDMaster];
                if(currentAttachments.size() > 0) {
                    return currentAttachments;
                }

            }
            return null;
        }
    */

    public Map<String, String> getFeedList() {
        setCaseId();
        if (caseId != null) {
            Map<String, String> MapOfFiles = new Map<String, String>();
            try {
                lfi = [select parentId, Type, ContentSize, ContentFileName, Title from FeedItem where parentId = :caseId AND Type = 'ContentPost'];

            } catch (Exception e) {

            }
            if (!lfi.isEmpty()) {
                system.debug('Feedlist to render ==>' + lfi);
                for (FeedItem FI : lfi) {
                    String fsize = String.valueOf(FI.ContentSize);
                    String fname = String.valueOf(FI.ContentFileName);
                    MapOfFiles.put(fname, fsize);
                }
                return MapOfFiles;
            }
        }
        return null;
    }


    public void save() {
        setCaseId();
        List<Attachment> toInsert = new List<Attachment>();
        for (Attachment newAtt : newAttachments) {
            if (newAtt.Body != null) {
                newAtt.parentId = caseId;
                toInsert.add(newAtt);
            }
        }
        if (toInsert.size() > 0) {
            recordCreated = true;
            insert toInsert;
            newAttachments.clear();
            addMore();
        }
    }

    public void updateAccount() {
        setCaseId();
        if (String.isNotBlank(caseId)) {
            c = [select id, AccountId, Purchase_Order_Number__c, Type from Case where id = :caseId limit 1];

            if (c.AccountId == null) {
                if (myFlow != null) {
                    if (String.isNotBlank(myFlow.acctId) && myFlow.acctId != 'undefined') {
                        c.AccountId = Id.valueOf(myFlow.acctId);
                        update c;
                    }
                }
            }
        }
    }


    public void sendEmail() {
        setCaseId();
        if (caseId != null) {
            List<Case> cases = [select id, ccEmail__c, Type, Purchase_Order_Number__c from Case where Id = :caseId];
            try {
                EmailComponentController.sendEmail(cases[0].ccEmail__c, caseId, myFlow.FormTypeValueMaster, cases[0].Type);
            } catch (Exception e) {

            }
        }
    }
}