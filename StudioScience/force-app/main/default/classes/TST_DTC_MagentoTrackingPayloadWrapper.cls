@IsTest
public class TST_DTC_MagentoTrackingPayloadWrapper {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"entity\": {'+
		'        \"order_id\": 11,'+
		'        \"parent_id\": 42,'+
		'        \"carrier_code\": \"ups\",'+
		'        \"track_number\": \"updt-12345\",'+
		'        \"title\": \"United Parcel Service\"'+
		'    }'+
		'}';
		DTC_MagentoTrackingPayloadWrapper obj = DTC_MagentoTrackingPayloadWrapper.parse(json);
		System.assert(obj != null);
	}
}