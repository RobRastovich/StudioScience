@isTest
public class TST_TI_UPS_APIService {
    @TestSetup
    public static void makeData(){
    	Carrier_Details__c carrierDetailsSettingObj = new Carrier_Details__c();
        carrierDetailsSettingObj.Name = SBP_Constants.carrierName;
        carrierDetailsSettingObj.Endpoint__c = 'https://onlinetools.ups.com/track/v1/details/';
        carrierDetailsSettingObj.AccessLicenseNumber__c = '1DC8B807618B11B5'; 
        insert carrierDetailsSettingObj;
    }
    @isTest static void testupdateBarrelTrackingInfo1(){
    	String responseBody1 = '{"trackResponse": {"shipment": [{"package": [{"trackingNumber": "12345678","deliveryDate": [{"type": "DEL","date": "20180111"}],"deliveryTime": {"type": "DEL", "endTime": "120500"}, "activity": [{"location": {"address": {"city": "Croton on Hudson NY US "  }    },'
                      			+ '"status": {"type": "D","description": "Delivered", "code": "012" }, "date": "20180111","time": "120500"},{"location": {"address": { "city": "Adairsville GA US " } },'   
                      			+ '"status": {"type": "NA","description": "Received into UPS possession","code": "002"},"date": "20180108","time": "163600" }],"packageCount": 1}]}] } }';
        String responseBody2 = '{"trackResponse": {"shipment": [{"package": [{"trackingNumber": "12345678","": [{"type": "DEL","date": "20180111"}],"deliveryTime": {"type": "DEL", "endTime": "120500"}, "activity": [{"location": {"address": {"city": "Croton on Hudson NY US "  }    },'
                      			+ '"status": {"type": "D","description": "Delivered", "code": "012" }, "date": "20180111","time": "120500"},{"location": {"address": { "city": "Adairsville GA US " } },'   
                      			+ '"status": {"type": "NA","description": "Received into UPS possession","code": "002"},"date": "20180108","time": "163600" }],"packageCount": 1}]}] } }';     
     	List<sObject> trackingNo = new List<sObject>();
        Barrel__c barrel_obj = new Barrel__c(Tracking_Number__c='12345678');
        trackingNo.add(barrel_obj);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(responseBody1));
            TI_UPS_APIService.updateBarrelTrackingInfo(trackingNo);
            Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(responseBody2));
            TI_UPS_APIService.updateBarrelTrackingInfo(trackingNo);
		Test.stopTest();
        System.assertEquals(false, barrel_obj.UPS_Delivery_Status__c == null , 'barrel updated');
    }
    @isTest static void testupdateBarrelTrackingInfoForNull(){
     	String responseBody3 = '';
        List<sObject> trackingNo = new List<sObject>();
        Barrel__c barrel_obj = new Barrel__c(Tracking_Number__c='12345678');
        insert barrel_obj;
        trackingNo.add(barrel_obj);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(responseBody3));
            TI_UPS_APIService.updateBarrelTrackingInfo(trackingNo);
		Test.stopTest();
        System.assertEquals(false, barrel_obj.UPS_Delivery_Status__c == null , 'barrel updated');
    }
    
}