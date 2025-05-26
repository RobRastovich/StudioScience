public class BCH_SAP_SalesOrdersProcessing implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    private List<Id> salesOrderIdList = new List<Id>();
    private Integer totalSizeRecords = 0;
    private UTL_API_Utility.CSRFAuthInfo csrfAuthInfo;
    
    public BCH_SAP_SalesOrdersProcessing(List<Id> salesOrdersIds, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo) {
        this.salesOrderIdList = salesOrdersIds;
        this.csrfAuthInfo = csrfAuthInfo;
        System.debug('salesOrderIdList--->'+salesOrderIdList);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(EXT_SAP_SalesOrderHelper.QUERY_SELECTED_SALES_ORDER);
    }
    
    public void execute(Database.BatchableContext BC, List<gvp__Sales_Order__c> salesOrders) { 
        System.debug('Start Batch - '+ salesOrders);
        totalSizeRecords += salesOrders.size();
        EXT_SAP_SalesOrderHelper.handleSalesOrderCreation(salesOrders, csrfAuthInfo);
    }   
    
    public void finish(Database.BatchableContext BC){         
        EXT_SAP_SOEmailNotificationHelper.sendingEmailNotification(salesOrderIdList);
    }
}