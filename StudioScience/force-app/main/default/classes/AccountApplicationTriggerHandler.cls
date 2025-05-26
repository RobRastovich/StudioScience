public class AccountApplicationTriggerHandler {
	public static void handleBeforeInsert(List<Account_Application__c> apps) {
		AccountApplicationServices.updateRegionalDiplomat(apps);
	}

	public static void handleBeforeUpdate(List<Account_Application__c> apps, Map<Id, Account_Application__c> oldApps) {
		AccountApplicationServices.createCaseOnApplicationApproval(apps, oldApps);
		AccountApplicationServices.approveApprovalProcess(apps, oldApps);
	}
	public static void handleAfterUpdate(List<Account_Application__c> apps, Map<Id, Account_Application__c> oldApps) {
		AccountApplicationServices.accountApplicationApprovedEmail(apps, oldApps);
	}
/*
	public static void handleBeforeDelete(List<Account_Application__c> apps, Map<Id, Account_Application__c> oldApps) {
	}

	public static void handleAfterInsert(List<Account_Application__c> apps, Map<Id, Account_Application__c> newApps) {
	}

	*/
}