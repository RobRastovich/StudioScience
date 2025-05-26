public without sharing class INT_Managers {
    public class SyncSharingGroupMembership implements TriggerAction.AfterUpdate, TriggerAction.AfterInsert, TriggerAction.AfterDelete {
        public void afterUpdate(List<INT_Manager__c> newList, List<INT_Manager__c> oldList) {
            INT_ManagerService.syncSharingGroupMembership(newList, new Map<Id,INT_Manager__c>(oldList));
        }

        public void afterInsert(List<INT_Manager__c> newList) {
            INT_ManagerService.syncSharingGroupMembership(newList, new Map<Id,INT_Manager__c>());
        }

        public void afterDelete(List<INT_Manager__c> oldList) {
            INT_ManagerService.syncSharingGroupMembership(oldList, new Map<Id,INT_Manager__c>());
        }
    }
}