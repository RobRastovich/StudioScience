public class LegalContractFormCmpCtrl {
    
 // On loading of the page getlegalContract Questionset
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getApplicationQuestionData() {
    	Boolean success = true;
		String message = null;
        Id legalRecordTypeId = Schema.SObjectType.Application_Question__c.getRecordTypeInfosByName()
                  .get('Legal Contract').getRecordTypeId();
        //holds all legal contract questions 
    	Map<String, Object> responseMap = new Map<String, Object>();
        List<Application_Question_Set__c> appQuestionSet = new List<Application_Question_Set__c>();
        set<string> orderedSection = new set<string>{};

        try{
            appQuestionSet = [select id, name, Brand__c from Application_Question_Set__c where Name = 'Legal' limit 1];
            List<Application_Question__c> appQuestions = [select Id,Question__c,Order__c,Type__c,Question_section__c,RecordTypeId,Help_Text__c,Active__c,Required__c from Application_Question__c where RecordTypeId=:legalRecordTypeId and Application_Question_Set__r.Brand__c = '' order by Order__c asc];
            //responseMap.put('appQuestionSet', appQuestionSet);
            //List<Application_Question__c> appsectionQuestions = [select Id,Question__c,Order__c,Type__c,Question_section__c,Required__c from Application_Question__c where RecordTypeId=:legalRecordTypeId and Application_Question_Set__r.Brand__c = '' order by Order__c asc];
            
            Map<String,List<Application_Question__c>> SectiontoQuestionMap  = new map<String,List<Application_Question__c>>();
            integer q = 0;
            for(Application_Question__c aq: appQuestions){
                System.debug('AppQuestions:::' + aq);
                orderedSection.add(aq.Question_section__c);
                System.debug('orderedSection:::' + orderedSection);                
                	if(SectiontoQuestionMap.containsKey(aq.Question_section__c))
                    SectiontoQuestionMap.get(aq.Question_section__c).add(aq);
                	else
                    SectiontoQuestionMap.put(aq.Question_section__c, new List<Application_Question__c>{aq});                
            }
            System.debug('sectionToQuestionMap'+ SectiontoQuestionMap);
            responseMap.put('SectiontoQuestionMap', SectiontoQuestionMap);
            responseMap.put('orderedSection', orderedSection);
            responseMap.put('appQuestions', appQuestions);
            responseMap.put('questionSetId', appQuestionSet[0].Id);
			            
        } catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage() + ' \n ' + e.getStackTraceString();
			success = false;

		}
		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;        
    }
    // Update Legal Contract Form
    @AuraEnabled
	public static LightningComponentUtility.RequestStatus updateLegalContractForm(String questionMap, String jsonApplications) {
		Boolean success = true;
        String message = null;
        System.debug(jsonApplications);
        // Update legal responses
        Legal_Contract_Form__c app = new Legal_Contract_Form__c();
		System.debug(jsonApplications);
		List<Legal_Contract_Form__c> applications = (List<Legal_Contract_Form__c>)System.JSON.deserialize(jsonApplications, List<Legal_Contract_Form__c>.Class);
	    app = applications[0];
        System.debug('app00000000001'+ app);
        Map<Id, String> legalFormID = new Map<Id, String>();
        List<Legal_Response__c> responses = (List<Legal_Response__c>)System.JSON.deserialize(questionMap, List<Legal_Response__c>.Class);
	    List<Legal_Response__c> updateResponsesList = new List<Legal_Response__c>();
        List<Legal_Response__c> createResponsesList =  new List<Legal_Response__c>();
        System.debug('App : LegalResponses22222'+responses);
        for (Legal_Response__c ar : responses) {            
            if(ar.id !=null){  
                Legal_Response__c updateResponses = new Legal_Response__c();
                updateResponses.Id = ar.id;
                updateResponses.Answer_Text__c = ar.Answer_Text__c;                
                legalFormID.put(ar.Legal_Contract_Form__c, ar.Application_Question__c);
                updateResponsesList.add(updateResponses);
            }
            else{
                Legal_Response__c insertResponses = new Legal_Response__c(Answer_Text__c = ar.Answer_Text__c,Legal_Contract_Form__c = ar.Legal_Contract_Form__c,Application_Question__c = ar.Application_Question__c);
                //createResponsesList.add(insertResponses);
                updateResponsesList.add(insertResponses);
            }
	    }  
        if(updateResponsesList.size() > 0){
	    	upsert updateResponsesList;
        }
        
        //if(createResponsesList.size() > 0){
	    	//insert createResponsesList;
        //}
        
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('LegalId', jsonApplications);
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
    }
    // Insert new Legal Contract Form
    @AuraEnabled
	public static LightningComponentUtility.RequestStatus insertLegalContractForm(String questionMap, String jsonApplications) {
		Boolean success = true;
		String message = null;             
		Map<String, Object> responseMap = new Map<String, Object>();
		Legal_Contract_Form__c app = new Legal_Contract_Form__c();
        System.debug('---questionMap---'+questionMap);
		System.debug('---jsonApplications---'+jsonApplications);
        List<Application_Question_Set__c> appQuestionSet1 = new List<Application_Question_Set__c>();
		appQuestionSet1 = [select id, name, Brand__c from Application_Question_Set__c where Name = 'Legal' limit 1];
        
		try {			
			// build legal contract form 
			List<Legal_Contract_Form__c> applications = (List<Legal_Contract_Form__c>)System.JSON.deserialize(jsonApplications, List<Legal_Contract_Form__c>.Class);
			app = applications[0];
			app.Name = 'Legal Contract Form'+ ' - ' + System.now();
			app.Status__c = 'New';
			app.Submitter__c = UserInfo.getUserId();
            app.Application_Question_Set__c = appQuestionSet1[0].Id; 
            Boolean checkRequired = true;
			insert app;

			// create legal responses
			List<Legal_Response__c> responses = (List<Legal_Response__c>)System.JSON.deserialize(questionMap, List<Legal_Response__c>.Class);
			for (Legal_Response__c ar : responses) {
				ar.Legal_Contract_Form__c = app.Id;				
			}
            /*if(checkRequired){
                success = false;
                message = 'Please make sure that the required fields are not blank!';
                LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
                System.debug(LoggingLevel.INFO, requestStatus);
                return requestStatus;                
            }*/
            
			
            insert responses;

			// update account application to kick of approval process
			app.Status__c = 'Pending Approval';

			update app;

			responseMap.put('accountApplication', app);
			responseMap.put('questionMap', questionMap);
		} catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage() + ' \n ' + e.getStackTraceString();
			success = false;

		}

		LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
		System.debug(LoggingLevel.INFO, requestStatus);
		return requestStatus;
	}
    @auraEnabled
    public static List<Legal_Contract_Form__c> getAlllegalcontracts()
    {
     List<Legal_Contract_Form__c> reg=new LIST<Legal_Contract_Form__c>();  
        reg=[Select id,name,Status__c,submitter__c,createdDate from Legal_Contract_Form__c where submitter__c=:userinfo.getuserid() and Status__c='Pending Approval' order by createdDate DESC limit 10];
        return reg;
    }
    @auraEnabled
    public static LightningComponentUtility.RequestStatus getSelectedlegalForms(String LegalId)
    { 
      Boolean success = true;
	  String message = null;   
      Map<String, Object> responseAnswerMap = new Map<String, Object>();
      Map<String, String> questionAnswerMap = new Map<String, String>();
      Map<String, String> answerResponseMap = new Map<String, String>();
      Map<String, String> legalFormMap = new Map<String, String>();
        
      System.debug('LegalId:'+ LegalId);
      try {
          Legal_Contract_Form__c reg=[select id,name,Status__c from Legal_Contract_Form__c where id=:LegalId];
          List<Legal_Response__c> appResponses = [Select Id, Legal_Contract_Form__c, Application_Question__c,Answer_Text__c,Question_Text__c from Legal_Response__c where Legal_Contract_Form__c=:LegalId]; 
          for(Legal_Response__c resp : appResponses){
              answerResponseMap.put(resp.Application_Question__c, resp.Id);
              questionAnswerMap.put(resp.Application_Question__c, resp.Answer_Text__c);
              legalFormMap.put(resp.Application_Question__c,resp.Legal_Contract_Form__c);
          }              
          responseAnswerMap.put('LegalContractForm', appResponses);
          responseAnswerMap.put('LegalResponses', questionAnswerMap);
          responseAnswerMap.put('LegalResponsesIds', answerResponseMap);
          responseAnswerMap.put('LegalContractFormIds', legalFormMap);
      }
      catch (Exception e) {
			System.debug(LoggingLevel.INFO, e.getMessage());
			message = e.getMessage() + ' \n ' + e.getStackTraceString();
			success = false;
	  }
      LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseAnswerMap);
      System.debug(LoggingLevel.INFO, requestStatus);
      return requestStatus;  
    }
}