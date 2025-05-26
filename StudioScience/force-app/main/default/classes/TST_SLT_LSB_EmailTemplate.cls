@isTest(seeAllData = false)
public class TST_SLT_LSB_EmailTemplate {
    @testSetup
    static void dataSetup() {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Test';
        validEmailTemplate.DeveloperName = 'TestTemplate';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        insert validEmailTemplate;
    }
	@isTest
    public static void testGetEmailTemplateList() {
        EmailTemplate testEmailTemplate = [SELECT Id, DeveloperName 
                                           from EmailTemplate 
                                           WHERE DeveloperName = 'TestTemplate'];
        test.startTest();
            List<EmailTemplate> recordEmailTemplates = SLT_LSB_EmailTemplate.getEmailTemplateList(testEmailTemplate.DeveloperName);
        test.stopTest();
        System.assertEquals(false, recordEmailTemplates == null, 'Email Template is Fetched');
    }
}