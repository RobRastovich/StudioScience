public without sharing class INT_EmailDeliveries {
    public class SetOwnership implements TriggerAction.BeforeUpdate {
        public void beforeUpdate(List<INT_EmailDelivery__c> newList, List<INT_EmailDelivery__c> oldList) {
            INT_EmailDeliveryService.setOwnership(newList, new Map<Id, INT_EmailDelivery__c>(oldList));
        }
    }

    public class SendNotifications implements TriggerAction.AfterUpdate {
        public void afterUpdate(List<INT_EmailDelivery__c> newList, List<INT_EmailDelivery__c> oldList) {
            INT_EmailDeliveryService.sendNotifications(newList, new Map<Id, INT_EmailDelivery__c>(oldList));
        }
    }

    public class SetBrandId implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
        public void beforeInsert(List<INT_EmailDelivery__c> newList) {
            INT_EmailDeliveryService.setBrandId(newList);
        }
        
        public void beforeUpdate(List<INT_EmailDelivery__c> newList, List<INT_EmailDelivery__c> oldList) {
            INT_EmailDeliveryService.setBrandId(newList);
        }
    }

    public class LockOwnership implements TriggerAction.BeforeUpdate {
        public void beforeUpdate(List<INT_EmailDelivery__c> newList, List<INT_EmailDelivery__c> oldList) {
            INT_EmailDeliveryService.lockOwnership(newList, new Map<Id, INT_EmailDelivery__c>(oldList));
        }
    }

    public class DeliveryName implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
        public void beforeInsert(List<INT_EmailDelivery__c> newList) {
            INT_EmailDeliveryService.setDeliveryName(newList);
        }
        
        public void beforeUpdate(List<INT_EmailDelivery__c> newList, List<INT_EmailDelivery__c> oldList) {
            INT_EmailDeliveryService.setDeliveryName(newList);
        }
    }
}