@isTest
public class TST_TI_SAP_Data_Extraction {
    @isTest static void test_fetch_Docnum_Data(){
        String exceptionMessage = '';
		String res = '{"d": {"results": [{"__metadata": {"id": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet(DocnumOr=\'1234567890\',ItemnumOr=\'\',Docnum=\'A123456789\',Itemnum=\'000000\')",'
                      + '"uri": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet(DocnumOr=\'1234567890\',ItemnumOr=\'\',Docnum=\'A123456789\',Itemnum=\'000000\')","type": "ZGSV_SD_DOCUMENT_FLOW_GET_SRV.SDDocFlow"},'
                      + '"DocnumOr": "1234567890","Docnum": "A123456789","VbtypN": "4"}]}}';
		
        Test.startTest();
        try{
            String shipmentNumber1 = TI_SAP_Data_Extraction.fetch_Docnum_Data(res);
        	String shipmentNumber2 = TI_SAP_Data_Extraction.fetch_Docnum_Data('');
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
            
        Test.stopTest();
        
        System.assertEquals(false, String.isEmpty(exceptionMessage));
        System.assertNotEquals(true, String.isEmpty(exceptionMessage));
    }
    @isTest static void test_fetch_TrackingNumber(){ 
        String exceptionMessage = '';
        String res = '{"d": {"results": [{"__metadata": {"id": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet(\'C410906663\')","uri": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet(\'C410906663\')","type": "ZGSV_SHIPMENT_SRV.Shipment"'
                		+'},"ShipmentNum": "C410906663","ContainerId": "850334310","ServiceAgentName": "TFORCE FREIGHT INC"}]}}';
        
        Test.startTest();
        try {
            List<String> trackingInfo1 = TI_SAP_Data_Extraction.fetch_TrackingNumber(res);
        	List<String> trackingInfo2 = TI_SAP_Data_Extraction.fetch_TrackingNumber('');
        } catch(Exception e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(exceptionMessage));
        System.assertNotEquals(true, String.isEmpty(exceptionMessage));
    }
}