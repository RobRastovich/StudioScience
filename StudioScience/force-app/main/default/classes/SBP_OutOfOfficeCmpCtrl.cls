/*
Author:			Yash Jain
Company:		Metacube
Description:	This class is used for out of office functionality(sending mails to their Heritage managers) for diplomats

History
<Date>           <Authors Name>    <Brief Description of Change>
06/21    		Yash Jain        		functionality when diplomats are out of office
*/
public class SBP_OutOfOfficeCmpCtrl {
    
                        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method checks whether user is out of office or not
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       checking user status of his availability in office

***************************************************************************************************************/
    @AuraEnabled
    public static boolean fetchUserOutOfOfficeState(){
        User u = [Select id,IsOutOfOffice__c from User where id =: UserInfo.getUserId()];
        return u.IsOutOfOffice__c;
    }
    
                        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method triggers mail when user out of switch is on or off
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       used for triggering of mails

***************************************************************************************************************/
    @AuraEnabled
    public static void handleToggleChangeMethod(Boolean toggledValue){
        User u = [Select id,Name,IsOutOfOffice__c from User where id =: UserInfo.getUserId()];
        u.IsOutOfOffice__c = toggledValue;
        update u;
        String userId = UserInfo.getUserId();
        User heritageManager = (User)SBP_AccountApplicationCmpCtrl.getHeritageManager(userId);
        String userEmail = heritageManager.Email;
        String heritageManagerName = heritageManager.Name;
        if(toggledValue == true)
        {
            sendActivationEmail(userEmail,u.Name,heritageManagerName);
        }
        else if(toggledValue == false)
        {
            sendDeactivationEmail(userEmail,u.Name,heritageManagerName);
        }
    }
                        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method sends the mails when user out of switch is on
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       sending of mails when switch is on

***************************************************************************************************************/
    public static void sendActivationEmail(String userEmail ,String diplomatName ,String heritageManagerName)
    {
        String portal = fetchPortalLink();
        String subjectText = Label.Out_Of_Office_Subject;
        String emailBody = 'Hello '+ heritageManagerName +',<br/><br/>';
        emailBody += diplomatName + ' has marked themselves as being out of office in the Single Barrel portal. All of ' + diplomatName + '\'s open applications have been reassigned to you for review and approval. Please check the list of pending applications in the application view in the <a href = "' + portal + '" target = "_blank	"> Salesforce Portal </a><br/><br/>';
        emailBody += 'Additionally, you will need to review and approve any applications sent to ' + diplomatName + ' while they’re out of office.<br/><br/>';
        emailBody += 'Thank you,<br/>';
        emailBody += 'The MMPS Team';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] {userEmail};
        email.setSubject(subjectText);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
    }
                        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method sends the mails to when user out of switch is off
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       sending of mails when switch is off

***************************************************************************************************************/
    public static void sendDeactivationEmail(String userEmail ,String diplomatName ,String heritageManagerName)
    {
        String subjectText = Label.Back_In_Office_Subject;
        String emailBody = 'Hello '+ heritageManagerName +',<br/><br/>';
        emailBody += diplomatName + ' has marked themselves as back in office in the Single Barrel portal. ';
        emailBody += diplomatName + ' should now be reviewing and approving all of their applications. <br/><br/>';
        emailBody += 'Thank you,<br/>';
        emailBody += 'The MMPS Team';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] {userEmail};
        email.setSubject(subjectText);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
    }
                        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used to get community portal link
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       used to get portal link

***************************************************************************************************************/
    public static String fetchPortalLink()
    {
        String name = Label.Single_Barrel_Portal_Name;        
        Site site = [SELECT Id FROM Site WHERE Name = :name];
        SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :site.Id];
        return mySiteDetail.SecureURL;
    }
    
}