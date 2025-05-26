public class OC_JapanQueueAssignmentNotification {
    
    @InvocableMethod(label='Send Notification To Queue Members')
    public static void sendEmailToQueueMembers(List<InputVariable> param) {
        
        Case c = param.get(0).c;
        
        List<String> recipient = new List<String>();
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember 
                                          WHERE Group.DeveloperName = :CSConstants.ORDER_CLAIM_JAPAN_PUBLIC_GROUP];
        Set<Id> userId = new Set<Id>();
        For(GroupMember gm: groupMembers){
            userId.add(gm.UserOrGroupId);
        }
        List<User> users = [SELECT Id, email from user where ID IN :userId]; 
        for(User u: users){
            recipient.add(u.email);
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcnoreply@beamsuntory.com'];
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :CSConstants.OC_JAPAN_NOTIFICATION_TEMPLATE LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0  && users.size() > 0) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
            email.setTargetObjectId(users.get(0).Id);
            email.setTemplateId(template.Id);
            email.setWhatId(c.Id);
            email.setToAddresses(recipient);
            email.setSaveAsActivity(false);   
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {email};
                try {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                    } 
                    return;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }    
        }
        
    }
    
    public class InputVariable {
        @InvocableVariable(label='c')
        public Case c;
        
    }
    
}