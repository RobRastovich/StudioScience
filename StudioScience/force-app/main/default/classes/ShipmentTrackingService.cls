public class ShipmentTrackingService {
    public static void fetchAndUpdateDeliveryStatus(List<SObject> scope, String sCarrier){
        //try catch required
        set <string> trackingNumbers= new set<string>();
        map <string, SObject> mTrackNumObj = new map <string, SObject>();
        
        for (SObject obj : scope){
            string trkNo = (string) obj.get('Tracking_Number__c');
            mTrackNumObj.put(trkNo, obj); //map traking number to calling sObject 
            trackingNumbers.add(trkNo);   //set of tracking numbers to pass to tracking api
        } 
        
        //send request and process response.
         map <string, ShipmentResponseWrapper> getStatus;
        if(Test.isRunningTest())
        {
            ShipmentResponseWrapper rep = new ShipmentResponseWrapper(null,'DL','Test',null,null);
            getStatus= new map <string, ShipmentResponseWrapper>();
            getStatus.put(trackingNumbers.iterator().next(),rep);
        }
        else{
           getStatus = ShipmentDelegate.GetShipmentTrackingInfo(trackingNumbers, sCarrier);
        }
        //map <string, ShipmentResponseWrapper> getStatus = ShipmentDelegate.GetShipmentTrackingInfo(trackingNumbers, sCarrier); 
        system.debug('getStatus--->'+getStatus);
        
        //set status and update back to calling sObject
        list <SObject> lstUpdateStatus = new list<SObject>();
        for (string trackNum : getStatus.keyset()){ 
            SObject obj = mTrackNumObj.get(trackNum); // get record from the map by tracking number as key
            ShipmentResponseWrapper responseWrapper = getStatus.get(trackNum);
            System.debug('responseWrapper--->'+responseWrapper);
            //Tracking number doesn't exist in Fedex
            if(responseWrapper!=null && responseWrapper.trackDetailNotificationCode != null){
                obj.put('Tracking_Number_Not_Matched__c', true);
                //obj.put('Delivery_Status__c', 'In Transit');
            }
            else if(responseWrapper!=null && responseWrapper.trackDetailNotificationCode == null){  
                
                if(responseWrapper!=null && responseWrapper.code == '')
                {
                    obj.put('Is_Manual__c', true);
                }                
                else
                {
                    if(responseWrapper!=null && responseWrapper.estimatedDeliveryDate != null){//Update Estimated_Delivery_Date__c
                        obj.put('Estimated_Delivery_Date__c', responseWrapper.estimatedDeliveryDate);
                    } 
                    //Update mapped DeliveryStatus
                    Map<String, String> fedExMappedStatusMap = getFedExMappedValues();
                    String mappedDeliveryStatus = fedExMappedStatusMap.get(responseWrapper.code);
                    obj.put('Delivery_Status__c', mappedDeliveryStatus);                    
                    //Update DeliveryStatus as it is
                        obj.put('FedEx_API_Status__c', responseWrapper.code);
                }
            }             
            lstUpdateStatus.add(obj);            
            system.debug('object ' + lstUpdateStatus);
        }
        
        try{
            update lstUpdateStatus;
        }
        catch(DmlException e) {
            String errorMessage = 'Dml Exception ' + e.getMessage() + '\n' + e.getStackTraceString();           
            CreateExceptionLog.insertErrorLog('ShipmentTrackingService', 'fetchAndUpdateDeliveryStatus', String.valueOf(errorMessage), 'Fatal');   
        }
       
    }
    
        
    public static Map<String, String> getFedExMappedValues()
    {
        Map<String, String> fedExMappedStatusMap = new map<String, String>();
        List<FedEx_Sample_Kit_Status_Mapping__mdt> statusMappings = [Select id,FedEx_Status__c,Mapped_Delivery_Status__c from FedEx_Sample_Kit_Status_Mapping__mdt];
        for(FedEx_Sample_Kit_Status_Mapping__mdt skStatusMapping : statusMappings)
        {
            fedExMappedStatusMap.put(skStatusMapping.FedEx_Status__c, skStatusMapping.Mapped_Delivery_Status__c);                   
        }
        return fedExMappedStatusMap;
    }
}