/*
Author:			Yash Jain
Company:		Metacube
Description:	This class is used for scheduling mails for date holds which are going to expire

History
<Date>           <Authors Name>    <Brief Description of Change>
06/21    		Yash Jain        		sending mails for date holds which are going to expire
*/

global class SBP_PlantEventsScheduledIndividualEmail Implements Schedulable
{
    
    global void execute(SchedulableContext sc)
    {
        sendmail();
    }
    
                    /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method sends the mails to individuals or owners of events about the list of holds which are going to expire
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       sending of mails about date holds which are going to expire

***************************************************************************************************************/
    
    public static void sendmail()
    {
        List<Plant_Event__c> pegoingToExpireList = [Select id,Scheduled_Date__c,ownerId,Time_Slot__c,owner.Name,owner.Email from Plant_Event__c where Scheduled_Date__c >= : System.Today().addDays(49) AND Scheduled_Date__c <= : System.Today().addDays(53) AND Case__c ='' AND Time_of_day__c != 'ALL' AND Brand__c = 'Makers Mark' order by Scheduled_Date__c];
        
        Map<id,List<Plant_Event__c>> peMap = new    Map<id,List<Plant_Event__c>>();
        for(Plant_Event__c et : pegoingToExpireList){
            if (peMap.containsKey(et.ownerId)){
                peMap.get(et.ownerId).add(et);
            }
            else
            {
                List<Plant_Event__c> pp = new List<Plant_Event__c>();
                pp.add(et);
                peMap.put(et.ownerId,pp);                
            }
        }
        
        for (Id owId : peMap.keySet()){
            List<Plant_event__c> ls= peMap.get(owId);
            String bo = '';            
            for(Plant_event__C p : ls)
            {
                bo +=p.Scheduled_Date__c + '->' + p.Time_Slot__c + '<br/>';
            }            
            String dateHoldRecipient = ls[0].owner.Name;
            String emailBody = 'Dear '+ dateHoldRecipient +',<br/><br/>';
            emailBody += 'The following date holds you’ve placed for in-person MMPS selections in Loretto will expire this week:  <br/><br/>';
            emailBody += bo + '<br/><br/>';
            emailBody += 'All holds are cancelled 6 weeks before the held date, to ensure our accounts are able to take advantage of every opportunity we can offer to share the Maker’s Mark Private Select Experience. Your holds cannot be renewed or extended, so please book in your account’s visit before your hold expires. <br/><br/>';
            emailBody += 'Please reach out to single.barrels@beamsuntory.com with any questions or concerns. <br/><br/>';
            emailBody += 'Thank you,<br/>';
            emailBody += 'The MMPS Team ';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Weekly Summary Of Plant Events that are going to expire');
            email.setHtmlBody(emailBody);
            email.setToAddresses(new String[] {ls[0].owner.Email});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        
    }
    
}