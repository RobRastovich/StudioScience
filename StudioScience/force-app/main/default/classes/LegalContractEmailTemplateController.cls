public class LegalContractEmailTemplateController {
    public Id legalContractFormId{get;set;}
    
    public List<Legal_Response__c> getLegalResponse(){
        List<Legal_Response__c> legalResponseList;
        legalResponseList = [Select Id, Answer_Text__c, Application_Question__r.Question__c, Question_Text__c From Legal_Response__c Where Legal_Contract_Form__c =: legalContractFormId Order By Order__c ASC];
    	return legalResponseList;
    }

}