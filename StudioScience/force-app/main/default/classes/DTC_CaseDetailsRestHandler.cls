public class DTC_CaseDetailsRestHandler {
    public static RestResponse getCaseDetails(){
        DTC_CaseDetailsResponseWrapper responseWrapper;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        try{
            Map<String, Object> mapOfCaseDetailsJSON = ((Map<String, Object>) request.params);
            List<Case> returnCaseDetails = new List<Case>();
            Boolean isCaseDetailValidated = true;
            if(mapOfCaseDetailsJSON != null){
                String validationMessageCase = validateCaseDetails(mapOfCaseDetailsJSON, 
                    DTC_Constants.CASE_REQUIRED_FIELDS_GET_CASE_DETAILS);
                if (String.isNotBlank(validationMessageCase)) {
                    responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.VALIDATION_FAILS,
                    DTC_Constants.REQUIRED_FIELD_MISSING, validationMessageCase, null);
                    response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                    isCaseDetailValidated = false;
                    return response;
                }
                if(isCaseDetailValidated){
                    if(String.isNotBlank(String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.EMAIL))) &&
                      String.isNotBlank(String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.BRAND)))){
                        Boolean isEmailValidated  = validateEmail(String.valueof(
                                                            mapOfCaseDetailsJSON.get(DTC_Constants.EMAIL)));
                        if (!isEmailValidated) {
                                responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.VALIDATION_FAILS, 
                                                            DTC_Constants.INCORRECT_EMAIL_FORMAT, validationMessageCase, 
                                                            null);
                                response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                                return response;
                        }
                        returnCaseDetails = SLT_DTC_Case.getCaseRecordsToEmailAndBrand(
                                                String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.ORDER_ID)), 
                                                String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.EMAIL)),
                                                String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.BRAND)));
                        if(returnCaseDetails.size() > 0 && !returnCaseDetails.isEmpty()){
                            responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.SUCCESS, 
                                                                    null, 
                                                                    DTC_Constants.RETURN_CASE_SUCCESSFULLY, 
                                                                    returnCaseDetails);
                            response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                            return response;
                        }
                        else{
                            responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.FAILURE, 
                                                                    DTC_Constants.INVALID_REQUEST, 
                                                                    DTC_Constants.RECORD_NOT_FOUND_CASE_DETAILS, null);
                            response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                            return response;
                        }
                    }else if(String.isBlank(String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.EMAIL)))){
                        responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                DTC_Constants.MISSING_EMAIL, null);
                        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                        return response;
                    }else if(String.isBlank(String.valueof(mapOfCaseDetailsJSON.get(DTC_Constants.BRAND)))){
                        responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.FAILURE, DTC_Constants.INVALID_REQUEST, 
                                                                DTC_Constants.MISSING_BRAND, null);
                        response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
                        return response;
                    }
                }
            } 
        }
        catch(Exception e){
            responseWrapper = new DTC_CaseDetailsResponseWrapper(DTC_Constants.FAILURE, 'Error', e.getMessage(), null);
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
    
    @testVisible
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
	}
}