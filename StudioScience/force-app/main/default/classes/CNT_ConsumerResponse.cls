public without sharing class CNT_ConsumerResponse {
    public String caseIdAttribute;
    public String emailContent;
    public String contactNameAttribute{get; set;} 
    
    /*Constructor of the class*/
    public CNT_ConsumerResponse() {}
	
    public void setCaseIdAttribute(String caseRecordValue) {
        this.caseIdAttribute = caseRecordValue;
        this.setEmailContent(this.caseIdAttribute);
    }
    
    public String getCaseIdAttribute() {
        return caseIdAttribute;
    }
    
    public void setEmailContent(String caseIdAttribute) {
        if(String.isNotBlank(caseIdAttribute)){
            Map<String, String> mapOfDynamicFieldWithApiname = new Map<String, String>();
            List<Consumer_Response_Dynamic_Field__mdt> responseDynamicFields = SLT_CustomMetadata.getResponseDynamicFields();
            for(Consumer_Response_Dynamic_Field__mdt recordCRDF : responseDynamicFields){
                mapOfDynamicFieldWithApiname.put(recordCRDF.Field_Apiname__c, 
                                                 recordCRDF.Field_in_Email_Content__c);
            } 
            Case caseRecord = CRM_SLT_Case.getCasesOwnerName(caseIdAttribute, mapOfDynamicFieldWithApiname.keyset());
            if(String.isNotBlank(caseRecord.ID)){
                Consumer_Response__c response;
                response = SLT_Consumer_Response.getConsumerResponseRecord(caseRecord);
                if(String.isNotBlank(response.Id)){
                    String content = CNT_ConsumerResponse.replacePatternStringWithValue(caseRecord, 
                                                                                        response.Email_Content__c,
                                                                                        mapOfDynamicFieldWithApiname);
                    content = content.replaceAll('<br>', '');
                    content = content.replaceAll('</p><p>', '<br/>');
                    content = content.replace('[NAME]', String.isNotBlank(contactNameAttribute) ? contactNameAttribute : ' ');
                    content = content.replace('{description}', String.isNotBlank(caseRecord.Description) ? caseRecord.Description : ' ');
                    this.emailContent = content;  
                } 
            }
        }
    }
    
    public String getEmailContent() {
        return this.emailContent;
    }    
    
    public static String replacePatternStringWithValue(Case caseRecord, String emailContent,
                                                       	   Map<String, String> mapDynamicFields){
        String content = emailContent;
        for(String field : mapDynamicFields.keyset()){
            String value = String.valueOf(caseRecord.get(field));          
            if(String.isNotBlank(value)){
                content = content.replace('{'+mapDynamicFields.get(field)+'}', String.valueOf(caseRecord.get(field))); 
            }
        }                                           
        return content;
    }
}