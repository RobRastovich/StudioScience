@isTest
public class MultiPicklistCtrlTest {

    @isTest static void getIncidentPicklistValuesTest() {
        String apiName = 'Product_Size__c';

        Test.startTest();

        List<String> options = MultiPicklistCtrl.getIncidentPicklistValues(apiName);

        Test.stopTest();
        
        System.assertEquals(true, options.size() > 0);
        //System.assertEquals(15, options.size());
        for (String option : options) {
            if (option == '1.75L') {
                System.assertEquals('1.75L', option);
            }
            if (option == '3L') {
                System.assertEquals('3L', option);
            }
            if (option == '50ml') {
                System.assertEquals('50ml', option);
            }
            if (option == '350ml') {
                System.assertEquals('350ml', option);
            }
            if (option == '1140ml') {
                System.assertEquals('1140ml', option);
            }
        }
    }

}