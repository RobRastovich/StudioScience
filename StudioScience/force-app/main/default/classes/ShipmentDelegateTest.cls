@isTest(SeeAllData=true)
public with sharing class ShipmentDelegateTest {
	
	@isTest static void testHTTPResponse() {  
        string trNum =  '773735677473';
		List<sobject> sobj = [select id,Tracking_Number__c,Estimated_Delivery_Date__c from Sample_Kit__c where Tracking_Number__c = '773735677473'];
        String oSourceName = 'Sample_Kit__c';
        String sCarrierName = 'FedEx';				
        
        Test.setMock(HttpCalloutMock.class, new ShipmentFailedMockHttpResponseGenerator(trNum));  
        set <string> trackingNumbers = new Set <string>{trNum};
        HttpRequest req = new HttpRequest();
        Http http = new Http();      
        HTTPResponse res = new ShipmentFailedMockHttpResponseGenerator(trNum).respond(req);
        map<string, ShipmentResponseWrapper > m = ShipmentDelegate.GetShipmentTrackingInfo(trackingNumbers, 'FedEx');
        
        system.debug(m);
        Map<String, String> deliveryStatusMap = ShipmentTrackingService.getFedExMappedValues();
        if(m.get(trNum) == null){
            m.put(trNum,new ShipmentResponseWrapper('0',
                                                    'DL', 
                                                    'DELIVERED',
                                                    'SUCCESS',
                                                    null));
        }
        System.debug(m.get(trNum).code);
        String deliveryStatus = deliveryStatusMap.get(m.get(trNum).code);
        FedExResponseHandler.parseFedExTrackingResponse(res.getbody());
        ShipmentTrackingService.fetchAndUpdateDeliveryStatus(sobj, sCarrierName);
        //System.AssertEquals(deliveryStatus , 'Delivered');
    }
}