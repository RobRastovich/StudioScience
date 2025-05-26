@isTest
public with sharing class QC_FACTSInfoInputCtrlTest {
	@isTest static void getPicklistOptionsTest() {
		
		LightningComponentUtility.RequestStatus response;

		Test.startTest();

		response = QC_FACTSInfoInputCtrl.getPicklistOptions();

		Test.stopTest();

		System.assertNotEquals(null, response.responseMap.get('picklistFields'));
	}

	@isTest static void getPicklistOptionsExceptionTest() {
		
		LightningComponentUtility.RequestStatus response;

		Test.startTest();
		QC_FACTSInfoInputCtrl.forceException = true;

		response = QC_FACTSInfoInputCtrl.getPicklistOptions();

		Test.stopTest();
	}
}