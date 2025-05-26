public without sharing class SBP_AttendeeCmpCtrl {

	/**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:   Inserts attendees for a particular plant event
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static LightningComponentUtility.RequestStatus createAttendeeRecords(String jsonAttendees) {
		Boolean success = true;
		String message = null;
		Map<String, Object> responseMap = new Map<String, Object>();

		try {
			List<Attendee__c> attendees = (List<Attendee__c>)System.JSON.deserialize(jsonAttendees, List<Attendee__c>.Class);
			insert attendees;
			responseMap.put('attendees', attendees);

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
    Author:        Mahesh Babu M
    Company:       TCS
    Description:   Returns Brand for a particular attendee
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    1/2019     	Mahesh babu M     Initial Creation

	***************************************************************************************************************/
    @AuraEnabled
    public static String getBrand(String case_Id){
        List<Attendee__c> attendeeList = new List<Attendee__c>();
        List<case> plantEventList = [Select id, plant_event__r.id, plant_event__r.Brand__c from case where id= : case_Id];
        if(plantEventList.size()>0){
            attendeeList = [Select Id, Name, plant_event__r.Brand__c from Attendee__c where Plant_Event__c =: plantEventList[0].plant_event__r.id ];
         }
    	return plantEventList[0].plant_event__r.Brand__c;
      
    }
    
    /**************************************************************************************************************
    Author:        Mahesh Babu M
    Company:       TCS
    Description:   Returns attendeelist for a particular plant event
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    1/2019     	Mahesh babu M     Initial Creation

	***************************************************************************************************************/
    @AuraEnabled
    public static List<Attendee__c> getAttendeeList(String case_Id){
         List<Attendee__c> attendeeList = new List<Attendee__c>();
         List<case> plantEventList = [Select id, plant_event__r.id from case where id= : case_Id];
         if(plantEventList.size()>0){
            attendeeList = [Select Id, Name, Incoming_Airline__c, Outgoing_Airline__c, First_Name__c, Last_Name__c, plant_event__r.Brand__c from Attendee__c where Plant_Event__c =: plantEventList[0].plant_event__r.id ];
         }
        return attendeeList;
    }
    
    /**************************************************************************************************************
    Author:        Mahesh Babu M
    Company:       TCS
    Description:   Inserting flight info for a particular attendee based on attendeeId
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    1/2019     	Mahesh babu M     Initial Creation

	***************************************************************************************************************/
    @AuraEnabled
    public static Boolean createFlightInfo(String Incoming_Airline, String Incoming_Flight_Number, String Incoming_Departure_City, DateTime Incoming_Arrival_Time,
                                           String Outgoing_Flight_Number, String Outgoing_Final_Destination, DateTime Outgoing_Departure_Time, String Additional_Notes, String Outgoing_Airline, String AttendeeId,
                                           String Outbound_Departure_City, String Inbound_Arrival_City){
        Boolean alertFlag = false;
        try{
        if(Incoming_Airline!=null && Incoming_Flight_Number!=null && Incoming_Departure_City!=null && Incoming_Arrival_Time!=null &&
            Outgoing_Flight_Number!=null && Outgoing_Final_Destination!=null && Outgoing_Departure_Time!=null && Outgoing_Airline!=null
            && Outbound_Departure_City != null && Inbound_Arrival_City != null){    
                
        Attendee__c attendeeDetails = [Select Id, Incoming_Airline__c, Outgoing_Airline__c from Attendee__c where Id =: AttendeeId ];
        attendeeDetails.Incoming_Airline__c = Incoming_Airline;
        attendeeDetails.Incoming_Flight_Number__c = Incoming_Flight_Number;
        attendeeDetails.Incoming_Departure_City__c = Incoming_Departure_City;
        attendeeDetails.Incoming_Arrival_Time__c = Incoming_Arrival_Time;
        attendeeDetails.Outgoing_Airline__c = Outgoing_Airline;
        attendeeDetails.Outgoing_Flight_Number__c = Outgoing_Flight_Number;
        attendeeDetails.Outgoing_Final_Destination__c = Outgoing_Final_Destination;
        attendeeDetails.Outgoing_Departure_Time__c = Outgoing_Departure_Time;
        attendeeDetails.Additional_Notes__c = Additional_Notes;
        attendeeDetails.Outbound_Departure_City__c = Outbound_Departure_City;
        attendeeDetails.Inbound_Arrival_City__c = Inbound_Arrival_City;
        update attendeeDetails;
        alertFlag = true;
        }        
        }catch(Exception e){
            CreateExceptionLog.insertErrorLog('SBP_AttendeeCmpCtrl', 'createFlightInfo', String.valueOf(e), 'Fatal');
        }
        return alertFlag;
    }

}