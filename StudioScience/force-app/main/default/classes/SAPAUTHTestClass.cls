@IsTest 
public class SAPAUTHTestClass { 

    private static final String OAUTH_TOKEN = 'testToken'; 
    private static final String STATE = 'mocktestState'; 
    private static final String REFRESH_TOKEN = 'refreshToken'; 
    private static final String LOGIN_ID = 'testLoginId'; 
    private static final String USERNAME = 'testUsername'; 
    private static final String FIRST_NAME = 'foo'; 
    private static final String LAST_NAME = 'foo'; 
    private static final String EMAIL_ADDRESS = 'testEmailAddress'; 
    private static final String LOCALE_NAME = 'testLocalName'; 
    private static final String FULL_NAME = FIRST_NAME + ' ' + LAST_NAME; 
    private static final String PROVIDER = 'SAPAuth'; 
    private static final String REDIRECT_URL = 'http://localhost/services/authcallback/orgId/SAPAUTH'; 
    private static final String KEY = 'testKey'; 
    private static final String SECRET = 'testSecret'; 
    private static final String STATE_TO_PROPOGATE = 'testState'; 
    private static final String ACCESS_TOKEN_URL =  'http://www.dummyhost.com/accessTokenUri'; 
    private static final String API_USER_VERSION_URL = 'http://www.dummyhost.com/user/20/1'; 
    private static final String AUTH_URL = 'http://www.dummy.com/authurl'; 
    private static final String API_USER_URL = 'www.SAPAUTHsolutions.com/user/api'; 
    private static final String CLIENTID = 'TestClientID';
    private static final String SCOPE= 'testscope12345';

// In the real world scenario, the key and value would be read 
// from the (custom fields in) custom metadata type record. 
private static Map<String,String> setupAuthProviderConfig () 
{ 
    Map<String,String> authProviderConfiguration = new Map<String,String>(); 
    authProviderConfiguration.put('Key__c', KEY); 
    authProviderConfiguration.put('Client_Secret__c', SECRET); 
    authProviderConfiguration.put('API_User_Url__c',API_USER_URL); 
    authProviderConfiguration.put('API_User_Version_Url__c',API_USER_VERSION_URL); 
    authProviderConfiguration.put('Redirect_Url__c',REDIRECT_URL); 
    authProviderConfiguration.put('Redirect_URI__c',REDIRECT_URL);
    authProviderConfiguration.put('Client_Id__c', CLIENTID);
    authProviderConfiguration.put('Authorization_URL__c', AUTH_URL);
    authProviderConfiguration.put('Scope__c', SCOPE);
    authProviderConfiguration.put('State__c', STATE);
    authProviderConfiguration.put('Access_Token_URL__c', ACCESS_TOKEN_URL); 
    return authProviderConfiguration; 

} 

static testMethod void testInitiateMethod() 
{ 
    String stateToPropogate = 'mocktestState'; 
    Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
    SAPAUTH SAPAUTHCls = new SAPAUTH(); 
    SAPAUTHCls.redirectUri = authProviderConfiguration.get('Redirect_Url__c'); 
    
    PageReference expectedUrl = new PageReference(authProviderConfiguration.get('Authorization_URL__c') + '?response_type=code&scope='+SCOPE+'&client_id='+ 
    authProviderConfiguration.get('Client_Id__c') +'&scope=USER,EXPRPT,LIST&redirect_uri='+ 
    authProviderConfiguration.get('Redirect_URI__c') + '&state=' + STATE_TO_PROPOGATE); 
    system.debug(expectedUrl.getUrl() );
                                                
    PageReference actualUrl = SAPAUTHCls.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
    System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
} 

static testMethod void testHandleCallback() 
{ 
    Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
    SAPAUTH SAPAUTHCls = new SAPAUTH(); 
    SAPAUTHCls.redirectUri = authProviderConfiguration.get ('Redirect_Url_c'); 

    Test.setMock(HttpCalloutMock.class, new SAPAUTHMockHttpResponseGenerator()); 

    Map<String,String> queryParams = new Map<String,String>(); 
    queryParams.put('code','code'); 
    queryParams.put('state',authProviderConfiguration.get('State_c')); 
    Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
    Auth.AuthProviderTokenResponse actualAuthProvResponse = SAPAUTHCls.handleCallback(authProviderConfiguration, cbState); 
    Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('SAPAUTH', OAUTH_TOKEN, REFRESH_TOKEN, null); 

    System.assertEquals(expectedAuthProvResponse.provider.toUpperCase(), actualAuthProvResponse.provider.toUpperCase()); 
    System.assertEquals(expectedAuthProvResponse.oauthToken,  actualAuthProvResponse.oauthToken); 
    System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken); 
    System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state); 

    Auth.OAuthRefreshResult actualRefreshAuthProvResponse = SAPAUTHCls.refresh(authProviderConfiguration, actualAuthProvResponse.oauthSecretOrRefreshToken); 
   
    System.assertEquals(expectedAuthProvResponse.oauthToken,  actualRefreshAuthProvResponse.accessToken); 
    System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualRefreshAuthProvResponse.refreshToken); 
   
} 


 
static testMethod void testGetUserInfo() 
{ 
    Map<String,String> authProviderConfiguration =  setupAuthProviderConfig(); 
    SAPAUTH SAPAUTHCls = new SAPAUTH(); 

    Test.setMock(HttpCalloutMock.class, new 
    SAPAUTHMockHttpResponseGenerator()); 

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
    PROVIDER, OAUTH_TOKEN ,'sampleOauthSecret', STATE); 
    Auth.UserData actualUserData = SAPAUTHCls.getUserInfo(authProviderConfiguration, response) ; 

    Map<String,String> provMap = new Map<String,String>(); 
    provMap.put('key1', 'value1'); 
    provMap.put('key2', 'value2'); 

    Auth.UserData expectedUserData = new Auth.UserData(LOGIN_ID, 
    FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS, 
    null, LOCALE_NAME, null, PROVIDER, null, provMap); 

    System.assertNotEquals(expectedUserData,null); 
    System.assertEquals(expectedUserData.firstName, actualUserData.firstName); 
    System.assertEquals(expectedUserData.lastName, actualUserData.lastName); 
    System.assertEquals(expectedUserData.fullName, actualUserData.fullName); 
    System.assertEquals(expectedUserData.email, actualUserData.email); 
   /* System.assertEquals(expectedUserData.username, actualUserData.username); 
    System.assertEquals(expectedUserData.locale, actualUserData.locale); 
    System.assertEquals(expectedUserData.provider, actualUserData.provider); 
    System.assertEquals(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl); */
} 


// Implement a mock http response generator for SAPAUTH. 
public class SAPAUTHMockHttpResponseGenerator implements HttpCalloutMock 
{ 
    public HTTPResponse respond(HTTPRequest req) 
    { 
        String namespace = API_USER_VERSION_URL; 
        String prefix = 'mockPrefix'; 

        /*Dom.Document doc = new Dom.Document(); 
        Dom.XmlNode xmlNode = doc.createRootElement('mockRootNodeName', namespace, prefix); 
        xmlNode.addChildElement('LoginId', namespace, prefix).addTextNode(LOGIN_ID); 
        xmlNode.addChildElement('FirstName', namespace, prefix).addTextNode(FIRST_NAME); 
        xmlNode.addChildElement('LastName', namespace, prefix).addTextNode(LAST_NAME); 
        xmlNode.addChildElement('EmailAddress', namespace, prefix).addTextNode(EMAIL_ADDRESS); 
        xmlNode.addChildElement('LocaleName', namespace, prefix).addTextNode(LOCALE_NAME); 
        xmlNode.addChildElement('Token', null, null).addTextNode(OAUTH_TOKEN); 
        System.debug(doc.toXmlString()); */

        // Create a fake response 
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
	        gen.writeStringField('access_token', OAUTH_TOKEN);
	        gen.writeStringField('refresh_token', REFRESH_TOKEN);
	        gen.writeendObject();
            String doc = gen.getAsString();
        HttpResponse res = new HttpResponse(); 
        res.setHeader('Content-Type', 'application/json');
        
        //res.setBody(doc.toXmlString()); 
        res.setBody(doc); 
        res.setStatusCode(200); 
        return res; 
    } 

} 
}