@isTest
private class SBP_AttendeeCmpCtrlTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		insert u;
	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Barrel_Number__c getBarrelNumberByBrand(String brand) {
		return [select id, Brand__c, Next_Barrel_Number__c from Barrel_Number__c where Brand__c = :brand limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status from Case where Brand__c = :brand limit 1];
	}

	public static Barrel__c getBarrelBySku(String sku) {
		return [select id, Selection_Date__c, Barrel_Number__c from Barrel__c where SKU__c = :sku limit 1];
	}

	public static List<Case> getCurrentNumberOfCases() {
		return [select Id from Case];
	}

	public static Account getTestAccount() {
		return [select id from Account where Name = 'Test Account'];
	}


	public static testMethod void createNewAttendeesTest() {
		Plant_Event__c plantEvent = new Plant_Event__c();
		plantEvent.Scheduled_Date__c = Date.today();
		plantEvent.Brand__c = 'Knob Creek';
		insert plantEvent;

		String jsonAttendees = '[{"Plant_Event__c":"' + plantEvent.Id + '","First_Name__c":"Test","Last_Name__c":"Attendee"}]';

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_AttendeeCmpCtrl.createAttendeeRecords(jsonAttendees);

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('attendees'), 'attendees should exist');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void createNewCaseErrorTest() {

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_AttendeeCmpCtrl.createAttendeeRecords('error');

		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should return successfully');
	}
    
    public static testMethod void createFlightInfoTest() {
   
        Case c = new Case();
        c.Status = 'New';
        insert c;
        
        Plant_Event__c plantEvent = new Plant_Event__c();
		plantEvent.Scheduled_Date__c = Date.today();
		plantEvent.Brand__c = 'El Tesoro';
        plantEvent.Case__c = c.id;
		insert plantEvent;
        
        Attendee__c attendee = new Attendee__c();
        attendee.Incoming_Airline__c='Test';
        attendee.Incoming_Flight_Number__c='Test123';
        attendee.Incoming_Departure_City__c = 'Testchennai';
        attendee.Outgoing_Airline__c = 'TestOut';
        attendee.Outgoing_Flight_Number__c = 'Test234';
        attendee.Outgoing_Final_Destination__c = 'TestUSA';
        attendee.Incoming_Arrival_Time__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        attendee.Outgoing_Departure_Time__c = datetime.newInstance(2014, 9, 15, 13, 30, 0);
        attendee.Additional_Notes__c = 'TestNotes';
        attendee.Plant_Event__c = plantEvent.id;
        insert attendee;
        
        String Incoming_Airline = 'Test'; 
        String Incoming_Flight_Number = 'Test123';
        String Incoming_Departure_City =  'Testchennai';
        DateTime Incoming_Arrival_Time = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        String Outgoing_Flight_Number= 'Test234';
        String Outgoing_Final_Destination = 'TestUSA';
        DateTime Outgoing_Departure_Time = datetime.newInstance(2014, 9, 15, 13, 30, 0);
        String Additional_Notes = 'TestNotes';
        String Outgoing_Airline = 'TestOut';
        String AttendeeId = attendee.Id;
        
        SBP_AttendeeCmpCtrl.createFlightInfo(Incoming_Airline, Incoming_Flight_Number, Incoming_Departure_City, Incoming_Arrival_Time, Outgoing_Flight_Number, Outgoing_Final_Destination, Outgoing_Departure_Time, Additional_Notes, Outgoing_Airline, AttendeeId, 'test', 'test');
 
        attendee.Incoming_Airline__c = 'Test1';
        
        update attendee;
      
    }
    
    public static testMethod void createBrand() {
   
        Case c = new Case();
        c.Status = 'New';
        insert c;
        SBP_AttendeeCmpCtrl.getBrand(c.id);
        SBP_AttendeeCmpCtrl.getAttendeeList(c.id);    
    }
    
    @isTest
    static void testCreateFlightInfoForLaphroaig(){
        Case newCase = SBP_TestDataFactory.createCase(null, true);
        Plant_Event__c plantEvent = SBP_TestDataFactory.createPlantEvent(null, newCase.Id, true);
        Attendee__c attendee = SBP_TestDataFactory.createAttendee(plantEvent.Id, true);
        Boolean isCreated = false;
        
        Test.startTest();
        	isCreated = SBP_AttendeeCmpCtrl.createFlightInfo('test','test','test',datetime.newInstance(2014, 9, 15, 12, 30, 0),
           	'test','test',datetime.newInstance(2014, 9, 15, 12, 30, 0),'test','test', attendee.Id,
            'test','test');
        Test.stopTest();
        
        System.assertEquals(True, isCreated, 'Record not created when expected');
    }
}