/*
This class responcible for handling conectivity for SAP integration
using oAuth
*/
public class BS_SAP_Connection_Manager {
    public BS_SAP_Connection_Manager() {}
    
    static string csrfToken=''; 
    static string sCookie='';
    static string authorizationHeader = '';
    static string endPoint ='';
    static string endPointAtch = '';
    static list<PR_detail__c> prDetails = new   list<PR_detail__c>();
    
    public static wrapPRResponse sendPRtoSAP(string prId) {
        
        wrapPRResponse retPRResponse = new wrapPRResponse();
        //if(getCSRFToken()){
        if(getCSRFToken_oAuth()){
            HttpResponse response = sendPRRequest(prId); // send PR
            if (response!=null){
                retPRResponse.retStatus = response.getStatus(); 
                if (response.getStatus()=='Created'){
                    transient string returnedSAPpr = pr_xml_helper.ParseTrackingResponse(response, 'PreqNo');
                    response=null;
                    retPRResponse.retPRNum = returnedSAPpr; // populate wrapper class
                    sendPRAttachments (prId, returnedSAPpr); // send attachments
                    //updateCampaignSpendDupKey(returnedSAPpr,prDetails);
                    updateCampaignSpendCommitted(prId,returnedSAPpr);
                    updatePRWithSAPNumber(prId, returnedSAPpr); // updates PR with SAP PR number
                    createAPILog(prId,returnedSAPpr,null);
                    System.debug('log print by badri');
                }
                else {
                    string returnedSAPErr = pr_xml_helper.ParseRequestError(response, 'message');
                    retPRResponse.retError = 'The PR request was not successful: '+  returnedSAPErr;
                    response=null;
                    createAPILog(prId,null,returnedSAPErr);
                    System.debug('log print by badri');
                }
            }
        } else {
            retPRResponse.retError = 'The PR request was not successful: CSRF Token Request Failed';
        }
        return retPRResponse;
    }
    
    /*static void setConnectionPropertiesBasicAuth(){
        
        String username = '';
        String password = ''; 
        StoredCredentials__c sap;
        if( Global_Utility.isProd() ){
            sap = StoredCredentials__c.getInstance('SAP_PR_Settings'); 
        }       
        else{ 
            sap = StoredCredentials__c.getInstance('SAP_PR_Settings_QA');
        }
        
        username = sap.Username__c; 
        password = sap.Password__c; 
        endPoint = sap.Full_Endpoint__c;// end point PR
        endPointAtch = sap.Full_Endpoint_2__c; // end point attachment
        authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));     
    }*/

    public static void setConnectionPropertiesoAuth(){
        try{
            StoredCredentials__c sap;
            if( Global_Utility.isProd() ){
                sap = StoredCredentials__c.getInstance('SAP_PR_Settings_oAuth'); 
            }       
            else{ 
                sap = StoredCredentials__c.getInstance('SAP_PR_Settings_oAuth_QA');
                system.debug('######### sap: ' + sap);
            }
            endPoint = sap.Full_Endpoint__c;// end point PR
            
            endPointAtch = sap.Full_Endpoint_2__c; // end point attachment
            
        }
        catch(Exception e) {
            system.debug(e); 
            String errorMessage = 'Error getting connection from custo setting ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('BS_SAP_ConnectionManager', 'setConnectionPropertiesoAuth', String.valueOf(errorMessage), 'Fatal');

        }
    }

    public static boolean getCSRFToken_oAuth(){
        boolean b = true;
        try{
                setConnectionPropertiesoAuth();
                HttpRequest req = new HttpRequest();
                Http http = new Http();      
                req.setMethod('GET');
                req.setEndpoint(endPoint);
                req.setHeader('x-csrf-token', 'fetch'); 
                // need to add a swithch for DEV/Prod here
                
                string namedCredentials = '';
                if( Global_Utility.isProd() ){
                    namedCredentials = 'SAPCustomProd'; 
                }       
                else{ 
                    namedCredentials = 'SAPCustomMobilQ';
                }

                NamedCredential nm = [SELECT Endpoint FROM NamedCredential where DeveloperName = : namedCredentials];
                string host = nm.Endpoint.replace('https://','');
                req.setHeader('Host', host);
                req.setHeader('Connection', 'keep-alive');
                req.setHeader('Accept-Encoding', 'gzip, deflate');
                req.setHeader('Accept', '*/*');  
                req.setHeader('Authorization' , 'Bearer ' + '{!$Credential.OAuthToken}'); 
                HTTPResponse res = http.send(req);
                system.debug(res);

                csrfToken=res.getHeader('x-csrf-token');
                sCookie = res.getHeader('Set-Cookie');

                if (csrfToken==null){ 
                    CalloutException e = new CalloutException();
                    e.setMessage('Failed to get CSRF token - ' + res.getstatus());
                    throw e;
                }
                req=null;
                res=null;
        }
        catch(Exception e)  {
                system.debug('getCSRFToken_oAuth ERROR:' + e);
                b= false;
                String errorMessage = 'Error establishing connection to external system ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('BS_SAP_ConnectionManager', 'getCSRFToken_oAuth', String.valueOf(errorMessage), 'Fatal');
        }  
        
        system.debug('sCookie:' + sCookie);
        system.debug('csrf token: ' + csrfToken);
        
    return b;
         
    }

    /*public static boolean getCSRFToken(){
        setConnectionPropertiesBasicAuth();
        boolean b = true;
        try{
            HttpRequest req = new HttpRequest();
            Http http = new Http();      
            req.setMethod('GET');
            req.setEndpoint(endPoint);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Authorization', 'Bearer ' + '{!$Credential.OAuthToken}');          
            req.setHeader('x-csrf-token', 'fetch');   
            HTTPResponse res = http.send(req);
            csrfToken=res.getHeader('x-csrf-token');
            sCookie = res.getHeader('set-cookie');
            if (csrfToken==null){ 
                CalloutException e = new CalloutException();
                e.setMessage('Failed to get CSRF token - ' + res.getstatus());
                throw e;
            }
            req=null;
            res=null;
        }
        catch(Exception e)  {
            system.debug(' getCSRFToken ERROR:' + e);
            b= false;
            String errorMessage = 'Error establishing connection to external system ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('BS_SAP_ConnectionManager', 'getCSRFToken', String.valueOf(errorMessage), 'Fatal');
        }  
        
        system.debug(' sCookie:' + sCookie);
        system.debug('csrf token: ' + csrfToken);
        
        return b;
    }*/
    
    static HttpResponse sendPRRequest(string prID){
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();     
        HTTPResponse res = new HTTPResponse();
        
        try{
            prDetails  = GetPrDetails(prID);
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            req.setHeader('x-csrf-token', csrfToken);
            req.setHeader('Cookie', sCookie);
            //req.setHeader('Authorization', authorizationHeader); 
            req.setHeader('Authorization', 'Bearer ' + '{!$Credential.OAuthToken}');          
            req.setHeader('Content-Type', 'application/xml');
            string reqBody=PR_XML_Helper.buildXml(prID, prDetails );
            
            req.setBody(reqBody);
            req.setTimeout(100000);
            res = http.send(req);
            system.debug ('SAP Response ' + res);
            req = null;
            http = null;
            
        }
        catch(Exception e)  {
            system.debug(' sendPRRequest ERROR:' + e);
            String errorMessage = 'Error sending PR request to external system ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('BS_SAP_ConnectionManager', 'sendPRRequest', String.valueOf(errorMessage), 'Fatal');
        }  
        return res;  
    }
    
    public static void sendPRAttachments(string prID, string PrNum){
        transient list <PR_Attachment__C> lstPrAttachments = [SELECT id, attachment_id__c 
                                                              FROM PR_Attachment__C 
                                                              WHERE pr_header__c =: prId and status__c != 'created'];
        for (PR_Attachment__C prAttchment : lstPrAttachments){ 
            sendPRAttachmentRequest (PrNum, prAttchment.attachment_id__c, prAttchment.ID);
        }
        lstPrAttachments=null;
    }
    
    @Future(callout=true) 
    public static void  sendPRAttachmentRequest(string PrNum, string attID, string prAttID ){
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{ 

            getCSRFToken_oAuth();
            transient string reqBody=PR_XML_Helper.buildAttachmentXml(attID, prNum);
            if (reqBody!=null){
                req.setMethod('POST');
                req.setEndpoint(endPointAtch);
                req.setHeader('x-csrf-token', csrfToken);
                req.setHeader('Cookie', sCookie);
                //req.setHeader('Authorization', authorizationHeader);
                req.setHeader('Authorization', 'Bearer ' + '{!$Credential.OAuthToken}');          

                endPointAtch= null;
                csrfToken= null;
                sCookie= null;
                //authorizationHeader= null;
                req.setHeader('Content-Type', 'application/xml');
                req.setBody(reqBody);
                reqBody = null; 
                req.setTimeout(100000);
                system.debug('before send = '+ limits.getHeapSize());
                system.debug('request size:' + (req.toString()).length() );
                res = http.send(req);
                req = null;
                
                transient PR_Attachment__C prAtt = new PR_Attachment__C();
                prAtt.id =  prAttID;
                prAtt.status__c =res.getStatus();
                req = null;
                res = null;
                http = null;
                update prAtt;
                prAtt = null; 
            }              
        }
        catch(Exception e)  {
            system.debug('sendPRRequest ERROR:' + e);
            String errorMessage = 'Error sending PR attachment request to external system ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('BS_SAP_ConnectionManager', 'sendPRAttachmentRequest', String.valueOf(errorMessage), 'Fatal');
        }  
    }
    
    
    static void updatePRWithSAPNumber(string prId, string PRNum) {
        PR_Header__c prHeader = [select id, SAP_PR_Number__c from PR_Header__c where id =: prId ];
        prHeader.SAP_PR_Number__c=PRNum;
        prHeader.Status__c = 'Completed';
        update(prHeader);
    }
    
    public class wrapPRResponse {
        public String retStatus {get; set;}
        public String retPRNum {get; set;}
        public String retError {get; set;}
    }
    
    public static list <PR_detail__c> getPrDetails (string prID){
        
        list<PR_detail__c> prDetails = [Select id
                                        ,name
                                        ,Account_Assignment_Category2__c
                                        ,Brand__c
                                        ,Campaign__c
                                        ,Description__c
                                        ,GL_Code2__c
                                        ,GLDescription2__c
                                        ,IOCode__c
                                        ,Material_Group__c
                                        ,Phasing_Amount__c
                                        ,Plant__c
                                        ,PR_Amount__c
                                        ,PR_Header__c
                                        ,PR_Header__r.Name
                                        ,PR_Header__r.pr_currency__c
                                        ,PR_Header__r.Payment_Terms__c
                                        ,PR_Header__r.SAP_Company_Code__c
                                        ,PR_Header__r.SAP_Support__c
                                        ,PR_Header__r.Vendor_Number__c
                                        ,PR_Header__r.Vendor_Name__r.name
                                        ,PR_Header__r.CreatedBy.Firstname
                                        ,PR_Header__r.CreatedBy.Lastname
                                        ,Campaign__r.SAP_Sales_District__c
                                        ,Campaign__r.SAP_Product_Hierarchy__c
                                        ,Campaign__r.SAP_Brand_Abbreviation__c
                                        ,Campaign__r.SAP_Territory_Abbreviation__c 
                                        ,Territory__c
                                        ,(Select id
                                          ,tolabel(month__c)
                                          ,Phasing_Amount__c
                                          ,Delivery_date__c
                                          ,Campaign_Spend__c
                                          from PR_Phasings__r where Phasing_Amount__c >0 order by Delivery_date__c ) 
                                        from PR_Detail__C where PR_Header__c =:prID order by IOCode__c asc]; 
        return prDetails;
    }
    
    static void updateCampaignSpendCommitted( id prID, string SAPpr){
        string itemSeq ;
        string itemNum;
        integer i = 10;
        list<Campaign_Spend__c> lstUpdateCmpSpend = new  list<Campaign_Spend__c>();
        list<PR_detail__c> prDetails= [select id,IOCode__c, (Select id,Campaign_Spend__c 
                                                             from PR_Phasings__r)from PR_Detail__C  where PR_Header__c =:prID];
        
        set <id> PhasingIDs = new set<id>();
        for (PR_detail__c prDetail : prDetails){     
            for (PR_Phasing__c prPhasing : prDetail.PR_Phasings__r ){
                PhasingIDs.add(prPhasing.id);
            }
        }
        
        list <campaign_spend__c> campSpends = [select id,recordtypeID from campaign_spend__c where PR_Phasing__c in: PhasingIDs];
        for (campaign_spend__c campSpend : campSpends){
            itemSeq =i.format();
            itemNum = itemSeq.leftPad(5,'00000');
            SAPpr = SAPpr.leftPad(10,'0000000000');
            campSpend.Line_Item_Number__c = itemNum;
            campSpend.recordtypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Committed').getRecordTypeId();
            campSpend.Committed_Type__c = 'PREQ';
            campSpend.Document_Number__c = SAPpr;
            lstUpdateCmpSpend.add(campSpend);
            i++;
        }                        
        update lstUpdateCmpSpend; 
    }
    static void createAPILog(String recordId, String responseBody, String errorMessage){
        
        try{
            PR_Header__c request = [Select Id,Name from PR_Header__c Where Id = :recordId];
            
            SAP_API_Logger__c apiLogger = new SAP_API_Logger__c();
            apiLogger.Response__c = responseBody != null ? responseBody : null;
            apiLogger.Requester__c = UserInfo.getUserId();
            apiLogger.Related_Transaction_Log_Id__c = recordId;
            apiLogger.Parent_Name_Text__c = request.Name;
            apiLogger.Error_Message__c = errorMessage != null ? errorMessage : null;
            
            insert apiLogger;
        }
        catch (Exception e){
            system.debug(' createAPILog ERROR:' + e);
            String errorMsg = 'Error creating log ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('BS_SAP_ConnectionManager', 'createAPILog', String.valueOf(errorMsg), 'Fatal');
        }

    }
    
    
}