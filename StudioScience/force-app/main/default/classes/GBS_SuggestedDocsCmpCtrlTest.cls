@isTest
    private class GBS_SuggestedDocsCmpCtrlTest {

            @isTest(SeeAllData = true)
            public static void getSuggestedDocsTest() {

                Test.startTest();

                LightningComponentUtility.RequestStatus response = GBS_SuggestedDocsCmpCtrl.getSuggestedDocs('PTO', '');

                Test.stopTest();

                System.assertNotEquals(NULL, response.responseMap.get('links'), 'Links should not be empty');
            }
    }