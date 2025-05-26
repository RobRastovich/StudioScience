public class TI_SAP_API_Delegate {
    public class SAPException extends Exception {}
    public static String fetchData(String sapNumber) {
        StoredCredentials__c sap;
        if( Global_Utility.isProd()){
            sap = StoredCredentials__c.getInstance('TI_SAP_ShipmentNumber_PROD');
        }       
        else{ 
            sap = StoredCredentials__c.getInstance('TI_SAP_ShipmentNumber_QA');            
        }
        return callAPI(sap, sapNumber);
    }
    public static String fetchTrackingNumber(String shipmentNumber) {
        StoredCredentials__c sap;
        if( Global_Utility.isProd()){
            sap = StoredCredentials__c.getInstance('TI_SAP_TrackingNumber_PROD');
        }       
        else{ 
            sap = StoredCredentials__c.getInstance('TI_SAP_TrackingNumber_QA');            
        }
        return callAPI(sap, shipmentNumber);
    }
    public static String callAPI(StoredCredentials__c sap, String apiKeyToBeCalled) {
        String username = sap.Username__c;
        String password = sap.Password__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        String url = sap.Full_Endpoint__c + apiKeyToBeCalled + sap.Full_Endpoint_2__c;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(url);
        req.setMethod('GET');
        try{
            Http http = new Http();
            HttpResponse res = http.send(req);
                if(String.isNotBlank(res.getBody()) && res.getStatusCode() == 200){
                    return res.getBody();
                } else if(res.getStatusCode() == 200) {
                    return '';
                } else {
                    Throw new SAPException('API Call Failed');
                }
        } catch(Exception e) {
            Throw e;
        }
    }
}