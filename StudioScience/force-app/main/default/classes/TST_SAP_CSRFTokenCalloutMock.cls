@isTest
public class TST_SAP_CSRFTokenCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('x-csrf-token','mocktoken');
        res.setHeader('set-cookie','mockcookies');
        res.setBody('');
        res.setStatusCode(200);
        return res;
    }
}