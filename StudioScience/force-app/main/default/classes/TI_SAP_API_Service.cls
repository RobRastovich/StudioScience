public class TI_SAP_API_Service {
	public static void updateShipmentNumberAndTrackingNumber(List<sObject> barrelFromBatch) {
        String shipmentNumber = '';
        String trackingNumber = '';
        String trackingCarrier = '';
        if(barrelFromBatch.size() > 0) {
            List<Barrel__c> barrelToBeUpdated = barrelFromBatch;
            map<String, String> mapCaseIdToSapNumber = getMapCaseIdToSapNumber(barrelToBeUpdated);
            for(Barrel__c obj : barrelToBeUpdated) {
                try {
                    shipmentNumber = obj.Shipment_Number__c;
                    if(String.isEmpty(shipmentNumber)){
                        String relatedCaseID = obj.Case__c;
                        String sapNum = mapCaseIdToSapNumber.get(relatedCaseID);
                        String res = TI_SAP_API_Delegate.fetchData(sapNum);
                        if(String.isNotBlank(res)){
                        shipmentNumber = TI_SAP_Data_Extraction.fetch_Docnum_Data(res);
                    }
                    }
                    if(String.isNotEmpty(shipmentNumber)) {
                        String trackingNumberResponse = TI_SAP_API_Delegate.fetchTrackingNumber(shipmentNumber);
                        List<String> trackingInfo = TI_SAP_Data_Extraction.fetch_TrackingNumber(trackingNumberResponse);
                        if(trackingInfo.size() > 0) {
                            trackingNumber = trackingInfo[0];
                            trackingCarrier = trackingInfo[1];
                        }
                    }
                    obj.Shipment_Number__c = shipmentNumber;
                    obj.Tracking_Number__c = trackingNumber;
                    obj.CarrierNew__c = trackingCarrier;
                    update obj;
                } catch(Exception e) {
                    CreateExceptionLog.insertErrorLog('TI_SAP_API_Service',
                                                      'updateShipmentNumberAndTrackingNumber','For Barrel : ' + obj.Name + String.valueOf(e), 'Fatal');
                }
            }
        }
    }
    public static map<String, String> getMapCaseIdToSapNumber(List<Barrel__c> barrelFromBatch){
        Set <Id> caseIds = new Set<Id>();
        for (Barrel__c recordBarrel : barrelFromBatch){
            caseIds.add(recordBarrel.Case__c);
        }
        List<Case> casesList = SLT_TI_SAP_API_Case.getCaseListByID(caseIds);
        Map<String,String> mapCaseIdToSapNumber = new Map<String,String>();
        for (Case recordCase:casesList){
            mapCaseIdToSapNumber.put(recordCase.Id, recordCase.SAP_Number__c);
        }
        return mapCaseIdToSapNumber;
    }
}