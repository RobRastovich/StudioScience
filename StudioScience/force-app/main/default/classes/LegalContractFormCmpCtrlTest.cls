@isTest(seealldata=false)
Private class LegalContractFormCmpCtrlTest {
    @testSetup static void setup() {
        Id legalRecordTypeId = Schema.SObjectType.Application_Question__c.getRecordTypeInfosByName().get('Legal Contract').getRecordTypeId();
        Application_Question_Set__c aqs = new Application_Question_Set__c(Name='Legal',Brand__c = null);
        insert aqs;
        
        List<Application_Question__c> laq = new List<Application_Question__c>();
        Application_Question__c aq1 = new Application_Question__c(Application_Question_Set__c = aqs.Id, Type__c = 'Text', Question__c = 'Test Question 1', Required__c = true, Question_Section__c = 'Test Section 1',RecordTypeId=legalRecordTypeId);
        Application_Question__c aq2 = new Application_Question__c(Application_Question_Set__c = aqs.Id, Type__c = 'Date Range', Question__c = 'Test Question 2', Required__c = true, Question_Section__c = 'Test Section 1',RecordTypeId=legalRecordTypeId);
        //Application_Question__c aq3 = new Application_Question__c(Application_Question_Set__c = aqs.Id, Type__c = 'Text', Question__c = 'Test Question 3', Required__c = true, Question_Section__c = 'Test Section 2',RecordTypeId=legalRecordTypeId);
        insert new List<Application_Question__c> {aq1, aq2};
            
        Legal_Contract_Form__c lrf = new Legal_Contract_Form__c(Name= 'Test_Legal', Application_Question_Set__c = aqs.Id, Status__c = 'New');
        insert lrf;
        
        Legal_Response__c l1r1 = new Legal_Response__c(Legal_Contract_Form__c = lrf.Id, Answer_Text__c = 'Test Answer 1', Application_Question__c = aq1.Id);
        Legal_Response__c l2r2 = new Legal_Response__c(Legal_Contract_Form__c = lrf.Id, Answer_Text__c = '05/05/2006', Application_Question__c = aq2.Id);
        insert new List<Legal_Response__c>{l1r1,l2r2};
        
    }
    
    public static List<Application_Question__c> getQuestions() {
		return [select id from Application_Question__c where Application_Question_Set__r.Name = 'Legal'];
	}
    
    public static Application_Question_Set__c getApplicationQuestionSet(String questionSetName) {
		return [select id from Application_Question_Set__c where Name = :questionSetName limit 1];
	}
    
    public static testMethod void getApplicationQuestion_Test() {
        test.startTest();
        LegalContractFormCmpCtrl lc = new LegalContractFormCmpCtrl();
        LightningComponentUtility.RequestStatus lr = LegalContractFormCmpCtrl.getApplicationQuestionData();
        test.stopTest();    
    }
    
    public static testMethod void getSelectedlegalForms_Test() {
        test.startTest();
        Legal_Contract_Form__c lrf = [Select Id, Name From Legal_Contract_Form__c Where Name = 'Test_Legal'];
        LightningComponentUtility.RequestStatus lr = LegalContractFormCmpCtrl.getSelectedlegalForms(lrf.Id);
        test.stopTest();    
    }
    
    public static testMethod void getAllLegalContractForm_Test(){
       List<Legal_Contract_Form__c> lcf = LegalContractFormCmpCtrl.getAlllegalcontracts();
    }
    
    public static testMethod void updateLegalContractForm_Test(){
        Id legalRecordTypeId = Schema.SObjectType.Application_Question__c.getRecordTypeInfosByName().get('Legal Contract').getRecordTypeId();
        Legal_Contract_Form__c lcf = [Select Id, Name, Application_Question_Set__r.Id,Application_Question_Set__c From Legal_Contract_Form__c Where Application_Question_Set__r.Name = 'Legal' limit 1];
     
        List<Legal_Response__c> llr = [Select Id, Application_Question__c, Answer_Text__c, Legal_Contract_Form__c From Legal_Response__c Where Legal_Contract_Form__c =: lcf.Id];
        
        Application_Question__c aq3 = new Application_Question__c(Application_Question_Set__c = lcf.Application_Question_Set__r.Id, Type__c = 'Text', Question__c = 'Test Question 3', Required__c = true, Question_Section__c = 'Test Section 2',RecordTypeId=legalRecordTypeId);
        insert aq3;
        
        String questionResponse = '[{'
		                          + '    "Application_Question__c": "' + llr[0].Application_Question__c + '",'
            					  + '	 "Id": "' + llr[0].Id + '",'
		                          + '    "Answer_Text__c": "No"'
		                          + '}, {'
		                          + '    "Application_Question__c": "' + llr[1].Application_Question__c + '",'
            					  + '	 "Id": "' + llr[1].Id + '",'
		                          + '    "Answer_Text__c": "No"'
		                          + '}, {'
		                          + '    "Application_Question__c": "' + aq3.Id + '",'            					 
		                          + '    "Answer_Text__c": "Yes"'
		                          + '}]';

		String jsonApplications = '[{'
            					+' " Legal_Contract_Form__c":"' + lcf.Id + '"'
            					+'}]';   
        Test.startTest();
       
		LightningComponentUtility.RequestStatus response = LegalContractFormCmpCtrl.updateLegalContractForm(questionResponse, jsonApplications);

        Test.stopTest(); 
        System.assertEquals(true, response.success, 'Operation Success');
    }
    
    public static testMethod void insertLegalContractFormLegalTeam_Test() {
        
        List<Application_Question__c> laq = getQuestions();
        Application_Question_Set__c aqs = getApplicationQuestionSet('Legal');
        String questionResponse = '[{'
		                          + '    "Application_Question__c": "' + laq[0].Id + '",'
		                          + '    "Answer_Text__c": "No"'
		                          + '}, {'
		                          + '    "Application_Question__c": "' + laq[1].Id + '",'
		                          + '    "Answer_Text__c": "Yes"'
		                          + '}]';

		String jsonApplications = '[{'
            					+' "Application_Question_Set__c":"' + aqs.Id + '"'
            					+'}]';    
        
        Test.startTest();
       
		LightningComponentUtility.RequestStatus response = LegalContractFormCmpCtrl.insertLegalContractForm(questionResponse, jsonApplications);

        Test.stopTest();
        System.assertEquals(true, response.success, 'Operation Success');
    }
    public static testmethod void emailTemplateMethod(){
        Legal_Contract_Form__c lrf = [Select Id, Name From Legal_Contract_Form__c Where Name = 'Test_Legal' Limit 1];
        LegalContractEmailTemplateController objLegalClass = new LegalContractEmailTemplateController();
        objLegalClass.legalContractFormId = lrf.Id;
        System.assertEquals(objLegalClass.getLegalResponse().size(), 2);
    }
}