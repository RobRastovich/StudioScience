@isTest
    private class ComboInputCmpCtrlTest {

            @isTest(SeeAllData = true)
            public static void getPicklistOptionsTest() {

                Test.startTest();

                LightningComponentUtility.RequestStatus response = ComboInputCmpCtrl.getPicklistOptions('Type','Case');

                Test.stopTest();

                System.assertNotEquals(NULL, response.responseMap.get('picklistValues'), 'Picklist values should not be empty');
            }
    }