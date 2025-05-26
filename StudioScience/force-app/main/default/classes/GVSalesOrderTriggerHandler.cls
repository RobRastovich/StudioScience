public without sharing class GVSalesOrderTriggerHandler {
    public static void handleAfterUpdate(List<gvp__Sales_Order__c> salesOrders, Map<Id, gvp__Sales_Order__c> oldOrders){ 
       list<User> lUser = [select  id , name from user where profile.name like '%System Administrator%' and isActive = true];
       Map<Id, user> userMap = new Map<Id, user>(lUser );
        if (userMap.get(userinfo.getUserId())!= null){
            List<gvp__Sales_Order__c> salesOrders_new = new List<gvp__Sales_Order__c>();
            for (gvp__Sales_Order__c order : salesOrders){
                if (order.gvp__ERP_Id__c != null){
                    salesOrders_new.add(order);
                }
            }
            if (salesOrders_new.size()!= 0){
                caseServices.CreateCaseFromSalesOrder(salesOrders_new, oldOrders);
            }
         }
    }
}