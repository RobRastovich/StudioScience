@isTest
private class TST_CNT_LWC_SOI_Innovations {
    @testSetup
    static void testDataSetup() {
        Innovation_Project_Master__c innovationMaster = TST_TestDataFactory.createInnovationMaster(true);
        List<Sample_Kit_Shipping_Address__c> shipAddressList = new List<Sample_Kit_Shipping_Address__c>();
        Sample_Kit_Shipping_Address__c shippingAddress = TST_TestDataFactory.createshippingAddress(false);
        Sample_Kit_Shipping_Address__c shippingAddress2 = TST_TestDataFactory.createshippingAddress(false);
        shippingAddress2.Name = 'Test Shipping Address 2';
        shipAddressList.add(shippingAddress);
        shipAddressList.add(shippingAddress2);
        insert shipAddressList;
    }
    
    private static Sample_Kit_Shipping_Address__c getShipAddress() {
        return [SELECT Id FROM Sample_Kit_Shipping_Address__c LIMIT 1];
    }
    
    private static Innovation_Project_Master__c getInnovationMaster() {
        return [SELECT Id FROM Innovation_Project_Master__c LIMIT 1];
    }
    
    @isTest
    private static void testGetInnovationSampleRecords() {
        List<Innovation_Project_Master__c> sampleList = new List<Innovation_Project_Master__c>();
        
        Test.startTest();
            sampleList = CNT_LWC_SOI_Innovations.getInnovationSampleRecords();
        Test.stopTest();
        
        System.assertEquals(true, sampleList.size() > 0, 'Should return Innovation Sample records');
        System.assertEquals('Test Project Master', sampleList[0].Name, 'Name of Record should be Test Project Master');
    }
    
    @isTest
    private static void testSaveInnovationRecords() {
        List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper> detailsWrapperList =
            new List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper>();
        CNT_LWC_SOI_Innovations.InnovationDetailsWrapper detailWrapper =
            new CNT_LWC_SOI_Innovations.InnovationDetailsWrapper();
        detailWrapper.addressId = getShipAddress().Id;
        detailWrapper.recipientEmail = 'test@gmail.com';
        detailWrapper.quantity = 100;
        detailWrapper.attentionTo = 'Test attn';
        detailWrapper.phone = '9956784565';
        detailWrapper.legalShipPoint = 'Test ship point';
        detailsWrapperList.add(detailWrapper);
        
        CNT_LWC_SOI_Innovations.InnovationRequestsWrapper requestWrapper =
            new CNT_LWC_SOI_Innovations.InnovationRequestsWrapper();
        requestWrapper.innovationSampleId = getInnovationMaster().Id;
        requestWrapper.submittedBy = 'Test submitter';
        requestWrapper.email = 'testrequest@gmail.com';
        requestWrapper.soldTo = 'Innovation samples';
        requestWrapper.costCenter = 'Test cost';
        requestWrapper.wbsElement = '';
        requestWrapper.projectList = JSON.serialize(detailsWrapperList);
        requestWrapper.region = 'Other';
        requestWrapper.notes = 'Test notes';
        requestWrapper.resubmission = false;
        String testJSONString = JSON.serialize(requestWrapper);
        
        Test.startTest();
            Boolean result = CNT_LWC_SOI_Innovations.saveInnovationRecords(testJSONString);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Result value should be true');
    }
    
    @isTest
    private static void testSaveInnovationRecordsForCatch() {
        List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper> detailsWrapperList =
            new List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper>();
        CNT_LWC_SOI_Innovations.InnovationDetailsWrapper detailWrapper =
            new CNT_LWC_SOI_Innovations.InnovationDetailsWrapper();
        detailWrapper.addressId = getShipAddress().Id;
        detailWrapper.recipientEmail = 'test@gmail.com';
        detailWrapper.quantity = 100;
        detailWrapper.attentionTo = 'Test attn';
        detailWrapper.phone = '9956784565';
        detailWrapper.legalShipPoint = 'Test ship point';
        detailsWrapperList.add(detailWrapper);
        
        CNT_LWC_SOI_Innovations.InnovationRequestsWrapper requestWrapper =
            new CNT_LWC_SOI_Innovations.InnovationRequestsWrapper();
        requestWrapper.innovationSampleId = getInnovationMaster().Id;
        requestWrapper.submittedBy = 'Test submitter';
        requestWrapper.email = 'testrequest@gmail.com';
        requestWrapper.soldTo = 'Innovation samples';
        requestWrapper.costCenter = '';
        requestWrapper.wbsElement = 'Test wbs';
        requestWrapper.projectList = JSON.serialize(detailsWrapperList);
        requestWrapper.region = 'Test Region';
        requestWrapper.notes = 'Test notes';
        requestWrapper.resubmission = false;
        String testJSONString = JSON.serialize(requestWrapper);
        
        Test.startTest();
            Boolean result = CNT_LWC_SOI_Innovations.saveInnovationRecords(testJSONString);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result value should be false');
    }
    
    @isTest
    private static void testSaveInnovationRecordsForEmptyEmail() {
        List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper> detailsWrapperList =
            new List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper>();
        CNT_LWC_SOI_Innovations.InnovationDetailsWrapper detailWrapper =
            new CNT_LWC_SOI_Innovations.InnovationDetailsWrapper();
        detailWrapper.addressId = getShipAddress().Id;
        detailWrapper.recipientEmail = '';
        detailWrapper.quantity = 100;
        detailWrapper.attentionTo = 'Test attn';
        detailWrapper.phone = '9956784565';
        detailWrapper.legalShipPoint = 'Test ship point';
        detailsWrapperList.add(detailWrapper);
        
        CNT_LWC_SOI_Innovations.InnovationRequestsWrapper requestWrapper =
            new CNT_LWC_SOI_Innovations.InnovationRequestsWrapper();
        requestWrapper.innovationSampleId = getInnovationMaster().Id;
        requestWrapper.submittedBy = 'Test submitter';
        requestWrapper.email = 'testrequest@gmail.com';
        requestWrapper.soldTo = 'Innovation samples';
        requestWrapper.costCenter = 'Test cost';
        requestWrapper.wbsElement = '';
        requestWrapper.projectList = JSON.serialize(detailsWrapperList);
        requestWrapper.region = 'Other';
        requestWrapper.notes = 'Test notes';
        requestWrapper.resubmission = false;
        String testJSONString = JSON.serialize(requestWrapper);
        
        Test.startTest();
            Boolean result = CNT_LWC_SOI_Innovations.saveInnovationRecords(testJSONString);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result value should be false');
    }
    
    @isTest
    private static void testSaveInnovationRecordsForInvalidEmail() {
        List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper> detailsWrapperList =
            new List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper>();
        CNT_LWC_SOI_Innovations.InnovationDetailsWrapper detailWrapper =
            new CNT_LWC_SOI_Innovations.InnovationDetailsWrapper();
        detailWrapper.addressId = getShipAddress().Id;
        detailWrapper.recipientEmail = 'testinvalid@.com';
        detailWrapper.quantity = 100;
        detailWrapper.attentionTo = 'Test attn';
        detailWrapper.phone = '9956784565';
        detailWrapper.legalShipPoint = 'Test ship point';
        detailsWrapperList.add(detailWrapper);
        
        CNT_LWC_SOI_Innovations.InnovationRequestsWrapper requestWrapper =
            new CNT_LWC_SOI_Innovations.InnovationRequestsWrapper();
        requestWrapper.innovationSampleId = getInnovationMaster().Id;
        requestWrapper.submittedBy = 'Test submitter';
        requestWrapper.email = 'testrequest@gmail.com';
        requestWrapper.soldTo = 'Innovation samples';
        requestWrapper.costCenter = 'Test cost';
        requestWrapper.wbsElement = '';
        requestWrapper.projectList = JSON.serialize(detailsWrapperList);
        requestWrapper.region = 'Other';
        requestWrapper.notes = 'Test notes';
        requestWrapper.resubmission = false;
        String testJSONString = JSON.serialize(requestWrapper);
        
        Test.startTest();
            Boolean result = CNT_LWC_SOI_Innovations.saveInnovationRecords(testJSONString);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result value should be false');
    }
    
    @isTest
    private static void testSaveInnovationRecordsForEmptyCostCenter() {
        List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper> detailsWrapperList =
            new List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper>();
        CNT_LWC_SOI_Innovations.InnovationDetailsWrapper detailWrapper =
            new CNT_LWC_SOI_Innovations.InnovationDetailsWrapper();
        detailWrapper.addressId = getShipAddress().Id;
        detailWrapper.recipientEmail = 'test@gmail.com';
        detailWrapper.quantity = 100;
        detailWrapper.attentionTo = 'Test attn';
        detailWrapper.phone = '9956784565';
        detailWrapper.legalShipPoint = 'Test ship point';
        detailsWrapperList.add(detailWrapper);
        
        CNT_LWC_SOI_Innovations.InnovationRequestsWrapper requestWrapper =
            new CNT_LWC_SOI_Innovations.InnovationRequestsWrapper();
        requestWrapper.innovationSampleId = getInnovationMaster().Id;
        requestWrapper.submittedBy = 'Test submitter';
        requestWrapper.email = 'testrequest@gmail.com';
        requestWrapper.soldTo = 'Innovation samples';
        requestWrapper.costCenter = '';
        requestWrapper.wbsElement = '';
        requestWrapper.projectList = JSON.serialize(detailsWrapperList);
        requestWrapper.region = 'Other';
        requestWrapper.notes = 'Test notes';
        requestWrapper.resubmission = false;
        String testJSONString = JSON.serialize(requestWrapper);
        
        Test.startTest();
            Boolean result = CNT_LWC_SOI_Innovations.saveInnovationRecords(testJSONString);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result value should be false');
    }
    
    @isTest
    private static void testSaveInnovationRecordsForEmptySoldTo() {
        List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper> detailsWrapperList =
            new List<CNT_LWC_SOI_Innovations.InnovationDetailsWrapper>();
        CNT_LWC_SOI_Innovations.InnovationDetailsWrapper detailWrapper =
            new CNT_LWC_SOI_Innovations.InnovationDetailsWrapper();
        detailWrapper.addressId = getShipAddress().Id;
        detailWrapper.recipientEmail = 'test@gmail.com';
        detailWrapper.quantity = 100;
        detailWrapper.attentionTo = 'Test attn';
        detailWrapper.phone = '9956784565';
        detailWrapper.legalShipPoint = 'Test ship point';
        detailsWrapperList.add(detailWrapper);
        
        CNT_LWC_SOI_Innovations.InnovationRequestsWrapper requestWrapper =
            new CNT_LWC_SOI_Innovations.InnovationRequestsWrapper();
        requestWrapper.innovationSampleId = getInnovationMaster().Id;
        requestWrapper.submittedBy = 'Test submitter';
        requestWrapper.email = 'testrequest@gmail.com';
        requestWrapper.soldTo = '';
        requestWrapper.costCenter = 'Test cost';
        requestWrapper.wbsElement = '';
        requestWrapper.projectList = JSON.serialize(detailsWrapperList);
        requestWrapper.region = 'Other';
        requestWrapper.notes = 'Test notes';
        requestWrapper.resubmission = false;
        String testJSONString = JSON.serialize(requestWrapper);
        
        Test.startTest();
            Boolean result = CNT_LWC_SOI_Innovations.saveInnovationRecords(testJSONString);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Result value should be false');
    }
    
    @isTest
    private static void testGetSoldToPicklistValues() {
        List<List<String>> pickListValuesList = new List<List<String>>();
        
        Test.startTest();
            pickListValuesList = CNT_LWC_SOI_Innovations.getSoldToPicklistValues();
        Test.stopTest();
        
        System.assertEquals(true, pickListValuesList.size() > 0, 'Picklist values list should not be blank');
    }
    
    @isTest
    private static void testGetRegionOptions() {
        List<List<String>> pickListValuesList = new List<List<String>>();
        
        Test.startTest();
            pickListValuesList = CNT_LWC_SOI_Innovations.getRegionOptions();
        Test.stopTest();
        
        System.assertEquals(true, pickListValuesList.size() > 0, 'Picklist values list should not be blank');
    }
    
    @isTest
    private static void testGetSampleKitShipAddressMap() {
        Map<String, Map<String, Id>> sampleKitShipAddressMap = new Map<String, Map<String, Id>>();
        
        Test.startTest();
            sampleKitShipAddressMap = CNT_LWC_SOI_Innovations.getSampleKitShipAddressMap(SOI_Constants.COUNTRY_USA);
        Test.stopTest();
        
        System.assertEquals(true, sampleKitShipAddressMap.size() > 0, 'Ship Address Map should not be blank');
    }
    
    @isTest
    private static void testFilterOfficeValueByStateMap() {
        Map<String, String> addressNameMap = new Map<String, String>();
        
        Test.startTest();
            addressNameMap = CNT_LWC_SOI_Innovations.filterOfficeValueByStateMap(SOI_Constants.COUNTRY_USA,
                                SOI_Constants.STATE_AR);
        Test.stopTest();
        
        System.assertEquals(true, addressNameMap.size() > 0, 'Address Name Map should not be blank');
    }
}