@isTest
public class ClonedMilestoneTest {

	@testSetup static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
		//insert u;

		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

		caseServices.runTrigger = false;

		Account acct = new Account();
		acct.Name = 'Test Account';
		insert acct;

		Case c = new Case();
		c.Status = 'New';
		c.Subject = 'Test Case';
		c.AccountId = acct.Id;
		c.Submitter__c = UserInfo.getUserId();
		c.Beam_Suntory_Item_Number__c = '111';
		c.RecordTypeId = recordTypeId;
		c.Product_Destination_Country__c = 'Sri Lanka';
		insert c;



		//List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);

	}

	public static List<Case> createChildCaseRecords(String recordTypeName, String status, Id parentId, Integer numOfChildRecords, Boolean autoCreate) {
		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		List<Case> casesToInsert = new List<Case>();
		Case parentCase = new Case();
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.AssignmentRuleHeader.useDefaultRule = true;

		for (Integer i = 0; i < numOfChildRecords; i++) {
			Case c = new Case();
			c.Status = status;
			c.ParentId = parentId;
			c.RecordTypeId = recordTypeId;
			//c.setOptions(dmo);
			casesToInsert.add(c);
		}

		if (autoCreate) {
			insert casesToInsert;
		}

		return casesToInsert;
	}

	public static List<Case> getCasesById(Set<Id> caseIds) {
		return [select id
		        , All_Sub_Cases_Closed__c
		        , Shipping_Plant__c
		        , isReOpened__c
		        , Expedited_Claim__c
		        , BusinessHoursId
		        , BusinessHours.Name
		        , Owner.Name
		        , OwnerId
		        , Financial_Disposition__c
		        , Return_SAP_Number__c
		        , Entitlement.Name from Case where Id IN :caseIds];
	}

	public static List<Case> getCasesByBeamItemNumber(String orderNumber) {
		return [select id
		        , All_Sub_Cases_Closed__c
		        , Shipping_Plant__c
		        , isReOpened__c
		        , Expedited_Claim__c
		        , BusinessHoursId
		        , BusinessHours.Name
		        , Owner.Name
		        , OwnerId
		        , Beam_Suntory_Item_Number__c
		        , Financial_Disposition__c
		        , Return_SAP_Number__c
		        , ccEmail__c
		        , Entitlement.Name from Case where Beam_Suntory_Item_Number__c = :orderNumber];
	}
	public static List<CaseMilestone> getCaseMilestoneByCaseId(Set<Id> caseIds) {
		return [select Id
		        , StartDate
		        , TargetDate
		        , CompletionDate
		        , MilestoneTypeId
		        , MilestoneType.Name
		        , IsCompleted
		        , BusinessHoursId
		        , CaseId
		        , Case.Status
		        , Case.RecordTypeId
		        , TargetResponseInMins
		        , TimeSinceTargetInMins
		        , TargetResponseInHrs
		        , TargetResponseInDays
		        , TimeRemainingInMins
		        , IsViolated FROM CaseMilestone where CaseId IN : caseIds];
	}

	public static testMethod void testBuildCloneMilestone() {

		Test.startTest();

		Case parentCase = getCasesByBeamItemNumber('111')[0];

		List<CaseMilestone> cm = getCaseMilestoneByCaseId(new Set<Id> {parentCase.Id});

		System.assertEquals(1, cm.size());

		List<Cloned_Milestone__c> clonedMilestones = ClonedMilestone.buildAndUpdateClonedMilestones(cm);

		Test.stopTest();

	}
}