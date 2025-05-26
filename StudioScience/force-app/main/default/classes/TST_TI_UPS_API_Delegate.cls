@isTest
public class TST_TI_UPS_API_Delegate {
    @TestSetup
    public static void makeData(){
        Carrier_Details__c carrierDetailsSettingObj = new Carrier_Details__c();
        carrierDetailsSettingObj.Name = SBP_Constants.carrierName;
        carrierDetailsSettingObj.Endpoint__c = 'https://onlinetools.ups.com/track/v1/details/';
        carrierDetailsSettingObj.AccessLicenseNumber__c = '1DC8B807618B11B5'; 
        insert carrierDetailsSettingObj;
    }    
    @isTest 
    static void test_fetchTrackingData(){
        String exceptionMessage = '';
        String trackingNumber = '12345678';           
        String responseBody1 = '{"trackResponse": {"shipment": [{"package": [{"trackingNumber": "12345678","deliveryDate": [{"type": "DEL","date": "20180111"}],"deliveryTime": {"type": "DEL", "endTime": "120500"}, "activity": [{"location": {"address": {"city": "Croton on Hudson NY US "  }    },'
                                  + '"status": {"type": "D","description": "Delivered", "code": "012" }, "date": "20180111","time": "120500"},{"location": {"address": { "city": "Adairsville GA US " } },'   
                                  + '"status": {"type": "NA","description": "Received into UPS possession","code": "002"},"date": "20180108","time": "163600" }],"packageCount": 1}]}] } }';
        String responseBody2 = '{"trackResponse": {"shipment": [{"package": [{"trackingNumber": "12345678","deliveryDate": [{"type": "DEL","date": "20180111"}],"deliveryTime": {"type": "DEL", "endTime": "120500"}, "activit": [{"location": {"address": {"city": "Croton on Hudson NY US "  }    },'
                                  + '"status": {"type": "D","description": "Delivered", "code": "012" }, "date": "20180111","time": "120500"},{"location": {"address": { "city": "Adairsville GA US " } },'   
                                  + '"status": {"type": "NA","description": "Received into UPS possession","code": "002"},"date": "20180108","time": "163600" }],"packageCount": 1}]}] } }';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(responseBody1));
            String response1 = TI_UPS_API_Delegate.fetchTrackingData(trackingNumber); 
            try {
                Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(responseBody2));
                String response2 = TI_UPS_API_Delegate.fetchTrackingData(trackingNumber);
            } catch(Exception e) {
                exceptionMessage = e.getMessage();
            }
        Test.stopTest();
        
        System.assertNotEquals(null, response1);
        System.assertEquals(false, String.isEmpty(exceptionMessage));
    }
    @isTest
    public static void invalidTrackingNumber() {
        String trackingNumber = '123';
        String exceptionMessage = '';
        Test.startTest();
        try{
            String response = TI_UPS_API_Delegate.fetchTrackingData(trackingNumber);
        } catch(Exception e) {
            exceptionMessage = e.getMessage();
        }
            
        Test.stopTest();
        
        System.assertEquals(false, String.isEmpty(exceptionMessage) , 'returned Exception as expected');
    }
    
}