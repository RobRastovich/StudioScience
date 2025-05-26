/**
* @description       : This class is use to execute assignment rule logic and send email notifications to customer, BA and Queue members. 
* @author            : Jaiveer Jha
* @group             : 
* @last modified on  : 07-10-2024
* @last modified by  : Jaiveer Jha
**/
public class LeadTriggerHandler{
    
    public static final String GROUP_NAME = 'Default_Queue_PRESTIGE';
    public static final String EMAIL_TEMPLATE_FOR_CUSTOMER_NOTIFICATION = 'New_lead_Enrollment_Notification_PRESTIGE';
    public static final String EMAIL_TEMPLATE_FOR_QUEUE_NOTIFICATION = 'New_Lead_Added_to_Database_Notification_PRESTIGE';
    public static final String EMAIL_TEMPLATE_FOR_BA_NOTIFICATION = 'New_Lead_Assignment_Notification_PRESTIGE';
    public static final String ORG_FROM_ADDRESS = 'sfdcnoreply@beamsuntory.com';
    public static final String WEB = 'Web';
    public static final String MANUAL =  'Manual';
    
    /**
* @description This method is use to update the owner to Prestige Default Queue
* @author Jaiveer Jha | 07-10-2024 
* @param listLead 
**/
    public static void updateLeadOwnerForPrestige(List<Lead> listLead){
        if(
            String.isNotBlank(listLead.get(0).Prestige_Lead_Source__c) &&
            listLead.get(0).Prestige_Lead_Source__c.equalsIgnoreCase(LeadTriggerHandler.WEB)
        ){
            List<Group> listGroup = [SELECT Id FROM Group WHERE Group.DeveloperName =: GROUP_NAME LIMIT 1];
        	listLead.get(0).ownerId = listGroup.get(0).Id;
        }
    }
    
    /**
* @description This method is use to execute the notification process
* @author Jaiveer Jha | 07-10-2024 
* @param listLead 
**/
    public static void executeNotificationProcess(List<Lead> listLead){
        if(String.isNotBlank(listLead.get(0).Prestige_Lead_Source__c)){
            if(listLead.get(0).Prestige_Lead_Source__c.equalsIgnoreCase(WEB)){
                sendEmailNotificationToCustomer(listLead);
                sendEmailNotificationToQueueMembers(listLead);
            }else if(listLead.get(0).Prestige_Lead_Source__c.equalsIgnoreCase(MANUAL)){
                sendEmailNotificationToQueueMembers(listLead);
            }
        }
    }
    
    /**
* @description This method is use to send email notification to customer
* @author Jaiveer Jha | 07-10-2024 
* @param listLead 
**/
    public static void sendEmailNotificationToCustomer(List<Lead> listLead) {
        sendEmailNotifications(listLead, EMAIL_TEMPLATE_FOR_CUSTOMER_NOTIFICATION, new List<String>{listLead.get(0).email});
    }
    /**
* @description This method is use to send email notification to queue members
* @author Jaiveer Jha | 07-10-2024 
* @param listLead 
**/
    public static void sendEmailNotificationToQueueMembers(List<Lead> listLead) {
        List<String> recipients = fetchQueueMembersEmailAddress(GROUP_NAME);
        sendEmailNotifications(listLead, EMAIL_TEMPLATE_FOR_QUEUE_NOTIFICATION, recipients);
    }
    /**
* @description This method is use to send email notification to BA
* @author Jaiveer Jha | 07-10-2024 
* @param listLead 
**/
    public static void sendEmailNotificationToBrandAmbassdor(List<Lead> listLead) {
        sendEmailNotifications(listLead, EMAIL_TEMPLATE_FOR_BA_NOTIFICATION, new List<String>{listLead.get(0).owner.email});
    }
    
    /**
* @description This method is use to fetch group member's email address
* @author Jaiveer Jha | 07-10-2024 
* @param groupName 
* @return List<String> 
**/
    public static List<String> fetchQueueMembersEmailAddress(String groupName) {
        List<String> listMembersEmails = new List<String>();
        Set<Id> setUserIDs = new Set<Id>();
        List<GroupMember> listGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :groupName];
        For(GroupMember memberObj: listGroupMembers){
            setUserIDs.add(memberObj.UserOrGroupId);
        }
        List<User> users = [SELECT Id, email from user where ID IN :setUserIDs]; 
        for(User userObj: users){
            listMembersEmails.add(userObj.email);
        }
        return listMembersEmails;
    }
    
    /**
* @description This common method is use to send email notification
* @author Jaiveer Jha | 07-10-2024 
* @param listLead 
* @param emailTemplateName 
* @param recipients 
**/
    public static void sendEmailNotifications(List<Lead> listLead, String emailTemplateName, List<String> recipients) {
        List<OrgWideEmailAddress> listOWEA = [select Id from OrgWideEmailAddress where Address =: ORG_FROM_ADDRESS LIMIT 1];
        List<EmailTemplate> listEmailTemplate = [SELECT Id, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: emailTemplateName];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        if(listOWEA != null && listOWEA.size() > 0 &&
           listEmailTemplate != null && listEmailTemplate.size() > 0 &&
           recipients != null && recipients.size() > 0 &&
           listLead != null && listLead.size() > 0
          ){
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
              email.setOrgWideEmailAddressId(listOWEA.get(0).Id);
              email.setTargetObjectId(listLead.get(0).Id);
              email.setTreatTargetObjectAsRecipient(false);
              email.setTemplateId(listEmailTemplate.get(0).Id);
              email.setToAddresses(recipients);
              email.setSaveAsActivity(true); 
              emails.add(email);
              
              try {
                  if(!Test.isRunningTest()){
                      List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
                      for (Messaging.SendEmailResult result : results) {
                          if (result.isSuccess()) {
                              System.debug('Email sent successfully');
                          } else {
                              System.debug('Error Sending Email: ' + result.getErrors()[0].getMessage());
                          }
                      }
                  }
              } catch (Exception e) {
                  System.debug(e.getMessage());
              }  
          }
    }  
        /**
* @description This common method is use to update the latest value in account record
* @author Jaiveer Jha | 07-10-2024 
* @param newLeadList 
**/    
    public static void updateLeadCurrentDetailstoAccount(List<Lead> newLeadList){
        lead leadObj = newLeadList.get(0);
        if(leadObj.IsConverted && leadObj.ConvertedAccountId != null && String.isNotBlank(leadObj.Prestige_Lead_Source__c)){
            List<Account> listAccount = [SELECT 
                                         ID, FirstName, LastName, Telephone__c 
                                         FROM Account
                                         WHERE ID =:leadObj.ConvertedAccountId];
            Account accObj = listAccount != null && listAccount.size() > 0 ? listAccount.get(0) : null;
            if(accObj != null && (
                accObj.FirstName != leadObj.FirstName ||
                accObj.LastName != leadObj.LastName ||
                accObj.Telephone__c != leadObj.Telephone__c
            )){
                accObj.FirstName = leadObj.FirstName;
                accObj.LastName = leadObj.LastName;
                accObj.Telephone__c = leadObj.Telephone__c;
                Database.update(accObj, false);
            }
        }
    }
}