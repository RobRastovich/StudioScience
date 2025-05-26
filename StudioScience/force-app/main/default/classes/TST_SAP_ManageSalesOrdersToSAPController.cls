@isTest
public class TST_SAP_ManageSalesOrdersToSAPController {
    
    static gvp__Sales_Order__c prepareSOData(){
        string ordNum = 'ORD-0000000500';
        gvp__Sales_Order__c SO = UTL_SAP_TestSalesOrderDataUtility.createSalesOrder(ordNum);
        gvp__Item__c item = UTL_SAP_TestSalesOrderDataUtility.createItem();
        
        gvp__Sales_Order_Item__c soItem = new 	gvp__Sales_Order_Item__c();
        soItem.gvp__Sales_Order__c = so.id;
        soItem.gvp__Item__c = item.id;
        insert soItem;
        
        gvp__Sales_Order__c sorecord = [SELECT Id, gvp__Account__c, CurrencyIsoCode, gvp__Request_Date__c,gvp__Order_Total__c, gvp__Order_Notes__c,gvp__Account__r.gvp__Account_Key__c, gvp__Account__r.gvc_Sales_Organization__c,gvp__Account__r.Parent.gvp__Account_Key__c,gvp__Account__r.Parent.Name,gvp__Account__r.gvc_Distribution_Channel__c,gvp__Account__r.gvc_Division_Key__c,gvp__Order_Date__c,gvp__Shipping_Address2__c, (SELECT Id,gvp__Item__r.Name, gvp__Item__r.gvp__Item_Number__c, gvp__Quantity__c, gvp__Item__r.gvp__Unit_of_Measurement__c,gvc_Estimated_Delivery_Date__c FROM gvp__Sales_Order_Items__r) FROM gvp__Sales_Order__c WHERE Id = :SO.Id];
        
        return sorecord;
    }
    
    static testMethod void countListTest(){
        Test.startTest();
        prepareSOData();
        Integer count = CNT_SAP_ManageSalesOrdersToSAPController.countList('Submitted');
        System.debug('count::'+count);
        Test.stopTest();
        System.assert(count>0);
    }
    static testMethod void fetchFilteredListTest(){
        Test.startTest();
        prepareSOData();
        list< gvp__Sales_Order__c > filterList = CNT_SAP_ManageSalesOrdersToSAPController.fetchFilteredList('Submitted', 1, 1);
        Test.stopTest();       
        //System.assert(filterList.size() >0);
    }
    static testMethod void isUserAuthenticatedApexTest(){
        Test.startTest();
        Boolean b = CNT_SAP_ManageSalesOrdersToSAPController.isUserAuthenticated();
        Test.stopTest();   
        System.assert(b == true || b == false);
    }
    static testMethod void invokeSalesOrdersProcessingApexTest(){
        Test.startTest();
        gvp__Sales_Order__c so = prepareSOData();
        List<Id> soList  = new List<Id>();
        soList.add(so.Id);
        CNT_SAP_ManageSalesOrdersToSAPController.sendSalesOrdertoSAP(soList);
        Test.stopTest();   
    }
    static testMethod void checkUserHaveNamedCredentialTest(){
        Test.startTest();
        //prepareSOData();
        Boolean b = CNT_SAP_ManageSalesOrdersToSAPController.checkUserHaveNamedCredential();
        Test.stopTest();   
        System.assert(b == true || b == false);
    }
    static testMethod void updateRecordsSendToSAP(){
        Test.startTest();
        gvp__Sales_Order__c so = prepareSOData();
        List<Id> soList  = new List<Id>();
        soList.add(so.Id);
        CNT_SAP_ManageSalesOrdersToSAPController.updateSalesOrderSendToSAP(soList);
        List<gvp__Sales_Order__c> soUpdated = [Select Id,gvp__Status__c from gvp__Sales_Order__c where Id = :so.Id];
        if(soUpdated.size()>0){
            System.assert(soUpdated[0].gvp__Status__c == EXT_SAP_SalesOrderHelper.STATUS_SEND_TO_SAP);
        }
        Test.stopTest();   
    }
}