@isTest 
public class TST_SAP_SalesOrdersProcessing 
{
    static testMethod void testSalesOrdersProcessingBatch() 
    {
        string ordNum = 'ORD-0000000500';
        gvp__Sales_Order__c SO = UTL_SAP_TestSalesOrderDataUtility.createSalesOrder(ordNum);
      
        gvp__Item__c item = UTL_SAP_TestSalesOrderDataUtility.createItem();

        gvp__Sales_Order_Item__c soItem = new 	gvp__Sales_Order_Item__c();
        soItem.gvp__Sales_Order__c = so.id;
        soItem.gvp__Item__c = item.id;
        insert soItem;

        List<gvp__Sales_Order__c> soList = new  List<gvp__Sales_Order__c>();
        soList.add(SO);

        //insert soList;
        List<Id> soIdList = new List<Id>();
        for(gvp__Sales_Order__c tempso : soList)
        {
            soIdList.add(tempso.Id);
        }
        
        UTL_API_Utility.CSRFAuthInfo csrfAuthInfo = EXT_SAP_SalesOrderHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_SO);
        
        Test.startTest();

            BCH_SAP_SalesOrdersProcessing obj = new BCH_SAP_SalesOrdersProcessing(soIdList,csrfAuthInfo);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}