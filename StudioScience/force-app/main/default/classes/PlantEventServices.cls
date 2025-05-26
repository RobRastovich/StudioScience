public class PlantEventServices {
    
    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:	Once the trip is equal to today a time based workflow will update this record to reflect that 
    the trip is occuring today, and then update any cases related to this event which will trigger
    a milestone on the case record
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018     	Craig Austgen       Initial Creation
    ***************************************************************************************************************/
    
    public static void updateRelatedCaseWhenTripIsToday(List<Plant_Event__c> events, Map<Id, Plant_Event__c> oldMap) {
        Set<Id> eventIds = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        
        for (Plant_Event__c event : events) {
            Plant_Event__c oldEvent = oldMap.get(event.Id);
            if (!oldEvent.isTripToday__c && event.isTripToday__c && event.Scheduled_Date__c == Date.today()) {
                eventIds.add(event.Id);
            }
        }
        
        for (Case c : [select id, isTripToday__c from Case where Plant_Event__c IN :eventIds]) {
            c.isTripToday__c = true;
            caseMap.put(c.Id, c);
        }
        
        if (!caseMap.isEmpty()) {
            //RecursionHandler.isNotRecursive = false;
            caseServices.isRecursiveCall = true;
            update caseMap.values();
        }
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	It is used to restrict duplicate entry of bookings by Plant Team Member from console before any update
    
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    07,2021    			Yash Jain      restricting duplicate entry of plant events
    **************************************************************************************************************/
    public static void restrictDuplicateEntryOfBookingsForUpdate(List<Plant_Event__c> newEventList, Map<Id, Plant_Event__c> oldMap) 
    {
        String errorMessage = System.Label.SBP_ScheduledDateErrorMessage;
		List<Date> scheduledDateList = new List<Date>();
		List<String> timeSlotList = new List<String>();
        Map<Id, boolean> scheduleDateChangeByIdMap = new Map<Id, boolean>();
        			
        for(Plant_Event__c newPlantEvent : newEventList)
        {
            scheduledDateList.add(newPlantEvent.Scheduled_Date__c);
            timeSlotList.add(newPlantEvent.Time_Slot__c);
            Boolean isScheduleDateChanged = (newPlantEvent.Scheduled_Date__c != oldMap.get(newPlantEvent.Id).Scheduled_Date__c 
            || (newPlantEvent.Scheduled_Date__c == oldMap.get(newPlantEvent.Id).Scheduled_Date__c 
                && newPlantEvent.Time_Slot__c != oldMap.get(newPlantEvent.Id).Time_Slot__c));
            scheduleDateChangeByIdMap.put(newPlantEvent.Id, isScheduleDateChanged);
        }
                    
        List<Plant_Event__c> bookedEvents = [Select id,Scheduled_Date__c, Time_Slot__c
                                                from Plant_Event__c 
                                                where Scheduled_Date__c IN : scheduledDateList 
                                                AND Time_Slot__c IN: timeSlotList
                                                AND Brand__c = :SBP_Constants.BRAND_MAKERS_MARK
                                                AND Case__c != null];
        
        set<String> bookedDateAndSlotSet = new set<String>();
        for(Plant_Event__c event : bookedEvents) {
            bookedDateAndSlotSet.add(event.Scheduled_Date__c +'-'+ event.Time_Slot__c);
        }
        
        for(Plant_Event__c planEvent : newEventList)
        {
            String timeSlotKey = planEvent.Scheduled_Date__c +'-'+ planEvent.Time_Slot__c;
            if(scheduleDateChangeByIdMap.get(planEvent.Id) 
                && bookedDateAndSlotSet.contains(timeSlotKey) 
                && planEvent.Brand__c == SBP_Constants.BRAND_MAKERS_MARK)
            {
                planEvent.Scheduled_Date__c.addError(errorMessage);
            } 
        }  
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	It is used to delete date holds on calendar when Plant Team Member makes any booking on that particular date from console after update
    
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    07,2021    			Yash Jain      deleting date holds
    **************************************************************************************************************/    
    public static void deleteDateHoldsForPlantTeamForUpdate(List<Plant_Event__c> newEventList, Map<Id, Plant_Event__c> oldMap) 
    {
        List<Date> scheduledDateList = new List<Date>();
        List<String> timeSlotList = new List<String>();
        Map<Id, boolean> scheduleDateChangeByIdMap = new Map<Id, boolean>();
        			
        for(Plant_Event__c newPlantEvent : newEventList)
        {
                
            scheduledDateList.add(newPlantEvent.Scheduled_Date__c);
            timeSlotList.add(newPlantEvent.Time_Slot__c);
            Boolean isScheduleDateChanged = (newPlantEvent.Scheduled_Date__c != oldMap.get(newPlantEvent.Id).Scheduled_Date__c 
                                                || (newPlantEvent.Scheduled_Date__c == oldMap.get(newPlantEvent.Id).Scheduled_Date__c 
                                                    && newPlantEvent.Time_Slot__c != oldMap.get(newPlantEvent.Id).Time_Slot__c));
            scheduleDateChangeByIdMap.put(newPlantEvent.Id, isScheduleDateChanged);
        }
        Set<Date> scheduledDateSet = new Set<Date>();
        scheduledDateSet.addAll(scheduledDateList);
        Set<String> timeSlotSet = new Set<String>();
        timeSlotSet.addAll(timeSlotList);
        
        List<Plant_Event__c> dateHoldEvents = [Select id, Scheduled_Date__c, Time_Slot__c
                                                from Plant_Event__c 
                                                where Scheduled_Date__c IN : scheduledDateSet 
                                                AND Time_Slot__c IN: timeSlotSet
                                                AND Brand__c = :SBP_Constants.BRAND_MAKERS_MARK
                                                AND Case__c = null];
        
        Map<String, Plant_Event__c> holdDateAndSlotMap = new Map<String, Plant_Event__c>();
        for(Plant_Event__c event : dateHoldEvents) {
            holdDateAndSlotMap.put(event.Scheduled_Date__c +'-'+ event.Time_Slot__c, event);
        }
        
        List<Plant_Event__c> deletePlantEventList = new List<Plant_Event__c>();
        for(Plant_Event__c planEvent : newEventList)
        {
            String timeSlotKey = planEvent.Scheduled_Date__c +'-'+ planEvent.Time_Slot__c;
            if(scheduleDateChangeByIdMap.get(planEvent.Id) 
                && holdDateAndSlotMap.containsKey(timeSlotKey) 
                && planEvent.Brand__c == SBP_Constants.BRAND_MAKERS_MARK)
            {
                deletePlantEventList.add(holdDateAndSlotMap.get(timeSlotKey));
            } 
        }
        if(!deletePlantEventList.isEmpty()) {
            delete(deletePlantEventList);
        }
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	It is used to restrict duplicate entry of bookings by Plant Team Member from console before any insert
    
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    07,2021    			Yash Jain      restricting duplicate entry of plant events
    **************************************************************************************************************/
    public static void restrictDuplicateEntryOfBookingsForInsert(List<Plant_Event__c> newEvents) 
    {
        String errorMessageBookingExist = System.Label.SBP_ScheduledDateErrorMessage;
        String errorMessageDateHoldExist = System.Label.SBP_DateHoldExistErrorMessage;
        List<Date> scheduledDateList = new List<Date>();
		List<String> timeSlotList = new List<String>();

        //User currentUser = [Select id, User_Type__c from User where id =: UserInfo.getUserId() limit 1];
        //if(currentUser != null && currentUser.User_Type__c == SBP_Constants.USER_TYPE_PLANT_TEAM_MEMBER)
        			
        for(Plant_Event__c newPlantEvent : newEvents)
        {
            scheduledDateList.add(newPlantEvent.Scheduled_Date__c);
            timeSlotList.add(newPlantEvent.Time_Slot__c);
        }
                    
        List<Plant_Event__c> bookedEvents = [Select id, Scheduled_Date__c, Time_Slot__c, Case__c
                                                from Plant_Event__c 
                                                where Scheduled_Date__c IN : scheduledDateList 
                                                AND Time_Slot__c IN: timeSlotList
                                                AND Brand__c = :SBP_Constants.BRAND_MAKERS_MARK
                                                ]; //AND Case__c != null
        
        Map<String, Plant_Event__c> bookedDateAndSlotMap = new Map<String, Plant_Event__c>();
        for(Plant_Event__c event : bookedEvents) {
            bookedDateAndSlotMap.put(event.Scheduled_Date__c +'-'+ event.Time_Slot__c, event);
        }
        
        for(Plant_Event__c planEvent : newEvents)
        {
            String timeSlotKey = planEvent.Scheduled_Date__c +'-'+ planEvent.Time_Slot__c;
            if(bookedDateAndSlotMap.containsKey(timeSlotKey) 
                && planEvent.Brand__c == SBP_Constants.BRAND_MAKERS_MARK)
            {
                Plant_Event__c existingEvent = bookedDateAndSlotMap.get(timeSlotKey);
                if(existingEvent.Case__c != null) {
                    planEvent.Scheduled_Date__c.addError(errorMessageBookingExist);
                } else if(planEvent.Case__c == null) {
                    planEvent.Scheduled_Date__c.addError(errorMessageDateHoldExist);
                }
            } 
        }  
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	It is used to delete date holds on calendar when Plant Team Member makes any booking on that particular date from console after insert
    
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    07,2021    			Yash Jain      deleting date holds
    **************************************************************************************************************/    
    public static void deleteDateHoldsForPlantTeamForInsert(List<Plant_Event__c> newEventList) 
    {
        List<Date> scheduledDateList = new List<Date>();
        List<String> timeSlotList = new List<String>();
        List<Id> idList = new List<Id>();
        Map<Id, boolean> scheduleDateChangeByIdMap = new Map<Id, boolean>();
        			
        for(Plant_Event__c newPlantEvent : newEventList)
        {
            scheduledDateList.add(newPlantEvent.Scheduled_Date__c);
            timeSlotList.add(newPlantEvent.Time_Slot__c);
            idList.add(newPlantEvent.id);
        }
        
        Set<Date> scheduledDateSet = new Set<Date>();
        scheduledDateSet.addAll(scheduledDateList);
        Set<String> timeSlotSet = new Set<String>();
        timeSlotSet.addAll(timeSlotList);
        Set<Id> idSet = new Set<Id>();
        idSet.addAll(idList);            
        
        List<Plant_Event__c> dateHoldEvents = [Select id,Scheduled_Date__c, Time_Slot__c
                                                from Plant_Event__c 
                                                where Scheduled_Date__c IN : scheduledDateSet 
                                                AND Time_Slot__c IN: timeSlotSet
                                                AND id NOT IN: idSet
                                                AND Brand__c = :SBP_Constants.BRAND_MAKERS_MARK
                                                AND Case__c = null];
        
        Map<String, Plant_Event__c> holdDateAndSlotMap = new Map<String, Plant_Event__c>();
        for(Plant_Event__c event : dateHoldEvents) {
            holdDateAndSlotMap.put(event.Scheduled_Date__c +'-'+ event.Time_Slot__c, event);
        }
        List<Plant_Event__c> deletePlantEventList = new List<Plant_Event__c>();
        for(Plant_Event__c planEvent : newEventList)
        {
            String timeSlotKey = planEvent.Scheduled_Date__c +'-'+ planEvent.Time_Slot__c;
            if(holdDateAndSlotMap.containsKey(timeSlotKey) 
                && planEvent.Brand__c == SBP_Constants.BRAND_MAKERS_MARK)
            {
                deletePlantEventList.add(holdDateAndSlotMap.get(timeSlotKey));
            } 
        }
        if(!deletePlantEventList.isEmpty()) {
            delete deletePlantEventList;
        } 
    }
    /**************************************************************************************************************
    Author:			Nishant Khandal
    Company:		Metacube
    Description:	It is used to update Trip booked of Time interval when Plant Event got delete.
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    **************************************************************************************************************/ 
    public static void updateTrippedBookedWhenPlantEventDelete(List<Plant_Event__c> oldPlantEvent){
        Map<ID, List<Plant_Event__c>> mapTimeIntervalIdWithPlantEvents = new Map<ID, List<Plant_Event__c>>();
        for(Plant_Event__c recordPlantEvent : oldPlantEvent){
            if(!mapTimeIntervalIdWithPlantEvents.containsKey(recordPlantEvent.Time_Interval__c)){
                mapTimeIntervalIdWithPlantEvents.put(recordPlantEvent.Time_Interval__c, new List<Plant_Event__c>());
            }
            mapTimeIntervalIdWithPlantEvents.get(recordPlantEvent.Time_Interval__c).add(recordPlantEvent);
        }
        if(!mapTimeIntervalIdWithPlantEvents.isEmpty()){
            List<Time_Interval__c> timeIntervals = SLT_Time_Interval.getTimeIntervalByGivenID(mapTimeIntervalIdWithPlantEvents.Keyset());
            for(Time_Interval__c timeInterval : timeIntervals){
                timeInterval.Trips_Booked__c = timeInterval.Trips_Booked__c - mapTimeIntervalIdWithPlantEvents.get(timeInterval.Id).Size();
            }
            if(!timeIntervals.isEmpty() && timeIntervals.size() > 0){
                update timeIntervals;
            }
        }
    }
}