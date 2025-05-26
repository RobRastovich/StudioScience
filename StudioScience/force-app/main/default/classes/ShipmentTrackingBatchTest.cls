@isTest()
public class ShipmentTrackingBatchTest {
    static testMethod void ShipTrackingBatchTest() {
        
        insert new FedExAPISettings__c(Name = 'FedEx Details',
            						   FedEx_Endpoint__c = 'https://wsbeta.fedex.com:443/web-services/track',
                                       FedEx_Key__c = 'rKBTCO4PXaWVqjbo',
                                       FedEx_Password__c = 'UZexXRpTUyB0lK4Y208t6xqvR',
                                       FedEx_Account_Number__c = '510087720',
                                       FedEx_Meter_Number__c = '100470371');

        string trNum =  '773735677473';
        string trNum2 = '123';
        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.type__c = 'Sample Kit'; 
        insert bg;
        Sample_Kit__c sk = new Sample_Kit__c();
        sk.Barrel_Order_Group__c = bg.id;
        sk.Tracking_Number__c = trNum; 
        sk.Carrier__c = 'FedEx';
        sk.delivery_status__C = 'In Transit';
   		insert sk;
        Sample_Kit__c sk2 = new Sample_Kit__c();
        sk2.Barrel_Order_Group__c = bg.id;
        sk2.Tracking_Number__c = trNum2; 
        sk2.Carrier__c = 'FedEx';
        sk2.delivery_status__C = 'In Transit';
        insert sk2;
       
        Test.setMock(HttpCalloutMock.class, new ShipmentUpsMockHttpResponseGenerator(trNum));  
        Test.startTest();
            String oSourceName = 'Sample_Kit__c';
            String sCarrierName = 'FedEx';				
            ShipmentTrackingBatch colBatch = new ShipmentTrackingBatch(oSourceName, sCarrierName);			 
            Id batchprocessid = Database.executeBatch(colBatch,30);		  	
        Test.stopTest();  

        list <Sample_Kit__c> lstSk = [select id, delivery_status__C from Sample_Kit__c where id =: sk.id ];
        system.assertNotEquals(lstSk[0].delivery_status__C,'' );
    }
}