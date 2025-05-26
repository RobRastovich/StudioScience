@isTest
public class TST_API_Utility {
    
    static String SAMPLE_REQUEST_JSONSTRING_SO = '{"d":{"ShipToPartnerName":"","SalesOrderSimulation":false,"SingleShipment":false,"OrderItemCount":1,"ShipToCity":"","SalesOrderNumber":"","PO":"","ShipToPartnerID":"","ShipToContact":"","ShippingCarrier":"","ShippingIncoTerms":"","Currency":"USD","ShipToPostalCode":"","FormattedAddress1":"HORIZON WINE & SPIRITS NASHVILLE","ShipToRegion":"","ShipmentInstruction":"","RequestedDate":"20201019","PaymentTerms":"","Status":"","PromotionCode":"","CustomerID":"30082","CustomerName":"HORIZON WINE & SPIRITS NASHVILLE","FormattedAddress9":"","Tax":"0.00","Freight":"0.00","FormattedAddress8":"","GrandTotal":"1000.00","ShipToAddressLine1":"337 28TH AVE NORTH","ShipToCountry":"US","FormattedAddress7":"","TotalAmount":"1000.00","FormattedAddress2":"PO Box 90305","FormattedAddress3":"NASHVILLE TN  37209-0305","FormattedAddress6":"","FormattedAddress4":"USA","FormattedAddress5":"","NotesToReceiver":"","SalesOrganization":"US30","DistributionChannel":"OU","Division":"20","OrderDate":"20201005","ShipToAddressLine2":"NASHVILLE TN 37209-0305","OrderItemSet":{"results":[{"UnitofMeasureTxt":"Case","ProductName":"SKGIRL VODKA BARE NAKED 750X12 30% 7J","MaterialNumber":"US114122","Quantity":"100.000","UnitofMeasure":"CS","NetAmount":"1000.00","ImageFlag":false,"RequestedDeliveryDate":"20201005","EstimatedDeliveryDate":"20201005","AvailableQuantity":"0.000","FinalPrice":"10.00","Product":"US114122","SalesOrderNumber":"1022009563","ItemNumber":"000010","Currency":"USD","DeliveryStatusCode":"","QuantityStatusCode":""}]}}}';     
    static String SAMPLE_RESPONSE_JSONSTRING_SO = '{ "d": { "ShipToPartnerName": "", "SalesOrderSimulation": false, "SingleShipment": false, "OrderItemCount": 0, "ShipToCity": "", "SalesOrderNumber": "1022009862", "PO": "", "ShipToPartnerID": "", "ShipToContact": "", "ShippingCarrier": "", "ShippingIncoTerms": "", "Currency": "", "ShipToPostalCode": "", "FormattedAddress1": "", "ShipToRegion": "", "ShipmentInstruction": "", "RequestedDate": "", "PaymentTerms": "", "Status": "", "PromotionCode": "", "CustomerID": "", "CustomerName": "", "FormattedAddress9": "", "Tax": "0.00", "Freight": "0.00", "FormattedAddress8": "", "GrandTotal": "0.00", "ShipToAddressLine1": "", "ShipToCountry": "", "FormattedAddress7": "", "TotalAmount": "0.00", "FormattedAddress2": "", "FormattedAddress3": "", "FormattedAddress6": "", "FormattedAddress4": "", "FormattedAddress5": "", "NotesToReceiver": "", "SalesOrganization": "", "DistributionChannel": "", "Division": "", "OrderDate": "", "ShipToAddressLine2": "", "OrderItemSet": { "results": [] } } }';
    static String SAMPLE_REQUEST_JSONSTRING_US = '{"d" : {"Respcctr" : "US30NA01","OrderType" : "SF01","OrderName" : "DE CZ Q2 ONP Menu Program","Order" : "CYXXX2077002","Currency" : "USD","CompCode" : "US30","CoArea" : "2000"}}';
    static String SAMPLE_RESPONSE_JSONSTRING_US = '{"d":{"__metadata":{"id":"https://MOBILED.BEAMSUNTORY.COM:44381/sap/opu/odata/sap/ZGSF_IO_CREATION_SRV/InternalOrderSet("CYXXX2077002")","uri":"https://MOBILED.BEAMSUNTORY.COM:44381/sap/opu/odata/sap/ZGSF_IO_CREATION_SRV/InternalOrderSet("CYXXX2077002")","type":"ZGSF_IO_CREATION_SRV.InternalOrder"},"Order":"CYXXX2077002","OrderType":"SF01","OrderName":"DE CZ Q2 ONP Menu Program","ExtOrdNo":"","ObjectNo":"ORCYXXX2077002","CoArea":"2000","CompCode":"US30","BusArea":"","Plant":"","ProfitCtr":"","Respcctr":"US30NA01","WbsElem":"000000000000000000000000","WbsElementExt":"","RequestCctr":"","RequCompCode":"","SalesOrd":"","SOrdItem":"000000","Taxjurcode":"","CctrPosted":"","Currency":"USD","CstgSheet":"","OverheadKey":"","ResAnalKey":"","InterestProf":"","Applicant":"","ApplicantPhone":"","PersonResp":"","PersonRespPhone":"","EstimatedCosts":"0.00","ApplicationDate":null,"Department":"","DateWorkBegins":null,"DateWorkEnds":null,"WorkPermit":"","ProcessingGroup":"00","PlnRelease":null,"PlnCompletion":null,"PlnClose":null,"RequestOrder":"","FuncArea":"","FuncAreaLong":"","InChargeUser":"","UserStatus":{"__deferred":{"uri":"https://MOBILED.BEAMSUNTORY.COM:44381/sap/opu/odata/sap/ZGSF_IO_CREATION_SRV/InternalOrderSet("CYXXX2077002")/UserStatus"}},"TransactionsPermited":{"__deferred":{"uri":"https://MOBILED.BEAMSUNTORY.COM:44381/sap/opu/odata/sap/ZGSF_IO_CREATION_SRV/InternalOrderSet("CYXXX2077002")/TransactionsPermited"}},"IOSRules":{"__deferred":{"uri":"https://MOBILED.BEAMSUNTORY.COM:44381/sap/opu/odata/sap/ZGSF_IO_CREATION_SRV/InternalOrderSet("CYXXX2077002")/IOSRules"}},"SystemStatus":{"__deferred":{"uri":"https://MOBILED.BEAMSUNTORY.COM:44381/sap/opu/odata/sap/ZGSF_IO_CREATION_SRV/InternalOrderSet("CYXXX2077002")/SystemStatus"}}}}';
    static String SAMPLE_REQUEST_JSONSTRING_AUS = '{"d" : {"WbsElement" : "AU19JBWJRBLSF002","Description" : "Dojo Bartender program","CompanyCode" : "AU60","ControllingArea" : "6000","Currency" : "AUD","CurrencyIso" : "AUD","WbsUp" : "AU19JBWH","SystemStatus" : "REL","ProjectDefinition" : "BIAU2019"}}';
    static String SAMPLE_RESPONSE_JSONSTRING_AUS = '{"error":{"code":"CNIF_PI/007","message":{"lang":"en","value":"Object WBS Element AU19JBWJRBLSF002 could not be created"},"innererror":{"application":{"component_id":"","service_namespace":"/SAP/","service_id":"ZGSF_PROJ_CREATION_SRV_01","service_version":"0001"},"transactionid":"A694D5FD5B7B0010E0060485880DAFA8","timestamp":"","Error_Resolution":{"SAP_Transaction":"","SAP_Note":"See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)"},"errordetails":[{"code":"CNIF_PI/007","message":"Object WBS Element AU19JBWJRBLSF002 could not be created","propertyref":"","severity":"error","transition":false,"target":""},{"code":"CJ/020","message":"WBS element AU19JBWJRBLSF002 already exists","longtext_url":"/sap/opu/odata/iwbep/message_text;o=ESDCLNT500/","propertyref":"","severity":"error","transition":false,"target":""},{"code":"/IWBEP/CX_SD_GEN_DPC_BUSINS","message":"Object WBS Element AU19JBWJRBLSF002 could not be created","propertyref":"","severity":"error","transition":false,"target":""}]}}}';
    
    static gvp__Sales_Order__c prepareSalesOrderData(){
        string ordNum = 'ORD-0000000500';
        gvp__Sales_Order__c SO = UTL_SAP_TestSalesOrderDataUtility.createSalesOrder(ordNum);
        
        gvp__Item__c item = UTL_SAP_TestSalesOrderDataUtility.createItem();

        gvp__Sales_Order_Item__c soItem = new gvp__Sales_Order_Item__c();
        soItem.gvp__Sales_Order__c = so.id;
        soItem.gvp__Item__c = item.id;
        insert soItem;
        
        return SO;
    }

   static testMethod void getEndpointHelperTest(){
        Test.startTest();
        String endpoint_SO = UTL_API_Utility.getEndpointHelper(UTL_API_Utility.APPNAME_SO);
        String endpoint_US = UTL_API_Utility.getEndpointHelper(UTL_API_Utility.APPNAME_USBI);
        String endpoint_AUS = UTL_API_Utility.getEndpointHelper(UTL_API_Utility.APPNAME_AUSBI);
        Test.stopTest();
        System.assert(endpoint_SO!=null);
        System.assert(endpoint_US!=null);
        System.assert(endpoint_AUS!=null);
    }
    
    static testMethod void checkUserNamedCredentialTest(){
        Test.startTest();
        boolean hasAccess_SO = UTL_API_Utility.checkUserNamedCredential(UserInfo.getUserId(),UTL_API_Utility.APPNAME_SO);
        boolean hasAccess_US = UTL_API_Utility.checkUserNamedCredential(UserInfo.getUserId(),UTL_API_Utility.APPNAME_USBI);
        boolean hasAccess_AUS = UTL_API_Utility.checkUserNamedCredential(UserInfo.getUserId(),UTL_API_Utility.APPNAME_AUSBI);
        Test.stopTest();
        System.assert(hasAccess_SO!=false);
        System.assert(hasAccess_US!=false);
        System.assert(hasAccess_AUS!=false);        
    }
    
        
    static testMethod void getUserFriendlyErrorTest(){
        String firstErrorMessageFromSAP = 'Data Property is invalid';
        String secondErrorMessageFromSAP = 'Reference Material MX005642 does not exist in storage location MX31 FTX0';
        String thirdErrorMessageFromSAP = 'Allocated Material MX007119 is not defined for sales org.MX30, distr.chan.OU, language ES';
        Test.startTest();
        String firstFriendlyError = UTL_API_Utility.getUserFriendlyError(firstErrorMessageFromSAP, UTL_API_Utility.APPNAME_SO);
        String secondFriendlyError = UTL_API_Utility.getUserFriendlyError(secondErrorMessageFromSAP, UTL_API_Utility.APPNAME_USBI);
        String thirdFriendlyError = UTL_API_Utility.getUserFriendlyError(thirdErrorMessageFromSAP, UTL_API_Utility.APPNAME_AUSBI);        
        Test.stopTest();
        System.assertEquals(firstFriendlyError , firstErrorMessageFromSAP);
        System.assertEquals(secondFriendlyError , secondErrorMessageFromSAP);
        System.assertEquals(thirdFriendlyError , thirdErrorMessageFromSAP);
    }
    
    static testMethod void getCSRFToken_oAuthTest(){
        Test.startTest();
        UTL_API_Utility.CSRFAuthInfo csrfresponse_US = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_USBI);
        UTL_API_Utility.CSRFAuthInfo csrfresponse_AUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_AUSBI);        
        UTL_API_Utility.CSRFAuthInfo csrfresponse_SO = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_SO);
        Test.stopTest();
        System.assert(csrfresponse_US.isUserAuthorized == false);
        System.assert(csrfresponse_AUS.isUserAuthorized == false);
        System.assert(csrfresponse_SO.isUserAuthorized == false);        
    } 
    
    static testMethod void  sendDataToSAPRequestTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new TST_SAP_SendDataToSAPRequestMock());         
        NamedCredential nm = [SELECT Endpoint FROM NamedCredential where DeveloperName = :UTL_API_Utility.NAMED_CREDENTIAL_TEST];
        UTL_API_Utility.CSRFAuthInfo csrfresponse = new UTL_API_Utility.CSRFAuthInfo(UTL_API_Utility.APPNAME_SO);
        csrfresponse.csrfToken = 'token';
        csrfresponse.errorMessage = 'Error message';
        csrfresponse.isUserAuthorized = true;
        csrfresponse.sCookie = 'cookies';
        csrfresponse.status = 'OK';
        csrfresponse.statusCode = 200;
        UTL_API_Utility.sendDataToSAPRequest(String.valueOf(prepareSalesOrderData()),'application/json','application/json',csrfresponse);
        Test.stopTest();
    }
    
    static testMethod void createAPILoggerTest(){
        Test.startTest();
        gvp__Sales_Order__c salesOrder = prepareSalesOrderData();
        SAP_API_Logger__c logger_SO = UTL_API_Utility.createAPILogger(salesOrder.Id, salesOrder.Name, UTL_API_Utility.APPNAME_SO, SAMPLE_REQUEST_JSONSTRING_SO, '200', SAMPLE_RESPONSE_JSONSTRING_SO);
        SAP_API_Logger__c logger_US = UTL_API_Utility.createAPILogger('a021k00000FP8IwAAL', 'AR LP FY Trade Events', UTL_API_Utility.APPNAME_USBI, SAMPLE_REQUEST_JSONSTRING_US, '200', SAMPLE_RESPONSE_JSONSTRING_US);
        SAP_API_Logger__c logger_AUS = UTL_API_Utility.createAPILogger('a021k00000FCu0JAAT', 'Ad Hoc Brand Research', UTL_API_Utility.APPNAME_AUSBI, SAMPLE_REQUEST_JSONSTRING_AUS, '200', SAMPLE_RESPONSE_JSONSTRING_AUS);
        Test.stopTest();
        System.assert(logger_SO != null);
        System.assert(logger_US != null);
        System.assert(logger_AUS != null);        
    }
    
    static testMethod void createAPILoggerTest2(){
        Test.startTest();
        gvp__Sales_Order__c salesOrder = prepareSalesOrderData();
        SAP_API_Logger__c logger_SO = UTL_API_Utility.createAPILogger(salesOrder.Id, salesOrder.Name, UTL_API_Utility.APPNAME_SO, SAMPLE_REQUEST_JSONSTRING_SO, '200', SAMPLE_RESPONSE_JSONSTRING_SO, 'test error');
        SAP_API_Logger__c logger_US = UTL_API_Utility.createAPILogger('a021k00000FP8IwAAL', 'AR LP FY Trade Events', UTL_API_Utility.APPNAME_USBI, SAMPLE_REQUEST_JSONSTRING_US, '200', SAMPLE_RESPONSE_JSONSTRING_US,'test error');
        SAP_API_Logger__c logger_AUS = UTL_API_Utility.createAPILogger('a021k00000FCu0JAAT', 'Ad Hoc Brand Research', UTL_API_Utility.APPNAME_AUSBI, SAMPLE_REQUEST_JSONSTRING_AUS, '200', SAMPLE_RESPONSE_JSONSTRING_AUS,'test error');
        Test.stopTest();
        System.assert(logger_SO != null);
        System.assert(logger_US != null);
        System.assert(logger_AUS != null);        
    }
    
}