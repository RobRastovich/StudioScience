/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-06-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SatisfactionSurveyLandingControllerTest{
	static testMethod void testRecordSurveyResponseSuccesses(){
		Test.setCurrentPageReference(new PageReference('Page.SatisfactionSurveyLanding'));
		Id GMDMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        
        contact con = new contact(LastName='testCon');
        insert con;
        User submitter = [select id from user where isActive = false limit 1];
        
		List<Case> caseList = new List<Case>();
		Case loggedCaseRating1 = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseRating1);
		Case loggedCaseRating2 = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseRating2);
		Case loggedCaseRating3 = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseRating3);
		Case loggedCaseRating4 = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseRating4);
		Case loggedCaseRating5 = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseRating5);
		insert caseList;
		Test.startTest();
		System.currentPageReference().getParameters().put('id', loggedCaseRating1.Id);
		System.currentPageReference().getParameters().put('rating', '1');
		SatisfactionSurveyLandingController surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
        surveyController.submitReasonOfRating();
		Case ratedCase1 = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseRating1.Id];
		System.assertEquals('1', ratedCase1.Satisfaction_Rating__c);
		System.assertEquals(false, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);

		System.currentPageReference().getParameters().put('id', loggedCaseRating2.Id);
		System.currentPageReference().getParameters().put('rating', '2');
		surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
        surveyController.submitReasonOfRating();
		Case ratedCase2 = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseRating2.Id];
		System.assertEquals('2', ratedCase2.Satisfaction_Rating__c);
		System.assertEquals(false, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);

		System.currentPageReference().getParameters().put('id', loggedCaseRating3.Id);
		System.currentPageReference().getParameters().put('rating', '3');
		surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
        surveyController.submitReasonOfRating();
		Case ratedCase3 = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseRating3.Id];
		System.assertEquals('3', ratedCase3.Satisfaction_Rating__c);
		System.assertEquals(false, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);

		System.currentPageReference().getParameters().put('id', loggedCaseRating4.Id);
		System.currentPageReference().getParameters().put('rating', '4');
		surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
		Case ratedCase4 = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseRating4.Id];
		System.assertEquals('4', ratedCase4.Satisfaction_Rating__c);
		System.assertEquals(false, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);

		System.currentPageReference().getParameters().put('id', loggedCaseRating5.Id);
		System.currentPageReference().getParameters().put('rating', '5');
		surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
		Case ratedCase5 = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseRating5.Id];
		System.assertEquals('5', ratedCase5.Satisfaction_Rating__c);
		System.assertEquals(false, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);
        Test.stopTest();
	}

	static testMethod void testRecordSurveyResponseFailures(){
		Test.setCurrentPageReference(new PageReference('Page.SatisfactionSurveyLanding'));
		Id GMDMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        
        contact con = new contact(LastName='testCon');
        insert con;
        User submitter = [select id from user where isActive = false limit 1];
        
		List<Case> caseList = new List<Case>();
		Case loggedCaseRating6 = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseRating6);
		Case loggedCaseShortId = new Case(Submitter__c = submitter.Id, ContactId = con.Id,RecordTypeId=GMDMRecordTypeId, Subject='Test Case', Category_1__c='Cat1', Category_2__c='Cat2', Status='Logged');
		caseList.add(loggedCaseShortId);
		insert caseList;
		
		//Testing a bad rating value
		System.currentPageReference().getParameters().put('id', loggedCaseRating6.Id);
		System.currentPageReference().getParameters().put('rating', '6');
		SatisfactionSurveyLandingController surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
		Case ratedCase6 = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseRating6.Id];
		System.assertEquals('0', ratedCase6.Satisfaction_Rating__c);
		System.assertEquals(true, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);

		//Testing a bad case id
		System.currentPageReference().getParameters().put('id', '500000000000001');
		System.currentPageReference().getParameters().put('rating', '5');
		surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
		System.assertEquals(true, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);

		//Testing a bad case id, too long/too short/empty
		System.currentPageReference().getParameters().put('id', '500');
		System.currentPageReference().getParameters().put('rating', '5');
		surveyController = new SatisfactionSurveyLandingController();
		surveyController.recordSurveyResponse();
		Case shortIdCase = [SELECT Id, Satisfaction_Rating__c FROM Case WHERE Id =: loggedCaseShortId.Id];
		System.assertEquals('0', shortIdCase.Satisfaction_Rating__c);		
		System.assertEquals(true, surveyController.invalidParam);
		System.assertEquals(true, surveyController.initialised);
	}
}