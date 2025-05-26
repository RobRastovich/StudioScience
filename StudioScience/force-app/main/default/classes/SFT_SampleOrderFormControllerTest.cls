@isTest
public class SFT_SampleOrderFormControllerTest {
    
    public static testMethod void fetchShippingAddressTest() {
        List<Sample_Kit_Shipping_Address__c> AddressList = new List<Sample_Kit_Shipping_Address__c>();
        Sample_Kit_Shipping_Address__c SampleAddress = new Sample_Kit_Shipping_Address__c();
        SampleAddress.Company__c = 'Beam';
        SampleAddress.City__c = 'Test';
        SampleAddress.Zip_Code__c = '12345';
        SampleAddress.Country__c = 'USA';
        SampleAddress.State__c = 'ID';
        SampleAddress.Name = 'Demo';
        SampleAddress.Street__c = 'DemoLane';
        AddressList.add(SampleAddress);
        
        Sample_Kit_Shipping_Address__c TestSampleAddress = new Sample_Kit_Shipping_Address__c();
        TestSampleAddress.Company__c = 'Beam2';
        TestSampleAddress.City__c = 'Test2';
        TestSampleAddress.Zip_Code__c = '22345';
        TestSampleAddress.Country__c = 'Canada';
        TestSampleAddress.State__c = 'AK';
        TestSampleAddress.Name = 'Demo2';
        TestSampleAddress.Street__c = 'DemoLane';
        AddressList.add(TestSampleAddress);
        insert AddressList;
        
        Test.startTest();
            Sample_Kit_Shipping_Address__c TestAddress = SFT_SampleOrderFormController.fetchShippingAddress('AK');
        Test.stopTest();
        
        System.assertEquals('AK', TestAddress.State__c);
    }
    
    public static testMethod void filterStatesByCountryTest() {
        List<Sample_Kit_Shipping_Address__c> AddressList = new List<Sample_Kit_Shipping_Address__c>();
        Sample_Kit_Shipping_Address__c SampleAddress = new Sample_Kit_Shipping_Address__c();
        SampleAddress.Company__c = 'Beam';
        SampleAddress.City__c = 'Test';
        SampleAddress.Zip_Code__c = '12345';
        SampleAddress.Country__c = 'USA';
        SampleAddress.State__c = 'ID';
        SampleAddress.Name = 'Demo';
        SampleAddress.Street__c = 'DemoLane';
        AddressList.add(SampleAddress);
        
        Sample_Kit_Shipping_Address__c TestSampleAddress = new Sample_Kit_Shipping_Address__c();
        TestSampleAddress.Company__c = 'Beam2';
        TestSampleAddress.City__c = 'Test2';
        TestSampleAddress.Zip_Code__c = '22345';
        TestSampleAddress.Country__c = 'Canada';
        TestSampleAddress.State__c = 'AK';
        TestSampleAddress.Name = 'Demo2';
        TestSampleAddress.Street__c = 'DemoLane';
        AddressList.add(TestSampleAddress);
        insert AddressList;
        
        Test.startTest();
            List<String> TestAddress = SFT_SampleOrderFormController.filterStatesByCountry('USA');
        Test.stopTest();
        
        System.assertEquals('ID', TestAddress[0]);
    }
    
    public static testMethod void filterOfficeValueByStateTest() {
        List<Sample_Kit_Shipping_Address__c> AddressList = new List<Sample_Kit_Shipping_Address__c>();
        Sample_Kit_Shipping_Address__c SampleAddress = new Sample_Kit_Shipping_Address__c();
        SampleAddress.Company__c = 'Beam';
        SampleAddress.City__c = 'Test';
        SampleAddress.Zip_Code__c = '12345';
        SampleAddress.Country__c = 'USA';
        SampleAddress.State__c = 'ID';
        SampleAddress.Name = 'Demo';
        SampleAddress.Street__c = 'DemoLane';
        AddressList.add(SampleAddress);
        
        Sample_Kit_Shipping_Address__c TestSampleAddress = new Sample_Kit_Shipping_Address__c();
        TestSampleAddress.Company__c = 'Beam2';
        TestSampleAddress.City__c = 'Test2';
        TestSampleAddress.Zip_Code__c = '22345';
        TestSampleAddress.Country__c = 'Canada';
        TestSampleAddress.State__c = 'AK';
        TestSampleAddress.Name = 'Demo2';
        TestSampleAddress.Street__c = 'DemoLane';
        AddressList.add(TestSampleAddress);
        insert AddressList;
        
        Test.startTest();
            List<String> TestAddress = SFT_SampleOrderFormController.filterOfficeValueByState('USA', 'ID');
        Test.stopTest();
        
        System.assertEquals('Demo', TestAddress[0]);
    }
    
    public static testMethod void filterExactInfoTest() {
        List<Sample_Kit_Shipping_Address__c> AddressList = new List<Sample_Kit_Shipping_Address__c>();
        Sample_Kit_Shipping_Address__c SampleAddress = new Sample_Kit_Shipping_Address__c();
        SampleAddress.Company__c = 'Beam';
        SampleAddress.City__c = 'Test';
        SampleAddress.Zip_Code__c = '12345';
        SampleAddress.Country__c = 'USA';
        SampleAddress.State__c = 'ID';
        SampleAddress.Name = 'Demo';
        SampleAddress.Street__c = 'DemoLane';
        AddressList.add(SampleAddress);
        
        Sample_Kit_Shipping_Address__c TestSampleAddress = new Sample_Kit_Shipping_Address__c();
        TestSampleAddress.Company__c = 'Beam2';
        TestSampleAddress.City__c = 'Test2';
        TestSampleAddress.Zip_Code__c = '22345';
        TestSampleAddress.Country__c = 'Canada';
        TestSampleAddress.State__c = 'AK';
        TestSampleAddress.Name = 'Demo2';
        TestSampleAddress.Street__c = 'DemoLane';
        AddressList.add(TestSampleAddress);
        insert AddressList;
        
        Test.startTest();
            Sample_Kit_Shipping_Address__c TestAddress = SFT_SampleOrderFormController.filterExactInfo('USA', 'ID', 'Demo');
        Test.stopTest();
        
        System.assertEquals('ID', TestAddress.State__c);
    }
    
    public static testMethod void fetchOfficeValuesTest() {
        List<Sample_Kit_Shipping_Address__c> AddressList = new List<Sample_Kit_Shipping_Address__c>();
        Sample_Kit_Shipping_Address__c SampleAddress = new Sample_Kit_Shipping_Address__c();
        SampleAddress.Company__c = 'Beam';
        SampleAddress.City__c = 'Test';
        SampleAddress.Zip_Code__c = '12345';
        SampleAddress.Country__c = 'USA';
        SampleAddress.State__c = 'ID';
        SampleAddress.Name = 'Demo';
        SampleAddress.Street__c = 'DemoLane';
        AddressList.add(SampleAddress);
        
        Sample_Kit_Shipping_Address__c TestSampleAddress = new Sample_Kit_Shipping_Address__c();
        TestSampleAddress.Company__c = 'Beam2';
        TestSampleAddress.City__c = 'Test2';
        TestSampleAddress.Zip_Code__c = '22345';
        TestSampleAddress.Country__c = 'Canada';
        TestSampleAddress.State__c = 'AK';
        TestSampleAddress.Name = 'Demo2';
        TestSampleAddress.Street__c = 'DemoLane';
        AddressList.add(TestSampleAddress);
        insert AddressList;
        
        Test.startTest();
            List<String> TestAddress = SFT_SampleOrderFormController.fetchOfficeValues();
        Test.stopTest();
        
        System.assertEquals(2, TestAddress.size());
    }
    
    public static testMethod void fetchFamilyValuesTest() {
        Sample_Order_Material_Master__c SampleMaterial = new Sample_Order_Material_Master__c();
        SampleMaterial.Brand_Family__c = 'Beam';
        SampleMaterial.Brand_Variety__c = 'Test';
        SampleMaterial.CMIR__c = '12345';
        SampleMaterial.Is_Active__c = true;
        SampleMaterial.Customer_Number__c = '123';
        SampleMaterial.Material_Description__c = 'Demo';
        SampleMaterial.Material_Master_ID__c = 'DemoLane';
        SampleMaterial.Material_Number__c = '12';
        SampleMaterial.Name = 'Dummy';
        SampleMaterial.Sold_to__c = 'Marketing';
        SampleMaterial.Unit_of_measure__c = 'Cases';
        SampleMaterial.Is_Active__c = true;
        insert SampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.fetchFamilyValues();
        Test.stopTest();
        
        System.assertEquals(1, TestMaterial.size());
    }
    
    public static testMethod void fetchVarietyValuesTest() {
        Sample_Order_Material_Master__c SampleMaterial = new Sample_Order_Material_Master__c();
        SampleMaterial.Brand_Family__c = 'Beam';
        SampleMaterial.Brand_Variety__c = 'Test';
        SampleMaterial.CMIR__c = '12345';
        SampleMaterial.Is_Active__c = true;
        SampleMaterial.Customer_Number__c = '123';
        SampleMaterial.Material_Description__c = 'Demo';
        SampleMaterial.Material_Master_ID__c = 'DemoLane';
        SampleMaterial.Material_Number__c = '12';
        SampleMaterial.Name = 'Dummy';
        SampleMaterial.Sold_to__c = 'Marketing';
        SampleMaterial.Unit_of_measure__c = 'Cases';
        SampleMaterial.Is_Active__c = true;
        insert SampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.fetchVarietyValues();
        Test.stopTest();
        
        System.assertEquals(1, TestMaterial.size());
    }
    
    public static testMethod void fetchMaterialDescValuesTest() {
        Sample_Order_Material_Master__c SampleMaterial = new Sample_Order_Material_Master__c();
        SampleMaterial.Brand_Family__c = 'Beam';
        SampleMaterial.Brand_Variety__c = 'Test';
        SampleMaterial.CMIR__c = '12345';
        SampleMaterial.Is_Active__c = true;
        SampleMaterial.Customer_Number__c = '123';
        SampleMaterial.Material_Description__c = 'Demo';
        SampleMaterial.Material_Master_ID__c = 'DemoLane';
        SampleMaterial.Material_Number__c = '12';
        SampleMaterial.Name = 'Dummy';
        SampleMaterial.Sold_to__c = 'Marketing';
        SampleMaterial.Unit_of_measure__c = 'Cases';
        SampleMaterial.Is_Active__c = true;
        insert SampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.fetchMaterialDescValues();
        Test.stopTest();
        
        System.assertEquals(1, TestMaterial.size());
    }
    
    public static testMethod void filterVarietyByFamilyValueTest() {
        Sample_Order_Material_Master__c SampleMaterial = new Sample_Order_Material_Master__c();
        SampleMaterial.Brand_Family__c = 'Beam';
        SampleMaterial.Brand_Variety__c = 'Test';
        SampleMaterial.CMIR__c = '12345';
        SampleMaterial.Is_Active__c = true;
        SampleMaterial.Customer_Number__c = '123';
        SampleMaterial.Material_Description__c = 'Demo';
        SampleMaterial.Material_Master_ID__c = 'DemoLane';
        SampleMaterial.Material_Number__c = '12';
        SampleMaterial.Name = 'Dummy';
        SampleMaterial.Sold_to__c = 'Marketing';
        SampleMaterial.Unit_of_measure__c = 'Cases';
        SampleMaterial.Is_Active__c = true;
        insert SampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.filterVarietyByFamilyValue('Beam','Marketing(222)');
        Test.stopTest();
        
        System.assertEquals('Test', TestMaterial[0]);
    }
    
    public static testMethod void filterMaterialDescByVarietyValueTest() {
        Sample_Order_Material_Master__c SampleMaterial = new Sample_Order_Material_Master__c();
        SampleMaterial.Brand_Family__c = 'Beam';
        SampleMaterial.Brand_Variety__c = 'Test';
        SampleMaterial.CMIR__c = '12345';
        SampleMaterial.Is_Active__c = true;
        SampleMaterial.Customer_Number__c = '123';
        SampleMaterial.Material_Description__c = 'Demo';
        SampleMaterial.Material_Master_ID__c = 'DemoLane';
        SampleMaterial.Material_Number__c = '12';
        SampleMaterial.Name = 'Dummy';
        SampleMaterial.Sold_to__c = 'Marketing';
        SampleMaterial.Unit_of_measure__c = 'Cases';
        SampleMaterial.Is_Active__c = true;
        insert SampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.filterMaterialDescByVarietyValue('Beam', 'Test', 'Marketing(222)');
        Test.stopTest();
        
        System.assertEquals('Demo', TestMaterial[0]);
    }
    
    public static testMethod void filterUnitValuesTest() {
        List<Sample_Order_Material_Master__c> MasterList = new List<Sample_Order_Material_Master__c>();
        Sample_Order_Material_Master__c SampleMaterial = new Sample_Order_Material_Master__c();
        SampleMaterial.Brand_Family__c = 'Beam';
        SampleMaterial.Brand_Variety__c = 'Test';
        SampleMaterial.CMIR__c = '12345';
        SampleMaterial.Is_Active__c = true;
        SampleMaterial.Customer_Number__c = '123';
        SampleMaterial.Material_Description__c = 'Demo';
        SampleMaterial.Material_Master_ID__c = 'DemoLane';
        SampleMaterial.Material_Number__c = '12';
        SampleMaterial.Name = 'Dummy';
        SampleMaterial.Sold_to__c = 'Marketing';
        SampleMaterial.Unit_of_measure__c = 'CS';
        SampleMaterial.Is_Active__c = true;
        MasterList.add(SampleMaterial);
        
        Sample_Order_Material_Master__c TestSampleMaterial = new Sample_Order_Material_Master__c();
        TestSampleMaterial.Brand_Family__c = 'Beam';
        TestSampleMaterial.Brand_Variety__c = 'Test';
        TestSampleMaterial.CMIR__c = '12345';
        TestSampleMaterial.Is_Active__c = true;
        TestSampleMaterial.Customer_Number__c = '123';
        TestSampleMaterial.Material_Description__c = 'Demo';
        TestSampleMaterial.Material_Master_ID__c = 'DemoLane';
        TestSampleMaterial.Material_Number__c = '12';
        TestSampleMaterial.Name = 'Dummy';
        TestSampleMaterial.Sold_to__c = 'Marketing';
        TestSampleMaterial.Unit_of_measure__c = 'EA';
        masterList.add(TestSampleMaterial);
        insert MasterList;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.filterUnitValues('Beam', 'Test', 'Demo');
        Test.stopTest();
        
        System.assertEquals('EA', TestMaterial[1]);
    }
    
    public static testMethod void filterMaterialNoByDescValueTest() {
        Sample_Order_Material_Master__c TestSampleMaterial = new Sample_Order_Material_Master__c();
        TestSampleMaterial.Brand_Family__c = 'Beam';
        TestSampleMaterial.Brand_Variety__c = 'Test';
        TestSampleMaterial.CMIR__c = '12345';
        TestSampleMaterial.Is_Active__c = true;
        TestSampleMaterial.Customer_Number__c = '123';
        TestSampleMaterial.Material_Description__c = 'Demo';
        TestSampleMaterial.Material_Master_ID__c = 'DemoLane';
        TestSampleMaterial.Material_Number__c = '12';
        TestSampleMaterial.Name = 'Dummy';
        TestSampleMaterial.Sold_to__c = 'Marketing';
        TestSampleMaterial.Unit_of_measure__c = 'Cases';
        TestSampleMaterial.Is_Active__c = true;
        insert TestSampleMaterial;
        
        Test.startTest();
            Sample_Order_Material_Master__c TestMaterial = SFT_SampleOrderFormController.filterMaterialNoByDescValue('Beam', 'Test', 'Demo', 'Marketing(222)');
        Test.stopTest();
        
        System.assertEquals('12', TestMaterial.Material_Number__c);
    }
    
    public static testMethod void filterAllSoldToValuesTest() {
        Sample_Order_Material_Master__c TestSampleMaterial = new Sample_Order_Material_Master__c();
        TestSampleMaterial.Brand_Family__c = 'Beam';
        TestSampleMaterial.Brand_Variety__c = 'Test';
        TestSampleMaterial.CMIR__c = '12345';
        TestSampleMaterial.Is_Active__c = true;
        TestSampleMaterial.Customer_Number__c = '123';
        TestSampleMaterial.Material_Description__c = 'Demo';
        TestSampleMaterial.Material_Master_ID__c = 'DemoLane';
        TestSampleMaterial.Material_Number__c = '12';
        TestSampleMaterial.Name = 'Dummy';
        TestSampleMaterial.Sold_to__c = 'Marketing';
        TestSampleMaterial.Unit_of_measure__c = 'Cases';
        TestSampleMaterial.Is_Active__c = true;
        insert TestSampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.filterAllSoldToValues();
        Test.stopTest();
        
        System.assertEquals(1, TestMaterial.size());
    }
    
    public static testMethod void filterFamilyValueBySoldToTest() {
        Sample_Order_Material_Master__c TestSampleMaterial = new Sample_Order_Material_Master__c();
        TestSampleMaterial.Brand_Family__c = 'Beam';
        TestSampleMaterial.Brand_Variety__c = 'Test';
        TestSampleMaterial.CMIR__c = '12345';
        TestSampleMaterial.Is_Active__c = true;
        TestSampleMaterial.Customer_Number__c = '123';
        TestSampleMaterial.Material_Description__c = 'Demo';
        TestSampleMaterial.Material_Master_ID__c = 'DemoLane';
        TestSampleMaterial.Material_Number__c = '12';
        TestSampleMaterial.Name = 'Dummy';
        TestSampleMaterial.Sold_to__c = 'Marketing';
        TestSampleMaterial.Unit_of_measure__c = 'Cases';
        TestSampleMaterial.Is_Active__c = true;
        insert TestSampleMaterial;
        
        Test.startTest();
            List<String> TestMaterial = SFT_SampleOrderFormController.filterFamilyValueBySoldTo('Marketing(222)');
        Test.stopTest();
        
        System.assertEquals('Beam', TestMaterial[0]);
    }
    
    public static testMethod void getCountryStateTest() {
        Country_State__c TestState = new Country_State__c();
        TestState.Name = 'Arizona';
        TestState.Abbreviations__c = 'AZ';
        TestState.Country__c = 'USA';
        insert TestState;
        
        Test.startTest();
            List<String> TestCountry = SFT_SampleOrderFormController.getCountryState('USA');
        Test.stopTest();
        
        System.assertEquals('Arizona', TestCountry[0]);
    }
    
    public static testMethod void getStateFullNameTest() {
        Country_State__c TestState = new Country_State__c();
        TestState.Name = 'Arizona';
        TestState.Abbreviations__c = 'AZ';
        TestState.Country__c = 'USA';
        insert TestState;
        
        Test.startTest();
            String TestCountry = SFT_SampleOrderFormController.getStateFullName('AZ');
        Test.stopTest();
        
        System.assertEquals('Arizona', TestCountry);
    }

    public static testMethod void saveCaseTest() {
        
        List<SFT_SampleOrderFormController.OrderInformationTable> TestOrderLst = new List<SFT_SampleOrderFormController.OrderInformationTable>();
        SFT_SampleOrderFormController.OrderInformationTable TestOrder = new SFT_SampleOrderFormController.OrderInformationTable();
        List<String> TestBrandList = new List<String>();
        List<SFT_SampleOrderFormController.SelectOptions> testOptions = new List<SFT_SampleOrderFormController.SelectOptions>();
        TestOrder.brandFamily = 'Makers Mark';
        TestOrder.brandVariety = 'MM B';
        TestOrder.materialDesc = 'Old sweet';
        TestOrder.materialNo = '2021/12/1';
        TestOrder.cmir = '12';
        TestOrder.qty = 'sd12';
        TestOrder.unit = '12';
        TestOrder.brandVarietyList = testOptions;
        TestOrder.materialDescList = testOptions;
        TestOrderLst.add(TestOrder);

		Test.startTest();
            SFT_SampleOrderFormController.SampleOrderWrapper SampleOrderWrapper = new SFT_SampleOrderFormController.SampleOrderWrapper();
            SampleOrderWrapper.avail = '';
            SampleOrderWrapper.mailroom = '';
            SampleOrderWrapper.req = '';
            SampleOrderWrapper.normalTime = true;
            SampleOrderWrapper.expedited = '';
            SampleOrderWrapper.beamCanada = true;
            SampleOrderWrapper.wbs = '';
            SampleOrderWrapper.notes = '';
            SampleOrderWrapper.courier = '';
            SampleOrderWrapper.submittedBy = '';
            SampleOrderWrapper.email = '';
            SampleOrderWrapper.sampleType = '';
            SampleOrderWrapper.phone = '';
            SampleOrderWrapper.purpose = '';
            SampleOrderWrapper.soldTo = '';
            SampleOrderWrapper.cost = '';
            SampleOrderWrapper.gl = '';
            SampleOrderWrapper.shipTo = '';
            SampleOrderWrapper.company = '';
            SampleOrderWrapper.attn = '';
            SampleOrderWrapper.addr = '';
            SampleOrderWrapper.city = '';
            SampleOrderWrapper.country = '';
            SampleOrderWrapper.state = '';
            SampleOrderWrapper.zip = '';
            SampleOrderWrapper.pho = '';
            SampleOrderWrapper.lss = testOrderLst;
        	SampleOrderWrapper.estimatedValueYes_NO = '';
        	SampleOrderWrapper.estimatedInputValue = '';
            String TestJSONString = JSON.serialize(SampleOrderWrapper);
            SFT_SampleOrderFormController.saveCase(TestJSONString);
		Test.stopTest();
        
		List<CASE> TestCase = [Select Id FROM CASE];
        System.assertEquals(1, TestCase.size());
	}
    
    public static testMethod void getPicklistValuesTest() {
        
        Test.startTest();
            List<SFT_SampleOrderFormController.SelectOptions> TestValues = new List<SFT_SampleOrderFormController.SelectOptions>();
            TestValues = SFT_SampleOrderFormController.getPicklistValues('Sample_Kit_Shipping_Address__c', 'Country__c');
        Test.stopTest();
        
        System.assertEquals(2,TestValues.size());
    }
    
    public static testMethod void sendEmailToSubmitterTest() {
        Case TestCase = new Case();
        TestCase.Submitted_By__c = 'Test Demo';
        insert TestCase;
        
        Blob testBlobValue ;
        String fileName = 'Demo';
        String str = 'Test';
        testBlobValue = Blob.valueOf(str);
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = testBlobValue;
        ContVerFile.Title = fileName; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient=fileName + '.pdf';
        insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
        ContentDocumentLink Cde = new ContentDocumentLink();
        Cde.ContentDocumentId = conDoc;
        Cde.LinkedEntityId = TestCase.Id;
        Cde.ShareType = 'V';
        Cde.Visibility = 'AllUsers';
        insert Cde;
        
        Test.startTest();
            SFT_SampleOrderFormController.sendEmailToSubmitter(TestCase.Id);
        Test.stopTest();
        
        System.assertEquals(true, TestCase != null);
    }

}