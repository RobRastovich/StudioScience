global class SAPAuth extends Auth.AuthProviderPluginClass {

    private String clientId;
    private String clientSecret;
    private String accessTokenURL;
    private String authorizationURL;
    private String scope;
    private String userInfoUrl;
    public String redirectUri;
    public string state;
    private String sUser = userinfo.getName();

    // This method is responsible for returning the custom metadata storing the api credentials and other details
    global String getCustomMetadataType() {
        return 'SAPAuthProvider__mdt';
    }

    // This method is responsible to initiate the authorization code flow
    global PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        clientId = authProviderConfiguration.get('Client_Id__c');
        authorizationUrl = authProviderConfiguration.get('Authorization_URL__c');
        scope = authProviderConfiguration.get('Scope__c');
        redirectUri = authProviderConfiguration.get('Redirect_URI__c');
        String url = authorizationUrl + '?response_type=code&scope='+scope+'&client_id='+clientId+'&redirect_uri='+redirectUri+'&state='+stateToPropagate;
        system.debug('url in initiate method...'+url);
        return new PageReference(url);
    }

    /*   
      This method is responsible to handle the callback from authorization code flow
      set the access token, refresh token and other parameters
    */
    global Auth.AuthProviderTokenResponse handleCallback(Map<String, String> authProviderConfiguration, Auth.AuthProviderCallbackState state) {
       //system.debug('Auth :'+ Auth. ); 
       clientId = authProviderConfiguration.get('Client_Id__c');
       clientSecret = authProviderConfiguration.get('Client_Secret__c');              
       String clientIdEncoded = EncodingUtil.urlEncode(clientId, 'UTF-8');
       String clientSecretEncoded = EncodingUtil.urlEncode(clientSecret, 'UTF-8');
       String ketTokenCombined = clientIdEncoded + ':' + clientSecretEncoded;
       redirectUri = authProviderConfiguration.get('Redirect_URI__c');              
       Map<String,String> queryParams = state.queryParameters;
       String code = queryParams.get('code');
       String sfdcState = queryParams.get('state');       
       HttpRequest req = new HttpRequest();
       req.setEndpoint(authProviderConfiguration.get('Access_Token_URL__c'));
       system.debug('handleCallback Method ::: Endpoint URL:: '+authProviderConfiguration.get('Access_Token_URL__c'));
       req.setHeader('Accept','application/json');       
       String authHeadParam = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(ketTokenCombined));
       req.setHeader('Authorization', authHeadParam);       
       req.setMethod('POST');
       req.setBody('grant_type=authorization_code&code='+code+
                   '&redirect_uri='+redirectUri+
                   '&client_id='+clientId+
                   '&state=anystate');
       Http http = new Http();
       system.debug('handleCallback Method ::: request:::'+req);
       HTTPResponse res = http.send(req);
        
        //string sCookie  = req.getHeader('set_cookie');
        //system.debug('#############sCookie: ' + sCookie);
       system.debug('handleCallback Method ::: responseBody: ' + res.getBody());      
       SAPResponse response = (SAPResponse) JSON.deserialize(res.getBody(), SAPResponse.class);  
       system.debug('Exit handleCallback Method'); 
       System.debug('Access Token: ' + response.access_token);      
       return new Auth.AuthProviderTokenResponse('SAPAuth', response.access_token, response.refresh_token, sfdcState);       
    }    
    
   
    //if access token expired, refresh method is used to retrieve a new access token    
    global override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {        
        system.debug('refresh method started');       
        clientId = authProviderConfiguration.get('Client_Id__c');
        clientSecret = authProviderConfiguration.get('Client_Secret__c');      
        String clientIdEncoded = EncodingUtil.urlEncode(clientId, 'UTF-8');
        String clientSecretEncoded = EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        String ketTokenCombined = clientIdEncoded + ':' + clientSecretEncoded;                     
        String authHeadParam = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(ketTokenCombined));
        HttpRequest req = new HttpRequest();        
        req.setHeader('Authorization', authHeadParam);         
        req.setEndpoint(authProviderConfiguration.get('Access_Token_URL__c')); 
        system.debug('refresh Method ::: Endpoint URL:: '+authProviderConfiguration.get('Access_Token_URL__c'));        
        req.setHeader('Accept','application/json');
        req.setMethod('POST'); 
        req.setBody('grant_type=refresh_token'
                    + '&redirect_uri='+authProviderConfiguration.get('Redirect_URI__c')
                    + '&client_id='+authProviderConfiguration.get('Client_Id__c')
                    + '&client_secret='+ authProviderConfiguration.get('Client_Secret__c')
                    + '&refresh_token='+ refreshToken);
        Http http = new Http();
        system.debug('Refresh Method ::: request:::'+req);
        HTTPResponse res = http.send(req);
        system.debug('Refresh method....response body::::::'+res.getBody());        
        SAPResponse response = (SAPResponse)JSON.deserialize(res.getBody(), SAPResponse.class);               
        return new Auth.OAuthRefreshResult(response.access_token, response.refresh_token, response.error);
    }
    
    
    
    // This method is responsible to get the user information used for authentication from the external api
    global Auth.UserData getUserInfo(Map<String, String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {        
        system.debug('Exit getUserInfo Method');
        return new Auth.UserData('foo','foo','foo','foo foo','testEmailAddress','what',userinfo.getName(),null,'SAPPROVIDER',null,new Map<String,String>());            
    }  

    // Wrapper class to handle Access Token API response
    public class SAPResponse {
      public String access_token;
      public String refresh_token;
      public String token_type;
      public String scope;
      public String error; //"invalid_request"
    }        
}