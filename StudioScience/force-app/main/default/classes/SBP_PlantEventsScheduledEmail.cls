/*
Author:			Yash Jain
Company:		Metacube
Description:	This class is used for scheduling mails for already expired date holds

History
<Date>           <Authors Name>    <Brief Description of Change>
06/21    		Yash Jain        		sending mails for expired date holds
*/

global class SBP_PlantEventsScheduledEmail Implements Schedulable
{
    
    global void execute(SchedulableContext sc)
    {
        sendmail();
    }
    
                /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method sends the mails to all diplomats,HMs and plant team members about the list of expired date holds
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       sending of mails

***************************************************************************************************************/
    
    public static void sendmail()
    {
        List<String> emailList = new List<String>();
        String bo = '';
        List<Plant_Event__c> peExpiredList = [Select id,Scheduled_Date__c,Time_Slot__c from Plant_Event__c where Scheduled_Date__c >= : System.Today().addDays(41) AND Scheduled_Date__c <= : System.Today().addDays(48) AND Case__c ='' AND Time_of_day__c != 'ALL' AND Brand__c = 'Makers Mark' AND Type__c != 'Blackout' order by Scheduled_Date__c ];
        for(Plant_event__C p : peExpiredList)
        {
            bo +=p.Scheduled_Date__c + '->' + p.Time_Slot__c + '<br/>';
        }
        List<User> userList = [Select Id,Email from User where User_Type__c IN ('Diplomat','Heritage Manager','Plant Team Member')];
        for(User u : userList)
        {
            emailList.add(u.Email);
        }
        String emailBody = 'Good morning MMPS team,<br/><br/>';
        emailBody += 'The following dates are about to expire and will open up if not booked ASAP for MMPS selection trips. Please reach out to any of your accounts that might be interested in visiting on those dates and book trips as soon as possible, as these dates are 6 weeks out from next week. <br/><br/>';
        emailBody += 'Please note that any of your cancelled date holds cannot be reactivated! All holds are cancelled 6 weeks out to ensure our accounts are able to take advantage of every opportunity we can offer to share the Maker’s Mark Private Select Experience in Loretto.<br/><br/>';
        emailBody += bo + '<br/><br/>';
        emailBody += 'Please reach out to single.barrels@beamsuntory.com with any questions or concerns. <br/><br/>';
        emailBody += 'Thank you,<br/>';
        emailBody += 'The MMPS Team ';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Weekly Summary Of Plant Events That Are About To Expire');
        email.setHtmlBody(emailBody);
        email.setToAddresses(emailList);
        Messaging.SingleEmailMessage[] emails =   new List<Messaging.SingleEmailMessage> {email};
        Messaging.sendEmail(emails);
    }
    
}