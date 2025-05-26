@isTest
private class SBP_SampleKitRelatedListControllerTest{
    //test data setup
    @testSetup static void setup(){
        
    }
    public static testMethod void getAllSampleKitsTest(){
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert testAccount;
        
        
        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.Type__c = 'Trip and Tour';
        
        Barrel_Order_Group__c bg2 = new Barrel_Order_Group__c();
        bg2.Type__c = 'Trip and Tour';
        
        insert new List<Barrel_Order_Group__c> {bg, bg2};
            
            
        Case c = new Case();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        c.Type = 'Trip and Tour';
        c.Barrel_Order_Group__c = bg.Id;
        c.Brand__c = 'Knob Creek';
        c.Product_Type__c = 'Rye';
        c.ccEmail__c = 'test@test.com';
        c.AccountId = testAccount.Id;
        c.Status = 'New';
        
        Case c2 = new Case();
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c2.Type = 'Trip and Tour';
        c2.Barrel_Order_Group__c = bg2.Id;
        //c2.Brand__c = 'Makers Mark';
        c2.AccountId = testAccount.Id;
        c2.Status = 'New';
        
        Case c3 = new Case();
        c3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c3.Type = 'Sample Kit';
        c3.Barrel_Order_Group__c = bg2.Id;
        c3.Brand__c = 'El Tesoro Laphroaig Cask';      
        c3.AccountId = testAccount.Id;
        c3.Status = 'New';
        
        Case c4 = new Case();
        c4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c4.Type = 'Sample Kit';
        c4.Barrel_Order_Group__c = bg2.Id;
        c4.Brand__c = 'Baker\'s';      
        c4.AccountId = testAccount.Id;
        c4.Status = 'New';
       
        insert new List<Case> {c, c2, c3, c4};
        Sample_Kit__c sampleKit = new Sample_Kit__c();
        
        sampleKit.Sample_Selected__c = false;
        sampleKit.Tracking_Number_Creation_Date__c = system.today();
        sampleKit.Barrel_Order_Group__c = bg.Id;
        sampleKit.Delivery_Status__c ='Shipped';
        sampleKit.Tracking_Number__c='test1213';
        sampleKit.Case__c  = c.Id;

        
        Sample_Kit__c sample2 = new Sample_Kit__c();
        
        sample2.Sample_Selected__c = false;
        sample2.Tracking_Number_Creation_Date__c = system.today();
        sample2.Barrel_Order_Group__c = bg2.Id;
        sample2.Delivery_Status__c ='Shipped';
        sample2.Tracking_Number__c='test23232';
        sample2.Case__c  = c2.Id;

        insert new List<Sample_Kit__c> {sampleKit, sample2};
        //Inserting Barrel as part of create3Samples enhancement     
        Barrel__c barrel = new Barrel__c();
        barrel.Case__c = c.Id;
        insert barrel;  
        
        Barrel__c barrel2 = new Barrel__c();
        barrel2.Case__c = c2.Id;
        insert barrel2;
        
        Barrel__c barrel3 = new Barrel__c();
        barrel3.Case__c = c3.Id;
        insert barrel3;
        
        SBP_SampleKitRelatedListController.getAllSampleKits(c2.id);
        SBP_SampleKitRelatedListController.getCaseDetails(c2.id);
        SBP_SampleKitRelatedListController.createNewSamples(sampleKit.id,barrel.Id);//Added by mahesh as part of createNewSamples enhancement
        SBP_SampleKitRelatedListController.getSampleDetails(c2.id);//Added by mahesh as part of createNewSamples enhancement
        SBP_SampleKitRelatedListController.DeleteSampleKitRecord(sample2.id);
        SBP_SampleKitRelatedListController.createNewSamples(sampleKit.id,barrel2.Id);
        SBP_SampleKitRelatedListController.createNewSamples(sampleKit.id,barrel3.Id);

    }

}