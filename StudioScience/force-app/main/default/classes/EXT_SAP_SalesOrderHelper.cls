public class EXT_SAP_SalesOrderHelper {

    public static final string QUERY_SELECTED_SALES_ORDER = 'SELECT '+
                    ' Id,Name, gvp__Account__c,CurrencyIsoCode, gvp__Request_Date__c, gvp__Delivery_Date__c, gvp__Order_Total__c,gvp__Account__r.Parent.gvp__Account_Groups__c,'+ 
                    ' gvp__Will_Call__c ,gvp__Account_Selector__c,gvp__Account_Selector__r.gvp__Account_Key__c,gvp__Account__r.RecordType.Name,gvc_Purchase_Order__c,gvp__Delivery_Instructions__c,'+
                    ' gvp__Order_Notes__c,gvp__Account__r.Name,gvp__Account__r.gvp__Account_Key__c, gvp__Account__r.gvc_Sales_Organization__c,'+ 
                    ' gvp__Account__r.Parent.gvp__Account_Key__c,gvp__Account__r.Parent.Name,gvp__Account__r.gvc_Distribution_Channel__c,'+ 
                    ' gvp__Account__r.gvc_Division_Key__c,gvp__Order_Date__c,gvp__Shipping_Address2__c,gvp__Order_Type__c,'+ 
                    ' (SELECT Id,gvp__Item__r.Name, gvp__Item__r.gvp__Item_Number__c, gvp__Quantity__c, '+ 
                    ' gvp__Item__r.gvp__Unit_of_Measurement__c,gvc_Estimated_Delivery_Date__c FROM gvp__Sales_Order_Items__r) '+ 
                    ' FROM gvp__Sales_Order__c where Id IN :salesOrderIdList ';
    
    public static final string STATUS_SEND_TO_SAP = 'Sent to SAP';
    public static final string STATUS_FAILED = 'Failed';
    public static final string STATUS_SUBMITTED = 'Submitted';
    public static final string OFFTRADE = '0001152245';
    public static final string ONTRADE = '0001152219';
    public static final Integer CHAR_LIMIT_LONG_TEXT = 131072;
    public static final Integer CHAR_LIMIT_STATUS_CODE = 50;

    public static UTL_API_Utility.CSRFAuthInfo getUserAuthenticationInfo(String appName){ 
        return UTL_API_Utility.getCSRFToken_oAuth(appName); 
    }

    public static void handleSalesOrderCreation(List<gvp__Sales_Order__c> salesOrders, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo) {
        List<SAP_API_Logger__c> apiLoggerUpsertList = new List<SAP_API_Logger__c>();
        List<gvp__Sales_Order__c> salesOrderUpdateList = new List<gvp__Sales_Order__c>();
        HttpResponse response = null;
        String requestBody = '';
        try {
            Set<id> salesOrderIdSet = new Map<id, gvp__Sales_Order__c>(salesOrders).keySet();
            Map<String, String> apiLoggerByRecordIdMap = UTL_API_Utility.getAPILoggers(salesOrderIdSet);

            for(gvp__Sales_Order__c salesOrder : salesOrders) {
                requestBody = prepareSalesOrderRequestJSON(salesOrder);
                UTL_API_Utility.HttpResponseWrapper responseWrapper = UTL_API_Utility.sendDataToSAPRequest(requestBody, UTL_API_Utility.CONTENT_TYPE_JSON, UTL_API_Utility.CONTENT_TYPE_JSON, csrfAuthInfo);  
                String errorMessage = '';
                // Logging the exception accured during the call out.
                if(!responseWrapper.isSuccess) {
                    errorMessage = responseWrapper.errorMessage;
                    handleCalloutFailure(errorMessage, salesOrder, requestBody, apiLoggerUpsertList, salesOrderUpdateList, apiLoggerByRecordIdMap);
                    continue;
                }
                response = responseWrapper.response;               
                // Update the Sales Order record as per the http response
                gvp__Sales_Order__c updatedSalesOrder = updateSalesOrdersRecords(salesOrder.Id, response);
                if(updatedSalesOrder != null) {
                    salesOrderUpdateList.add(updatedSalesOrder);
                }
                String statusCode = String.valueOf(response.getStatusCode());
                if(!Test.isRunningTest() && String.isNotBlank(response.getBody())) {
                    SAP_ErrorResponse sapErrorResponse = SAP_ErrorResponse.parse(response.getBody());
                    if(sapErrorResponse.error != null){
                        errorMessage = sapErrorResponse.error.message.value;
                    }
                }
                System.debug('after error parsing response---->'+response);
                SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(salesOrder.id, salesOrder.name, UTL_API_Utility.APPNAME_SO, requestBody, statusCode,  response.getBody(),errorMessage);
                if(apiLoggerByRecordIdMap.containsKey(salesOrder.Id)) {
                    log.id = apiLoggerByRecordIdMap.get(salesOrder.Id);
                }
                apiLoggerUpsertList.add(log);
            }
            if(!salesOrderUpdateList.isEmpty()) {
                Database.SaveResult[] updateResult = Database.update(salesOrderUpdateList,false);
                for(Integer i=0; i < updateResult.size(); i++) {
                    if(!updateResult.get(i).isSuccess()) {
                        SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(salesOrderUpdateList.get(i).id, salesOrderUpdateList.get(i).name, UTL_API_Utility.APPNAME_SO, requestBody, UTL_API_Utility.APEX_FAILURE,response.getBody(),updateResult[i].getErrors()[0].getMessage());
                        apiLoggerUpsertList.add(log);
                    }
                }
            } 
        } catch(Exception e) {
            Set<Id> salesOrderIdsSet = (new Map<Id,gvp__Sales_Order__c>(salesOrders)).keySet();   
            String errorMessage = 'Exception while processing the Sales Order to SAP. Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
            SAP_API_Logger__c log = UTL_API_Utility.createAPILogger('', '', UTL_API_Utility.APPNAME_SO, requestBody, UTL_API_Utility.TRANSACTION_FAILURE , '' , errorMessage);                            
            apiLoggerUpsertList.add(log); 
            CreateExceptionLog.insertErrorLog('EXT_SAP_SalesOrderHelper', 'handleSalesOrderCreation', String.valueOf(errorMessage), 'Fatal');
        } finally {
            UTL_API_Utility.saveAPILogger(apiLoggerUpsertList);
        }
    }

    public static void handleCalloutFailure(String errorMessage, gvp__Sales_Order__c salesOrder, String requestBody, 
                        List<SAP_API_Logger__c> apiLoggerUpsertList, 
                        List<gvp__Sales_Order__c> salesOrderUpdateList,
                        Map<String, String> apiLoggerByRecordIdMap) {
        SAP_API_Logger__c log = UTL_API_Utility.createAPILogger(salesOrder.Id, salesOrder.Name, UTL_API_Utility.APPNAME_SO, requestBody, UTL_API_Utility.STATUS_CODE_CALLOUT_EXCEPTION, null ,errorMessage);                 
        if(apiLoggerByRecordIdMap.containsKey(salesOrder.Id)) {
            log.id = apiLoggerByRecordIdMap.get(salesOrder.Id);
        }
        apiLoggerUpsertList.add(log);
        gvp__Sales_Order__c saleOrderToUpdate = new gvp__Sales_Order__c(Id = salesOrder.Id);
        saleOrderToUpdate.gvp__Status__c = STATUS_FAILED;
        saleOrderToUpdate.SAP_Error__c = errorMessage != null ? errorMessage.left(CHAR_LIMIT_LONG_TEXT) : null; 
        salesOrderUpdateList.add(saleOrderToUpdate);
    }

    public static gvp__Sales_Order__c updateSalesOrdersRecords(Id salesOrderId, HttpResponse response) {
        gvp__Sales_Order__c saleOrderToUpdate = null;
        String responseBody = response.getBody();
        if(String.isNotBlank(responseBody))
        {
            saleOrderToUpdate = new gvp__Sales_Order__c(Id = salesOrderId);
            responseBody = responseBody.replaceFirst('"Currency" :', '"Currency_so" :');
            responseBody = responseBody.replace('"Currency" :', '"Currency_soi" :');
            if(response.getStatusCode() == 201){
                SAP_SalesOrderResponseModel responseModel = SAP_SalesOrderResponseModel.parse(responseBody);        
                saleOrderToUpdate.gvp__ERP_Id__c = responseModel.d.SalesOrderNumber;
                saleOrderToUpdate.SAP_Error__c = '';
            } else {
                SAP_ErrorResponse sapErrorResponse = SAP_ErrorResponse.parse(responseBody);
                saleOrderToUpdate.gvp__Status__c = STATUS_FAILED;
                String errorMessageFromSAP = sapErrorResponse.error.message.value;
                saleOrderToUpdate.SAP_Error__c = UTL_API_Utility.getUserFriendlyError(errorMessageFromSAP ,UTL_API_Utility.APPNAME_SO);               
            }
        }
        return saleOrderToUpdate;
    }

    //try for generic
    public static String prepareSalesOrderRequestJSON(gvp__Sales_Order__c salesOrderObject){   
        SAP_SalesOrderRequestModel salesOrderRequest = new SAP_SalesOrderRequestModel();
        
        List<SAP_SalesOrderRequestModel.Results> salesOrderItemList =  new List<SAP_SalesOrderRequestModel.Results>(); 
        Integer sequenceNumber = 000010;
        
        for(gvp__Sales_Order_Item__c tempSalesOrderItem : salesOrderObject.gvp__Sales_Order_Items__r){
            SAP_SalesOrderRequestModel.Results salesOrderItem = new SAP_SalesOrderRequestModel.Results();
            salesOrderItem.UnitofMeasureTxt = '';//Case
            salesOrderItem.ProductName = tempSalesOrderItem.gvp__Item__r.Name;
            salesOrderItem.MaterialNumber = tempSalesOrderItem.gvp__Item__r.gvp__Item_Number__c;
            salesOrderItem.Quantity = String.ValueOf(tempSalesOrderItem.gvp__Quantity__c);
            salesOrderItem.UnitofMeasure = tempSalesOrderItem.gvp__Item__r.gvp__Unit_of_Measurement__c;
            salesOrderItem.NetAmount = '0.00';//?
            salesOrderItem.ImageFlag = false;
            salesOrderItem.RequestedDeliveryDate = dateConverter(salesOrderObject.gvp__Delivery_Date__c);
            salesOrderItem.EstimatedDeliveryDate = dateConverter(tempSalesOrderItem.gvc_Estimated_Delivery_Date__c);
            salesOrderItem.AvailableQuantity = '0.000';//?
            salesOrderItem.FinalPrice = '0.00';//?
            salesOrderItem.Product = '';//US114122
            salesOrderItem.SalesOrderNumber = '';
            salesOrderItem.ItemNumber = String.ValueOf(sequenceNumber);//Calculated sequence number starting with 00010 +10
            salesOrderItem.Currency_soi = salesOrderObject.CurrencyIsoCode;
            salesOrderItem.DeliveryStatusCode = ''; 
            salesOrderItem.QuantityStatusCode = '';
            salesOrderItem.PurchNo_S = tempSalesOrderItem.Id;
            
            salesOrderItemList.add(salesOrderItem);
            
            sequenceNumber = sequenceNumber + 10;
        }
        
        
        SAP_SalesOrderRequestModel.OrderItemSet orderItemSet = new SAP_SalesOrderRequestModel.OrderItemSet();
        orderItemSet.results = salesOrderItemList;
        
        SAP_SalesOrderRequestModel.d salesOrderObj = new SAP_SalesOrderRequestModel.d();        
        salesOrderObj = populateShipToSoldToForMexico(salesOrderObject,salesOrderObj); 
        salesOrderObj.ShipToPartnerName = '';
        salesOrderObj.SalesOrderSimulation = false;
        salesOrderObj.SingleShipment = false;
        salesOrderObj.OrderItemCount = salesOrderItemList.size();
        salesOrderObj.ShipToCity = '';
        salesOrderObj.SalesOrderNumber = '';
        salesOrderObj.PO = salesOrderObject.gvc_Purchase_Order__c;
        //salesOrderObj.ShipToPartnerID = salesOrderObject.gvp__Account__r.gvp__Account_Key__c;
        salesOrderObj.ShipToContact = '';
        salesOrderObj.ShippingCarrier = '';
        salesOrderObj.ShippingIncoTerms = '';
        salesOrderObj.Currency_so = salesOrderObject.CurrencyIsoCode;
        salesOrderObj.ShipToPostalCode = '';
        salesOrderObj.FormattedAddress1 = '';
        salesOrderObj.ShipToRegion = '';
        salesOrderObj.ShipmentInstruction = salesOrderObject.gvp__Delivery_Instructions__c;
        salesOrderObj.RequestedDate = dateConverter(salesOrderObject.gvp__Delivery_Date__c);
        salesOrderObj.PaymentTerms = '';
        salesOrderObj.Status = '';
        salesOrderObj.PromotionCode = '';         
        //salesOrderObj.CustomerID = String.isBlank(salesOrderObject.gvp__Account__r.Parent.gvp__Account_Key__c) ? salesOrderObject.gvp__Account__r.gvp__Account_Key__c :salesOrderObject.gvp__Account__r.Parent.gvp__Account_Key__c;//30082
        //salesOrderObj.CustomerID = (String.isNotBlank(salesOrderObject.gvp__Account__r.Parent.gvp__Account_Key__c) && salesOrderObject.gvp__Account__r.Parent.gvp__Account_Groups__c == 'Sold to')? salesOrderObject.gvp__Account__r.Parent.gvp__Account_Key__c:salesOrderObject.gvp__Account__r.gvp__Account_Key__c ;
        salesOrderObj.CustomerName = '';
        salesOrderObj.FormattedAddress9 = '';
        salesOrderObj.Tax = '0.00';
        salesOrderObj.Freight = '0.00';
        salesOrderObj.FormattedAddress8 = '';
        salesOrderObj.GrandTotal = '0.00';
        salesOrderObj.ShipToAddressLine1 = '';
        salesOrderObj.ShipToCountry = '';
        salesOrderObj.FormattedAddress7 = '';
        salesOrderObj.TotalAmount = String.valueOf(salesOrderObject.gvp__Order_Total__c);
        salesOrderObj.FormattedAddress2 = '';
        salesOrderObj.FormattedAddress3 = '';
        salesOrderObj.FormattedAddress6 = '';
        salesOrderObj.FormattedAddress4 = '';
        salesOrderObj.FormattedAddress5 = '';
        salesOrderObj.NotesToReceiver = salesOrderObject.gvp__Order_Notes__c == null ?'':salesOrderObject.gvp__Order_Notes__c ;
        salesOrderObj.SalesOrganization = salesOrderObject.gvp__Account__r.gvc_Sales_Organization__c;
        salesOrderObj.DistributionChannel = salesOrderObject.gvp__Account__r.gvc_Distribution_Channel__c;
        salesOrderObj.Division =  salesOrderObject.gvp__Account__r.gvc_Division_Key__c;
        salesOrderObj.OrderDate = '';
        salesOrderObj.ShipToAddressLine2 = '';
        salesOrderObj.DocType = salesOrderObject.gvp__Order_Type__c == 'YFDU'? salesOrderObject.gvp__Order_Type__c : 'YOU';
        salesOrderObj.PurchNo_S = salesOrderObject.Id;
        salesOrderObj.YourRef = '';
        salesOrderObj.OrderItemSet = orderItemSet;
        
        salesOrderRequest.d = salesOrderObj;      
        String reqBody = JSON.serializePretty(salesOrderRequest);
        reqBody = reqBody.replace('"Currency_so" :', '"Currency" :');
        reqBody = reqBody.replace('"Currency_soi" :', '"Currency" :');
        return reqBody;
    }
    
    public static String dateConverter(Date dateValue){
        String dateString = '';
        if(String.isNotBlank(String.valueOf(dateValue)) || dateValue != null)
        {
            String sMonth = String.valueof(dateValue.month());
            String sDay = String.valueof(dateValue.day());
            if(sMonth.length()==1){
                sMonth = '0' + sMonth;
            }
            if(sDay.length()==1){
                sDay = '0' + sDay;
            }
            dateString = String.valueof(dateValue.year()) + sMonth + sDay ;
        }
        return dateString;
    } 

    public static SAP_SalesOrderRequestModel.d populateShipToSoldToForMexico(gvp__Sales_Order__c salesOrderObject,SAP_SalesOrderRequestModel.d salesOrderObj){

        String wholesaler = '';
        if(String.isNotBlank(salesOrderObject.gvp__Account_Selector__r.gvp__Account_Key__c))
        {
         wholesaler = String.valueOf(salesOrderObject.gvp__Account_Selector__r.gvp__Account_Key__c); 
        }

        String rectype = salesOrderObject.gvp__Account__r.RecordType.Name;
        String ordertype = salesOrderObject.gvp__Order_Type__c;
        String offtrade = OFFTRADE;
        String ontrade = ONTRADE;
        String office = '';

        String soldto = (String.isNotBlank(salesOrderObject.gvp__Account__r.Parent.gvp__Account_Key__c) && 
        salesOrderObject.gvp__Account__r.Parent.gvp__Account_Groups__c == 'Sold to') ? 
        salesOrderObject.gvp__Account__r.Parent.gvp__Account_Key__c:salesOrderObject.gvp__Account__r.gvp__Account_Key__c;//customerId 
        
        String shipto = salesOrderObject.gvp__Account__r.gvp__Account_Key__c;//shiptopartnerId 

        if(String.isNotBlank(wholesaler) && (rectype=='Off-Premise'|| rectype=='Off Premise' || rectype=='On-Premise' || rectype=='On Premise'))
        {
            office = wholesaler;
        }
        else if(String.isBlank(wholesaler) && (rectype=='Off-Premise'|| rectype=='Off Premise'))
        {
            office = offtrade;
        }      
        else 
        {
            office = ontrade;
        }
  
        boolean willcall = salesOrderObject.gvp__Will_Call__c;

        if((rectype=='Off-Premise'|| rectype=='Off Premise'  || rectype=='Distributor' || rectype=='On-Premise' || rectype=='On Premise') && ordertype=='YFDU' && willcall==true)
        {
            salesOrderObj.CustomerID = office;
            salesOrderObj.ShipToPartnerID = shipto;
        }
        else
        {
            salesOrderObj.CustomerID = soldto;
            salesOrderObj.ShipToPartnerID = shipto;
        } 

        return salesOrderObj;
    }
}