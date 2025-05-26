/******************************************************************************
Apex Class Name  : PosBottleTextChange
Created Date     : 06/2023		Vikash Kumar		Metacube
Function         : This class is used to send email notification when El Tesoro Bottle Plate text updated.
***********************************************************************************/
public class PosBottleTextChange {
    @InvocableMethod(label='Send Text Change Notification')
    public static void bottleTextUpdateNotification(List<PosLabelTextParam> parameters) {
        for (PosLabelTextParam param : parameters) {
           sendEmail(param.oldText,param.newText,param.barrelId,param.labelType);
        }
    }
    
    public static void sendEmail(String oldText, String newText, Id barrelId, String labelType) {
    	String updateLineOld1 = ' ', updateLineOld2 =' ', updateLineOld3 =' ';
        String updateLineNew1= ' ', updateLineNew2= ' ', updateLineNew3= ' ';
        if(labelType == CSConstants.ET_BOTTLE_PLATE_LINE_1){
            updateLineOld1 = oldText;
            updateLineNew1 = newText;
        }else if(labelType == CSConstants.ET_BOTTLE_PLATE_LINE_2){
            updateLineOld2 = oldText;
            updateLineNew2 = newText;
        }else if(labelType == CSConstants.ET_BOTTLE_PLATE_LINE_3){
            updateLineOld3 = oldText;
            updateLineNew3 = newText;
        }
        List<String> bottleTextList = new List<String>();
        List<POS_Customization__c> posItems = [Select Id, Insert_Text__c, Type__c From POS_Customization__c Where Barrel__r.Id =:barrelId AND Type__c IN :CSConstants.TYPELIST];
        for(POS_Customization__c pI: posItems){
            if(pI.Type__c != labelType){
                bottleTextList.add(pI.Insert_Text__c);
            }
        }
        Integer currentIndex = 0;
        String unchangedLine =' ';
        for(String str: bottleTextList){
            if(currentIndex == bottleTextList.size()- 1){
                unchangedLine += str;
            }else{
                unchangedLine += str+'/';
            }
            currentIndex++;
        }
        POS_Customization__c pItem = [Select Id, Name, Barrel__r.Case__r.CaseNumber, State__c, Account_Name__c, LastModifiedBy.Name From POS_Customization__c Where Barrel__r.Id =:barrelId AND Type__c =:labelType];
       
        String emailBody = 'Hello,<br/><br/><br/>';
        emailBody += pItem.LastModifiedBy.Name +' has updated the label text on barrel ' +pItem.Barrel__r.Case__r.CaseNumber+ ' for '+pItem.Account_Name__c+ ' in '+pItem.State__c+'.<br/><br/>';
        emailBody += 'POS Customization Name: '+pItem.Name+'<br/><br/>';
        emailBody += 'Previous Text (Line 1): '+updateLineOld1+'<br/>';
		emailBody += 'New Text (Line 1): '+updateLineNew1+'<br/><br/>';
		emailBody += 'Previous Text (Line 2): '+updateLineOld2+'<br/>';
        emailBody += 'New Text (Line 2): '+updateLineNew2+'<br/><br/>';
		emailBody += 'Previous Text (Line 3): '+updateLineOld3+'<br/>';
		emailBody += 'New Text (Line 3): '+updateLineNew3+'<br/><br/>';
		emailBody += 'Unchanged Line: '+unchangedLine+'<br/><br/>';
		emailBody += 'Plant team – please ensure that the labels print with the new, corrected text. Please reach out to '+pItem.LastModifiedBy.Name+' with any questions or concerns.<br/><br/><br/>';
		emailBody += 'Thank You,<br/>';
		emailBody += 'The Single Barrel Team';
        List<String> recipient = new List<String>();
        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember 
                                          WHERE Group.DeveloperName = :CSConstants.EL_TESORO_BOTTLE_TEXT_UPDATE_GROUP];
        Set<Id> userId = new Set<Id>();
        For(GroupMember gm: groupMembers){
            userId.add(gm.UserOrGroupId);
        }
        List<User> users = [SELECT Id, email from user where ID IN :userId]; 
        for(User u: users){
            recipient.add(u.email);
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'single.barrels@beamsuntory.com'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        email.setSubject('El Tesoro Bottle Text Updated');
        email.setHtmlBody(emailBody);
        email.setToAddresses(recipient);
        Messaging.SingleEmailMessage[] emails =   new List<Messaging.SingleEmailMessage> {email};
        Messaging.sendEmail(emails);
    }
    public class PosLabelTextParam {
        @InvocableVariable(label='Old Text')
        public String oldText;
        
        @InvocableVariable(label='Updated Text')
        public String newText;
        
		@InvocableVariable(label='BarrelId')
        public Id barrelId;
		
		@InvocableVariable(label='Type')
        public String labelType;        
       
    }
    
}