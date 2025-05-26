@isTest
public class SampleOrderPDFForEskerControllerTest {
    
    public static testMethod void SampleOrderPDFControllerTest() {
        
        List<SFT_SampleOrderFormController.OrderInformationTable> testOrderLst = new List<SFT_SampleOrderFormController.OrderInformationTable>();
        SFT_SampleOrderFormController.OrderInformationTable testOrder = new SFT_SampleOrderFormController.OrderInformationTable();
        List<String> testBrandList = new List<String>();
        List<SFT_SampleOrderFormController.SelectOptions> testOptions = new List<SFT_SampleOrderFormController.SelectOptions>();
        testOrder.brandFamily = 'Makers Mark';
        testOrder.brandVariety = 'MM B';
        testOrder.materialDesc = 'Old sweet';
        testOrder.materialNo = '2021/12/1';
        testOrder.cmir = '12';
        testOrder.qty = 'sd12';
        testOrder.unit = '12';
        testOrder.brandVarietyList = testOptions;
        testOrder.materialDescList = testOptions;
        testOrderLst.add(testOrder);
        
        SFT_SampleOrderFormController.SampleOrderWrapper sampleOrderWrapper = new SFT_SampleOrderFormController.SampleOrderWrapper();
        sampleOrderWrapper.avail = '';
        sampleOrderWrapper.mailroom = '';
        sampleOrderWrapper.req = '';
        sampleOrderWrapper.normalTime = true;
        sampleOrderWrapper.expedited = '';
        sampleOrderWrapper.beamCanada = true;
        sampleOrderWrapper.wbs = '';
        sampleOrderWrapper.notes = '';
        sampleOrderWrapper.courier = '';
        sampleOrderWrapper.submittedBy = '';
        sampleOrderWrapper.email = '';
        sampleOrderWrapper.sampleType = '';
        sampleOrderWrapper.phone = '';
        sampleOrderWrapper.purpose = '';
        sampleOrderWrapper.soldTo = 'Sales(1123)';
        sampleOrderWrapper.cost = '';
        sampleOrderWrapper.gl = '';
        sampleOrderWrapper.shipTo = '';
        sampleOrderWrapper.company = '';
        sampleOrderWrapper.attn = '';
        sampleOrderWrapper.addr = '';
        sampleOrderWrapper.city = '';
        sampleOrderWrapper.country = '';
        sampleOrderWrapper.state = '';
        sampleOrderWrapper.zip = '';
        sampleOrderWrapper.pho = '';
        sampleOrderWrapper.lss = testOrderLst;
        String testJSONString = JSON.serialize(sampleOrderWrapper);
        Case testCase = new Case();
        testCase.Sample_Order_Information__c = testJSONString;
        insert testCase;
        
        Test.startTest();
        
        	PageReference pageRef = Page.SampleOrderPDFForEsker;
        	test.setCurrentPageReference(pageRef);
        	pageRef.getParameters().put('id', testCase.Id);
        	SampleOrderPDFForEskerController testObject = new SampleOrderPDFForEskerController();
        
        Test.stopTest();
        
        System.assertEquals(true, testObject!=null);
    }

}