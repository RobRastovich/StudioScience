/**************************************************************************************
Apex Class Name     : DTC_MagentoHTTP_Util
Created Date        : 05/2023
Function            : Used to callout external Magento Api GET/POST request.
*************************************************************************************/
public class DTC_MagentoHTTP_Util {
/**************************************************************************************
Method Name         : getorderIdByIncId
Created Date        : 05/2023	Vikash Kumar 	Metacube
Details             : Call the GET method to extract order_id of Magento system by passing Case orderId
*************************************************************************************/
    @future(callout=true)
    public static void getorderIdByIncId(String inc_Id, String ups_Track_Number){
        Magento_setting__c ms = Magento_setting__c.getValues('Default');
        String baseUrl = String.valueOf(ms.BaseUrl__c);
        String orderEndp = String.valueOf(ms.OrderEndpoint__c);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl+orderEndp+inc_id);
        req.setMethod('GET');
        req.setHeader('content-type',String.valueOf(ms.ContentType__c));
        req = DTC_MagentoAuth.signRequest(req,String.valueOf(ms.Consumer_Key__c),String.valueOf(ms.Access_Token__c),
        String.valueOf(ms.Token_Secret__c),String.valueOf(ms.SignatureMethod__c),String.valueOf(ms.OauthVersion__c));
        Http h = new Http();
        HttpResponse resp = new HttpResponse();
        String order_id;
        try{
            resp = h.send(req);
            if(resp.getStatusCode() == 200 && String.isNotBlank(resp.getBody())){
                String input = resp.getBody();
                if(input.contains('order_id')){
                    Map<String,Object> jsonParsed =(Map<String,Object> ) JSON.deserializeUntyped(input);
                    List<Object> v =(List<Object>) jsonParsed.get('items');
                    Map<String, Object> q = (Map<String, Object>) v[0];
                    List<Object> q1 =(List<Object>) q.get('items');
                    Map<String, Object> v1 = (Map<String, Object>) q1[0];
                    order_id = String.valueOf(v1.get('order_id'));
                    getShipmentByOrderId(order_id,  ms, baseUrl, ups_Track_Number);
                }
            }
        }
        catch(Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug(errorMessage+'Response Status: '+resp.getStatusCode());
        }
    }
    
/**************************************************************************************
Method Name         : getShipmentByOrderId
Created Date        : 05/2023	Vikash Kumar 	Metacube
Details             : Call the GET method to extract shipment's entity_id/parent_id of Magento system by order_id received from the first method.
*************************************************************************************/
    public static void getShipmentByOrderId(String order_id , Magento_setting__c ms, String baseUrl, String ups_Track_Number){
        String shipmentEndp = String.valueOf(ms.ShipmentEndpoint__c);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl+shipmentEndp+order_id);
        req.setMethod('GET');
        req.setHeader('content-type',String.valueOf(ms.ContentType__c));
        req = DTC_MagentoAuth.signRequest(req, String.valueOf(ms.Consumer_Key__c), String.valueOf(ms.Access_Token__c), 
        String.valueOf(ms.Token_Secret__c),String.valueOf(ms.SignatureMethod__c),String.valueOf(ms.OauthVersion__c));
        Http h = new Http();
        HTTPResponse resp = new HTTPResponse();
        try{
            resp = h.send(req);
            if(resp.getStatusCode() == 200 && String.isNotBlank(resp.getBody())){
                String parent_id;
                String input = resp.getBody();
                Map<String,Object> jsonParsed =(Map<String,Object> ) JSON.deserializeUntyped(input);
                List<Object> v =(List<Object>) jsonParsed.get('items');
                Map<String, Object> q = (Map<String, Object>) v[0];
                System.debug('order_id: '+ q.get('order_id'));
                System.debug('Parent Id = '+ q.get('entity_id'));
                parent_id = String.valueOf(q.get('entity_id'));
                postUpdatedTrackingNumb(order_id,parent_id, ms, baseUrl, ups_Track_Number);
            }
        }
        catch(Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug(errorMessage+'Response Status: '+resp.getStatusCode());
        }
    }
    
/**************************************************************************************
Method Name         : postUpdatedTrackingNumb
Created Date        : 05/2023	Vikash Kumar 	Metacube
Details             : Call the POST Method to send the updated tracking number to Magento system by order_id and parent_id.
*************************************************************************************/
    public static void postUpdatedTrackingNumb(String order_id, String parent_id, Magento_setting__c ms, String baseUrl, String ups_Track_Number){
        String trackEndp = String.valueOf(ms.TrackEndpoint__c);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl+trackEndp);
        req.setMethod('POST');
        req.setHeader('content-type',String.valueOf(ms.ContentType__c));
        
        String lastUpdatedTrackNumber;
        if(ups_Track_Number.contains(',')){
            String ls = ups_Track_Number.substring(ups_Track_Number.lastIndexOf(',')+1);
            if(lS.contains('(')){
                lastUpdatedTrackNumber = ls.substring(0,ls.indexOf('(')).trim();
            }else{
                lastUpdatedTrackNumber = ls.trim();
            }
        }else{
            lastUpdatedTrackNumber = ups_Track_Number.trim();
        }

        DTC_MagentoTrackingPayloadWrapper jsonObj1 = new DTC_MagentoTrackingPayloadWrapper();
        DTC_MagentoTrackingPayloadWrapper.Entity jsonObj2 = new DTC_MagentoTrackingPayloadWrapper.Entity();
        
        jsonObj2.order_id = order_id;
        jsonObj2.parent_id = parent_id;
        jsonObj2.carrier_code = 'ups';
        jsonObj2.track_number = lastUpdatedTrackNumber;
        jsonObj2.title = 'United Parcel Service';
        
        jsonObj1.entity = jsonObj2;
        String jsonBody = json.serialize(jsonObj1);        
        if (jsonBody != null)
            req.setBody(jsonBody);
        req.setHeader('Content-length',string.valueOf(jsonBody.length()));
        
        req = DTC_MagentoAuth.signRequest(req,String.valueOf(ms.Consumer_Key__c), String.valueOf(ms.Access_Token__c), 
        String.valueOf(ms.Token_Secret__c),String.valueOf(ms.SignatureMethod__c),String.valueOf(ms.OauthVersion__c));
        Http h = new Http();
        HTTPResponse resp = new HTTPResponse();
        try{
            resp = h.send(req);
            if(resp.getStatusCode() == 200 && String.isNotBlank(resp.getBody())){
                String input = resp.getBody();
                if(input.contains('order_id')){
                    System.debug('Successfully Updated');
                } 
            }
        }
        catch(Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug(errorMessage+'Response Status: '+resp.getStatusCode());
        }
    }
}