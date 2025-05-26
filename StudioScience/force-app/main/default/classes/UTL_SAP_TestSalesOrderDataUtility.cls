@isTest
public class UTL_SAP_TestSalesOrderDataUtility {
    public static void createSalesOrderwithItems() {
        string ordNum = 'ORD-0000000500';
        gvp__Sales_Order__c SO = createSalesOrder(ordNum);
    }
    public static Account CreateAccount(string accName, string accKey){
        Account a = new Account();
        string accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Off_Premise').getRecordTypeId();
        a.RecordTypeId = accountRTId;
        a.gvp__Account_Key__c =accKey;
        a.Name = accName;
        a.gvp__account_Groups__c = 'Ship to';
        a.Division__c = 'Mexico';

        insert a;
        return a;
    }
    public static gvp__Sales_Order__c createSalesOrder(string ordNumber) {
        
        account acc  = CreateAccount('Test Account','0001151234');
        system.debug('acc: ' + acc);

        gvp__Sales_Order__c salesOrder  = new gvp__Sales_Order__c();
        salesOrder.gvp__Account__c = acc.id;
        salesOrder.gvp__Order_Number__c = ordNumber;
        salesOrder.gvp__Status__c = 'Submitted';
        salesOrder.gvp__Sales_Order_Key__c = '';
        salesOrder.gvp__Order_Date__c = system.today();
        salesOrder.gvp__Order_Type__c ='YPOU';
    
        insert salesOrder;
        system.debug('acc: ' + salesOrder);
        return salesOrder;
    }

    public static gvp__Item__c createItem(){

        gvp__Brand__c brand = new gvp__Brand__c();
        brand.Name = 'KNOB CREEK';
        brand.gvp__Brand_Key__c = 'KB';
        insert brand;

        gvp__Label__c label = new gvp__Label__c();
        label.name = 'KNOB CREEK BOURBON';
        label.gvp__Label_Key__c = 'KBGBC';
        label.gvp__Brand__c = brand.id;
        insert label;

        gvp__Size__c size = new gvp__Size__c();
        size.name = '750ml';
        size.gvp__Liter_Volume__c = 0.750;
        size.gvp__Size_Key__c='750ml';
        insert size;

        gvp__Item__c item = new gvp__Item__c();
        item.name = 'HORNITOS PLATA';
        item.gvp__Label__c = label.id;
        item.gvp__Size__c = size.id;
        item.gvp__Quantity__c = 100;
        item.gvp__Units__c = 5;
        insert item;
        return item;
    }
    

    @isTest
    public static void testData() {
        string ordNum = 'ORD-0000000500';
        gvp__Sales_Order__c SO = createSalesOrder(ordNum);
      
        gvp__Item__c item = createItem();

        gvp__Sales_Order_Item__c soItem = new 	gvp__Sales_Order_Item__c();
        soItem.gvp__Sales_Order__c = so.id;
        soItem.gvp__Item__c = item.id;
        insert soItem;

        gvp__Sales_Order__c chkSO = [select id from gvp__Sales_Order__c where gvp__Order_Number__c =: ordNum];

        system.assert (SO.id==chkSO.id);
	}

}