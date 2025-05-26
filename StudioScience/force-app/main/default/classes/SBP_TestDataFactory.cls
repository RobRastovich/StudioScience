public class SBP_TestDataFactory {
    public static Case createCase(Id recordTypeId, Boolean isInsert) {
        Case newcase = new Case();
        newcase.Status = 'Pending Selection';
        newcase.First_name__c = 'test';
        newcase.Last_name__c = 'customer 1';
        newcase.Email_Address__c = 'test@example.com';
        newcase.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        newcase.STO_Number__c = '1234567899';
        newcase.STO_Created__c = false;
        newcase.Type = SBP_Constants.TRIP_AND_TOUR;
        newcase.SAP_Number__c = '123456';
        if(recordTypeId == null){
            newcase.RecordTypeId = SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID;
        } else {
            newcase.RecordTypeId = recordTypeId;
        }
        if(isInsert){
            insert newcase;
        }
        return newcase;
    }

    public static Account createAccount(Id recordTypeId, Boolean isInsert) {
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'paccount';
        if (recordTypeId != null) {
            acc.RecordTypeId = recordTypeId;
        }
        if(isInsert) {
            insert acc;
        }
        return acc;
    }

    public static Contact createContact(Id recordTypeId, Boolean isInsert) {
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.Email = 'test@example.com';
        con.MagentoID__c = 'test123';
        if (recordTypeId != null) {
            con.RecordTypeId = recordTypeId;
        }
        if(isInsert) {
            insert con;
        }
        return con;
    }
    
    public static Plant_Event__c createPlantEvent(Id recordTypeId, Id caseId, Boolean isInsert) {
        Plant_Event__c plantEvent = new Plant_Event__c();
		plantEvent.Scheduled_Date__c = Date.today();
		plantEvent.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        plantEvent.Case__c = caseId;
        if (recordTypeId == null) {
            plantEvent.RecordTypeId = SBP_Constants.LAPHROAIG_SINGLE_CASK_EVENT_RT_ID;
        } else {
            plantEvent.RecordTypeId = recordTypeId;
        }
        if(isInsert) {
            insert plantEvent;
        }
        return plantEvent;
    }
    
    public static Attendee__c createAttendee(Id plantEventId, Boolean isInsert) {
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
        attendee.Inbound_Arrival_City__c = 'Test City';
        attendee.Outbound_Departure_City__c = 'Test City';
        attendee.Plant_Event__c = plantEventId;
        if(isInsert) {
            insert attendee;
        }
        return attendee;
    }

    public static Account_Application__c createAccountApplication(Application_Question_Set__c questionsSet, Account accnt,
        Boolean isInsert) {
        Account_Application__c application = new Account_Application__c();
		application.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
		application.Status__c = 'New';
		application.Regional_Diplomat__c = null;
		application.Case__c = null;
		application.Application_Question_Set__c = questionsSet.Id;
		application.Account__c = accnt.Id;
		application.Submitter__c = UserInfo.getUserId();
        application.Heritage_Manager__c = UserInfo.getUserId();
        application.Diplomat_Partner_for_Your_Barrel__c = UserInfo.getUserId();
        if(isInsert) {
            insert application;
        }
        return application;
    }

    public static Application_Question_Set__c createApplicationQuestionSet(Boolean isInsert) {
        Application_Question_Set__c questionSet = new Application_Question_Set__c();
		questionSet.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
		questionSet.Name = 'LSC';
        if(isInsert) {
            insert questionSet;
        }
        return questionSet;
    }

    public static Barrel__c createBarrel(Id recordTypeId, case cases, Boolean isInsert) {
        Barrel__c barrel = new Barrel__c();
		barrel.Brand__c = SBP_Constants.LAPHROAIG_SINGLE_CASK;
        barrel.Case__c = cases.Id;
        barrel.SKU__c = 'Test Barrel';
        barrel.Quantity__c = 1;
        barrel.Proof__c = 1;
        barrel.Barrel_Proof__c = 1;
        barrel.Bottling_Date__c = System.today();
        if (recordTypeId != null) {
            barrel.RecordTypeId = recordTypeId;
        } else {
            barrel.RecordTypeId = SBP_Constants.LAPHROAIG_SINGLE_CASK_FULL_BARREL_RT_ID;
        }
        if(isInsert) {
            insert barrel;
        }
        return barrel;
    }
}