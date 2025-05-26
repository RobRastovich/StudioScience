@isTest
public class TI_SAP_API_ServiceTests {
    @testSetup
    public static void setup(){
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
    
    @isTest static void testUpdateShipmentNumberAndTrackingNumber(){
        String responseBody1 = '{"d": {"results": [{"__metadata": {"id": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet(DocnumOr=\'1234567890\',ItemnumOr=\'\',Docnum=\'\',Itemnum=\'000000\')",'
                                  + '"uri": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet(DocnumOr=\'1234567890\',ItemnumOr=\'\',Docnum=\'\',Itemnum=\'000000\')","type": "ZGSV_SD_DOCUMENT_FLOW_GET_SRV.SDDocFlow"},'
                                  + '"DocnumOr": "1234567890","Docnum": "","VbtypN": "4"}]}}';
        String responseBody2 = '{"d": {"results": [{"__metadata": {"id": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet(DocnumOr=\'1234567890\',ItemnumOr=\'\',Docnum=\'A123456789\',Itemnum=\'000000\')",'
                                  + '"uri": "https://MOBILEQ.BEAMSUNTORY.COM:44382/sap/opu/odata/sap/ZGSV_SD_DOCUMENT_FLOW_GET_SRV/SDDocFlowSet(DocnumOr=\'1234567890\',ItemnumOr=\'\',Docnum=\'A123456789\',Itemnum=\'000000\')","type": "ZGSV_SD_DOCUMENT_FLOW_GET_SRV.SDDocFlow"},'
                                  + '"DocnumOr": "1234567890","Docnum": "A123456789","VbtypN": "4"}]}}';
        List<sObject> shipmentNo = new List<sObject>();
        Barrel__c barrel_obj1 = new Barrel__c(Shipment_Number__c='', Case__c='5008M000001WAZuQAO');
        Barrel__c barrel_obj2 = new Barrel__c(Shipment_Number__c='A123456789');
        shipmentNo.add(barrel_obj1);
        shipmentNo.add(barrel_obj2);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_TI_UPS_APIService_HttpMockCallout(responseBody1));
            TI_SAP_API_Service.updateShipmentNumberAndTrackingNumber(shipmentNo);
        Test.stopTest();
        
        System.assertEquals('A123456789', barrel_obj2.Shipment_Number__c, 'barrel updated');
    }
}