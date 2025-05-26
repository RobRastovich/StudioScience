@isTest
private class TestBSMEmailHelper {
	
	@isTest static void test_method_ContactWithEmail() {

		// Run as a user
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@beamsuntory.com';
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias='TestMX', Email='testUser@beamsuntory.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                  LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Chicago',UserName=uniqueUserName);
		
		System.runAs(u) {

			// Create Test data- Account
		List <RecordType> rtypes  = [Select Id From RecordType where sObjectType='Account' and isActive=true and name = 'On-Premise Chain HQ' limit 1]; 
		ID accRecordTypeId = rtypes[0].id;
		//Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('On-Premise Chain HQ').getRecordTypeId();
		Account acct= new Account();
		acct.name=' Test Mexico On-Premise';
		acct.recordTypeId= accRecordTypeId;
		insert acct;

		//Create Contact Data

		Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();
		Contact accCnt= new Contact();
		accCnt.lastName= 'Test';
		accCnt.firstName='Contact';
		accCnt.accountId= acct.Id;
		accCnt.recordTypeId=conRecordTypeId;
		accCnt.email='Test@beamsuntory.com';
		insert accCnt;

		// Create Bonus Coupon Data

		Bonus_Coupon__c bc = new Bonus_Coupon__c();
		bc.account__c= acct.Id;
		bc.contact__c= accCnt.Id;
		bc.amount__c=1500.00;
		bc.redemption_Start_Date__C= Date.newInstance(2018, 03, 10);
		bc.redemption_End_Date__c = Date.newInstance(2018, 05, 10);
		bc.coupon_code__c= 'TESTBSMESP';
		bc.date_Issued__c= Date.today();
		insert bc;

		Test.startTest();

			ApexPages.StandardController sc= new ApexPages.StandardController(bc);
			BSMemailHelper testEmail = new BSMemailHelper(sc);
			testEmail.sendApexEmail();

		Test.stopTest();

		}
	}
	
	@isTest static void test_method_ContactWithoutEmail() {
		
		// Run as a user
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@beamsuntory.com';
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias='TestMX', Email='testUser@beamsuntory.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                  LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Chicago',UserName=uniqueUserName);
		
		System.runAs(u) {

			// Create Test data- Account
		List <RecordType> rtypes  = [Select Id From RecordType where sObjectType='Account' and isActive=true and name = 'On-Premise Chain HQ' limit 1]; 
		ID accRecordTypeId = rtypes[0].id;
		//Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('On-Premise Chain HQ').getRecordTypeId();

		Account acct= new Account();
		acct.name=' Test Mexico On-Premise';
		acct.recordTypeId= accRecordTypeId;
		insert acct;

		//Create Contact Data

		Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();
		Contact accCnt= new Contact();
		accCnt.lastName= 'Test';
		accCnt.firstName='Contact';
		accCnt.accountId= acct.Id;
		accCnt.email='test@beamsuntory.com';
		accCnt.recordTypeId=conRecordTypeId;
		insert accCnt;

		// Create Bonus Coupon Data

		Bonus_Coupon__c bc = new Bonus_Coupon__c();
		bc.account__c= acct.Id;
		bc.contact__c= accCnt.Id;
		bc.amount__c=1500.00;
		bc.redemption_Start_Date__C= Date.newInstance(2018, 03, 10);
		bc.redemption_End_Date__c = Date.newInstance(2018, 05, 10);
		bc.coupon_code__c= 'TESTBSMESP';
		bc.date_Issued__c= Date.today();
		insert bc;

		//Update contact email to empty
		accCnt.email ='';
		update accCnt;

		Test.startTest();

			ApexPages.StandardController sc= new ApexPages.StandardController(bc);
			BSMemailHelper testEmail = new BSMemailHelper(sc);
			testEmail.emailuser=true;
			testEmail.sendApexEmail();

		Test.stopTest();

		}
	}

	@isTest static void test_method_Cancel() {
		
		// Run as a user
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@beamsuntory.com';
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias='TestMX', Email='testUser@beamsuntory.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		                  LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Chicago',UserName=uniqueUserName);
		

		System.runAs(u) {

		// Create Test data- Account
		List <RecordType> rtypes  = [Select Id From RecordType where sObjectType='Account' and isActive=true and name = 'On-Premise Chain HQ' limit 1]; 
		ID accRecordTypeId = rtypes[0].id;
		//ID accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('On-Premise Chain HQ').getRecordTypeId();
		Account acct= new Account();
		acct.name=' Test Mexico On-Premise';
		acct.recordTypeId= accRecordTypeId;
		insert acct;

		//Create Contact Data

		Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Account Contact').getRecordTypeId();
		Contact accCnt= new Contact();
		accCnt.lastName= 'Test';
		accCnt.firstName='Contact';
		accCnt.accountId= acct.Id;
		accCnt.email='test@beamsuntory.com';
		accCnt.recordTypeId=conRecordTypeId;
		insert accCnt;

		// Create Bonus Coupon Data

		Bonus_Coupon__c bc = new Bonus_Coupon__c();
		bc.account__c= acct.Id;
		bc.contact__c= accCnt.Id;
		bc.amount__c=1500.00;
		bc.redemption_Start_Date__C= Date.newInstance(2018, 03, 10);
		bc.redemption_End_Date__c = Date.newInstance(2018, 05, 10);
		bc.coupon_code__c= 'TESTBSMESP';
		bc.date_Issued__c= Date.today();
		insert bc;

		//Update contact to empty
		bc.contact__c =null;
		update bc;

		Test.startTest();

			ApexPages.StandardController sc= new ApexPages.StandardController(bc);
			BSMemailHelper testEmail = new BSMemailHelper(sc);
			testEmail.cancel();

		Test.stopTest();


		}
	}
	
}