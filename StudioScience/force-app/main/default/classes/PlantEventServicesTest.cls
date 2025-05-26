@isTest
private class PlantEventServicesTest {
    
    @future
    public static void insertUser()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com', Regional_Diplomat_Regions__c = 'Illinois;Indiana',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        insert u;
    }
    
    @testSetup static void setup() {
        Id userId = [SELECT Id FROM USER LIMIT 1].Id;
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert testAccount;
        
        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.Type__c = 'Trip and Tour';
        
        Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
        bg2.Type__c = 'Trip and Tour';
        
        insert new List<Barrel_Order_Group__c> {bg, bg2};
            
        Plant_Event__c event = new Plant_Event__c();
        event.Scheduled_Date__c = Date.today();
        event.Time_of_Day__c = 'AM';
        insert event;
        
        
        Case c = new Case();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c.Type = 'Trip and Tour';
        c.Plant_Event__c = event.Id;
        c.Barrel_Order_Group__c = bg.Id;
        c.Brand__c = 'Knob Creek';
        c.Product_Type__c = 'Bourbon';
        c.ccEmail__c = 'test@test.com';
        c.AccountId = testAccount.Id;
        
        Case c2 = new Case();
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c2.Type = 'Trip and Tour';
        c2.Barrel_Order_Group__c = bg2.Id;
        c2.Brand__c = 'Makers Mark';
        c2.AccountId = testAccount.Id;
        

            
        Case demoCase = new Case();
        insert new List<Case> {c, c2, demoCase};
        
        Date d = System.Today().addDays(200);
        Plant_Event__c plantEvent = (new Plant_event__c(Scheduled_Date__c = d));
        plantEvent.ownerId = userId;
        plantEvent.Time_Slot__c = null;
        plantEvent.Brand__C = 'Knob Creek';
        plantEvent.Case__c = demoCase.Id;
        insert plantEvent;
        
        List<Time_Interval__c> intervals =  new List<Time_Interval__c>();
        Time_Interval__c interval = new Time_Interval__c();
        interval.Start_Date__c = Date.newInstance(2022, 08, 10);
        interval.End_Date__c = Date.newInstance(2022, 08, 20);
        interval.Max_Number_of_Groups__c = 3;
        interval.Trip_Group__c = 3;
        interval.Trips_Booked__c = 2;
        interval.Brand__c = 'Laphroaig Single Cask';
        interval.isActive__c = true;
        interval.Type__c = 'Season Program Length';
        intervals.add(interval);
        if(!intervals.isEmpty()){
            insert intervals;
        }

        List<Plant_Event__c> events = new List<Plant_Event__c>();
        Plant_Event__c event1 = new Plant_Event__c();
        event1.Brand__c = 'Laphroaig Single Cask';
        event1.RecordTypeId = SBP_Constants.LAPHROAIG_SINGLE_CASK_EVENT_RT_ID;
        event1.Time_of_Day__c = 'PM';
        event1.Time_Interval__c = interval.Id;
        events.add(event1);
        if(!events.isEmpty()){
            insert events;
        }
    }
    
    public static Case getCaseById(Id caseId) {
        return [select id from Case where Id = :caseId limit 1];
    }
    
    public static Case getCaseByPlantEventId(Id eventId) {
        return [select id, isTripToday__c from Case where Plant_Event__c = :eventId limit 1];
    }
    
    public static Plant_Event__c getEventByDate(Date dateVal) {
        return [select id, isTripToday__c from Plant_Event__c where Scheduled_Date__c = :dateVal limit 1];
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
    
    public static testMethod void updateRelatedCaseWhenTripIsTodayTest() {
        Plant_Event__c event = getEventByDate(Date.today());
        Case c = getCaseByPlantEventId(event.Id);
        
        System.assertEquals(FALSE, c.isTripToday__c, 'Flag should be set to false');
        
        Test.startTest();
        
        event.isTripToday__c = true;
        update event;
        
        Case updatedCase = getCaseByPlantEventId(event.Id);
        
        Test.stopTest();
        
        System.assertEquals(TRUE, updatedCase.isTripToday__c, 'Plant event should update the related cases');
    }
    
    public static testMethod void restrictDuplicateEntryOfBookingsTest() 
    {
        User plantTeamUser = [Select id from User where User_Type__c = 'Plant Team Member' limit 1];
        Date d = System.Today().addDays(100);
        Plant_Event__c plantEvent = [Select id,Scheduled_Date__c from Plant_Event__c where Brand__C = 'Knob Creek' limit 1];
        plantEvent.Scheduled_Date__c = d;
        Test.startTest();
        System.runAs(plantTeamUser)
        {        
            Database.SaveResult str = database.update(plantEvent , False);        
            System.assert(str.isSuccess() != false);
            Test.stopTest();
        }
        
    }
    /**
    public static testMethod void deleteDateHoldsForPlantTeamTest() 
    {
        User plantTeamUser = [Select id from User where User_Type__c = 'Plant Team Member' limit 1];
        Date d = System.Today().addDays(100);
        Plant_Event__c plantEvent = [Select id,Scheduled_Date__c from Plant_Event__c where Brand__C = 'Makers Mark' limit 1];
        Date d2 = System.Today().addDays(100);
        Plant_Event__c plantEvent2 = (new Plant_event__c(Scheduled_Date__c = d));
        plantEvent2.Time_Slot__c = null;
        plantEvent2.Brand__C = 'Makers Mark';
        insert plantEvent2;
        
        Date d3 = System.Today().addDays(50);
        Plant_Event__c plantEvent3 = (new Plant_event__c(Scheduled_Date__c = d3));
        plantEvent3.Time_Slot__c = null;
        plantEvent3.Brand__C = 'Makers Mark';
        
        plantEvent.Scheduled_Date__c = d2;
        Test.startTest();
        System.runAs(plantTeamUser)
        {        
            Database.SaveResult str = database.update(plantEvent , False);        
            System.assert(str.isSuccess() != false);
            Database.SaveResult strInsert = database.insert(plantEvent3 , False);
            System.assert(strInsert.isSuccess() != false);
            Test.stopTest();
        }
    }
    */
    //LSB-139
    @isTest
    public static void testUpdateTrippedBookedWhenPlantEventDelete(){
         Plant_Event__c event = [SELECT Id 
                                   FROM Plant_Event__c 
                                   WHERE Time_of_Day__c = 'PM'
                                   LIMIT 1];
    
        Test.startTest();
            delete event;
        Test.stopTest();
        Time_Interval__c interval = [SELECT Id, Trips_Booked__c
                                        FROM Time_Interval__c 
                                        WHERE Brand__c = 'Laphroaig Single Cask'
                                        LIMIT 1]; 
        
        System.assertEquals(interval.Trips_Booked__c, 1, 'Trip booked not updated'); 
    } 
}