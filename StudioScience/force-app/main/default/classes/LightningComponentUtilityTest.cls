@isTest
private class LightningComponentUtilityTest {

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

	public static testMethod void testGetLabelMap() {
		LightningComponentUtility.RequestStatus requestStatus;

		Test.startTest();

		requestStatus = OrderClaimComponentController.getClaimsIdLabelMap();

		Test.stopTest();

		System.assertEquals(true, requestStatus.responseMap.containsKey('labelMap'));
	}

	@isTest(SeeAllData = true)
	public static void getListViewTest() {
		LightningComponentUtility.RequestStatus requestStatus;

		Test.startTest();

		ListView listview = LightningComponentUtility.getListView('My Open Cases', 'Case');

		Test.stopTest();

		System.assertNotEquals(NULL, listview);
	}
}