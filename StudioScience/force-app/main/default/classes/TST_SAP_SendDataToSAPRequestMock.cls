@isTest
public class TST_SAP_SendDataToSAPRequestMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"d":{"ShipToPartnerName":"","SalesOrderSimulation":false,"SingleShipment":false,"OrderItemCount":0,"ShipToCity":"","SalesOrderNumber":"5360000022","PO":"","ShipToPartnerID":"","ShipToContact":"","ShippingCarrier":"","ShippingIncoTerms":"","Currency":"","ShipToPostalCode":"","FormattedAddress1":"","ShipToRegion":"","ShipmentInstruction":"","RequestedDate":"","PaymentTerms":"","Status":"","PromotionCode":"","CustomerID":"","CustomerName":"","FormattedAddress9":"","Tax":"0.00","Freight":"0.00","FormattedAddress8":"","GrandTotal":"0.00","ShipToAddressLine1":"","ShipToCountry":"","FormattedAddress7":"","TotalAmount":"0.00","FormattedAddress2":"","FormattedAddress3":"","FormattedAddress6":"","FormattedAddress4":"","FormattedAddress5":"","NotesToReceiver":"","SalesOrganization":"","DistributionChannel":"","Division":"","OrderDate":"","ShipToAddressLine2":"","OrderType":"","OrderItemSet":{"results":[]}}}');
        response.setStatusCode(201);
        return response; 
    }
}