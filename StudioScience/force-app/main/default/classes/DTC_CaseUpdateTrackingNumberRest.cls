@RestResource(urlMapping='/casesUpdateTrackingNumber/*')
global class DTC_CaseUpdateTrackingNumberRest {
    @HttpPatch
    global static void updateCase() {
        RestContext.response = DTC_CaseUpdateTrackingNumberRestHandler.updateCaseTrackingNumber();
    }
}