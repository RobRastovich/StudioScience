@isTest(SeeAllData=true)
public class SurveyQuestionResponseAfterInsertTest {
    @isTest static void surveyQuestionResponseAfterInsert() {
        List<SurveyQuestionResponse> surveyQuestionResponses = [SELECT Id, DataType, ResponseValue, InvitationId FROM SurveyQuestionResponse
                                                               WHERE DataType ='Number' AND NumberValue IN (1,2)
                                                               AND SurveyVersion.Name IN ('CS Customer Survey Changes', 'CS Customer Survey Escalated Form')
                                                               LIMIT 1];
        Test.startTest();
        	//System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent yet.');
        	SurveyQuestionResponseAfterInsertAction.surveyQuestionResponseAfterInsert(surveyQuestionResponses);
        	//System.assertEquals(1, Limits.getEmailInvocations(), 'The email to the Survey Submitter should have been sent.');
        Test.stopTest();
   }

}