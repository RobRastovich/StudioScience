global without sharing class BEST_LightningSelfRegisterController {

    public BEST_LightningSelfRegisterController() {

    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @AuraEnabled
    public static String selfRegisterContactCreation(String firstname ,String lastname, String email, String accountId, String territory) {
        try {
            if(firstname == null || String.isEmpty(firstname)) {
                return Label.FirstName_Is_Required_Label;
            }
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }
            
            if(accountId == null || String.isEmpty(accountId)) {
                return Label.Agency_Is_Required_Label;
            }
            
            Id PortalRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Portal_User').getRecordTypeId();
            List<Contact> contacts = [Select id, email, User_Approval_Status__c from Contact where email =: email and recordTypeId =: PortalRecordTypeId];
            if(contacts.size() > 0) {
                if(contacts[0].User_Approval_Status__c == 'Approved') {
                    return Label.Duplicate_Email_for_BEST_Registration;
                } else if(contacts[0].User_Approval_Status__c == 'Pending Review') {
                    return Label.BEST_Duplicate_Pending_Email_Message;
                }else {
                    Map<String, Object> Params = new Map<String, Object>();
                    Params.put('recordId',contacts[0].id);
                    Flow.Interview.BEST_Duplicate_Rejected_Email_Flow flow1 = new Flow.Interview.BEST_Duplicate_Rejected_Email_Flow(Params);
                    flow1.start();
                    return Label.BEST_Duplicate_Rejected_Email_Message;
                }                
            }
            List<User> users = [Select id, email, firstName,LastName from User where email =: email];
            if(users.size() > 0)
            {
                return Label.Duplicate_Email_for_BEST_Registration;
            }
            
            Contact bestContact = new Contact();
            bestContact.FirstName = firstname;
            bestContact.LastName = lastname;
            bestContact.AccountId = accountId;
            bestContact.Email = email;
            bestContact.User_Approval_Status__c = 'Pending Review';
            bestContact.Territory__c = territory;
            bestContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Portal_User').getRecordTypeId();
            List<Account> acc = [Select id , Account_Manager_Email__c from Account where id = :accountId];
            if(acc.size() > 0) {
                bestContact.Account_Manager_Email__c = acc[0].Account_Manager_Email__c;
            }
            insert bestContact;
            Map<String, Object> Param = new Map<String, Object>();
            Param.put('recordId',bestContact.id);
            Flow.Interview.BEST_EVER_User_Approval_Flow approvalFlow = new Flow.Interview.BEST_EVER_User_Approval_Flow(Param);
            approvalFlow.start();

            Site bestEverSite = [SELECT Id FROM Site WHERE Name = 'BEST_EVER_Portal'];
            SiteDetail bestEverSiteDetail = [select SecureURL from SiteDetail where DurableId = :bestEverSite.Id];
            String returnConfirmUrl = bestEverSiteDetail.SecureURL + '/s/UserAcknowledgement';
            ApexPages.PageReference confirmRef = new PageReference(returnConfirmUrl);
            if(!Test.isRunningTest()) {
                aura.redirect(confirmRef);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }
    
    @AuraEnabled
    public static List<SelectOptions> getPicklistValues(String ObjectApi_name,String Field_name){
        List<String> pickListValues = new List<String>();
        List<SelectOptions> picklistOptions = new List<SelectOptions>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            picklistOptions.add(new SelectOptions(a.getLabel(), a.getValue()));//add the value  to our final list
        }
        return picklistOptions;
    }
    
    public class SelectOptions{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public SelectOptions(String label, String value){
            this.label = label;
            this.value = value;
        }
    }    

}