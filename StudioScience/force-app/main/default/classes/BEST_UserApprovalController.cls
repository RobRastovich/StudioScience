public without sharing class BEST_UserApprovalController {    
    
    @AuraEnabled
    public static String updateContactOnApproval(Id contactId) {
        Contact con = [Select id, User_Approval_Status__c from Contact where id = :contactId];
        try {
            con.User_Approval_Status__c = 'Approved';
            update con;
        } catch (Exception ex) {
            if(ex.getDmlMessage(0).contains('DUPLICATE_USERNAME')){
                return 'DUPLICATE_USERNAME: Duplicate Username. The username already exists in this or another Salesforce organization. Usernames must be unique across all Salesforce organizations. To resolve, use a different username (it doesn\'t need to match the user\'s email address).';
            }
            return ex.getMessage();
        }
        return null;
    }
    
    @AuraEnabled
    public static void updateContactReasonOnRejection(Id contactId, String reason) {
        Contact con = [Select id, User_Approval_Status__c, Rejection_Reason__c from Contact where id = :contactId];
        con.User_Approval_Status__c = 'Rejected';
        con.Rejection_Reason__c = reason;
        update con;
    }
    
    @AuraEnabled
    public static Contact getContactDetails(String recordId) {
        Contact contactRecord = [Select Id, Name, Email, User_Approval_Status__c, Territory__c, Account.Name, Rejection_Reason__c from Contact where Id = :recordId limit 1];
        return contactRecord;
    }
}