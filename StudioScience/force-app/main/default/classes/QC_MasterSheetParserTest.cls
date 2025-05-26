@isTest
public class QC_MasterSheetParserTest {

        public static Id factsRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('FACTS').getRecordTypeId();
        public static Id distributorRecordType = Schema.SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();

	@testSetup static void setupMasterSheetParser() {

        	Incident__c parentIncident = new Incident__c();
                parentIncident.RecordTypeId = factsRecordType;
                insert parentIncident;

                List<Account> testAccounts = new List<Account>();

                Account testAccount1 = new Account();
                testAccount1.Name = 'CONNECTICUT DISTRIBUTORS INC';
                testAccounts.add(testAccount1);

                Account testAccount2 = new Account();
                testAccount2.Name = 'HORIZON BEVERAGE OF RI';
                testAccounts.add(testAccount2);

                Account testAccount3 = new Account();
                testAccount3.Name = 'IN SF W ACCOUNT';
                testAccounts.add(testAccount3);

                insert testAccounts;

                List<Incident__c> existingSubincidents = new List<Incident__c>();

                Incident__c distributorIncident1 = new Incident__c();
                distributorIncident1.RecordTypeId = distributorRecordType;
                distributorIncident1.Account__c = testAccount3.Id;
                distributorIncident1.Parent_Incident__c = parentIncident.Id;
                existingSubincidents.add(distributorIncident1);

                Incident__c distributorIncident2 = new Incident__c();
                distributorIncident2.RecordTypeId = distributorRecordType;
                distributorIncident2.Account_Name__c = 'IN SF NO ACCOUNT';
                distributorIncident2.Parent_Incident__c = parentIncident.Id;
                existingSubincidents.add(distributorIncident2);

                insert existingSubincidents;

	}

	@isTest static void parseFileTest() {
		Incident__c inc = [SELECT Id FROM Incident__c LIMIT 1];
		String s = 'Ship Date,Order Number,Delivery Number,Customer*,Ship To Country,State (US ONLY),Item#/SKU,Product Description,Lot Code,# of Cases Shipped\n'+
					'7/23/2018,D270443138,1024503150,CONNECTICUT DISTRIBUTORS INC,United States,CT,US112938,JB HONEY 50X120 35% 7H,L8190FFX,16\n'+
					'11/23/2019,D269465662,1024501522,HORIZON BEVERAGE OF RI,United States,RI,US112938,JB HONEY 50X120 35% 7H,L8190FFX,108\n'+
					'11/29/2019,D269465362,1024501322,Fake Account,United States,MN,US112938,JB HONEY 50X120 35% 7H,L8190FFX,101\n'+
					'12/24/2019,D269465664,1024501524,HORIZON BEVERAGE OF RI,United States,RI,US112938,JB HONEY 50X120 35% 7H,L8190FFX,150\n'+
					'11/30/2019,D269465363,1024501323,Fake Account,United States,MN,US112938,JB HONEY 50X120 35% 7H,L8190FFX,103\n'+
					'8/23/2018,D270443139,1024503151,IN SF W ACCOUNT,United States,CA,US112938,JB HONEY 50X120 35% 7H,L8190FFX,161\n'+
					'7/27/2018,D270443131,1024503152,IN SF NO ACCOUNT,United States,MA,US112938,JB HONEY 50X120 35% 7H,L8190FFX,169';
		
		Test.startTest();

		QC_MasterSheetParser.parseFile(s, String.valueOf(inc.Id));

		Test.stopTest();

		List<Incident__c> subincidents = [SELECT Id, Account__c, Account_Name__c, Parent_Incident__c FROM Incident__c WHERE Parent_Incident__c = :inc.Id];
		List<Case> cases = [SELECT Id, Incident__c FROM Case WHERE Incident__c IN :subincidents];
                List<Account> accounts = [SELECT Id, Name FROM Account];

		System.assertEquals(5, subincidents.size());
		System.assertEquals(7, cases.size());

                Integer countOfCTDist = 0;
                Integer countOfHorizonBev = 0;
                Integer countOfFakeAccount = 0;
                Integer countOfInSFWAccount = 0;
                Integer countOfInSFNoAccount = 0;

                for (Incident__c subincident : subincidents) {
                        if (subincident.Account__c != null) {
                                for (Account account : accounts) {
                                        if (subincident.Account__c == account.Id && account.Name == 'CONNECTICUT DISTRIBUTORS INC') {
                                                countOfCTDist++;
                                        }
                                        if (subincident.Account__c == account.Id && account.Name == 'HORIZON BEVERAGE OF RI') {
                                                countOfHorizonBev++;
                                        }
                                        if (subincident.Account__c == account.Id && account.Name == 'IN SF W ACCOUNT') {
                                                countOfInSFWAccount++;
                                        }
                                }
                        }
                        else if (!String.isBlank(subincident.Account_Name__c)) {
                                if (subincident.Account_Name__c == 'IN SF NO ACCOUNT') {
                                        countOfInSFNoAccount++;
                                }
                                if (subincident.Account_Name__c == 'Fake Account') {
                                        countOfFakeAccount++;
                                }
                        }
                }

                System.assertEquals(1, countOfCTDist);
                System.assertEquals(1, countOfHorizonBev);
                System.assertEquals(1, countOfFakeAccount);
                System.assertEquals(1, countOfInSFWAccount);
                System.assertEquals(1, countOfInSFNoAccount);

                for (Case c : cases) {
                        System.assertNotEquals(null, c.Incident__c);
                }
	}
}