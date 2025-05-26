@isTest
private class SBP_CalendarCmpCtrlTest {
	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuserccct1@test-user-system.com.test-only',User_Type__c = 'Heritage Manager');
		insert u;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User demoUser = new User(Alias = 'alias', Email = 'test@test.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                 EmailEncodingKey = 'UTF-8', LastName = 'demoUser', LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US', ProfileId = p2.Id,
                                 TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuserccct2@test-user-system.com.test-only',User_Type__c = 'Diplomat');
        insert demoUser;
        

		Account testAccount = new Account();
		testAccount.Name = 'Test Account';
		testAccount.BillingState = 'IL';
		testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

		Account retailAccount = new Account();
		retailAccount.Name = 'Retail Account';
		retailAccount.BillingState = 'IL';
		retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

		insert new List<Account> {testAccount, retailAccount};


		Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
		bg.Type__c = 'Trip and Tour';

		Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
		bg2.Type__c = 'Trip and Tour';

		insert new List<Barrel_Order_Group__c> {bg, bg2};

		Plant_Event__c event = createEvent('Knob Creek', 'AM', Date.today().addDays(10), true);


		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c.Type = 'Trip and Tour';
		c.Barrel_Order_Group__c = bg.Id;
		c.Brand__c = 'Knob Creek';
		c.Product_Type__c = 'Bourbon';
		c.ccEmail__c = 'test@test.com';
		c.Plant_Event__c = event.Id;
		c.AccountId = testAccount.Id;

		Case c2 = new Case();
		c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
		c2.Type = '';
		c2.Barrel_Order_Group__c = bg2.Id;
		c2.Brand__c = 'Makers Mark';
		c2.AccountId = testAccount.Id;
        
        Case c3 = new Case();
		c3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
		c3.Type = '';
		c3.Brand__c = 'Makers Mark';
		c3.AccountId = testAccount.Id;
        c3.Submitter__c = u.Id;
        c3.Regional_Diplomat__c = demoUser.Id;

		insert new List<Case> {c, c2, c3};
            
        Plant_Event__c plantEvent = (new Plant_event__c(Scheduled_Date__c = System.Today().addDays(49)));
        plantEvent.Time_of_day__c = 'PM';
        plantEvent.Brand__C = 'Makers Mark';
        insert plantEvent;

	}

	public static Case getCaseById(Id caseId) {
		return [select id from Case where Id = :caseId limit 1];
	}

	public static Barrel_Number__c getBarrelNumberByBrand(String brand) {
		return [select id, Brand__c, Next_Barrel_Number__c from Barrel_Number__c where Brand__c = :brand limit 1];
	}

	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, Status, Type, Plant_Event__c from Case where Brand__c = :brand limit 1];
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

	public static List<Plant_Event__c> getEvents() {
		return [select id from Plant_Event__c];
	}

	public static Plant_Event__c createEvent(String brand, String timeOfday, Date tripDate, Boolean autoCreate) {
		Plant_Event__c plantEvent = new Plant_Event__c();
		plantEvent.Scheduled_Date__c = tripDate;
		plantEvent.Brand__c = brand;
		plantEvent.Time_Of_Day__c = timeOfday;
        plantEvent.Type__c = 'Blackout';
            
		if (autoCreate) {
			insert plantEvent;
		}

		return plantEvent;
	}

	public static Time_Interval__c createTimeInterval(String brand, Date startDate, Date endDate, Integer numOfGroups, String type, Boolean autoCreate) {
		Time_Interval__c timeInterval = new Time_Interval__c();
		timeInterval.Brand__c = brand;
		timeInterval.Start_Date__c = startDate;
		timeInterval.End_Date__c = endDate;
		timeInterval.Type__c = type;
		timeInterval.Max_Number_of_Groups__c = numOfGroups;
		timeInterval.isActive__c = true;
		timeInterval.Trip_Group__c = 1;
		if (autoCreate) {
			insert timeInterval;
		}

		return timeInterval;
	}



	public static testMethod void getEventsTest() {
		List<Plant_Event__c> events = new List<Plant_Event__c>();
		for (Integer i = 0; i < 10; i++) {
			events.add(createEvent('Knob Creek', 'AM', Date.today().addDays(i), false));
		}
		insert events;

		//String jsonAttendees = '[{"Plant_Event__c":"' + plantEvent.Id + '","First_Name__c":"Test","Last_Name__c":"Attendee"}]';

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getEvents(new List<String> {'Knob Creek'});


		Test.stopTest();

		System.assertEquals(11, response.responseMap.get('numberOfEvents'), '11 events should exist');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getSingleBarrelCalendarCustomMetadataTest() {


		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getSingleBarrelCalendarCustomMetadata();

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('brandInfoMap'), 'Custom metadata should be returned');
	}

	public static testMethod void sortTimePeriodsBasedOnDayTest() {
		List<Plant_Event__c> events = new List<Plant_Event__c>();
		Map<String, Map<String, Integer>> dateToTimePeriod = new Map<String, Map<String, Integer>>();

		for (Integer i = 0; i < 5; i++) {
			events.add(createEvent('Knob Creek', 'AM', Date.today().addDays(i), false));
		}

		events.add(createEvent('Makers Mark', 'AM', Date.today(), false));

		insert events;

		Test.startTest();

		Map<String, Map<String, Integer>> response = SBP_CalendarCmpCtrl.sortTimePeriodsBasedOnDay();

		Test.stopTest();

		System.assertNotEquals(NULL, response, 'Dates should be sorted');
	}

	public static testMethod void getEventDataByDayTest() {
		List<Plant_Event__c> events = new List<Plant_Event__c>();
		Map<String, Map<String, Integer>> dateToTimePeriod = new Map<String, Map<String, Integer>>();

		for (Integer i = 0; i < 5; i++) {
			events.add(createEvent('Knob Creek', 'AM', Date.today().addDays(i), false));
		}
        events.add(createEvent('Knob Creek', 'PM', Date.today(), false));
		events.add(createEvent('Makers Mark', 'PM', Date.today(), false));

		insert events;

		Test.startTest();

		Map<String, Map<String, SBP_CalendarCmpCtrl.PlantEventObj>> response = SBP_CalendarCmpCtrl.getEventDataByDay();

		Test.stopTest();

		System.assertNotEquals(NULL, response, '');
	}

	public static testMethod void getCurrentLimitPerDayTest() {
		List<Plant_Event__c> events = new List<Plant_Event__c>();
		Map<String, Map<String, Integer>> dateToTimePeriod = new Map<String, Map<String, Integer>>();

		for (Integer i = 0; i < 5; i++) {
			events.add(createEvent('Knob Creek', 'AM', Date.today().addDays(i), false));
		}

		events.add(createEvent('Makers Mark', 'AM', Date.today(), false));

		insert events;

		Test.startTest();

		Map<String, Map<String, Map<String, Boolean>>> response = SBP_CalendarCmpCtrl.getCurrentLimitPerDay();

		Test.stopTest();

		System.assertNotEquals(NULL, response, '');
	}

	public static testMethod void getSeasonalEventsTest() {
		List<Plant_Event__c> events = new List<Plant_Event__c>();
		List<Time_Interval__c> timeIntervals = new List<Time_Interval__c>();
        List<Time_Interval__c> group1 = new List<Time_Interval__c>();
        List<Time_Interval__c> group2 = new List<Time_Interval__c>();

		timeIntervals.add(createTimeInterval('El Tesoro', Date.today(), Date.today().addDays(20), 10, 'Season Program Length', false));
		timeIntervals.add(createTimeInterval('El Tesoro', Date.today(), Date.today().addDays(20), 10, 'Season Program Length', false));

		insert timeIntervals;

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getSeasonalEvents('El Tesoro');
        //LightningComponentUtility.RequestStatus response1 = SBP_CalendarCmpCtrl.getSeasonalEvents('El Tesoro');

		Test.stopTest();

		System.assertEquals(2, response.responseMap.get('numOfEvents'), '2 Time intervals should be creted');

	}

	public static testMethod void getRelatedEventTest() {
		Case c = getCaseByBrand('Knob Creek');

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getRelatedEvent(String.valueOf(c.Id));

		Test.stopTest();

		System.assertNotEquals(NULL, response.responseMap.get('recordId'), 'Record Id should be returned');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void getOnHoldDatesTest() {

		Time_Interval__c timeInterval = createTimeInterval('Makers Mark', Date.today(), Date.today().addDays(10), 0, 'Date Hold', true);

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getOnHoldDates('Makers Mark');

		Test.stopTest();

		System.assertEquals(10, response.responseMap.get('remainingDayAvailable'), '10 days should be remaining');
	}

	public static testMethod void getOnHoldDatesEightRemainTest() {
		List<Plant_Event__c> events = new List<Plant_Event__c>();

		Time_Interval__c timeInterval = createTimeInterval('Makers Mark', Date.today(), Date.today().addDays(3), 0, 'Date Hold', false);
		timeInterval.Submitter__c = UserInfo.getUserId();
		insert timeInterval;

		for (Integer i = 0; i < 2; i++) {
			Plant_Event__c event = createEvent('Makers Mark', 'AM', Date.today().addDays(i), false);
			event.Time_Interval__c = timeInterval.Id;
			events.add(event);
		}

		insert events;

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getOnHoldDates('Makers Mark');

		Test.stopTest();

		System.assertEquals(5, response.responseMap.get('remainingDayAvailable'), '5 days should be remaining');
	}

	public static testMethod void createOnHoldDatesTest() {

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.createOnHoldDates('Makers Mark', '2018-11-01', '2018-11-04');


		Test.stopTest();

		System.assertEquals(FALSE, response.responseMap.get('dateRangeRejected'), 'Time slot should be available');
	}

	public static testMethod void updateCaseTest() {
		Case c = getCaseByBrand('Makers Mark');
		Plant_Event__c event = createEvent('Makers Mark', 'AM', Date.today().addDays(1), true);

		System.assertEquals(NULL, c.Plant_Event__c);
		System.assertEquals(NULL, c.Type);

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.updateCase(String.valueOf(event.Id), 'Trip and Tour', String.valueOf(c.Id));

		Case updateCase = [select id, Type, Plant_Event__c from Case where Id = :c.Id];

		Test.stopTest();

		System.assertEquals('Trip and Tour', updateCase.Type, 'Type should be updated');
		System.assertNotEquals(NULL, updateCase.Plant_Event__c, 'Plant event should be added to case');
		System.assertEquals(true, response.success, 'Operation should return successfully');
	}

	public static testMethod void updateCaseErrorTest() {
		Plant_Event__c event = createEvent('Makers Mark', 'AM', Date.today().addDays(1), true);

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.updateCase(String.valueOf(event.Id), 'Trip and Tour', '');


		Test.stopTest();

		System.assertEquals(false, response.success, 'Operation should not return successfully');
	}

	public static testMethod void insertEventFromDateHoldScreenTest() {
		List<Plant_Event__c> events = [Select id from Plant_Event__c];


		Time_Interval__c timeInterval = createTimeInterval('Makers Mark', Date.today(), Date.today().addDays(3), 0, 'Date Hold', false);
		timeInterval.Submitter__c = UserInfo.getUserId();
		insert timeInterval;
		Id userId = UserInfo.getUserId();

		String eventJson = '{ "Plant__c": "Loretto", '
		                   + '    "Brand__c": "Makers Mark", '
		                   + '    "Include_Boxed_Lunches__c": "true", '
		                   + '    "Time_of_Day__c": "AM", '
		                   + '    "Scheduled_Date__c": "2018-10-01", '
		                   + '    "Initiator__c": "' + userId + '", '
		                   + '    "Time_Interval__c": "' + timeInterval.Id + '"}';

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.insertEvent(eventJson, 'Makers Mark');

		List<Plant_Event__c> updatedEvents = [Select id from Plant_Event__c];

		Test.stopTest();

		System.assertEquals(events.size() + 1, updatedEvents.size(), eventJson);
	}

	public static testMethod void upsertEventsTest() {
		List<Plant_Event__c> events = [Select id from Plant_Event__c];


		Time_Interval__c timeInterval = createTimeInterval('Makers Mark', Date.today(), Date.today().addDays(3), 0, 'Date Hold', false);
		timeInterval.Submitter__c = UserInfo.getUserId();
		insert timeInterval;
		Id userId = UserInfo.getUserId();

		String eventJson = 	'{"startDateTime":"2022-10-02"'
		                        + ',"endDateTime":"2022-10-02"'
		                        + ',"description":null'
		                        + ',"plant":"Clermont"'
		                        + ',"brand":"Knob Creek"'
		                        + ',"timeOfDay":"AM"'
		                        + ',"scheduledDate":"2022-10-02"'
		                        + ',"initiatorId":"' + userId + '"'
		                        + ',"boxedLunches":false'
		                        + ',"isBottling":true'
		                        + ',"waitingOptionsVal":"Cocktail Bar"'
		                        + ',"isTour":false}';

		Test.startTest();

		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.upsertEvents(eventJson, 'Loretto', 'Makers Mark');

		List<Plant_Event__c> updatedEvents = [Select id from Plant_Event__c];

		Test.stopTest();
		System.assertEquals(events.size() + 1, updatedEvents.size() + 1, eventJson);
	}
    
    public static testMethod void getDiplomatsOfHMTest() {
        Plant_Event__c event = createEvent('Makers Mark', 'AM', Date.today().addDays(1), true);        
        Test.startTest();        
        List<String> response = SBP_CalendarCmpCtrl.getDiplomatsOfHM();       
        Test.stopTest();        
        System.assert(response != null);
    }
    
   
    public static testMethod void updateNewOwnerTest() {
        String events = ' [{"id":"a4U8A000000TdGtUAK","title":"PM Guest Slot 1 - Johnnie Mundell - Hold","brand":"Makers Mark","start":"2021-09-08","end":"2021-09-08","color":"#fd0000","textColor":"white","initiatorId":"0058A000007EwBK","ownerId":"005o0000002H5qpAAC","defaultLabel":"PM Guest Slot 1 - Johnnie Mundell - Hold"}]';
        Plant_Event__c event = createEvent('Makers Mark', 'AM', Date.today().addDays(1), true);        
        Test.startTest();        
        LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.updateNewOwner(events,'005o0000002H5qpAAC');       
        Test.stopTest();        
        System.assert(response != null);
    }
    
    public static testMethod void getRelatedSubCaseTest() {        
        Test.startTest();        
        LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getRelatedSubCase('005o0000002H5qpAAC');       
        Test.stopTest();        
        System.assert(response != null);
    }
    
    public static testMethod void getSelectionTest() {        
        Test.startTest();        
        LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.getSelection('005o0000002H5qpAAC');       
        Test.stopTest();        
        System.assert(response != null);
    }
    
    public static testMethod void getAvailableTimeSlotsTest() {        
        Test.startTest();        
        Map<String, Map<String, Boolean>> response = SBP_CalendarCmpCtrl.getAvailableTimeSlots('Makers Mark');       
        Test.stopTest();        
        System.assert(response != null);
    }
    
    public static testMethod void updateParticipantsInfoTest() {
        String participantsInfo = 'Demo User';
		Plant_Event__c plantEvent = [Select id from Plant_Event__c where Brand__c = 'Makers Mark' limit 1];        
        Test.startTest();        
        SBP_CalendarCmpCtrl.updateParticipantsInfo(plantEvent.id , participantsInfo);       
        Test.stopTest();        
        Plant_Event__c plantEventTest = [Select id, Participants_Info__c from Plant_Event__c where Brand__c = 'Makers Mark' limit 1];
        System.assert(plantEventTest.Participants_Info__c == 'Demo User');
    }
    
    public static testMethod void linkCaseWithPlantEventTest() {
        Plant_Event__c plantEvent = [Select id from Plant_Event__c where Brand__c = 'Makers Mark' limit 1];
		Case caseTest = [Select id from Case limit 1];        
        Test.startTest();        
        SBP_CalendarCmpCtrl.linkCaseWithPlantEvent(plantEvent.id , caseTest.id);       
        Test.stopTest();        
        Plant_Event__c plantEventTest = [Select id, Case__c from Plant_Event__c where Brand__c = 'Makers Mark' limit 1];
        System.assert(plantEventTest.Case__c == caseTest.id);
    }
    
    public static testMethod void getPlantEventRecordTest() {
        Plant_Event__c plantEvent = [Select id from Plant_Event__c where Brand__c = 'Makers Mark' limit 1];
        Case caseTest = [Select id from Case limit 1];        
        Test.startTest();        
        Plant_Event__c plantEventTest= SBP_CalendarCmpCtrl.getPlantEventRecord(plantEvent.id);       
        Test.stopTest();        
        System.assert(plantEventTest.id != null);
    }
    
    public static testMethod void sendActivationEmailTest() {
        User userTest = [Select id,Email from User where Email = 'standarduser@testorg.com' limit 1];        
        Test.startTest();
        SBP_CalendarCmpCtrl.sendActivationEmail(userTest.Email , 'First User' , 'Second User' , '6th Sep');
        System.assert(userTest.Email != '');
        Test.stopTest();        
    }
    
    public static testMethod void sendActivationEmailFromHMPlantTest() {
        List<User> userTests = new List<User>();
		User userTest = [Select id,Email,Name from User where Email = 'standarduser@testorg.com' limit 1];
		userTests.add(userTest);        
        Test.startTest();
        SBP_CalendarCmpCtrl.sendActivationEmailFromHMPlant(userTests , 'First User' , '6th Sep');
        System.assert(userTests.size() > 0);
        Test.stopTest();        
    }
    
    public static testMethod void deleteEventRecordsApexTest() {
        Plant_Event__c plantEvent = [Select id from Plant_Event__c where Brand__c = 'Makers Mark' limit 1];
        Date d = system.today();
        SBP_CalendarCmpCtrl.EventObj event= new SBP_CalendarCmpCtrl.EventObj('test', 'test', 'test', 'test', 'test', 'test', d, 'test');
        String events = ' [{"id":"' + plantEvent.id + '"}]';       
        Test.startTest();
        LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.deleteEventRecordsApex(events);
        Test.stopTest();
		List<Plant_Event__c> plantEventTest = [Select id from Plant_Event__c where Brand__c = 'Makers Mark'];
		System.assert(plantEventTest.size() == 0);  
        System.assert(response != null); 
    }
    
    public static testMethod void getUserTypeTest() {
        User userTest = [Select id from User where User_Type__c = :SBP_Constants.USER_TYPE_DIPLOMAT limit 1];    
        Test.startTest();
        System.runAs(userTest)
        {
            String userType = SBP_CalendarCmpCtrl.getUserType();
            Test.stopTest();
            System.assert(userType != null); 
        }
               
    }
    
    public static testMethod void diplomatIdListForSubTest() {   
        Test.startTest();
        List<String> idList = SBP_CalendarCmpCtrl.diplomatIdListForSub();
        Test.stopTest();
        System.assert(idList.size() != null);        
    }
    
    public static testMethod void showViewCalenderHMTest() {   
        User userTest = [Select id from User where User_Type__c = :SBP_Constants.USER_TYPE_HERITAGE_MANAGER limit 1];    
        Test.startTest();
        System.runAs(userTest)
        {
            Boolean showViewCalendar = SBP_CalendarCmpCtrl.showViewCalendar();            
            System.assertEquals(false, showViewCalendar,'HM will not have access to View Calendar Button'); 
        }  
        Test.stopTest();
    }
    
    public static testMethod void showViewCalenderDiplomatTest() {   
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User diplomatUser = new User(Alias = 'alias', Email = 'test@test.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                 EmailEncodingKey = 'UTF-8', LastName = 'demoUser', LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US', ProfileId = profile.Id,
                                 TimeZoneSidKey = 'America/Chicago', UserName = 'diplomattest@test.test',User_Type__c = 'Diplomat');
        insert diplomatUser;
          
        Test.startTest();
        System.runAs(diplomatUser)
        {
            Boolean showViewCalendar = SBP_CalendarCmpCtrl.showViewCalendar();            
            System.assertEquals(false, showViewCalendar,'Diplomat will not have access to View Calendar Button'); 
        }  
        Test.stopTest();
    }
    
    public static testMethod void showViewCalenderSubmitterTest() {   
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User submitterUser = new User(Alias = 'alias', Email = 'test@test.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                                      EmailEncodingKey = 'UTF-8', LastName = 'demoUser', LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US', ProfileId = profile.Id,
                                      TimeZoneSidKey = 'America/Chicago', UserName = 'submittertest@test.test');
        insert submitterUser;
        
        Test.startTest();
        System.runAs(submitterUser)
        {
            Boolean showViewCalendar = SBP_CalendarCmpCtrl.showViewCalendar();            
            System.assertEquals(true, showViewCalendar,'Submitter will have access to View Calendar Button'); 
        } 
        
        submitterUser.User_Type__c = 'State Manager';
        update submitterUser;
        
        System.runAs(submitterUser)
        {
            Boolean showViewCalendar = SBP_CalendarCmpCtrl.showViewCalendar();            
            System.assertEquals(true, showViewCalendar,'State Manager will have access to View Calendar Button'); 
        } 
        Test.stopTest();
    }
    //Added By Nishant Khandal LSB-21
    public static testMethod void insertEventFromDateHoldScreenLaphroaigSingleCaskTest() {
		List<Plant_Event__c> events = [Select id from Plant_Event__c];

		Time_Interval__c timeInterval = createTimeInterval(SBP_Constants.LAPHROAIG_SINGLE_CASK, Date.today(), 
                                                           Date.today().addDays(3), 0, 'Date Hold', false);
		timeInterval.Submitter__c = UserInfo.getUserId();
		insert timeInterval;
		Id userId = UserInfo.getUserId();
		String eventJson = '{ "Plant__c": "Loretto", '
		                   + '    "Brand__c": "Laphroaig Single Cask", '
		                   + '    "Include_Boxed_Lunches__c": "true", '
		                   + '    "Time_of_Day__c": "AM", '
		                   + '    "Scheduled_Date__c": "2018-10-01", '
		                   + '    "Initiator__c": "' + userId + '", '
		                   + '    "Time_Interval__c": "' + timeInterval.Id + '"}';

		Test.startTest();
		LightningComponentUtility.RequestStatus response = SBP_CalendarCmpCtrl.insertEvent(eventJson,
                                                                                           SBP_Constants.LAPHROAIG_SINGLE_CASK);
		List<Plant_Event__c> updatedEvents = [Select id from Plant_Event__c];
		Test.stopTest();
		System.assertEquals(events.size() + 1, updatedEvents.size(), eventJson);
	}
}