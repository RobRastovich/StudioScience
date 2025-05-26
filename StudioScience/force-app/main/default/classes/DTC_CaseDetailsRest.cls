@RestResource(urlMapping='/retrieveCasedetails/*')
global class DTC_CaseDetailsRest {
    @HttpGet
    global static void getCaseDetails() {
        RestContext.response = DTC_CaseDetailsRestHandler.getCaseDetails();
       
    }
}