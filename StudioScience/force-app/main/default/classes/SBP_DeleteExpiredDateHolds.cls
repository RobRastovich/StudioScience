/*
Author:			Yash Jain
Company:		Metacube
Description:	This class is used for deletion of expired date holds from calendar

History
<Date>           <Authors Name>    <Brief Description of Change>
25th June,2021    Yash Jain        deletion of expired date holds
*/

global class SBP_DeleteExpiredDateHolds Implements Schedulable
{
    
    global void execute(SchedulableContext sc)
    {
        removeDateHolds();
    }
    
            /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method deletes date holds when they are expired
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       Deletion of date holds

***************************************************************************************************************/
    //Changes for SAL-2334 start
    public static void removeDateHolds()
    {
        List<Plant_Event__c> peExpiredList = [Select id,Scheduled_Date__c,Time_Slot__c from Plant_Event__c where Scheduled_Date__c = : System.Today().addDays(41) AND Case__c ='' AND Brand__c = 'Makers Mark' AND Type__c != 'Blackout' order by Scheduled_Date__c ];
        if(peExpiredList.size() > 0)
            delete peExpiredList;
    }
    //End
}