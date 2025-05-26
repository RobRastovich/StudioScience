public with sharing class UTL_API_Utility {

    public static final String CUST_SETTING_STOREDCREDENTIALS_SO_APINAME = 'SAP_SO_Settings_oAuth';
    public static final String CUST_SETTING_STOREDCREDENTIALS_PR_APINAME = 'SAP_PR_Settings_oAuth'; 
    public static final String CUST_SETTING_STOREDCREDENTIALS_USBI_APINAME = 'SAP_USBI_Settings_oAuth';
    public static final String CUST_SETTING_STOREDCREDENTIALS_AUSBI_APINAME = 'SAP_AUSBI_Settings_oAuth';
    
    public static final String CUST_SETTING_STOREDCREDENTIALS_SO_QA_APINAME = 'SAP_SO_Settings_oAuth_QA';
    public static final String CUST_SETTING_STOREDCREDENTIALS_PR_QA_APINAME = 'SAP_PR_Settings_oAuth_QA';
    public static final String CUST_SETTING_STOREDCREDENTIALS_USBI_QA_APINAME = 'SAP_USBI_Settings_oAuth_QA';
    public static final String CUST_SETTING_STOREDCREDENTIALS_AUSBI_QA_APINAME = 'SAP_AUSBI_Settings_oAuth_QA';
    
    public static final String CONTENT_TYPE_XML = 'application/xml';
    public static final String CONTENT_TYPE_JSON = 'application/json';
    public static final Integer LONG_TEXT_CHAR_LIMIT = 131072;

    public static final String NAMED_CREDENTIAL_USBI_PROD = 'SAPCustomUSBIProd';
    public static final String NAMED_CREDENTIAL_AUSBI_PROD = 'SAPCustomAUSBIProd';
    public static final String NAMED_CREDENTIAL_SO_PROD = 'SAPCustomSOProd';
    public static final String NAMED_CREDENTIAL_PR_PROD = 'SAPCustomProd'; 
    public static final String NAMED_CREDENTIAL_TEST = System.Label.SAP_Org_Named_Credential; 

    public static final String SAP_SO_CREATE_RESOURCE ='/sap/opu/odata/sap/ZSRA017_SALESORDER_CREATE_SRV/SalesOrders'; 

    public static String applicationName = '';
    public static String rCSRFToken = '';
    public static String rCookie = '';
    public static final String APPNAME_SO = 'SO';
    public static final String APPNAME_PR = 'PR';
    public static final String APPNAME_AUSBI = 'AUS BI';
    public static final String APPNAME_USBI = 'US BI';
     
    public static final String APEX_FAILURE = 'Apex Failure';
    public static final String STATUS_CODE_REQ_INIT = 'SAP REQ INIT';
    public static final String STATUS_CODE_CALLOUT_EXCEPTION = 'CALLOUT EXCEPTION';
    public static final String TRANSACTION_FAILURE = 'Transaction Failure';

    public static final Map<String, String> CUST_SETTING_STOREDCREDENTIALS_MAP = new Map<String, String> {
        APPNAME_SO => CUST_SETTING_STOREDCREDENTIALS_SO_APINAME,
        APPNAME_PR => CUST_SETTING_STOREDCREDENTIALS_PR_APINAME,
        APPNAME_USBI => CUST_SETTING_STOREDCREDENTIALS_USBI_APINAME,
        APPNAME_AUSBI => CUST_SETTING_STOREDCREDENTIALS_AUSBI_APINAME
    };

    public static final Map<String, String> CUST_SETTING_STOREDCREDENTIALS_TEST_MAP = new Map<String, String> {
        APPNAME_SO => CUST_SETTING_STOREDCREDENTIALS_SO_QA_APINAME,
        APPNAME_PR => CUST_SETTING_STOREDCREDENTIALS_PR_QA_APINAME,
        APPNAME_USBI => CUST_SETTING_STOREDCREDENTIALS_USBI_QA_APINAME,//Similar entry for Prod in below map
        APPNAME_AUSBI => CUST_SETTING_STOREDCREDENTIALS_AUSBI_QA_APINAME    
    };

    public static final Map<String, String> NAMED_CREDENTIAL_MAP = new Map<String, String> {
        APPNAME_SO => NAMED_CREDENTIAL_SO_PROD,
        APPNAME_PR => NAMED_CREDENTIAL_PR_PROD,
        APPNAME_USBI => NAMED_CREDENTIAL_USBI_PROD,
        APPNAME_AUSBI => NAMED_CREDENTIAL_AUSBI_PROD    
    };

    public static String getEndpointHelper(String appName){
        String endpoint = '';
        StoredCredentials__c sap;
        Map<String,String> appStoredCredentialMap = CUST_SETTING_STOREDCREDENTIALS_TEST_MAP;
        if( Global_Utility.isProd()) {
            appStoredCredentialMap = CUST_SETTING_STOREDCREDENTIALS_MAP;
        }
        
        if(appStoredCredentialMap.containsKey(appName)){
            sap = StoredCredentials__c.getInstance(appStoredCredentialMap.get(appName));
            if(sap != null)
            endPoint = sap.Full_Endpoint__c;
        }
        return endPoint; 
    }

    public static CSRFAuthInfo getCSRFToken_oAuth(string appName){
        HTTPResponse response = new HTTPResponse();
        CSRFAuthInfo csrfResponse = new CSRFAuthInfo(appName);
        try {              
            String namedCredentials = NAMED_CREDENTIAL_TEST;
            if( Global_Utility.isProd()) {
                namedCredentials = NAMED_CREDENTIAL_MAP.get(appName); 
            }
            
            // need to make it dynamic based on calling app and prod vs sandbox         
            HttpRequest request = new HttpRequest();
            Http http = new Http();      
            request.setMethod('GET');
            String endpoint = getEndpointHelper(appName);
            if(appName == APPNAME_USBI)
            {
                endpoint = endpoint.replace('/InternalOrderSet', '/$metadata');
            }
            else if(appName == APPNAME_AUSBI)
            {
                endpoint = endpoint.replace('/WBSElementSet', '/$metadata');
            }
            
            else if(appName == APPNAME_SO)
            {
                endpoint = endpoint.replace('/SalesOrders', '/$metadata');
                system.debug(endpoint);
            }
            request.setEndpoint(endpoint);
            request.setHeader('x-csrf-token', 'fetch'); 
            
            NamedCredential nm = [SELECT Endpoint FROM NamedCredential where DeveloperName = : namedCredentials];
            string host = nm.Endpoint.replace('https://','');
            request.setHeader('Host', host);
            request.setHeader('Connection', 'keep-alive');
            request.setHeader('Accept-Encoding', 'gzip, deflate');
            request.setHeader('Accept', '*/*');  
            request.setHeader('Authorization' , 'Bearer ' + '{!$Credential.OAuthToken}');
            if(!Test.isRunningTest())
            response = http.send(request);
            system.debug(response);
                        
            string csrfToken=response.getHeader('x-csrf-token');
            string sCookie = response.getHeader('Set-Cookie');
            //-------------------------------------------------------------------
            if(response.getStatusCode() == 200)
            {
                csrfResponse.isUserAuthorized = true;
                csrfResponse.status = response.getStatus();
                csrfResponse.statusCode =  response.getStatusCode();
                csrfResponse.csrfToken = csrfToken;
                csrfResponse.sCookie = sCookie;
                System.debug('csrfToken generated::'+csrfToken);
                System.debug('sCookie generated::'+sCookie);
            } else {
                csrfResponse.isUserAuthorized = false;
                csrfResponse.status = response.getStatus();
                csrfResponse.statusCode =  response.getStatusCode();
                csrfResponse.errorMessage = response.getStatus();
            }

        } catch(Exception e)  {
            system.debug('getCSRFToken_oAuth ERROR:' + e);
            String errorMessage = 'Error establishing connection to external system ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('UTL_API_Utility', 'getCSRFToken_oAuth', String.valueOf(errorMessage), 'Fatal');
            //-------------------------------------------------------------------
            csrfResponse.isUserAuthorized = false;
            csrfResponse.errorMessage = errorMessage; 
            //-------------------------------------------------------------------
        }  
        return csrfResponse;       
    }
    
    public static String getUserFriendlyError(String errorMessageFromSAP ,String appName)
    {
        String errorString;
        List<SAP_Error_Mapping__mdt> errorMappings = [Select id,SAP_Meaningful_Error_Message__c,SAP_Error_Message__c from SAP_Error_Mapping__mdt where Application_Name__c =:appName ];
        for(SAP_Error_Mapping__mdt s : errorMappings)
        {
        	errorString = s.SAP_Error_Message__c;
        	if(errorMessageFromSAP.startsWith(errorString)){
        		errorMessageFromSAP = s.SAP_Meaningful_Error_Message__c;
        		break;
        	}                     
        }
        return errorMessageFromSAP;
        
    }

    public static boolean checkUserNamedCredential(Id userId, String appName) {
        String namedCredentials = UTL_API_Utility.NAMED_CREDENTIAL_TEST;
        if( Global_Utility.isProd()) {
            namedCredentials = NAMED_CREDENTIAL_MAP.get(appName);
        }
        NamedCredential nm = [SELECT AuthProviderId FROM NamedCredential where DeveloperName = : namedCredentials];
        ExternalDataUserAuth[] externalDataUserAuth = [SELECT AuthProviderId, Id FROM ExternalDataUserAuth WHERE AuthProviderId = :nm.AuthProviderId AND UserId = :userId];
        return (externalDataUserAuth.size() > 0);
    }

    public static HttpResponse sendPRDataToSAP(SObject record, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo) {
        String contentType = CONTENT_TYPE_XML; 
        PR_detail__c prDetalObject = (PR_detail__c)record;
        String prId = prDetalObject.PR_Header__c;
        List<PR_detail__c> prDetails = BS_SAP_Connection_Manager.getPrDetails(prID);
        String requestBody = PR_XML_Helper.buildXml(prID, prDetails); //adjust to app type
        HttpResponseWrapper responseWrapper =  sendDataToSAPRequest(requestBody, contentType, null, csrfAuthInfo);  
        return responseWrapper.response;
    }

    public static HttpResponseWrapper sendDataToSAPRequest(String requestBody, String contentType, String acceptType, UTL_API_Utility.CSRFAuthInfo csrfAuthInfo) {   
        System.debug('csrfAuthInfo------>>>>>>::'+ csrfAuthInfo);
        HttpResponseWrapper responseWrapper;
        HttpRequest request = new HttpRequest();
        String reqBody = '';
        Http http = new Http();     
        HTTPResponse response = new HTTPResponse();    
        try {
            request.setMethod('POST');
            request.setEndpoint(getEndpointHelper(csrfAuthInfo.appName));
            request.setHeader('x-csrf-token', csrfAuthInfo.csrfToken);
            request.setHeader('Cookie', csrfAuthInfo.sCookie);
            request.setHeader('Authorization', 'Bearer ' + '{!$Credential.OAuthToken}'); 
            request.setHeader('Content-Type', contentType); 
            if(String.isNotBlank(acceptType)) {
                request.setHeader('Accept', acceptType);
            }
            System.debug('reqBody---> for create:: '+ requestBody);
            request.setBody(requestBody);
            request.setTimeout(100000);
            response = http.send(request);
            responseWrapper = new HttpResponseWrapper(true, response);
            request = null;
            http = null;        
        } catch(Exception e) {
            system.debug(' sendDataToSAPRequest ERROR:' + e);
            String errorMessage = 'Error sending request to external SAP system ' + e.getMessage() + '\n' + e.getStackTraceString();
            responseWrapper = new HttpResponseWrapper(false, response, errorMessage); 
        }
        return responseWrapper;
    }

    public static SAP_API_Logger__c createAPILogger(String recordId, String recordName, String appName, 
        String requestBody, String statusCode, String errorMessage) {
        return createAPILogger(recordId, recordName, appName, requestBody, statusCode, null, errorMessage);
    }
    
    public static SAP_API_Logger__c createAPILogger(String recordId, String recordName, String appName, 
        String requestBody, String statusCode, String responseBody, String errorMessage) {
        SAP_API_Logger__c apiLogger = new SAP_API_Logger__c();
        apiLogger.Response__c = responseBody != null ? responseBody.left(LONG_TEXT_CHAR_LIMIT) : null;   
        apiLogger.Requester__c = UserInfo.getUserId();
        apiLogger.Response_Status__c = statusCode != null ? statusCode.left(EXT_SAP_SalesOrderHelper.CHAR_LIMIT_STATUS_CODE) : null;
        apiLogger.Parent_Record_Type__c = appName;
        apiLogger.Request__c = requestBody != null ? requestBody.left(LONG_TEXT_CHAR_LIMIT) : null;
        apiLogger.Related_Transaction_Log_Id__c = recordId;
        apiLogger.Parent_Name_Text__c = recordName;
        apiLogger.Error_Message__c = errorMessage != null ? errorMessage.left(LONG_TEXT_CHAR_LIMIT) : null;
        return apiLogger;
    }
    
    public static void saveAPILogger(List<SAP_API_Logger__c> apiLoggerUpsertList) {
        try {
            if(!apiLoggerUpsertList.isEmpty()) {
                upsert apiLoggerUpsertList;
            }
        } catch(Exception e) {
            String errorMessage = 'Exception while saving the API Logger. Error: ' + e.getMessage();
            CreateExceptionLog.insertErrorLog('EXT_BI_SalesOrderHelper', 'saveAPILogger', errorMessage, 'Fatal');
        }
    }
    
    public static Map<String, String> getAPILoggers(Set<id> recordIdSet) {
        List<SAP_API_Logger__c> loggers = [SELECT id, Related_Transaction_Log_Id__c FROM SAP_API_Logger__c 
                                           where Related_Transaction_Log_Id__c IN: recordIdSet 
                                           AND Response_Status__c  = :STATUS_CODE_REQ_INIT 
                                           ORDER BY CreatedDate Desc];
        Map<String, String> loggerIdToRecordIdMap = new Map<String, String>();
        for(SAP_API_Logger__c log : loggers) {
            if(!loggerIdToRecordIdMap.containsKey(log.Related_Transaction_Log_Id__c)) {
                loggerIdToRecordIdMap.put(log.Related_Transaction_Log_Id__c, log.id);
            }
        }
        return loggerIdToRecordIdMap;
    }

    /*
     * Inner class to hold the CSRF Response Details
     */ 
    public class CSRFAuthInfo {
        public String appName {get;set;}
        public Boolean isUserAuthorized {get; set;}
        public String status {get; set;}
        public Integer statusCode {get; set;}
        public String errorMessage {get; set;}
        public String csrfToken {get; set;}
        public String sCookie {get; set;}

        public CSRFAuthInfo(String appName) {
            this.appName = appName;
        }
    }

    public class HttpResponseWrapper {
        public boolean isSuccess {get;set;} 
        public String errorMessage {get;set;}
        public HttpResponse response {get;set;}

        public HttpResponseWrapper(boolean isSuccess, HttpResponse response) {
            this(isSuccess, response, null);
        }

        public HttpResponseWrapper(boolean isSuccess, HttpResponse response, String errorMessage) {
            this.isSuccess = isSuccess;
            this.response = response;
            this.errorMessage = errorMessage;
        }
    }
}