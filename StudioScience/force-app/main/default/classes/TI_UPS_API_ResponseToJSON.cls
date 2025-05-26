public class TI_UPS_API_ResponseToJSON {
    //added for metadata
    static map<String, String> allCodes = SLT_DTC_CustomMetadata.getTrackTypeList();
      public static List<String> fetchUPS_API_DateAndSatus(String res){
        List<String> dateAndStatus = new List<String>();
        try{
            //all variables are initialized with empty string so that index values do not change if anything does not appear
            Map<String, Object> trackResponseDeserialized = (Map<String, Object>) JSON.deserializeUntyped(res);            
            Map<String, Object> trackResponse =(Map<String, Object>) (trackResponseDeserialized.get('trackResponse'));
            List<Object> shipment = (List<Object>)trackResponse.get('shipment');
            Map<String, Object> packageDeserialized =(Map<String, Object>) shipment[0];
            List<Object> package1 =(List<Object>) packageDeserialized.get('package');
            Map<String, Object> deliveryDateDeserialized = (Map<String, Object>) package1[0];
            List<Object> deliveryDate =(List<Object>) deliveryDateDeserialized.get('deliveryDate');
            Map<String, Object> dateDeserialized = (Map<String, Object>) deliveryDate[0];
            List<Object> activityDeserialized =(List<Object>) deliveryDateDeserialized.get('activity');
            Map<String, Object> activity = (Map<String, Object>) activityDeserialized[0];
            Map<String, Object> status =(Map<String, Object>) (activity.get('status'));
            //added for location
            Map<String, Object> Location =(Map<String, Object>) (activity.get('location'));
            Map<String, Object> Address =(Map<String, Object>) (Location.get('address'));
            
            String UIDate = '';
            UIDate = dateDeserialized.get('date').toString();
            UIDate = UIDate.right(8);
            UIDate = UIDate.left(4) +  '-' + UIDate.substring(4, 6) + '-' + UIDate.right(2);
            dateAndStatus.add(UIDate);//index 0
            
            //description acc to metadata ---- CODE CHANGED HERE
            String description = '';
            description = status.get('description').toString();
            dateAndStatus.add(description);//index 1
            
            String locationOfBarrel = '';
            
            if(Address.get('city') != null && String.isNotBlank(Address.get('city').toString())){
			    locationOfBarrel = locationOfBarrel + Address.get('city').toString();
            }
            if(Address.get('stateProvince') != null && String.isNotBlank(Address.get('stateProvince').toString())){
                if(String.isEmpty(locationOfBarrel)) {
                    locationOfBarrel = locationOfBarrel + Address.get('stateProvince').toString();
                } else {
                    locationOfBarrel = locationOfBarrel + ',' + Address.get('stateProvince').toString();
                }
            }
            if(Address.get('country') != null && Address.get('country') != ''){
                if(String.isEmpty(locationOfBarrel)) {
                    locationOfBarrel = locationOfBarrel + Address.get('country').toString();
                } else {
                    locationOfBarrel = locationOfBarrel + ','  + Address.get('country').toString();
                }
            }
            dateAndStatus.add(locationOfBarrel);//index 2
            
            
            //adding type
            String typeOfStatus = SBP_Constants.carrierName + '_' + status.get('type').toString();
            String trackStatusType = allCodes.get(typeOfStatus);
            dateAndStatus.add(trackStatusType);//index 3
       
            return dateAndStatus;
        } catch(Exception e) {
            Throw e;
        }
    }
}