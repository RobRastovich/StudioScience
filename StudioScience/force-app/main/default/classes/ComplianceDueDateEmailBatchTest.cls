@isTest (SeeAllData=false)
public class ComplianceDueDateEmailBatchTest {
	public static testMethod void testConstructor(){
		ComplianceDueDateEmailBatch con = new ComplianceDueDateEmailBatch();
	}

	public static testMethod void executeBatchPricePosting(){

		List<Case> pricePostingCaseList = new List<Case>();
		for(Integer i = 1; i < 8; i++){
			Case pricePostingCase = CaseComplianceUtilityTest.createPricePostingCase();
			pricePostingCase.Submitted_Compliance__c = false;
			pricePostingCase.Posting_Date__c= System.today()+i;
			pricePostingCaseList.add(pricePostingCase);
		}
		insert pricePostingCaseList;

		Test.startTest();

		ComplianceDueDateEmailBatch b = new ComplianceDueDateEmailBatch();
		DataBase.executeBatch(b);

		Test.stopTest();
	}

	public static testMethod void executeBatchBrandRegistration(){

		List<Case> brandRegCaseList = new List<Case>();
		Case brandRegCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
		brandRegCase.Submitted_Compliance__c = false;
		brandRegCase.Due_Date__c= System.today();
		brandRegCase.Status = 'Waiting for Sub Cases';
		brandRegCaseList.add(brandRegCase);
		insert brandRegCaseList;

		Test.startTest();

		ComplianceDueDateEmailBatch b = new ComplianceDueDateEmailBatch();
		DataBase.executeBatch(b);

		Test.stopTest();
	}

	public static testMethod void executeBatchSubCases(){

		List<Case> brandRegCaseList = new List<Case>();
		Case brandRegCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
		brandRegCaseList.add(brandRegCase);
		insert brandRegCaseList;

		List<Case> subCaseList = new List<Case>();
		for(Integer i = 1; i < 8; i++){
			Case brandRegSubCase = CaseComplianceUtilityTest.createBrandRegistrationComplianceSubCase(brandRegCase.Id, 'Arizona');
			brandRegSubCase.Submitted_Compliance__c = false;
			brandRegSubCase.Due_Date__c= System.today()+i;
			subCaseList.add(brandRegSubCase);
		}
		insert subCaseList;

		for(Case c: subCaseList){
			c.OwnerId = UserInfo.getUserId();
		}
		update subCaseList;

		Test.startTest();

		ComplianceDueDateEmailBatch b = new ComplianceDueDateEmailBatch();
		DataBase.executeBatch(b);

		Test.stopTest();
	}
}