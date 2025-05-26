public class TI_UPS_APIService {
  public class emptyResponseException extends Exception {}
  public class UPSException extends Exception {}
  public static void updateBarrelTrackingInfo(List<sObject> trackingNo) {
      if(trackingNo.Size() > 0) {
          List<Barrel__c> barrelToBeUpdated = trackingNo;
          for(Barrel__c obj : barrelToBeUpdated){
              try {
                  String trackingNumber = obj.Tracking_Number__c;
                  String res = TI_UPS_API_Delegate.fetchTrackingData(trackingNumber);
                  if (String.isNotBlank(res) && res != null && res.contains('activity')) {
                   
                    List<String> dateAndStatus = TI_UPS_API_ResponseToJSON.fetchUPS_API_DateAndSatus(res);           
                    String Location = dateAndStatus[2];
                    String trackType = dateAndStatus[3];
                    String UPS_Delivery_Status = dateAndStatus[1];
                    String EstimatedDeliveryDate = dateAndStatus[0];
                    if(UPS_Delivery_Status != null && String.isNotBlank(UPS_Delivery_Status) && EstimatedDeliveryDate != null 
                       && String.isNotBlank(EstimatedDeliveryDate) && Location != null 
                       && String.isNotBlank(Location) && trackType != null 
                       && String.isNotBlank(trackType))
                    {
                        obj.UPS_Delivery_Status__c =  UPS_Delivery_Status;
                        obj.Estimated_Delivery_Date__c = Date.valueOf(EstimatedDeliveryDate);
                        obj.Location__c = Location;
                        obj.Track_Status_Type__c = trackType;
                        update obj;
                    }
                      
                    } else {
                        if(String.isBlank(res) || res == null) {
                            throw new emptyResponseException('Bad Request or error code!');
                        } else if(!res.contains('activity')) {
                            throw new UPSException('No Activity Recieved by UPS');
                        }
                    } 
          } catch(Exception e) {
              if(e.getMessage() == SBP_Constants.noTrackingDetails) {
                  //obj.Track_Status_Type__c = 'Exception';
                  obj.UPS_Delivery_Status__c =  e.getMessage();
                  //obj.Is_Manual__c = True;
                  update obj;
              }
              else {
                  CreateExceptionLog.insertErrorLog('TI_UPS_APIService', 'updateBarrelTrackingInfo','For Barrel : ' + obj.Name + String.valueOf(e), 'Fatal');
              }
              
          }
        }
      }
     
  }
}