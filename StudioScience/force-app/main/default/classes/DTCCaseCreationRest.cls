@RestResource(urlMapping='/Cases/*')
global with sharing class DTCCaseCreationRest {
    @HttpPost
    global static void createCase() {
        RestContext.response = DTCCaseCreationRestHandler.createCase();
    }
    @HttpPatch
    global static void updateCase() {
        RestContext.response = DTCCaseCreationRestHandler.updateCase();
    }
}