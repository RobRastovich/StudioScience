public with sharing class CNT_SAP_ManageSalesOrdersToSAPController {
    private static final Integer BATCH_SIZE = 90;

    @AuraEnabled
    public static Integer countList(String filterSearch) {
        list < gvp__Sales_Order__c > lstorder = new List < gvp__Sales_Order__c > (); 
        if(filterSearch!='all'){
            lstorder = [SELECT Name, gvp__Account__r.Name,gvp__Sold_To__c,CreatedBy.Name,CreatedDate,gvc_Purchase_Order__c,gvp__Order_Type__c,gvp__Status__c,SAP_Error__c FROM gvp__Sales_Order__c WHERE gvp__Status__c =:filterSearch  AND gvp__Order_Type__c IN ('YPOU','YFDU') AND gvp__Account__r.gvp__Account_Key__c !='' AND (gvp__Account__r.gvp__Account_Groups__c IN ('Sold To','Ship To','Sold to','Ship to','ZESH','ZESP') OR gvp__Account__r.Parent.gvp__Account_Groups__c IN ('Sold To','Sold to','ZESP'))];
        }
        else{
            lstorder = [SELECT Name, gvp__Account__r.Name,gvp__Sold_To__c,CreatedBy.Name,CreatedDate,gvc_Purchase_Order__c,gvp__Order_Type__c,gvp__Status__c,SAP_Error__c FROM gvp__Sales_Order__c WHERE gvp__Status__c IN ('Submitted','Failed') AND gvp__Order_Type__c IN ('YPOU','YFDU') AND gvp__Account__r.gvp__Account_Key__c !='' AND (gvp__Account__r.gvp__Account_Groups__c IN ('Sold To','Ship To','Sold to','Ship to','ZESH','ZESP') OR gvp__Account__r.Parent.gvp__Account_Groups__c IN ('Sold To','Sold to','ZESP'))];
        }
        return lstorder.size();
    }
    
    @AuraEnabled
    public static list< gvp__Sales_Order__c > fetchFilteredList(String filterSearch,Integer intOffSet,Integer lim) {
        list < gvp__Sales_Order__c > returnSalesOrderList = new List < gvp__Sales_Order__c > ();
        list < gvp__Sales_Order__c > lstorder = new List < gvp__Sales_Order__c > (); 
        if(filterSearch!='all'){
            lstorder = [SELECT Name, gvp__Account__r.Name,gvp__Sold_To__c,CreatedBy.Name,CreatedDate,gvc_Purchase_Order__c,gvp__Order_Type__c,gvp__Status__c,SAP_Error__c FROM gvp__Sales_Order__c WHERE gvp__Status__c =:filterSearch  AND gvp__Order_Type__c IN ('YPOU','YFDU') AND gvp__Account__r.gvp__Account_Key__c !='' AND (gvp__Account__r.gvp__Account_Groups__c IN ('Sold To','Ship To','Sold to','Ship to','ZESH','ZESP') OR gvp__Account__r.Parent.gvp__Account_Groups__c IN ('Sold To','Sold to','ZESP')) LIMIT :Integer.valueOf(lim) OFFSET : Integer.valueOf(intOffSet)];
        }
        else{
            lstorder = [SELECT Name, gvp__Account__r.Name,gvp__Sold_To__c,CreatedBy.Name,CreatedDate,gvc_Purchase_Order__c,gvp__Order_Type__c,gvp__Status__c,SAP_Error__c FROM gvp__Sales_Order__c WHERE gvp__Status__c IN ('Submitted','Failed') AND gvp__Order_Type__c IN ('YPOU','YFDU') AND gvp__Account__r.gvp__Account_Key__c !='' AND (gvp__Account__r.gvp__Account_Groups__c IN ('Sold To','Ship To','Sold to','Ship to','ZESH','ZESP') OR gvp__Account__r.Parent.gvp__Account_Groups__c IN ('Sold To','Sold to','ZESP')) LIMIT :Integer.valueOf(lim) OFFSET : Integer.valueOf(intOffSet)];
        }
        System.debug('lstorder--'+lstorder);
        for (gvp__Sales_Order__c c: lstorder) {
            returnSalesOrderList.add(c);
        }
        return returnSalesOrderList;
    } 
    
    @AuraEnabled
    public static Boolean isUserAuthenticated() {
        UTL_API_Utility.CSRFAuthInfo csrfResponse = EXT_SAP_SalesOrderHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_SO);
        return csrfResponse.isUserAuthorized;
    }
    
    @AuraEnabled
    public static boolean checkUserHaveNamedCredential(){
        return UTL_API_Utility.checkUserNamedCredential(UserInfo.getUserId(),UTL_API_Utility.APPNAME_SO);
    }

    @AuraEnabled
    public static List<Id> updateSalesOrderSendToSAP(List<Id> salesOrderIdList){
        String failedStatus = EXT_SAP_SalesOrderHelper.STATUS_FAILED;
        String submitedStatus = EXT_SAP_SalesOrderHelper.STATUS_SUBMITTED;
        String queryString = 'Select Id,gvp__Status__c,gvp__ERP_Id__c from gvp__Sales_Order__c where Id IN :salesOrderIdList and gvp__Status__c IN (:failedStatus,:submitedStatus)';
        List<gvp__Sales_Order__c> soList = Database.query(queryString);
        List<gvp__Sales_Order__c> salesOrderStatusUpdateList = new List<gvp__Sales_Order__c>();
        List<Id> refreshedSOIdList = new List<Id>();
        for(gvp__Sales_Order__c salesOrder : soList)
        {
            salesOrder.gvp__Status__c = EXT_SAP_SalesOrderHelper.STATUS_SEND_TO_SAP;
            salesOrderStatusUpdateList.add(salesOrder);          
            refreshedSOIdList.add(salesOrder.Id);
        }
        if(!salesOrderStatusUpdateList.isEmpty()) {
            update salesOrderStatusUpdateList;
        }
        return refreshedSOIdList;
    }

    @AuraEnabled
    public static void sendSalesOrdertoSAP(List<Id> salesOrderIdList){
        UTL_API_Utility.CSRFAuthInfo csrfResponse = EXT_SAP_SalesOrderHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_SO);
        BCH_SAP_SalesOrdersProcessing salesOrdersProcessingBatch = new BCH_SAP_SalesOrdersProcessing(salesOrderIdList, csrfResponse);
        ID batchprocessid = Database.executeBatch(salesOrdersProcessingBatch, BATCH_SIZE); 
    }
}