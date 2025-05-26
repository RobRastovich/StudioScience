@isTest
public class TST_TI_UPS_API_ResponseToJSON {
    @isTest 
    static void test_fetchUPS_API_DateAndSatus(){
        String exceptionMessage = '';
        String response1 = '{"trackResponse": {"shipment": [{"package": [{"trackingNumber": "12345678","deliveryDate": [{"type": "DEL","date": "20180111"}],"deliveryTime": {"type": "DEL", "endTime": "120500"}, "activity": [{"location": {"address": {"city": "Croton on Hudson NY US "  }    },'
                              + '"status": {"type": "D","description": "Delivered", "code": "012" }, "date": "20180111","time": "120500"},{"location": {"address": { "city": "Adairsville GA US " } },'   
                              + '"status": {"type": "NA","description": "Received into UPS possession","code": "002"},"date": "20180108","time": "163600" }],"packageCount": 1}]}] } }';
        String response2 = '{"trackResponse": {"shipment": [{"": [{"trackingNumber": "12345678","deliveryDate": [{"type": "DEL","date": "20180111"}],"deliveryTime": {"type": "DEL", "endTime": "120500"}, "activity": [{"location": {"address": {"city": "Croton on Hudson NY US "  }    },'
                              + '"status": {"type": "D","description": "Delivered", "code": "012" }, "date": "20180111","time": "120500"},{"location": {"address": { "city": "Adairsville GA US " } },'   
                              + '"status": {"type": "NA","description": "Received into UPS possession","code": "002"},"date": "20180108","time": "163600" }],"packageCount": 1}]}] } }';
           
        Test.startTest();
            List<String> dateAndStatus1 = TI_UPS_API_ResponseToJSON.fetchUPS_API_DateAndSatus(response1);
            try {
                List<String> dateAndStatus2 = TI_UPS_API_ResponseToJSON.fetchUPS_API_DateAndSatus(response2); 
            } catch(Exception e) {
                exceptionMessage = e.getMessage();
            }
            
        Test.stopTest();
        
        System.assertEquals(4,dateAndStatus1.size());
        System.assertEquals(false,String.isEmpty(exceptionMessage),'returned Exception Message as expected');
        System.assertNotEquals(null, dateAndStatus1, 'returned not null because response1 is perfect');
    }
}