public with sharing class ShipmentDelegate {
    public ShipmentDelegate() {
    }
    public static  map<string, ShipmentResponseWrapper > GetShipmentTrackingInfo(set<string> trackingNumbers, string carrier){
  		HTTPResponse res = new HTTPResponse();
        res = ShipmentRequestHandler.BuildTrackingRequest(carrier, trackingNumbers, true);
        map <string, ShipmentResponseWrapper> getStatus = new Map<string, ShipmentResponseWrapper>();
		getStatus = shipmentRequestHandler.ProcessTrackingResponse('FedEx',res);
		system.debug('getStatus');
		system.debug(getStatus);        
        return  getStatus;
    }
    public class ShipmentCustomException extends Exception{}
}