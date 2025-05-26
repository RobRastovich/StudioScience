public class DTC_CaseUpdateTrackingNumberRestHandler {
    public static RestResponse updateCaseTrackingNumber(){
        ResponseWrapper responseWrapper;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        try{
            Map<String, Object> mapOfUpdateTrackingNumberJSON = new Map<String, Object>();
            Case caseStoreRecord;
            Boolean isCaseDetailValidated = true;
            DTC_CaseAvataxBraintreeSAPJSON caseAvataxBraintreeSapObj;
            String jsonBody = request.requestBody.toString();
            if(jsonBody != null)
                mapOfUpdateTrackingNumberJSON = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            if(mapOfUpdateTrackingNumberJSON != null){
                String validationMessageCase = validateCaseDetails(mapOfUpdateTrackingNumberJSON, 
                                                                    DTC_Constants.CASE_REQUIRED_FIELDS_UPDATE_TRACKING_NUMBER);
                if (String.isNotBlank(validationMessageCase)) {
                    responseWrapper = new ResponseWrapper(DTC_Constants.VALIDATION_FAILS, DTC_Constants.REQUIRED_FIELD_MISSING, 
                                                            validationMessageCase, caseStoreRecord);
                    response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                    isCaseDetailValidated = false;
                    return response;
                } 
                if(isCaseDetailValidated){
                    if(String.isNotBlank(String.valueof(mapOfUpdateTrackingNumberJSON.get('orderId'))) &&
                      String.isNotBlank(String.valueof(mapOfUpdateTrackingNumberJSON.get('trackingNumber')))){
                        caseStoreRecord = SLT_DTC_Case.getCaseRecordByOrderID(
                                                        String.valueof(mapOfUpdateTrackingNumberJSON.get('orderId')));
                        if(caseStoreRecord == null){
                            responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, 
                                                                    DTC_Constants.INVALID_REQUEST, 
                                                                    DTC_Constants.RECORD_NOT_FOUND_AGAINST_ORDERID, null);
                            response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                            return response;
                        }
                    }else if(String.isBlank(String.valueof(mapOfUpdateTrackingNumberJSON.get('orderId')))){
                        responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                DTC_Constants.MISSING_ORDERID, null);
                        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                        return response;
                    }else if(String.isBlank(String.valueof(mapOfUpdateTrackingNumberJSON.get('trackingNumber')))){
                        responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                DTC_Constants.MISSING_TRACKING_NUMBER, null);
                        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                        return response;
                    }
                    if(caseStoreRecord != null){
                        caseStoreRecord = SRV_DTC_Case.updateCaseTrackingNumber(caseStoreRecord, mapOfUpdateTrackingNumberJSON);
                        responseWrapper = new ResponseWrapper(DTC_Constants.SUCCESS, null, 
                                                                DTC_Constants.RECORD_UPDATED_SUCCESSFULLY, caseStoreRecord);
                    }
                }
            }
        }
        catch(Exception e){
            responseWrapper = new ResponseWrapper(DTC_Constants.FAILURE, 'Error', e.getMessage(), null);
        }
        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
        return response;
    }
    
    @testVisible
    private static String validateCaseDetails(Map<String, object> mapOfCaseDetail, Set<String> requiredFields) {
        Set<String> setOfFieldAPINames = requiredFields;
        String fieldLabels = '';
        Boolean ifValidationFails = false;
        for(String fieldName: setOfFieldAPINames) {
            if(mapOfCaseDetail.get(fieldName) == null || mapOfCaseDetail.get(fieldName) == false) {
                String labelName = fieldname;
                if(!String.isBlank(labelName)) {
                    fieldLabels += labelName + ', ';
                }
                ifValidationFails = true;
            }
        }
        if(ifValidationFails){
            return appendFieldLabel(fieldLabels);
        }
        return null;
    }
    
    @testVisible
    private static String appendFieldLabel(String fieldLabels) { 
        fieldLabels = fieldLabels.removeEnd(', ');
        if (fieldLabels.countMatches(',')>1) {
            fieldLabels = DTC_Constants.REQUIRED_FIELDS_ARE_MISSING + fieldLabels;
        } else {
            fieldLabels = DTC_Constants.REQUIRED_FIELD_IS_MISSING + fieldLabels;
        }
        return fieldLabels;
    }
}