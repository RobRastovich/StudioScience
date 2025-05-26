/***********************************************************************************************************************************
Apex Class Name : SBP_PlantEventsScheduledEmailToUser
Description     : This method sends the emails to particular user or owners of events about the list of holds which are going to expire
<Date>   <Authors Name>     <Company>     <Brief Description of Change>
5/2023     Sahana S S    	 Metacube   sending of emails about date holds which are going to expire
*************************************************************************************************************************************/
global class SBP_PlantEventsScheduledEmailToUser Implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        sendmail();
    }
    
    public static void sendmail()
    {
        List<Plant_Event__c> planteventList = [Select id,Scheduled_Date__c,ownerId,Time_Slot__c,owner.Name,owner.Email from Plant_Event__c where Scheduled_Date__c >= : System.Today().addDays(42) AND Scheduled_Date__c <= : System.Today().addDays(48) AND Case__c ='' AND Time_of_day__c != 'ALL' AND Brand__c = 'Makers Mark' AND Type__c != 'Blackout' order by Scheduled_Date__c];
        
        Map<id,List<Plant_Event__c>> planteventMap = new Map<id,List<Plant_Event__c>>();
        for(Plant_Event__c plantevt : planteventList){
            if (planteventMap.containsKey(plantevt.ownerId)){
                planteventMap.get(plantevt.ownerId).add(plantevt);
            }
            else
            {
                List<Plant_Event__c> plants = new List<Plant_Event__c>();
                plants.add(plantevt);
                planteventMap.put(plantevt.ownerId,plants);                
            }
        }
        
        for (Id owId : planteventMap.keySet()){
            List<Plant_event__c> ls = planteventMap.get(owId);
            String bo = '';            
            for(Plant_event__C p : ls)
            {
                Integer numOfDays = System.Today().addDays(41).daysBetween(p.Scheduled_Date__c);              
                bo +=p.Scheduled_Date__c + '->' + p.Time_Slot__c + '-' + ' will expire and be deleted in ' + numOfDays + ' days' + '<br/>';
            }
            String dateHoldRecipient = ls[0].owner.Name;
            String emailBody = 'Good morning '+ dateHoldRecipient +',<br/><br/>';
            emailBody += 'You have a MMPS distillery hold that needs to be booked immediately or it will expire-  <br/><br/>';
            emailBody += bo + '<br/><br/>';
            emailBody += 'Please note that any of your cancelled date holds cannot be reactivated! All holds are automatically cancelled 6 weeks out to ensure our accounts are able to take advantage of every opportunity we can offer to share the Maker’s Mark Private Select Experience in Loretto. <br/><br/>';
            emailBody += 'Thanks.<br/>';
            emailBody += 'The MMPS Team ';	
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Your Distillery Hold is Expiring');
            email.setHtmlBody(emailBody);
            email.setToAddresses(new String[] {ls[0].owner.Email});                   
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});	
        }
    }
}