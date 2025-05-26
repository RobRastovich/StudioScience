@isTest 
public with sharing class TST_SAP_SalesOrderHelper {
    static String SAMPLE_REQUEST_JSONSTRING = '{"d":{"ShipToPartnerName":"","SalesOrderSimulation":false,"SingleShipment":false,"OrderItemCount":1,"ShipToCity":"","SalesOrderNumber":"","PO":"","ShipToPartnerID":"","ShipToContact":"","ShippingCarrier":"","ShippingIncoTerms":"","Currency":"USD","ShipToPostalCode":"","FormattedAddress1":"HORIZON WINE & SPIRITS NASHVILLE","ShipToRegion":"","ShipmentInstruction":"","RequestedDate":"20201019","PaymentTerms":"","Status":"","PromotionCode":"","CustomerID":"30082","CustomerName":"HORIZON WINE & SPIRITS NASHVILLE","FormattedAddress9":"","Tax":"0.00","Freight":"0.00","FormattedAddress8":"","GrandTotal":"1000.00","ShipToAddressLine1":"337 28TH AVE NORTH","ShipToCountry":"US","FormattedAddress7":"","TotalAmount":"1000.00","FormattedAddress2":"PO Box 90305","FormattedAddress3":"NASHVILLE TN  37209-0305","FormattedAddress6":"","FormattedAddress4":"USA","FormattedAddress5":"","NotesToReceiver":"","SalesOrganization":"US30","DistributionChannel":"OU","Division":"20","OrderDate":"20201005","ShipToAddressLine2":"NASHVILLE TN 37209-0305","OrderItemSet":{"results":[{"UnitofMeasureTxt":"Case","ProductName":"SKGIRL VODKA BARE NAKED 750X12 30% 7J","MaterialNumber":"US114122","Quantity":"100.000","UnitofMeasure":"CS","NetAmount":"1000.00","ImageFlag":false,"RequestedDeliveryDate":"20201005","EstimatedDeliveryDate":"20201005","AvailableQuantity":"0.000","FinalPrice":"10.00","Product":"US114122","SalesOrderNumber":"1022009563","ItemNumber":"000010","Currency":"USD","DeliveryStatusCode":"","QuantityStatusCode":""}]}}}';     
    static String SAMPLE_RESPONSE_JSONSTRING = '{ "d": { "ShipToPartnerName": "", "SalesOrderSimulation": false, "SingleShipment": false, "OrderItemCount": 0, "ShipToCity": "", "SalesOrderNumber": "1022009862", "PO": "", "ShipToPartnerID": "", "ShipToContact": "", "ShippingCarrier": "", "ShippingIncoTerms": "", "Currency": "", "ShipToPostalCode": "", "FormattedAddress1": "", "ShipToRegion": "", "ShipmentInstruction": "", "RequestedDate": "", "PaymentTerms": "", "Status": "", "PromotionCode": "", "CustomerID": "", "CustomerName": "", "FormattedAddress9": "", "Tax": "0.00", "Freight": "0.00", "FormattedAddress8": "", "GrandTotal": "0.00", "ShipToAddressLine1": "", "ShipToCountry": "", "FormattedAddress7": "", "TotalAmount": "0.00", "FormattedAddress2": "", "FormattedAddress3": "", "FormattedAddress6": "", "FormattedAddress4": "", "FormattedAddress5": "", "NotesToReceiver": "", "SalesOrganization": "", "DistributionChannel": "", "Division": "", "OrderDate": "", "ShipToAddressLine2": "", "OrderItemSet": { "results": [] } } }';
    static String SAMPLE_ERROR_JSONSTRING = '{ "error":{ "code":"/IWFND/CM_BEC/029", "message":{ "lang":"en", "value":"RFC Error: Runtime error occurred in backend system" }, "innererror":{ "application":{ "component_id":"SD-SLS", "service_namespace":"SAP", "service_id":"SRA017_SALESORDER_CREATE_SRV", "service_version":"0001" }, "transactionid":"5773F43355B10030E005FA4E3B46EEC3", "timestamp":"20201216083610.5944970", "Error_Resolution":{ "SAP_Transaction":"For backend administrators: use ADT feed reader SAP Gateway Error Log or run transaction /IWFND/ERROR_LOG on SAP Gateway hub system and search for entries with the timestamp above for more details", "SAP_Note":"See SAP Note 1797736 for error analysis" }, "errordetails":[ ] } } }';
    
    static gvp__Sales_Order__c prepareSOData(string ordNum){
        gvp__Sales_Order__c SO = UTL_SAP_TestSalesOrderDataUtility.createSalesOrder(ordNum);
        
        gvp__Item__c item = UTL_SAP_TestSalesOrderDataUtility.createItem();
        
        gvp__Sales_Order_Item__c soItem = new 	gvp__Sales_Order_Item__c();
        soItem.gvp__Sales_Order__c = so.id;
        soItem.gvp__Item__c = item.id;
        insert soItem;
        
        gvp__Sales_Order__c sorecord = [SELECT Id, Name,gvp__Account__c,gvp__Delivery_Instructions__c,gvc_Purchase_Order__c,gvp__Order_Type__c,gvp__Will_Call__c,gvp__Account_Selector__c,gvp__Account_Selector__r.gvp__Account_Key__c,gvp__Account__r.RecordType.Name, CurrencyIsoCode, gvp__Request_Date__c, gvp__Delivery_Date__c, gvp__Order_Total__c, gvp__Order_Notes__c,gvp__Account__r.gvp__Account_Key__c, gvp__Account__r.gvc_Sales_Organization__c,gvp__Account__r.Parent.gvp__Account_Key__c,gvp__Account__r.Parent.Name,gvp__Account__r.gvc_Distribution_Channel__c,gvp__Account__r.gvc_Division_Key__c,gvp__Order_Date__c,gvp__Shipping_Address2__c, (SELECT Id,gvp__Item__r.Name, gvp__Item__r.gvp__Item_Number__c, gvp__Quantity__c, gvp__Item__r.gvp__Unit_of_Measurement__c,gvc_Estimated_Delivery_Date__c FROM gvp__Sales_Order_Items__r) FROM gvp__Sales_Order__c WHERE Id = :SO.Id];
        
        return sorecord;
    }
    
    static testMethod void userAuthenticationTest(){
        Test.startTest();
        UTL_API_Utility.CSRFAuthInfo authInfor = EXT_SAP_SalesOrderHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_SO);
        Test.stopTest();
        System.assert(authInfor.isUserAuthorized == false);
    }
    
    static testMethod void createSalesOrderInSAPTest(){ 
        Test.startTest();
        UTL_API_Utility.CSRFAuthInfo authInfor = EXT_SAP_SalesOrderHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_SO);
        List<gvp__Sales_Order__c> soList = new List<gvp__Sales_Order__c>();
        soList.add(prepareSOData('ORD-0000000500'));
        EXT_SAP_SalesOrderHelper.handleSalesOrderCreation(soList,authInfor);
        Test.stopTest();
    }
    
    static testMethod void prepareSalesOrderRequestJSONTest(){
        Test.startTest();
        String jsonString = EXT_SAP_SalesOrderHelper.prepareSalesOrderRequestJSON(prepareSOData('ORD-0000000510'));
        Test.stopTest();
        System.assert(String.isNotEmpty(jsonString));
    }
    
    static testMethod void testSalesOrderRequestModelParse(){
        String  reqBody = SAMPLE_REQUEST_JSONSTRING;
        SAP_SalesOrderRequestModel sorm = SAP_SalesOrderRequestModel.parse(reqBody);
        System.assert(sorm.d.SalesOrderSimulation!=null);
        
    }
    
    static testMethod void testSalesOrderResponseModelParse(){
        String  resBody = SAMPLE_RESPONSE_JSONSTRING;
        SAP_SalesOrderResponseModel sorm = SAP_SalesOrderResponseModel.parse(resBody);
        System.assert(sorm.d.SalesOrderSimulation!=null);
    }
    
    static testMethod void testSAPErrorResponse() {
        String json = SAMPLE_ERROR_JSONSTRING;
        SAP_ErrorResponse obj = SAP_ErrorResponse.parse(json);
        System.assert(obj != null);
    }
    
    static testMethod void dateConverterTest(){
        Test.startTest();
        String dateString = EXT_SAP_SalesOrderHelper.dateConverter(Date.today());
        System.assert(String.isNotBlank(dateString));
        Test.stopTest();
    }
    
}