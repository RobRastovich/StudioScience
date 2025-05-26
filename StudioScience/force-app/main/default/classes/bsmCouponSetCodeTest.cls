@isTest
private class bsmCouponSetCodeTest {
    @isTest static void test_method_bsmCoupon() {
        // Run as a user
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@beamsuntory.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias='TestMX', Email='testUser@beamsuntory.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Chicago',UserName=uniqueUserName);

        System.runAs(u) {

            // Create Test data- Account
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MX On-Premise').getRecordTypeId();
            Account acct= new Account();
            acct.name='Test Mexico On-Premise';
            acct.recordTypeId= accRecordTypeId;
            insert acct;
    
            //Create Contact Data
            Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();
            Contact accCnt= new Contact();
            accCnt.lastName = 'Test';
            accCnt.firstName ='Contact';
            accCnt.accountId = acct.Id;
            accCnt.recordTypeId = conRecordTypeId;
            accCnt.email = 'Test@test.com';
            insert accCnt;
                
            // Create Bonus Coupon Data
            Bonus_Coupon__c bc = new Bonus_Coupon__c();
            bc.account__c= acct.Id;
            bc.contact__c= accCnt.Id;
            bc.amount__c=1500.00;
            bc.redemption_Start_Date__C= Date.newInstance(2018, 03, 10);
            bc.redemption_End_Date__c = Date.newInstance(2018, 05, 10);
            bc.date_time_issued__c= Date.today();
            insert bc;
                          
            // Verification
            bc = [SELECT Coupon_Code__c FROM Bonus_Coupon__c WHERE Id = :bc.Id];
            System.assertEquals(10, bc.Coupon_Code__c.length(), 'Length is 10');
        }
    }
}