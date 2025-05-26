@isTest
global class ShipmentFailedMockHttpResponseGenerator implements HttpCalloutMock{
   
    global final String trackNumber;  

    public ShipmentFailedMockHttpResponseGenerator(string trackNum) {
        this.trackNumber = trackNum;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseBody());
        res.setStatusCode(200);
        return res;
    }

    static String responseBody(){
        String responseJson ='{"transactionId":"85d465bc-455a-4ef4-9a51-4e09b71b5e73","output":{"completeTrackResults":[{"trackingNumber":"778551834869","trackResults":[{"latestStatusDetail":{"code":"SF","derivedCode":"OW","statusByLocale":"On the way","description":"At destination sort facility"},"dateAndTimes":[{"type":"ESTIMATED_DELIVERY","dateTime":"2024-09-16T17:00:00-04:00"}]}]}]}}';
          return responseJson;
    }
}