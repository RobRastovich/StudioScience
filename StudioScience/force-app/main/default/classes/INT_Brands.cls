public without sharing class INT_Brands {
    public class SyncPublicGroups implements TriggerAction.AfterUpdate, TriggerAction.AfterInsert {
        public void afterUpdate(List<INT_Brand__c> newList, List<INT_Brand__c> oldList) {
            INT_BrandService.syncPublicGroups(newList, new Map<Id, INT_Brand__c>(oldList));
        }

        public void afterInsert(List<INT_Brand__c> newList) {
            INT_BrandService.syncPublicGroups(newList, new Map<Id, INT_Brand__c>());
        }
    }
}