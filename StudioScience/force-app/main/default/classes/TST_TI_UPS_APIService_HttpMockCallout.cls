@isTest
global class TST_TI_UPS_APIService_HttpMockCallout implements HttpCalloutMock {
    String body;
    public TST_TI_UPS_APIService_HttpMockCallout(String body){
    	this.body = body;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);    
        res.setStatusCode(200);	
        return res;
    }
}