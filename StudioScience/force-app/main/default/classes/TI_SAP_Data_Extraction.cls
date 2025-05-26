public class TI_SAP_Data_Extraction {
    public static String fetch_Docnum_Data(String res) {
        String shipmentNumber = '';
        try {
            Map<String, Object> docnumDeserialized = (Map<String, Object>) JSON.deserializeUntyped(res);            
            Map<String, Object> data =(Map<String, Object>) (docnumDeserialized.get('d'));
            List<Object> results = (List<Object>) data.get('results');
            if(results.size() > 0) {
                
            Map<String, Object> resultsDeserialized =(Map<String, Object>) results[0];
                shipmentNumber = (String) resultsDeserialized.get('Docnum');
            }
            return shipmentNumber;
        } catch(Exception e) {
            Throw e;
        }
    }
    public static List<String> fetch_TrackingNumber(String res) {
        List<String> trackingInfo = new List<String>();
        try {
            Map<String, Object> docnumDeserialized = (Map<String, Object>) JSON.deserializeUntyped(res);            
            Map<String, Object> data =(Map<String, Object>) (docnumDeserialized.get('d'));
            List<Object> results = (List<Object>) data.get('results');
            if(results.size() > 0) {
                
            Map<String, Object> resultsDeserialized =(Map<String, Object>) results[0];
            String trackingNumber = (String) resultsDeserialized.get('ContainerId');
            String carrierName = (String) resultsDeserialized.get('ServiceAgentName');
            carrierName = carrierName.toUpperCase();
            trackingInfo.add(trackingNumber);
            if(carrierName.contains('TFORCE')) {
                trackingInfo.add(SBP_Constants.carrierName);
            } else {
                trackingInfo.add(carrierName);
                }
            }
            return trackingInfo;
        } catch(Exception e) {
            Throw e;
        }
    }
}