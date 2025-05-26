public class SBP_Laphroaig_Approval_Email_Controller {
	public static Id recordId{get;set;}
    public static String getURL(){
        String url = System.URL.getSalesforceBaseUrl().getHost();
        if(url.contains('site')){
            url = url.replace('site','salesforce');
        }
        
        return url.contains('beamsuntory') ? 'https://'+url+'/'+recordId : 'https://beamsuntory'+url+'/'+recordId;
    }
    public static String getCaseNumber(){
        Case caseObj = SLT_Case.getCaseByID(recordId);
        if (caseObj != null) {
            return caseObj.CaseNumber;
        }
        return null;
    }
}