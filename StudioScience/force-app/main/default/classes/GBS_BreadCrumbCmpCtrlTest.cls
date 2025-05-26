@isTest
private class GBS_BreadCrumbCmpCtrlTest {
        @testSetup static void setup() {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

            User u = new User();
            u.Alias = 'beamtu';
            u.Email = 'standarduser@testorg.com';
            u.EmailEncodingKey = 'UTF-8';
            u.LastName = 'Test';
            u.FirstName = 'Test';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
            u.ProfileId = p.Id;
            u.TimeZoneSidKey = 'America/Chicago';
            u.UserName = 'beamsuntorytestuser@test-user-system.com.test-only';
            insert u;
        }

        @isTest
        public static void getCaseFieldLabelsTest() {

            Map<String, String> fieldMap = new Map<String, String>{
                'Type'=> 'type',
                'Category_1__c' => 'primary',
                'Category_2__c' => 'secondary',
                'Category_3__c' => 'tertiary'
            };

            Test.startTest();

            LightningComponentUtility.RequestStatus response = GBS_BreadCrumbCmpCtrl.getCaseFieldLabels(fieldMap);

            Test.stopTest();

            System.assertNotEquals(NULL, response.responseMap.get('fieldMap'), 'fieldmap should be populated');
        }
}