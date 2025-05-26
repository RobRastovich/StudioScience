public class FedExResponseHandler {
    public String transactionId;
    public String customerTransactionId;
    public Output output;
    
    public class Output {
        public List<CompleteTrackResult> completeTrackResults;
    }
    
    public class CompleteTrackResult {
        public String trackingNumber;
        public List<TrackResult> trackResults;
    }
    
    public class TrackResult {
        public TrackingNumberInfo trackingNumberInfo;
        public Error error;
        public LatestStatusDetail latestStatusDetail;
        public List<dateAndTime> dateAndTimes;
        public String type;
        public List<ScanEvent> scanEvents;
    }
    
    public class TrackingNumberInfo {
        public String trackingNumber;
        public String carrierCode;
    }
    
    public class Error {
        public String code;
        public String message;
    }
    
    public class LatestStatusDetail {
        public String statusByLocale;
        public String description;
        public Location location;
        public String derivedStatusCode;
        public String code;
    }
    
    public class ScanEvent {
        public String dateD;
        public String eventDescription;
        public String exceptionDescription;
        public Location location;
    }
    
    public class Location {
        public String city;
        public String stateOrProvinceCode;
        public String countryCode;
    }
    
    public class dateAndTime {
        public DateTime DateTime_X;
        public String type;
    }
    
    public static map<string, ShipmentResponseWrapper> parseFedExTrackingResponse(String jsonResponse) {
        map <string, ShipmentResponseWrapper > mReturnStatuses = new map <string, ShipmentResponseWrapper>();
        // Replace "dateTime" with "DateTime_X"
        String modifiedJsonResponse = jsonResponse.replace('"dateTime":', '"DateTime_X":');
        // Deserialize the JSON response
        FedExResponseHandler response = (FedExResponseHandler) JSON.deserialize(modifiedJsonResponse, FedExResponseHandler.class);
        // Accessing the parsed data 
        for (FedExResponseHandler.CompleteTrackResult completeTrackResult : response.output.completeTrackResults) {
            System.debug('Tracking Number: ' + completeTrackResult.trackingNumber);
            for (FedExResponseHandler.TrackResult trackResult : completeTrackResult.trackResults) {
                String jNotificationErrorCode;
                String jStatusCode;
                String jStatusDescription;
                String jSeverity;
                Date estimatedDeliveryDate;
                if (trackResult.latestStatusDetail != null) {
                    jStatusCode = trackResult.latestStatusDetail.code;
                    jStatusDescription = trackResult.latestStatusDetail.description;
                }
                if (trackResult.error != null) {
                    jNotificationErrorCode = trackResult.error.code;
                }
                if(trackResult.dateAndTimes != null) {
                    for (dateAndTime dateTimeEst : trackResult.dateAndTimes) {
                        if (dateTimeEst.type == 'ESTIMATED_DELIVERY') {
                            estimatedDeliveryDate =  date.newinstance(dateTimeEst.DateTime_X.year(), dateTimeEst.DateTime_X.month(), dateTimeEst.DateTime_X.day());
                        } else {
                            estimatedDeliveryDate = null;
                        }
                    }  
                }
                mReturnStatuses.put(completeTrackResult.trackingNumber, new ShipmentResponseWrapper(jNotificationErrorCode,
                                                                                                    jStatusCode,
                                                                                                    jStatusDescription,
                                                                                                    jSeverity,
                                                                                                    estimatedDeliveryDate));
            } 
        }
        return mReturnStatuses;
    } 
}