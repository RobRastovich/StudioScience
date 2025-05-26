/*
Author:			Craig Austgen
Company:		Slalom, LLC
Description:	For the Single Barrel Program there is a custom calendar inside of the the Customer Community
The methods in this class provide data to the calendar and perform dml operations

History
<Date>      <Authors Name>     <Brief Description of Change>
7/8/2018    Craig Austgen        Initial Creation
*/
public without sharing class SBP_CalendarCmpCtrl {
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	For the Single Barrel Program there is a custom calendar housed in the Customer Community,
Users will have the option to schedule an event by using the calendar.  This method creates that
event in Salesforce under a custom event object Plant Event
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus upsertEvents(String sEventObj, String plant, String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean existingEvent = false;
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        Plant_Event__c newRecord = new Plant_Event__c();
        if (upsertingEvent.Id != null) {
            newRecord.put('Id', upsertingEvent.Id);
        }
        
        newRecord.Description__c = upsertingEvent.description;
        newRecord.Plant__c = SBP_Constants.brandToPlant.get(brand);
        newRecord.Brand__c = brand;
        newRecord.RecordTypeId = SBP_Constants.plantEventRtIdMap.get(brand);
        newRecord.Time_of_Day__c = upsertingEvent.timeOfDay;
        newRecord.Time_Slot__c = upsertingEvent.timeSlot;
        newRecord.Scheduled_Date__c = upsertingEvent.scheduledDate;
        newRecord.Initiator__c = Id.valueOf(upsertingEvent.initiatorId);
        newRecord.Include_Boxed_Lunches__c = Boolean.valueOf(upsertingEvent.boxedLunches);
        newRecord.Tour__c = Boolean.valueOf(upsertingEvent.isTour);
        newRecord.isBottling__c = Boolean.valueOf(upsertingEvent.isBottling);
        newRecord.Waiting_Options__c = upsertingEvent.waitingOptionsVal;
        newRecord.Case__c = String.isBlank(upsertingEvent.caseId)? null :upsertingEvent.caseId ;
		newRecord.Participants_Info__c = (brand == SBP_Constants.BRAND_MAKERS_MARK) ? upsertingEvent.participantsInfo : '';
        List<Plant_Event__c> exisitingEvents;
        if(newRecord.Brand__c == SBP_Constants.BRAND_MAKERS_MARK && newRecord.Scheduled_Date__c.year() > 2019 && String.isNotBlank(newRecord.Case__c)){
            exisitingEvents = [select Id, Time_of_Day__c, Time_Slot__c, Scheduled_Date__c from Plant_Event__c where Brand__c = :newRecord.Brand__c
                               AND Scheduled_Date__c = :newRecord.Scheduled_Date__c
                               AND Time_Slot__c = :newRecord.Time_Slot__c AND Case__c != null];
        }
        else if(newRecord.Brand__c == SBP_Constants.BRAND_MAKERS_MARK && newRecord.Scheduled_Date__c.year() > 2019){
            exisitingEvents = [select Id, Time_of_Day__c, Time_Slot__c, Scheduled_Date__c from Plant_Event__c where Brand__c = :newRecord.Brand__c
                               AND Scheduled_Date__c = :newRecord.Scheduled_Date__c
                               AND Time_Slot__c = :newRecord.Time_Slot__c];
        }
        else{
            exisitingEvents = [select Id, Time_of_Day__c, Time_Slot__c, Scheduled_Date__c from Plant_Event__c where Brand__c = :newRecord.Brand__c
                               AND Scheduled_Date__c = :newRecord.Scheduled_Date__c
                               AND Time_of_Day__c = :newRecord.Time_of_Day__c];
        }
        List<Plant_Event__c> plantListTotal = [Select Id,OwnerId from Plant_Event__c where OwnerId =: UserInfo.getUserId() AND Scheduled_Date__c >= : System.Today() AND Case__c = null];
        Integer listLength = plantListTotal.size();
        //AggregateResult ar =  [Select COUNT(Id)totalcount from Plant_Event__c where OwnerId =: UserInfo.getUserId() AND Scheduled_Date__c >= : System.Today() AND Case__c = null];
        //Integer listLength = (Integer)ar.get('totalcount');
        
        String dateHoldLimitForDiplomatHM = System.Label.DateHoldLimitForDiplomatHM;
        String  dateHoldLimitForPlantTeam= System.Label.DateHoldLimitForPlantTeam;
        String scheduledPeriodFromToday = System.Label.ScheduledPeriodFromToday;
        Integer dateHoldLimitForDiplomatHMInt = integer.valueof(dateHoldLimitForDiplomatHM);
        Integer dateHoldLimitForPlantTeamInt = integer.valueof(dateHoldLimitForPlantTeam);
        Integer scheduledPeriodFromTodayInt = integer.valueof(scheduledPeriodFromToday);
        try {
            boolean invalidConsecutiveDaysLimit = isConsecutiveEventLimitReached(String.valueOf(upsertingEvent.scheduledDate));
            boolean isSchDateWithin6Weeks = ((System.Today()).daysBetween(Date.valueOf(upsertingEvent.scheduledDate)) < scheduledPeriodFromTodayInt) ? true : false ;
            boolean maxLimit = (((getUserType() == SBP_Constants.USER_TYPE_DIPLOMAT || getUserType() == SBP_Constants.USER_TYPE_HERITAGE_MANAGER || getUserType() == SBP_Constants.USER_TYPE_SUPER_HERITAGE_MANAGER) && listLength >= dateHoldLimitForDiplomatHMInt) || ((getUserType() == SBP_Constants.USER_TYPE_PLANT_TEAM_MEMBER) && listLength >= dateHoldLimitForPlantTeamInt)) ? true : false ;
            responseMap.put('consecutiveEventLimitReached', false);
            responseMap.put('isSchDateWithin6Weeks', false);
            responseMap.put('maxLimit', false);
            
            List<Plant_Event__c> pe = [Select Id, Participants_info__c from Plant_Event__c where Id = :newRecord.Id];
                
            if (!exisitingEvents.isEmpty() && !pe.isEmpty() && pe[0].Participants_info__c == newRecord.Participants_Info__c) {
                existingEvent = true;
            }else if (String.isBlank(newRecord.Id) && String.isBlank(newRecord.Case__c) && newRecord.Brand__c == SBP_Constants.BRAND_MAKERS_MARK && invalidConsecutiveDaysLimit && getUserType() == SBP_Constants.USER_TYPE_DIPLOMAT) {
                responseMap.put('consecutiveEventLimitReached', true);
            }else if(String.isBlank(newRecord.Id) && String.isBlank(newRecord.Case__c) && newRecord.Brand__c == SBP_Constants.BRAND_MAKERS_MARK && isSchDateWithin6Weeks && (getUserType() == SBP_Constants.USER_TYPE_DIPLOMAT || getUserType() == SBP_Constants.USER_TYPE_HERITAGE_MANAGER || getUserType() == SBP_Constants.USER_TYPE_PLANT_TEAM_MEMBER || getUserType() == SBP_Constants.USER_TYPE_SUPER_HERITAGE_MANAGER )){
                responseMap.put('isSchDateWithin6Weeks', true);
            }
            else if(String.isBlank(newRecord.Id) && String.isBlank(newRecord.Case__c) && newRecord.Brand__c == SBP_Constants.BRAND_MAKERS_MARK && maxLimit && (getUserType() == SBP_Constants.USER_TYPE_DIPLOMAT || getUserType() == SBP_Constants.USER_TYPE_HERITAGE_MANAGER || getUserType() == SBP_Constants.USER_TYPE_PLANT_TEAM_MEMBER )){
                responseMap.put('maxLimit', true);
            }
            else {
                System.debug('newRecord-->'+newRecord);
                upsert newRecord;
                EventObj newEv = new EventObj(newRecord.Id,
                                              String.valueOf(newRecord.Description__c),
                                              String.valueOf(newRecord.Plant__c),
                                              String.valueOf(newRecord.Brand__c),
                                              String.valueOf(newRecord.Time_of_Day__c),
                                              String.valueOf(newRecord.Time_Slot__c),
                                              Date.valueOf(newRecord.Scheduled_Date__c),
                                              String.valueOf(newRecord.Initiator__c).substring(0, String.valueOf(newRecord.Initiator__c).length() - 3)
                                             );
                
                responseMap.put('newEvent', newEv);
            }
            
            responseMap.put('eventAlreadyExists', existingEvent);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getStackTraceString());
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	Pulls in Custom metadata for the custom calendar for the Single Barrel Program
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getSingleBarrelCalendarCustomMetadata() {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Single_Barrel_Calendar_Setting__mdt> brandInfoMap = new Map<String, Single_Barrel_Calendar_Setting__mdt>();
        
        for (Single_Barrel_Calendar_Setting__mdt cm : [select MasterLabel, Event_Color__c, Plant__c, Event_Text_Color__c, Time_Zone__c from Single_Barrel_Calendar_Setting__mdt]) {
            brandInfoMap.put(cm.MasterLabel, cm);
        }
        
        try {
            responseMap.put('brandInfoMap', brandInfoMap);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);      
        return requestStatus;
    }
    
    
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	Pulls in all events in Salesforce to populate the custom calendar for the Single Barrel Program
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getEvents(List<String> brands) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        
        List<EventObj> eventRecords = new List<EventObj>();
        String query = 'SELECT ';
        String objectName = 'Plant_Event__c';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        query += String.join(new List<String>(objectFields.keySet()), ',' );
        query += ' ,Owner.Name ';
        query += ' FROM ' + objectName;
        
        List<Plant_Event__c> events = new List<Plant_Event__c>();
        
        if (!brands.isEmpty()) {
            query += ' WHERE Brand__c IN :brands';
            events = Database.query(query);
        }
        
        for (Plant_Event__c event : events) {
            String initiatorId;
            if (event.Initiator__c != null) {
                initiatorId = String.valueOf(event.Initiator__c).substring(0, String.valueOf(event.Initiator__c).length() - 3);
            }
            
            EventObj newEv = new EventObj(event.Id,
                                          String.valueOf(event.Description__c),
                                          String.valueOf(event.Plant__c),
                                          String.valueOf(event.Brand__c),
                                          String.valueOf(event.Time_of_Day__c),
                                          String.valueOf(event.Time_Slot__c),
                                          Date.valueOf(event.Scheduled_Date__c),
                                          initiatorId,
                                          String.valueOf(event.OwnerId),
                                          String.valueOf(event.Case__c),
                                          String.valueOf(event.Owner.Name),
                                          event.Participants_Info__c
                                         );
            eventRecords.add(newEv);
        }
        
        responseMap.put('eventsMap', eventRecords);
        responseMap.put('numberOfEvents', eventRecords.size());
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    public class EventObj {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String plant {get; set;}
        @AuraEnabled public String brand {get; set;}
        @AuraEnabled public String timeOfDay {get; set;}
        @AuraEnabled public String timeSlot {get; set;}
        @AuraEnabled public Date scheduledDate {get; set;}
        @AuraEnabled public String initiatorId {get; set;}
        @AuraEnabled public String boxedLunches {get; set;}
        @AuraEnabled public String isTour {get; set;}
        @AuraEnabled public String isBottling {get; set;}
        @AuraEnabled public String waitingOptionsVal {get; set;}
        @AuraEnabled public String ownerId {get; set;}
        @AuraEnabled public String caseId {get; set;}
        @AuraEnabled public String ownerName {get;set;}
        @AuraEnabled public String participantsInfo {get;set;}       
        
        
        public EventObj(String i, String d, String p, String b, String td, String ts, Date sd, String cb) {
            this.Id = i;
            this.description = d;
            this.plant = p;
            this.brand = b;
            this.timeOfDay = td;
            this.timeSlot = ts;
            this.scheduledDate = sd;
            this.initiatorId = cb;
        }

        public EventObj(String i, String d, String p, String b, String td, String ts, Date sd, String cb, String oId,String cId,String oName,String pi){
            this.Id = i;
            this.description = d;
            this.plant = p;
            this.brand = b;
            this.timeOfDay = td;
            this.timeSlot = ts;
            this.scheduledDate = sd;
            this.initiatorId = cb;
            this.ownerId = oId;
            this.caseId = cId;
        	this.ownerName = oName;
            this.participantsInfo = pi;
        }
        
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	Sorts the time period based on the day
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static Map<String, Map<String, Integer>> sortTimePeriodsBasedOnDay() {
        Map<String, Map<String, Integer>> dateToTimePeriod = new Map<String, Map<String, Integer>>();
        
        for (Plant_Event__c event : [select id, Scheduled_Date__c, Time_of_Day__c, Plant__c from Plant_Event__c]) {
            if (dateToTimePeriod.containsKey(String.valueOf(event.Scheduled_Date__c))) {
                Map<String, Integer> schedDateMap = dateToTimePeriod.get(String.valueOf(event.Scheduled_Date__c));
                
                if (schedDateMap.containsKey(event.Time_of_Day__c)) {
                    Integer numOfTimePeriod = schedDateMap.get(event.Time_of_Day__c);
                    schedDateMap.put(event.Time_of_Day__c, numOfTimePeriod++);
                } else {
                    schedDateMap.put(event.Time_of_Day__c, 1);
                }
            } else {
                dateToTimePeriod.put(String.valueOf(event.Scheduled_Date__c), new Map<String, Integer> {event.Time_of_Day__c => 1});
            }
        }
        
        return dateToTimePeriod;
    }
    
    
    public class PlantEventObj {
        @AuraEnabled
        public String plant {get; set;}
        @AuraEnabled
        public Integer totalEvents {get; set;}
        @AuraEnabled
        public String scheduledDate {get; set;}
        @AuraEnabled
        public String blackoutType {get; set;}
        @AuraEnabled
        public Integer AM;
        @AuraEnabled
        public Integer PM;
        @AuraEnabled
        public List<Id> plantEventIds;
        
        public PlantEventObj(String p, Integer n, String sd, String b, Integer am, Integer pm, List<Id> pi) {
            this.plant = p;
            this.totalEvents = n;
            this.scheduledDate = sd;
            this.blackoutType = b;
            this.AM = am;
            this.PM = pm;
            this.plantEventIds = pi;
        }
    }
    
    public class DayDetail {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer AM;
        @AuraEnabled
        public Integer PM;
    }
    
    /*
"El Tesoro": {
"2018-05-01": {
AM: 1,
PM: 0,
blackoutType: "NONE",
plant: "El Tesoro",
plantEventIds: ["a4Am000000010wTEAQ"],
scheduledDate: "2018-05-01",
totalEvents: 1
}
}
*/
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	Create an object for each day with specfic information about that day to pass into the lightning component
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static Map<String, Map<String, PlantEventObj>> getEventDataByDay() {
        Map<String, Map<String, List<Plant_Event__c>>> brandToDayToEventsMap = new Map<String, Map<String, List<Plant_Event__c>>>();
        Map<String, Map<String, PlantEventObj>> brandToEventObject = new Map<String, Map<String, PlantEventObj>> ();
        
        Map<String, Map<String, Integer>> tripPerDayMap = buildBrandLimitMap();
        
        // group all events by plant
        for (Plant_Event__c event : [select id, Scheduled_Date__c, Time_of_Day__c, Plant__c, Type__c, Brand__c from Plant_Event__c]) {
            // plant already exists in map
            if (brandToDayToEventsMap.containsKey(event.Brand__c)) {
                Map<String, List<Plant_Event__c>> dayToEvents = brandToDayToEventsMap.get(event.Brand__c);
                // check if day already exsists in map
                if (dayToEvents.containsKey(String.valueOf(event.Scheduled_Date__c))) {
                    // add event to day
                    dayToEvents.get(String.valueOf(event.Scheduled_Date__c)).add(event);
                } else {
                    // add day to plant map
                    // also add event to day
                    dayToEvents.put(String.valueOf(event.Scheduled_Date__c), new List<Plant_Event__c> {event});
                }
            } else {
                Map<String, List<Plant_Event__c>> dayToPlantsMap = new Map<String, List<Plant_Event__c>>();
                dayToPlantsMap.put(String.valueOf(event.Scheduled_Date__c), new List<Plant_Event__c> {event});
                brandToDayToEventsMap.put(event.Brand__c, dayToPlantsMap);
            }
        }
        
        // sort through each brand's events
        for (String brand : brandToDayToEventsMap.keySet()) {
            
            Map<String, DayDetail> brandMap = new Map<String, DayDetail>();
            Map<String, List<Plant_Event__c>> pEventMap = brandToDayToEventsMap.get(brand);
            Map<String, Map<String, Integer>> eventDateToAmPmCountMap = new Map<String, Map<String, Integer>>();
            
            Integer numOfEventsPerDay = 0;
            
            // loop through each day
            for (String day : pEventMap.keySet()) {
                
                Map<Id, Id> plantEventIds = new Map<Id, Id>();
                String blackoutType = 'NONE';
                String plant;
                numOfEventsPerDay = pEventMap.get(day).size();
                Map<String, Integer> amPmCount = new Map<String, Integer>();
                
                // loop through each day's events
                for (Plant_Event__c event : pEventMap.get(day)) {
                    DayDetail bObj = new DayDetail();
                    plantEventIds.put(event.Id, event.Id);
                    plant = event.Plant__c;
                    
                    // if brand already exsits then add the time of day of the event
                    if (brandMap.containsKey(event.Brand__c)) {
                        bObj = brandMap.get(event.Brand__c);
                        if (event.Time_of_Day__c == 'AM') {
                            if (bObj.AM != null) {
                                Integer currentAMCount = bObj.AM;
                                bObj.AM = currentAMCount++;
                            } else {
                                bObj.AM = 1;
                            }
                        } else if (event.Time_of_Day__c == 'PM') {
                            if (bObj.PM != null) {
                                Integer currentPMCount = bObj.PM;
                                bObj.PM = currentPMCount++;
                            } else {
                                bObj.PM = 1;
                            }
                        }
                        brandMap.put(event.Brand__c, bObj);
                    } else {
                        
                        if (event.Time_of_Day__c == 'AM') {
                            bObj.AM = 1;
                        } else if (event.Time_of_Day__c == 'PM') {
                            bObj.PM = 1;
                        }
                        bObj.name = event.Brand__c;
                        brandMap.put(event.Brand__c, bObj);
                    }
                    
                    if (amPmCount.containsKey(event.Time_of_Day__c)) {
                        Integer currentCount = amPmCount.get(event.Time_of_Day__c);
                        currentCount++;
                        amPmCount.put(event.Time_of_Day__c, currentCount);
                    } else {
                        amPmCount.put(event.Time_of_Day__c, 1);
                    }
                    
                    if (event.Type__c == 'Blackout') {
                        if (event.Time_of_Day__c == 'AM') {
                            blackoutType = 'AM';
                        } else if (event.Time_of_Day__c == 'PM') {
                            blackoutType = 'PM';
                        } else if (event.Time_of_Day__c == 'ALL') {
                            blackoutType = 'ALL';
                        }
                    }
                } // end of events for a given day loop
                
                Integer amCount = amPmCount.get('AM') == null ? 0 : amPmCount.get('AM');
                Integer pmCount = amPmCount.get('PM') == null ? 0 : amPmCount.get('PM');
                
                PlantEventObj dayEObject = new PlantEventObj(plant, numOfEventsPerDay, day, blackoutType, amCount, pmCount, plantEventIds.values());
                
                if (brandToEventObject.containsKey(brand)) {
                    Map<String, PlantEventObj> existingMap = brandToEventObject.get(brand);
                    existingMap.put(day, dayEObject);
                    brandToEventObject.put(brand, existingMap);
                    
                } else {
                    brandToEventObject.put(brand, new Map <String, PlantEventObj> {day => dayEObject});
                }
                
            } // end of day for loop
        }
        return brandToEventObject;
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	For the Single Barrel Program there is a Calendar there is a limit per brand on how many
trips can be scheduled, this method pulls that limit from the custom metadata
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static Map<String, Map<String, Integer>> buildBrandLimitMap() {
        Map<String, Map<String, Integer>> tripLimitMap = new Map<String, Map<String, Integer>>();
        for (Single_Barrel_Trip_Limit_Setting__mdt cm : [select MasterLabel, Per_Day_Total__c, AM__c, PM__c from Single_Barrel_Trip_Limit_Setting__mdt]) {
            tripLimitMap.put(cm.MasterLabel, new Map<String , Integer> {'perDay' => 0});
            tripLimitMap.get(cm.MasterLabel).put('AM' , Integer.valueOf(cm.AM__c));
            tripLimitMap.get(cm.MasterLabel).put('PM', Integer.valueOf(cm.PM__c));
        }
        System.debug('tripLimitMap--->'+tripLimitMap);
        return tripLimitMap;
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	Creates objects per brand and per day on their availablity 
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static Map<String, Map<String, Map<String, Boolean>>> getCurrentLimitPerDay() {
        // day => (am/pm count = > integer)
        Map<String, Map<String, Integer>> dayEventCount;
        Map<String, Map<String, Boolean>> isTimeBooked;
        Map<String, Map<String, Integer>> tripPerDayMap = buildBrandLimitMap();
        System.debug('tripPerDayMap:::'+tripPerDayMap);
        Map<String, Map<String, PlantEventObj>> eventsByDay = getEventDataByDay();
        System.debug('eventsByDay:::'+eventsByDay); 
        Map<String, Map<String, Map<String, Boolean>>> brandTimeMap = new Map<String, Map<String, Map<String, Boolean>>>();
        Map<String, List<String>> plantToBrandsMap = new Map<String, List<String>> {
            'Clermont' => new List<String>{'Knob Creek'},
                'Loretto' => new List<String>{'Makers Mark'}
        };
            
            for (String plant : plantToBrandsMap.keySet()) {
                dayEventCount = new Map<String, Map<String, Integer>>();
                Map<String, PlantEventObj> dayToEventObj = new Map<String, PlantEventObj>();
                for (String brandWithSamePlant : plantToBrandsMap.get(plant)) {
                    if (eventsByDay.containsKey(brandWithSamePlant)) {
                        dayToEventObj = eventsByDay.get(brandWithSamePlant);
                    } else {
                        break;
                    }
                    
                    isTimeBooked = new Map<String, Map<String, Boolean>>();
                    
                    for (String day : dayToEventObj.keySet()) {
                        System.debug('day:::' + day);
                        if (!isTimeBooked.containsKey(day)) {
                            isTimeBooked.put(day, new Map<String, Boolean> {'AM' => false, 'PM' => false});
                        }
                        if (!dayEventCount.containsKey(day)) {
                            dayEventCount.put(day, new Map<String, Integer> {'AmCount' => dayToEventObj.get(day).AM, 'PmCount' => dayToEventObj.get(day).PM });
                        }
                        
                        if (dayEventCount.containsKey(day)) {
                            Integer futureAmCount = dayEventCount.get(day).get('AmCount') + dayToEventObj.get(day).AM;
                            Integer futurePmCount = dayEventCount.get(day).get('PmCount') + dayToEventObj.get(day).PM;
                            System.debug('dayEventCount ' + dayEventCount);
                            System.debug('tripPerDayMap ' + tripPerDayMap);
                            System.debug('futureAmCount ' + futureAmCount);
                            System.debug('futurePmCount ' + futurePmCount);
                            System.debug('AM ' + tripPerDayMap.get(brandWithSamePlant).get('AM'));
                            System.debug('PM ' + tripPerDayMap.get(brandWithSamePlant).get('PM'));
                            // has the limit been reached for AM or will it be reached once we add the current count
                            if ((tripPerDayMap.get(brandWithSamePlant).get('AM') <= dayEventCount.get(day).get('AmCount')) ||
                                (tripPerDayMap.get(brandWithSamePlant).get('AM') == futureAmCount && (brandWithSamePlant!= SBP_Constants.BRAND_MAKERS_MARK || day.contains('2019'))) ||
                                (dayToEventObj.get(day).blackoutType == 'AM') ||
                                (dayToEventObj.get(day).blackoutType == 'ALL')) {
                                    isTimeBooked.get(day).put('AM', true);
                                } else {
                                    Integer currentAmCount = dayEventCount.get(day).get('AmCount') + dayToEventObj.get(day).AM;
                                    dayEventCount.get(day).put('AmCount', currentAmCount);
                                }
                            
                            // has the limit been reached for PM or will it be reached once we had the current count
                            if ((tripPerDayMap.get(brandWithSamePlant).get('PM') <= dayEventCount.get(day).get('PmCount')) ||
                                (tripPerDayMap.get(brandWithSamePlant).get('PM') == futurePmCount && brandWithSamePlant!= SBP_Constants.BRAND_MAKERS_MARK) ||
                                (dayToEventObj.get(day).blackoutType == 'PM') ||
                                (dayToEventObj.get(day).blackoutType == 'ALL')) {
                                    isTimeBooked.get(day).put('PM', true);
                                } else {
                                    Integer currentPmCount = dayEventCount.get(day).get('PmCount') + dayToEventObj.get(day).PM;
                                    dayEventCount.get(day).put('PmCount', currentPmCount);
                                }
                        }
                    }
                    if (!brandTimeMap.containsKey(brandWithSamePlant)) {
                        brandTimeMap.put(brandWithSamePlant, isTimeBooked);
                    }
                }
            }
        return brandTimeMap;
    }
    
    
    /**************************************************************************************************************
Author:        Mahesh Babu, Priyankar Saha, Abhishek
Company:       TCS
Description:	return map of brand to day to timeslot to availability(Boolean)
History
<Date>      <Authors Name>     <Brief Description of Change>
8/2019     	Mahesh Babu, Priyankar Saha, Abhishek  Initial Creation

***************************************************************************************************************/    
    
    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getAvailableTimeSlots(String brand) {
        Map<String, Map<String, Boolean>> daytoTimeSlot = new Map<String, Map<String, Boolean>>();
        Date todaysDate = System.today();
        for(Plant_Event__c event: [select id, Scheduled_Date__c, Time_of_Day__c, Time_Slot__c, Plant__c, Type__c, Brand__c 
                                   from Plant_Event__c where Scheduled_Date__c >=: todaysDate AND Brand__c=:brand]) {
                                       String day = String.valueOf(event.Scheduled_Date__c);
                                       if(daytoTimeSlot.containsKey(day)){
                                           daytoTimeSlot.get(day).put(event.Time_Slot__c, true);
                                       }    
                                       else{
                                           daytoTimeSlot.put(day, new map<String, Boolean>{event.Time_Slot__c => true});
                                       }
                                       
                                   }
        System.debug('daytoTimeSlot:::'+daytoTimeSlot);
        if(daytoTimeSlot!=null){
            return daytoTimeSlot;
        }    
        return null;
    } 
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	return all seasonal events for a given program
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getSeasonalEvents(String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Time_Interval__c> timeIntervals = new List<Time_Interval__c>();
        List<Time_Interval__c> group1 = new List<Time_Interval__c>();
        List<Time_Interval__c> group2 = new List<Time_Interval__c>();
        
        try {
            for (Time_Interval__c timeInterval : [select id
                                                  , Start_Date__c
                                                  , Max_Number_of_Groups__c
                                                  , End_Date__c
                                                  , Date_Range_Label__c
                                                  , Trip_Group__c
                                                  , (Select Id, Time_of_Day__c, Time_Interval__r.Date_Range_Label__c from Plant_Events__r) from Time_Interval__c where Brand__c = :brand and isActive__c = true AND Type__c = 'Season Program Length' ORDER BY Start_Date__c ASC]) {
                                                      if (timeInterval.Max_Number_of_Groups__c > timeInterval.Plant_Events__r.size()) {
                                                          timeIntervals.add(timeInterval);
                                                      }
                                                      
                                                  }
            if(brand=='El Tesoro'){
                System.debug('---Brand El Tesoro---');
                for(Time_Interval__c ti : timeIntervals){
                    if(ti.Trip_Group__c == 1)
                    {
                        group1.add(ti);
                    }
                    else if(ti.Trip_Group__c == 2){
                        group2.add(ti);
                    }
                } 
                responseMap.put('group1', group1);
                responseMap.put('group2', group2);
            }    
            
            if(brand!='El Tesoro'){
                responseMap.put('events', timeIntervals);
            }    
            responseMap.put('numOfEvents', timeIntervals.size());
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug('---Request Status---'+requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description: 	get plant event data from a specific case
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getRelatedEvent(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            Case c = [select id, Plant_Event__c, Brand__c from Case where Id = :Id.valueOf(recordId) limit 1];
            Id profileId= userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            
            responseMap.put('recordId', c.Plant_Event__c);
            responseMap.put('participantsInfo', '');
            responseMap.put('brand', c.Brand__c);
            responseMap.put('profile', profileName);
            responseMap.put('tripDateRange', ''); //Added For LSB-167
            
            if(!String.isEmpty(c.Plant_Event__c)){
                String peId = c.Plant_Event__c;
                //Add Time_Interval__r.Date_Range_Label__c in below SOQL LSB-167
                Plant_Event__c pe = [select id, Time_Interval__r.Date_Range_Label__c, Participants_Info__c, RecordType.Name from Plant_Event__c where Id = :peId limit 1];
                responseMap.put('participantsInfo', pe.Participants_Info__c);
                responseMap.put('brandRecordType', pe.RecordType.Name);
                responseMap.put('tripDateRange', pe.Time_Interval__r.Date_Range_Label__c); //Added For LSB-167
            }
            
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	get on hold dates to pass into the booking calendar showing them as unavailable
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getOnHoldDates(String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Set<Date> datesToKeep = new Set<Date>();
        //Map<String, OnHoldDate> events = new Map<String, OnHoldDate>();
        List<OnHoldDate> events = new List<OnHoldDate>();
        Set<String> dateStrings = new Set<String>();
        Set<String> otherDateStrings = new Set<String>();
        Map<String, Map<String, Boolean>> brandTimeMap = new Map<String, Map<String, Boolean>>();
        Integer totalOnHoldDays = 0;
        
        
        try {
            brandTimeMap = getCurrentLimitPerDay().get(brand);
            List<Time_Interval__c> timeIntervals = [select id
                                                    , Start_Date__c
                                                    , End_Date__c
                                                    , (Select Id, Time_of_Day__c from Plant_Events__r)
                                                    from Time_Interval__c where Brand__c = :brand
                                                    and isActive__c = true
                                                    and Type__c = 'Date Hold'
                                                    and Submitter__c = :UserInfo.getUserId()];
            for (Time_Interval__c timeInterval : timeIntervals) {
                // if the day is not in the map then it has not been booked yet
                Integer daysBetween = timeInterval.Start_Date__c.daysBetween(timeInterval.End_Date__c);
                totalOnHoldDays = totalOnHoldDays + 2;
                totalOnHoldDays = totalOnHoldDays + daysBetween;
                System.debug('total days > ' + totalOnHoldDays);
                Date startDate = timeInterval.Start_Date__c;
                Date endDate = timeInterval.End_Date__c;
                // check to see if the start date has been booked am or pm
                if (!brandTimeMap.containsKey(String.valueOf(timeInterval.Start_Date__c))) {
                    
                    events.add(new OnHoldDate('AM', startDate, String.valueOf(startDate), startDate.month(), startDate.day(), startDate.year(), String.valueOf(timeInterval.Id)));
                    events.add(new OnHoldDate('PM', startDate, String.valueOf(startDate), startDate.month(), startDate.day(), startDate.year(), String.valueOf(timeInterval.Id)));
                } else {
                    if (brandTimeMap.get(String.valueOf(timeInterval.Start_Date__c)).get('AM')) {
                        events.add(new OnHoldDate('AM', startDate, String.valueOf(startDate), startDate.month(), startDate.day(), startDate.year(), String.valueOf(timeInterval.Id)));
                    }
                    if (brandTimeMap.get(String.valueOf(timeInterval.Start_Date__c)).get('PM')) {
                        events.add(new OnHoldDate('PM', startDate, String.valueOf(startDate), startDate.month(), startDate.day(), startDate.year(), String.valueOf(timeInterval.Id)));
                    }
                }
                // check to see if the end date has been booked am or pm
                if (!brandTimeMap.containsKey(String.valueOf(timeInterval.End_Date__c))) {
                    
                    events.add(new OnHoldDate('AM', endDate, String.valueOf(endDate), endDate.month(), endDate.day(), endDate.year(), String.valueOf(timeInterval.Id)));
                    events.add(new OnHoldDate('PM', endDate, String.valueOf(endDate), endDate.month(), endDate.day(), endDate.year(), String.valueOf(timeInterval.Id)));
                } else {
                    if (brandTimeMap.get(String.valueOf(timeInterval.End_Date__c)).get('AM')) {
                        events.add(new OnHoldDate('AM', endDate, String.valueOf(endDate), endDate.month(), endDate.day(), endDate.year(), String.valueOf(timeInterval.Id)));
                    }
                    if (brandTimeMap.get(String.valueOf(timeInterval.Start_Date__c)).get('PM')) {
                        events.add(new OnHoldDate('PM', endDate, String.valueOf(endDate), endDate.month(), endDate.day(), endDate.year(), String.valueOf(timeInterval.Id)));
                    }
                }
                
                // go through the days in between the date hold
                for (Integer i = 1; i < daysBetween; i++) {
                    Date nextDay = timeInterval.Start_Date__c.addDays(i);
                    otherDateStrings.add(String.valueOf(nextDay));
                    
                    if (!brandTimeMap.containsKey(String.valueOf(nextDay))) {
                        dateStrings.add(String.valueOf(nextDay));
                        //events.put(dateString, new OnHoldDate('AM', dateString));
                        //events.put(dateString, new OnHoldDate('PM', dateString));
                        
                        events.add(new OnHoldDate('AM', nextDay, String.valueOf(nextDay), nextDay.month(), nextDay.day(), nextDay.year(), String.valueOf(timeInterval.Id)));
                        events.add(new OnHoldDate('PM', nextDay, String.valueOf(nextDay), nextDay.month(), nextDay.day(), nextDay.year(), String.valueOf(timeInterval.Id)));
                    } else {
                        if (brandTimeMap.get(String.valueOf(nextDay)).get('AM')) {
                            events.add(new OnHoldDate('AM', endDate, String.valueOf(endDate), endDate.month(), endDate.day(), endDate.year(), String.valueOf(timeInterval.Id)));
                        }
                        if (brandTimeMap.get(String.valueOf(nextDay)).get('PM')) {
                            events.add(new OnHoldDate('PM', endDate, String.valueOf(endDate), endDate.month(), endDate.day(), endDate.year(), String.valueOf(timeInterval.Id)));
                        }
                    }
                }
            }
            
            totalOnHoldDays = 10 - totalOnHoldDays;
            responseMap.put('events', events);
            responseMap.put('brandTimeMap', brandTimeMap);
            responseMap.put('remainingDayAvailable', totalOnHoldDays);
            responseMap.put('bookedDays', dateStrings);
            responseMap.put('otherDateStrings', otherDateStrings);
            
            
        } catch (Exception e) {
            message = e.getMessage() + '\n' + e.getStackTraceString();
            message = message + brandTimeMap;
            success = false;
            System.debug(LoggingLevel.INFO, message);
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    public class OnHoldDate {
        
        @AuraEnabled public String timeVal {get; set;}
        @AuraEnabled public Date dateVal {get; set;}
        @AuraEnabled public String dateStringVal {get; set;}
        @AuraEnabled public Integer month {get; set;}
        @AuraEnabled public Integer day {get; set;}
        @AuraEnabled public Integer year {get; set;}
        @AuraEnabled public String timeInterval {get; set;}
        
        
        public OnHoldDate(String timeVal, Date dateVal, String dateStringVal, Integer month, Integer day, Integer year, String timeInterval) {
            this.timeVal = timeVal;
            this.dateVal = dateVal;
            this.dateStringVal = dateStringVal;
            this.month = month;
            this.day = day;
            this.year = year;
            this.timeInterval = timeInterval;
        }
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus insertEvent(String sEventObj, String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        System.debug('sEventObj ' + sEventObj);
        
        Plant_Event__c newEvent = (Plant_Event__c)JSON.deserialize(sEventObj, Plant_Event__c.class);
        newEvent.RecordTypeId = SBP_Constants.plantEventRtIdMap.get(brand);
        newEvent.Plant__c = SBP_Constants.brandToPlant.get(brand);
        //Added By Nishant Khandal for LSC Brand LSB-21
        if(brand=='El Tesoro' || brand == SBP_Constants.LAPHROAIG_SINGLE_CASK){ 
            newEvent.Scheduled_Date__c = Date.today();  
        }
        try {
            insert newEvent;
            //Added for El Tesoro
            //Added By Nishant Khandal for LSC Brand Condition LSB-21
            if(brand=='El Tesoro' || brand == SBP_Constants.LAPHROAIG_SINGLE_CASK){
                Time_Interval__c timeinterval = [select Max_Number_of_Groups__c, Remaining_Available_Trips__c, Trips_Booked__c from Time_Interval__c where isActive__c=true AND Id=:newEvent.Time_Interval__c];
                if(timeinterval.Trips_Booked__c==NULL){
                    timeinterval.Trips_Booked__c =+1;
                }else{
                    timeinterval.Trips_Booked__c =timeinterval.Trips_Booked__c + 1;
                }
                
                System.debug('Trips_Booked__c is::'+timeinterval.Trips_Booked__c);
                update timeinterval;
                newEvent.Time_Interval__c = timeinterval.Id;
                update newEvent;
            }
            responseMap.put('newEvent', newEvent);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getStackTraceString());
            message = e.getStackTraceString();
            message = message + e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:	checks to see if the requested date range is already taken, if so returns an error, else creates date holds
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018     	Craig Austgen       Initial Creation
    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus createOnHoldDates(String brand, String startDate, String endDate) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean dateRangeRejected = false;
        Time_Interval__c timeInterval = new Time_Interval__c();
        
        Date startDateVal = Date.valueOf(startDate);
        Date endDateVal = Date.valueOf(endDate);
        
        for (Time_Interval__c tInterval : [select id, Start_Date__c, End_Date__c from Time_Interval__c where Brand__c = :brand AND isActive__c = true]) {
            if ((startDateVal >= tInterval.Start_Date__c) && (startDateVal <= tInterval.End_Date__c)) {
                dateRangeRejected = true;
                break;
            } else if ((startDateVal <= tInterval.Start_Date__c) && (endDateVal >= tInterval.Start_Date__c)) {
                dateRangeRejected = true;
                break;
            }
        }
        
        List<Plant_Event__c> plantEvents = [select id, Scheduled_Date__c from Plant_Event__c where Brand__c = :brand AND
                                            ((Scheduled_Date__c >= :startDateVal AND Scheduled_Date__c <= :endDateVal)
                                             OR Scheduled_Date__c = :startDateVal
                                             OR Scheduled_Date__c = :endDateVal)];
        
        if (!plantEvents.isEmpty()) {
            dateRangeRejected = true;
        }
        
        
        try {
            if (!dateRangeRejected) {
                timeInterval.Brand__c = brand;
                timeInterval.Start_Date__c = startDateVal;
                timeInterval.End_Date__c = endDateVal;
                timeInterval.Type__c = 'Date Hold';
                timeInterval.isActive__c = true;
                timeInterval.Submitter__c = UserInfo.getUserId();
                insert timeInterval;
            }
            
            
            responseMap.put('timeInterval', timeInterval);
            responseMap.put('dateRangeRejected', dateRangeRejected);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getStackTraceString());
            message = e.getStackTraceString();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:	Updates the related case with the plant event 
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018     	Craig Austgen       Initial Creation
    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateCase(String eventId, String programType, String caseId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            Case c = new Case();
            c.put('Id', Id.valueOf(caseId));
            if (String.isNotBlank(programType)) {
                c.put('Type', programType);
            }
            if (String.isNotBlank(eventId)) {
                c.put('Plant_Event__c', Id.valueOf(eventId));
            }
            update c;
            
            responseMap.put('case', c);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
            
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    @AuraEnabled 
    public static String getUserType() { 
        return SBP_CaseSearchController.getUserType();
    }
    
    @AuraEnabled 
    public static Boolean showViewCalendar() {
        Boolean showCalendar = true;
        String userType = SBP_CaseSearchController.getUserType();
        if(userType != null && (userType == SBP_Constants.USER_TYPE_SUPER_HERITAGE_MANAGER  || userType == SBP_Constants.USER_TYPE_HERITAGE_MANAGER   || userType == SBP_Constants.USER_TYPE_DIPLOMAT)){
            showCalendar = false; 
        }
        return showCalendar;
    }
    /**************************************************************************************************************
    Author:        Naman Jangid
    Company:       Metacube
    Description:   Method for Consecutive Date Hold validations by user
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018     	Naman Jangid       Initial Creation
    ***************************************************************************************************************/
    @AuraEnabled
    public static boolean isConsecutiveEventLimitReached(String selectedScheduleDate) {
        Map<String,Boolean> availableDateSlotMap = new Map<String,Boolean>();
        Date selectedDate = Date.valueOf(selectedScheduleDate);
        SBP_Consecutive_Date_Hold_Limit__c dateHoldLimit = SBP_Consecutive_Date_Hold_Limit__c.getInstance('Diplomat_Consecutive_Date_Hold_Limit');
        Integer limitConsecutive = (Integer)dateHoldLimit.Consecutive_Limit__c;
        
        // In case of test run overriding the limit
        if(Test.isRunningTest()){
            limitConsecutive = 5;
        } 

        //Set start date
        Date startDateTemp = selectedDate;
        Integer startDateIndex = 0;
        while(startDateTemp > System.today() && startDateIndex < limitConsecutive){
            DateTime myDT = DateTime.newInstance(startDateTemp, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = myDT.format('EEEE');
            if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday' ){
                startDateIndex++;
                availableDateSlotMap.put(String.valueOf(startDateTemp),true);
            } 
            startDateTemp = startDateTemp.addDays(-1);               
        }
        Date startDate = startDateTemp;

        //Set end date
        Date endDateTemp = selectedDate;
        Integer endDateIndex = 0;
        while(endDateTemp > System.today() && endDateIndex < limitConsecutive){
            DateTime myDT1 = DateTime.newInstance(endDateTemp, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek1 = myDT1.format('EEEE');
            
            if(dayOfWeek1 != 'Saturday' && dayOfWeek1 != 'Sunday' ){
                endDateIndex++;
                availableDateSlotMap.put(String.valueOf(endDateTemp),true);
            } 
            endDateTemp = endDateTemp.addDays(1);    
        }
        DateTime myDT2 = DateTime.newInstance(endDateTemp, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek2 = myDT2.format('EEEE');
        if(dayOfWeek2 == 'Saturday'){
            endDateTemp = endDateTemp.addDays(2);    
        } else if(dayOfWeek2 == 'Sunday' ){
            endDateTemp = endDateTemp.addDays(1);    
        } 
        Date endDate = endDateTemp;
        
        //Get all events of user in date range from startdDate to endDate
        availableDateSlotMap.put(String.valueOf(selectedDate),false);
        List<Plant_Event__c> evList = [SELECT AM_PM__c,Brand__c,Case__c,CreatedById,Name,Number_of_Attendees__c,OwnerId,RecordTypeId,Scheduled_Date__c,Status__c,Subject__c,Time_Interval__c,Time_of_Day__c,Time_Slot__c,Tour__c,Type__c FROM Plant_Event__c 
                                       where Scheduled_Date__c >= TODAY and Scheduled_Date__c >= :startDate and Scheduled_Date__c <= :endDate and 
                                       OwnerId = :UserInfo.getUserId() and case__c = '' order by Scheduled_Date__c];
        
        for(Plant_Event__c pe : evList){
            DateTime myDateTime = DateTime.newInstance(pe.Scheduled_Date__c, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = myDateTime.format('EEEE');
            if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday'){            
                availableDateSlotMap.put(String.valueOf(pe.Scheduled_Date__c),false);
            }
        }

        //Check for limit reached or not 
        List<String> keySetList = new List<String>();
        keySetList.addAll(availableDateSlotMap.keySet());
        keySetList.sort();
        Integer countConsecutive = 0;
        for(String dateKey : keySetList){
            if(!availableDateSlotMap.get(dateKey)){
                countConsecutive++;
                if(countConsecutive >  limitConsecutive){
                    return true;
                }
            }else
            {
                countConsecutive = 0;
            }
        } 
        return false;     
    }
    
    /**************************************************************************************************************
    Author:			Naman Jangid
    Company:		Metacube
    Description:	it is used to update owner of plant event when the date hold is transferred

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Naman Jangid       updating owner of event
    **************************************************************************************************************/  
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateNewOwner(String events, String ownerId) {
        Boolean success = true;
        String message = null;
        String dateHoldDay = '';
        Id i;
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            List<Object> eventData = (List<Object>) JSON.deserializeUntyped(events);
            List<Plant_Event__c> lstPlantEventToUpdate = new List<Plant_Event__c>();
            List<Id> idVal = new List<Id>();
            List<Id> idVal2 = new List<Id>();
            for(Object event : eventData) {
                Map<String, Object> eventMap = (Map<String, Object>) event;
                idVal.add((Id) eventMap.get('id'));
                lstPlantEventToUpdate.add(new Plant_Event__c(Id = (Id) eventMap.get('id'), OwnerId = ownerId));
                dateHoldDay = (String) eventMap.get('start');
            }
            List<Plant_Event__c> s = [Select OwnerId from Plant_Event__C where id IN : idVal];
            for(Plant_Event__C pe : s){
                idVal2.add(pe.OwnerId);
            }
            List<User> u2 = [Select id,User_Type__c,Name,Email from User where id IN: idVal2];
            //Badri changes for SAL-1488
            // Start
            responseMap.put('maxLimit', false);
            String dateHoldLimitForDiplomatHM = System.Label.DateHoldLimitForDiplomatHM;
            Integer dateHoldLimitForDiplomatHMInt = integer.valueof(dateHoldLimitForDiplomatHM);
            List<Plant_Event__c> plantListTotal = [Select Id,OwnerId from Plant_Event__c where OwnerId = :ownerId AND Scheduled_Date__c >= : System.Today() AND Case__c = null];
        	Integer listLength = plantListTotal.size();// length of existing events of new owner
            Integer lstPlantEventToUpdateLength = lstPlantEventToUpdate.size();// length of events which will be transferred to the new owner
            Integer totalLength = listLength + lstPlantEventToUpdateLength;
            List<User> dateHoldRecipient = [Select User_Type__c,Name,Email from User where Id = :ownerId];
            if((dateHoldRecipient[0].User_Type__c == SBP_Constants.USER_TYPE_DIPLOMAT || dateHoldRecipient[0].User_Type__c == SBP_Constants.USER_TYPE_HERITAGE_MANAGER || dateHoldRecipient[0].User_Type__c == SBP_Constants.USER_TYPE_SUPER_HERITAGE_MANAGER) && totalLength >= dateHoldLimitForDiplomatHMInt){
                responseMap.put('maxLimit', true);
            }else if(!lstPlantEventToUpdate.isEmpty()) {
                update lstPlantEventToUpdate;
                sendActivationEmail(dateHoldRecipient[0].Email,UserInfo.getName(),dateHoldRecipient[0].Name,dateHoldDay);
                List<User> u = [Select id,User_Type__c from User where id =: UserInfo.getUserId()];
                if(u[0].User_Type__c == SBP_Constants.USER_TYPE_HERITAGE_MANAGER || u[0].User_Type__c == SBP_Constants.USER_TYPE_PLANT_TEAM_MEMBER)
                	sendActivationEmailFromHMPlant(u2,UserInfo.getName(),dateHoldDay);
            }
            responseMap.put('plantEventRecord', lstPlantEventToUpdate);
            //end
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	it is used to delete events

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Yash Jain       deletion of events 
    **************************************************************************************************************/     
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus deleteEventRecordsApex(String listOfEvents) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try{
            List<Object> eventData = (List<Object>) JSON.deserializeUntyped(listOfEvents);            
            List<Plant_Event__c> lstPlantEventToDelete = new List<Plant_Event__c>();
            List<Id> plantEventIdList = new List<Id>();

            for(Object event : eventData) {
                Map<String, Object> eventMap = (Map<String, Object>) event;
                lstPlantEventToDelete.add(new Plant_Event__c(Id = (Id) eventMap.get('id')));
                plantEventIdList.add((Id) eventMap.get('id'));
            }
            
            //Checking booking count
            AggregateResult aggr = [Select COUNT(Id)bookingCount from Plant_Event__c where Id in :plantEventIdList and Case__c != null];
            if((Integer)aggr.get('bookingCount') > 0){
                message = 'BOOKING_EXIST';
                success = false;
            }

            if(!lstPlantEventToDelete.isEmpty() && success) {
                delete lstPlantEventToDelete;
            }
        }catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
                  
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	it is used to send mail to the new owner when date hold is transferred

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021 			Yash Jain       sending mail 
    **************************************************************************************************************/ 
    public static void sendActivationEmail(String userEmail ,String dateHoldTransferrer ,String dateHoldRecipient ,String dateHoldDay)
    {
        String subjectText = 'Plant Event Transfered';
        String emailBody = 'Hello '+ dateHoldRecipient +',<br/><br/>';
        emailBody += dateHoldTransferrer + ' has given you a date hold for a MMPS on-site trip and selection on '+ dateHoldDay+ '.<br/><br/>';
        emailBody += 'Please note holds are cancelled 6 weeks out to ensure our accounts are able to take advantage of every opportunity we can offer to share the Maker’s Mark Private Select Experience in Loretto,<b> so please book in your account’s visit as soon as possible.</b> <br/><br/>';
        emailBody += 'If you aren’t sure why you’ve received this date hold, please reach out to ' + dateHoldTransferrer +' with any questions.<br/><br/>';
        emailBody += 'Thank you,<br/>';
        emailBody += 'The MMPS Team';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] {userEmail};
        email.setSubject(subjectText);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	it is used to send mail to old owner for transferring of holds

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Yash Jain       sending mail 
    **************************************************************************************************************/  
    public static void sendActivationEmailFromHMPlant(List<User> u,String dateHoldTransferrer ,String dateHoldDay)
    {
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        for(User us : u){
            String subjectText = 'Plant Event Transfered';
            String emailBody = 'Hello '+ us.Name +',<br/><br/>';
            emailBody += dateHoldTransferrer + ' has moved your MMPS in-person selection hold on '+ dateHoldDay+ '.Please reach out to them with any questions or concerns about the move. <br/><br/>';
            emailBody += 'Thank you,<br/>';
            emailBody += 'The MMPS Team';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.toAddresses = new String[] {us.Email};
            email.setSubject(subjectText);
            email.setHtmlBody(emailBody); 
            emailMessageList.add(email);            
        }
        Messaging.sendEmail(emailMessageList); 
    }
    
    /**************************************************************************************************************
    Author:			Naman Jangid
    Company:		Metacube
    Description:	it is used to update scheduled date and time slot of the booking event when rescheduling

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Naman Jangid       update events during rescheduling 
    **************************************************************************************************************/  
    @AuraEnabled
    public static void updateEventRecordsApex(String listOfEventIds, String targetDate, String timeSlot) {
        System.debug('--istOfEventIds'+listOfEventIds+'targetDate'+targetDate);
        List<String> idList = (List<String>) JSON.deserialize(listOfEventIds,List<String>.Class);
        List<Plant_Event__c> lstPlantEventToUpdate = new List<Plant_Event__c>();    
        for(Plant_Event__c event : [Select Id,Scheduled_Date__c,Time_Slot__C from Plant_Event__c where Id IN :idList]) {
            event.Scheduled_Date__c = Date.valueOf(targetDate) ;
            event.Time_Slot__C = timeSlot;
            lstPlantEventToUpdate.add(event);
        }
        System.debug('lstPlantEventToUpdate--'+lstPlantEventToUpdate);
        if(!lstPlantEventToUpdate.isEmpty()) {
            update lstPlantEventToUpdate;
        }       
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	it is used to fetch diplomats for a Heritage Manager from diplomatic hierarchy object

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Yash Jain       fetching diplomats for Heritage Manager 
    **************************************************************************************************************/   
    @AuraEnabled
    public static List<String> getDiplomatsOfHM() {
        List<Diplomatic_Hierarchy__c> listDH = [Select Diplomat__c from Diplomatic_Hierarchy__c where Manager__c = :UserInfo.getUserId()];
        System.debug('listDH--->'+listDH);
        List<String> diplomatIdList = new List<String>();     
        for(Diplomatic_Hierarchy__c dh : listDH){
            diplomatIdList.add(dh.Diplomat__c);
        }
        diplomatIdList.add(UserInfo.getUserId());
        return diplomatIdList; 
    }
    
    /**************************************************************************************************************
    Author:			Naman Jangid
    Company:		Metacube
    Description:	it is used to fetch regional diplomat id for submitter while booking date holds

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Naman Jangid       fetching diplomat id 
    **************************************************************************************************************/
    @AuraEnabled
    public static List<String> diplomatIdListForSub() {
        List<Case> listDH = [Select Regional_Diplomat__c from Case where Status = 'New' and Case_Record_Type__c like '%Single Barrel - Proof Specific%' and Submitter__c = :UserInfo.getUserId()];
        List<String> diplomatIdList = new List<String>();
        for(Case dh : listDH){
            diplomatIdList.add(dh.Regional_Diplomat__c);
        }
        return diplomatIdList; 
    }
    
    /**************************************************************************************************************
    Author:			Naman Jangid
    Company:		Metacube
    Description:	it is used to fetch plant event record for a case

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Naman Jangid       fetching plant event record for a case 
    **************************************************************************************************************/
    @AuraEnabled
    public static Plant_Event__c getPlantEventRecord(String recordId) {
        List<Plant_Event__c> peList = [Select Id,Name,Case__c,Case__r.CaseNumber from Plant_Event__c where Id = :recordId];
        if(!peList.isEmpty())
            return peList[0];
        else
            return null;
    }
    
    /**************************************************************************************************************
    Author:			Naman Jangid
    Company:		Metacube
    Description:	it is used to link case with plant event

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Naman Jangid       linking case with Plant event 
    **************************************************************************************************************/
    @AuraEnabled
    public static void linkCaseWithPlantEvent(String plantEventId, String caseEventId) {
        Plant_Event__c planEvent = new Plant_Event__c(Id = plantEventId, Case__c = caseEventId);
        Case caseToUpdate = new Case(Id = caseEventId, Plant_Event__c = plantEventId, Type = 'Trip and Tour',Status = 'Pending Selection' );
        upsert planEvent;
        upsert caseToUpdate;
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	it is used to fetch barrel laid down sub case information on parent case on the portal

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Yash Jain       fetching subcase information 
    **************************************************************************************************************/  
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getRelatedSubCase(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            responseMap.put('recordId', '');
            responseMap.put('caseDate', '');
            responseMap.put('isSubCaseClosed', false);
            responseMap.put('isSubCaseCreated', false);
            List<Case> parentCase = [select id, MMPS_Barrel_Fill_Subcase_Number__c,Type,Brand__c from Case where Id = :Id.valueOf(recordId) limit 1];
            responseMap.put('type', parentCase[0].Type);
            responseMap.put('brand', parentCase[0].Brand__c);
            if (parentCase.size() > 0){
                System.debug('pCa '+ parentCase);
                if(parentCase[0].MMPS_Barrel_Fill_Subcase_Number__c == null)
                    responseMap.put('isSubCaseCreated', false);
                else
                    responseMap.put('isSubCaseCreated', true);
            }
            List<Case> subCase = [select id, Barrel_Laid_Down_On__c, Aging_Complete_On__c,Case_Date__c from Case where ParentId = :Id.valueOf(recordId) limit 1];
			responseMap.put('subCase', subCase[0]);
            responseMap.put('barrelLaidDown', '');
            responseMap.put('aging', '');
            if (subCase.size() > 0){
                System.debug('subCase '+ subCase);
                responseMap.put('recordId', subCase[0].id);
                responseMap.put('caseDate', subCase[0].Case_Date__c);                
                if(subCase[0].Barrel_Laid_Down_On__c == null)
                    responseMap.put('isSubCaseClosed', false);
                else
                    responseMap.put('isSubCaseClosed', true);
                responseMap.put('barrelLaidDown', subCase[0].Barrel_Laid_Down_On__c);
                responseMap.put('aging', subCase[0].Aging_Complete_On__c);
            }
            
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
    Author:			Yash Jain
    Company:		Metacube
    Description:	it is used to fetch information for selection info

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021   Yash Jain       fetching information for selection info 
    **************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getSelection(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            Case parentCase = [select id,Type,Remote_Selection_Date__c,Location_Name__c,Brand__c from Case where Id = :Id.valueOf(recordId) limit 1];
            responseMap.put('type', parentCase.Type);
            responseMap.put('selDate', parentCase.Remote_Selection_Date__c);
            responseMap.put('loc', parentCase.Location_Name__c);
			responseMap.put('brand', parentCase.Brand__c);            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
   
    /**************************************************************************************************************
    Author:			Naman Jangid
    Company:		Metacube
    Description:	it is used to update participant info on plant event

    History
    <Date>           <Authors Name>    <Brief Description of Change>
    05,2021    Naman Jangid       updating participant info
    **************************************************************************************************************/
    @AuraEnabled
    public static void updateParticipantsInfo(String plantEventId,String participantsInfo) {
        System.debug('participantsInfo-->'+participantsInfo);
        Plant_Event__c pe = new Plant_Event__c(Id=plantEventId,Participants_Info__c=participantsInfo);
        upsert pe;
    }
}