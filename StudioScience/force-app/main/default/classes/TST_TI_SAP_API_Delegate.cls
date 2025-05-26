@isTest
public class TST_TI_SAP_API_Delegate {
    @testSetup static void setup(){
        List<StoredCredentials__c> storedCredentials_List = new List<StoredCredentials__c>();
        StoredCredentials__c sap1 = new StoredCredentials__c(Name='TI_SAP_ShipmentNumber_PROD',Full_Endpoint__c='https://mobile.beamsuntory.com/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet?$select=DocnumOr,Docnum,VbtypN&$filter=DocnumOr%20eq%20\'',Full_Endpoint_2__c='\'%20and%20%20VbtypN%20eq%20\'8\'&$format=json',Password__c='S@l3sF0rceTF',Username__c='SYS_SFUS_TF');
        StoredCredentials__c Sap2 = new StoredCredentials__c(Name='TI_SAP_ShipmentNumber_QA',Full_Endpoint__c='https://mobileq.beamsuntory.com:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet?$select=DocnumOr,Docnum,VbtypN&$filter=DocnumOr%20eq%20\'',Full_Endpoint_2__c='\'%20and%20%20VbtypN%20eq%20\'8\'&$format=json',Password__c='S@l3sF0rceTF',Username__c='SYS_SFUS_TF');
        StoredCredentials__c Sap3 = new StoredCredentials__c(Name='TI_SAP_TrackingNumber_PROD',Full_Endpoint__c='https://mobileq.beamsuntory.com:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet?$select=ShipmentNum,ContainerId,ServiceAgentName&$filter=ShipmentNum%20eq%20\'',Full_Endpoint_2__c='\'&$format=json',Password__c='S@l3sF0rceTF',Username__c='SYS_SFUS_TF');
        StoredCredentials__c Sap4 = new StoredCredentials__c(Name='TI_SAP_TrackingNumber_QA',Full_Endpoint__c='https://mobileq.beamsuntory.com:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet?$select=ShipmentNum,ContainerId,ServiceAgentName&$filter=ShipmentNum%20eq%20\'',Full_Endpoint_2__c='\'&$format=json',Password__c='S@l3sF0rceTF',Username__c='SYS_SFUS_TF');
        storedCredentials_List.add(sap1);
        storedCredentials_List.add(sap2);
        storedCredentials_List.add(sap3);
        storedCredentials_List.add(sap4);
        insert storedCredentials_List;
    }
    @isTest static void test_fetchData(){
        String exceptionMessage = '';
        String res = '{"d": {"results": [{"__metadata": {"id": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet(\'C410906663\')","uri": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet(\'C410906663\')","type": "ZGSV_SHIPMENT_SRV.Shipment"'
                		+'},"ShipmentNum": "C410906663","ContainerId": "850334310","ServiceAgentName": "TFORCE FREIGHT INC"}]}}';
        String sapNumber = '1022432980';
        
        Test.startTest();
            try {
                Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(res));
                String resData1 = TI_SAP_API_Delegate.fetchData(sapNumber);
                Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(''));
                String resData2 = TI_SAP_API_Delegate.fetchData(sapNumber);
            } catch(Exception e) {
                exceptionMessage = e.getMessage();
            }

        Test.stopTest();
        
        System.assertNotEquals(false, String.isEmpty(exceptionMessage));
        System.assertEquals(true, String.isEmpty(exceptionMessage));
    }
    @isTest static void test_fetchTrackingNumber(){
        String exceptionMessage = '';
        String res = '{"d": {"results": [{"__metadata": {"id": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet(\'C410906663\')","uri": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SHIPMENT_SRV/ShipmentSet(\'C410906663\')","type": "ZGSV_SHIPMENT_SRV.Shipment"'
                		+'},"ShipmentNum": "C410906663","ContainerId": "850334310","ServiceAgentName": "TFORCE FREIGHT INC"}]}}';
        String shipmentNumber = 'C410906663';
        
        Test.startTest();
        try {
        	Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(res));
            String resData1 = TI_SAP_API_Delegate.fetchTrackingNumber(shipmentNumber);
            Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(''));
        	String resData2 = TI_SAP_API_Delegate.fetchTrackingNumber(shipmentNumber);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertNotEquals(false, String.isEmpty(exceptionMessage));
        System.assertEquals(true, String.isEmpty(exceptionMessage)); 
    }
}