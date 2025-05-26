@isTest
public class BGSW_WBS_HttpCalloutMock implements WebServiceMock {

    protected String campaignWBSId;
    protected String wbsCreated;
    protected String responseText;

    public BGSW_WBS_HttpCalloutMock(String campaignWBSId, String wbsCreated, String responseText) {
        this.campaignWBSId = campaignWBSId;
        this.wbsCreated = wbsCreated;
        this.responseText = responseText;
    }

    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction,
        String requestName, String responseNS, String responseName, String responseType) {
        
        BGSW_WBS_v2.Result_element respElement = new BGSW_WBS_v2.Result_element();
        respElement.Created = wbsCreated;
        respElement.ID = campaignWBSId;
        respElement.Response = responseText;
        BGSW_WBS_v2.WBS_Response wbsResponse = new BGSW_WBS_v2.WBS_Response();
        wbsResponse.Result = new List<BGSW_WBS_v2.Result_element>{respElement}; 

        response.put('response_x', wbsResponse);

    }
}