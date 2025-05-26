public with sharing class ShipmentRequestHandler {
    public ShipmentRequestHandler() { }
    public class TrackingNumberInfo {
        public String trackingNumber;
    }
    
    public class TrackingInfo {
        public TrackingNumberInfo trackingNumberInfo;
    }
    
    public class RequestBody {
        public List<TrackingInfo> trackingInfo;
        public Boolean includeDetailedScans;
    }
    public static HttpResponse BuildTrackingRequest( String sCarrier, set <String> TrackingNumbers, Boolean includeDetailedScans) {
        HttpResponse sRequest = new HTTPResponse();
        If (TrackingNumbers.size()!=null){
            If (sCarrier == SBP_Constants.SAMPLE_KIT_FEDEXCARRIERNAME) {//move to constant class
                sRequest = BuildTrackingRequestFedEx(TrackingNumbers, includeDetailedScans);
            }
        }
        return sRequest;
    }
    
    public static String getAccessToken() {
        FedExAPISettings__c apiSetting = FedExAPISettings__c.getInstance('FedEx Details'); 
        final String TOKEN_URL = apiSetting.FedEx_Authorization_Endpoint__c; 
        String CLIENT_ID = apiSetting.Client_Id__c;
        String CLIENT_SECRET = apiSetting.Client_Secret__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        } else {
            throw new CalloutException('Failed to get access token: ' + res.getBody());
        }
    }
    
    public static HttpResponse BuildTrackingRequestFedEx(Set<String> trackingNumbers, Boolean includeDetailedScans) {
        String accessToken = getAccessToken();
        FedExAPISettings__c apiSetting = FedExAPISettings__c.getInstance('FedEx Details'); 
        final String TRACKING_URL = apiSetting.FedEx_Endpoint__c;
        RequestBody requestBody = new RequestBody();
        requestBody.trackingInfo = new List<TrackingInfo>();
        
        for (String trackingNumber : trackingNumbers) {
            TrackingInfo info = new TrackingInfo();
            info.trackingNumberInfo = new TrackingNumberInfo();
            info.trackingNumberInfo.trackingNumber = trackingNumber;
            requestBody.trackingInfo.add(info);
        }
        try {
            requestBody.includeDetailedScans = includeDetailedScans;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(TRACKING_URL);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(requestBody));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200) {
                throw new CalloutException('Failed to track packages: ' + res.getBody());
                
            } 
            return res;
        } catch(Exception e){
            String errorMessage = 'Error establishing connection to FedEx system ' + e.getMessage() + '\n' + e.getStackTraceString();           
            CreateExceptionLog.insertErrorLog('ShipmentDelegate', 'GetShipmentTrackingInfo', String.valueOf(errorMessage), 'Fatal');
            System.debug('errorMessage '+errorMessage);
            return null;
        }
        
    }
    
    public static map<string, ShipmentResponseWrapper > ProcessTrackingResponse( String sCarrier, HttpResponse res) {
        map <string, ShipmentResponseWrapper> getStatus = new map <string, ShipmentResponseWrapper>();
        If (res!=null){
            If (sCarrier == SBP_Constants.SAMPLE_KIT_FEDEXCARRIERNAME) {
                system.debug('res.getbody() in response');
                system.debug(res.getbody());
                getStatus = FedExResponseHandler.parseFedExTrackingResponse(res.getbody());
            }
        }
        return getStatus;
    }
    public class ShipmentCustomException extends Exception{}
}