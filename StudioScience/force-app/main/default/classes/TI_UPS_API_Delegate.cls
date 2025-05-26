public class TI_UPS_API_Delegate {

    public static string fetchTrackingData(String trackingNumber) {
    HttpRequest req = new HttpRequest();
    Carrier_Details__c CS_Obj = Carrier_Details__c.getInstance('TForce');
    req.setEndpoint(CS_Obj.Endpoint__c + trackingNumber);
    req.setMethod('GET');
    req.setHeader('AccessLicenseNumber', CS_Obj.AccessLicenseNumber__c);

    //send the request
    try{
        Http http = new Http();
        HttpResponse res = http.send(req);
        
            if(String.isNotBlank(res.getBody()) && res.getStatusCode() == 200 && res.getBody().contains('activity')){
                return res.getBody();
            } else if(res.getStatusCode() == 200 || res.getStatusCode() == 400) {
                Throw new TI_UPS_APIService.UPSException('Tracking Details not Found');
            } else {
                return null;
            }
    } catch(Exception e) {
        Throw e;
    }
        
    }
    
}