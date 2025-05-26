@isTest
public class TST_BI_CampaignHelper {
    
    public static String jsonStringUS = '{\n  "d" : {\n    "Respcctr" : "US30NA01",\n    "OrderType" : "SF01",\n    "OrderName" : "AR LP FY Trade Events",\n    "Order" : "JJXXX2022027",\n    "Currency" : "USD",\n    "CompCode" : "US30",\n    "CoArea" : "2000"\n  }\n}';    
    public static String jsonStringAUS = '{"d" : {"WbsElement" : "AU19JBWJRBLSF002","Description" : "Dojo Bartender program","CompanyCode" : "AU60","ControllingArea" : "6000","Currency" : "AUD","CurrencyIso" : "AUD","WbsUp" : "AU19JBWH","SystemStatus" : "REL","ProjectDefinition" : "BIAU2019"}}';
    public static Integer currentYear = System.Today().year();
    @testSetup static void setup() {
        list<StoredCredentials__c> sc_lst = new list<StoredCredentials__c>();
        StoredCredentials__c sc_qa = new StoredCredentials__c(Name = 'SAP Credentials QA', Username__c = 'TestUser', Password__c = 'TestPassword', Full_Endpoint__c = 'https://intq.beamsuntory.com:44371');
        StoredCredentials__c sc_prod = new StoredCredentials__c(Name = 'SAP Credentials', Username__c = 'TestUser', Password__c = 'TestPassword', Full_Endpoint__c = 'https://int.beamsuntory.com:44371');
        sc_lst.add(sc_qa);
        sc_lst.add(sc_prod);
        insert sc_lst;
        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.RecordTypeId = programRecordTypeId;
        testProgram2.FocusType__c = '2018 Program';

        insert new List<Program__c>{testProgram, testProgram2};
    }
    
    static Program__c getOtherProgram()
    {
        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        System.debug([SELECT Id FROM Program__c WHERE Name = 'Other' AND RecordTypeId =: programRecordTypeId]);
        return [SELECT Id FROM Program__c WHERE Name = 'Other' AND RecordTypeId =: programRecordTypeId ];      
    }
    
    static Campaign__c createCampaignForIO()
    {
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
        planNames.add('2018 US JBW American AMR SDP Heritage Louisana $15K'); 
        planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K'); 
    
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c plan1 = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
        MarketingPlan__c plan2 = plans.get('2018 US JBW American AMR SDP Heritage Louisana $15K');
        MarketingPlan__c plan3 = plans.get('2018 US JBW American AMR SDP Legacy Missouri $20K');
    
        plan1.Next_IO_Sequence__c = null;
        plan1.SAP_Controlling_Area__c = '2000';
        plan1.SAP_Company_Code__c = 'US30';
        plan1.SAP_Cost_Center__c = 'US30NA33';      
        update plan1;
        Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(currentYear, 1, 5), date.newinstance(currentYear, 1, 27), 'USD', tagsMap.get('BQ_Jim Beam White'));
        camp1.Related_Priority__c = getOtherProgram().Id;
        insert camp1;
        return camp1;
    }
    
    static Campaign__c createCampaignForWBS()
    {
        TestDataFactory.createWBSAUSMarketingPlanHierarchy();
        Map<String, Id> tagsMap = TestDataFactory.GetTagsMap();
        List<String> planNames = new List<String>();
        planNames.add('2017 AUS CCL Australian CCL BTL NSW $5K'); 
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c plan1 = plans.get('2017 AUS CCL Australian CCL BTL NSW $5K');

        //Plan1 will not have a Next Sequence Number set yet.
        plan1.Next_IO_Sequence__c = null;
        plan1.SAP_Controlling_Area__c = '2000';
        plan1.SAP_Company_Code__c = 'US30';
        plan1.SAP_Cost_Center__c = 'US30NA33';
        update plan1;
        System.debug(LoggingLevel.INFO, plan1);

        //Create the campaigns
        Campaign__c camp1 = TestDataFactory.MapCampaign(plan1.Id, 3000.00, date.newinstance(2017, 1, 5), date.newinstance(2017, 1, 27), 'AUD', tagsMap.get('BQ_Canadian Club'));
        System.debug(LoggingLevel.INFO, camp1);
        camp1.Related_Priority__c = getOtherProgram().Id;
        insert camp1;
        return camp1;
    }
    
        
    static testMethod void prepareIOCampaignRequestJSONTest(){
        
       Campaign__c camp1 = createCampaignForIO();
       Test.startTest();
       String req = EXT_BI_CampaignHelper.prepareIOCampaignRequestJSON(camp1);
       Test.stopTest();
       System.assert(req!=null); 
    }
    
    static testMethod void prepareWBSCampaignRequestJSONTest(){
        
       Campaign__c camp1 = createCampaignForWBS();
       Test.startTest();
       String req = EXT_BI_CampaignHelper.prepareWBSCampaignRequestJSON(camp1);
       Test.stopTest();
       System.assert(req!=null); 
    }


    static testMethod void handleCampaignBatchTest(){
       List<Campaign__c> c = new List<Campaign__c>();        
       Campaign__c camp1 = createCampaignForIO();
       c.add(camp1);
        
       List<Campaign__c> cmp = new List<Campaign__c>();        
       Campaign__c camp2 = createCampaignForWBS();
       cmp.add(camp2); 
       UTL_API_Utility.CSRFAuthInfo csrfresponseUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_USBI);
       csrfresponseUS.csrfToken = 'token';
       csrfresponseUS.errorMessage = 'Error message';
       csrfresponseUS.isUserAuthorized = true;
       csrfresponseUS.sCookie = 'cookies';
       csrfresponseUS.status = 'OK';
       csrfresponseUS.statusCode = 200;
        
       UTL_API_Utility.CSRFAuthInfo csrfresponseAUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_USBI);
       csrfresponseAUS.csrfToken = 'token';
       csrfresponseAUS.errorMessage = 'Error message';
       csrfresponseAUS.isUserAuthorized = true;
       csrfresponseAUS.sCookie = 'cookies';
       csrfresponseAUS.status = 'OK';
       csrfresponseAUS.statusCode = 200; 
       Test.startTest();
       EXT_BI_CampaignHelper.handleCampaignBatch(c,csrfresponseUS,UTL_API_Utility.APPNAME_USBI);
       EXT_BI_CampaignHelper.handleCampaignBatch(cmp,csrfresponseAUS,UTL_API_Utility.APPNAME_AUSBI); 
       Test.stopTest();
       System.assert(c.size()!=0);
       System.assert(cmp.size()!=0); 
    }


    static testMethod void handleCampaignRecordTest(){      
       List<Campaign__c> c = new List<Campaign__c>();        
       Campaign__c camp1 = createCampaignForIO();
       c.add(camp1);
        
       List<Campaign__c> cmp = new List<Campaign__c>();        
       Campaign__c camp2 = createCampaignForWBS();
       cmp.add(camp2); 
       UTL_API_Utility.CSRFAuthInfo csrfresponseUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_USBI);
       csrfresponseUS.csrfToken = 'token';
       csrfresponseUS.errorMessage = 'Error message';
       csrfresponseUS.isUserAuthorized = true;
       csrfresponseUS.sCookie = 'cookies';
       csrfresponseUS.status = 'OK';
       csrfresponseUS.statusCode = 200;
        
       UTL_API_Utility.CSRFAuthInfo csrfresponseAUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_AUSBI);
       csrfresponseAUS.csrfToken = 'token';
       csrfresponseAUS.errorMessage = 'Error message';
       csrfresponseAUS.isUserAuthorized = true;
       csrfresponseAUS.sCookie = 'cookies';
       csrfresponseAUS.status = 'OK';
       csrfresponseAUS.statusCode = 200; 

       Test.startTest();
       BI_CampaignControllerExtension.generateCodeFromPageLayout(c.get(0).id,UTL_API_Utility.APPNAME_USBI);
       BI_CampaignControllerExtension.generateCodeFromPageLayout(cmp.get(0).id,UTL_API_Utility.APPNAME_AUSBI); 
       EXT_BI_CampaignHelper.handleCampaignRecord(c,csrfresponseUS,UTL_API_Utility.APPNAME_USBI);
       EXT_BI_CampaignHelper.handleCampaignRecord(cmp,csrfresponseAUS,UTL_API_Utility.APPNAME_AUSBI); 
       Test.stopTest();
       Campaign__c cmpUS= [Select id,IOCode__c,RequestStatus__c from Campaign__c where id =:c.get(0).id];
       Campaign__c cmpAUS= [Select id,WBSCode__c,RequestStatus__c from Campaign__c where id =:cmp.get(0).id]; 
       System.assert(cmpUS.IOCode__c!=null);
       System.assert(cmpAUS.WBSCode__c!=null); 
    }
    
    static testMethod void updateCampaignsRecordsTest(){             
       Campaign__c camp1 = createCampaignForIO();
       Campaign__c camp2 = createCampaignForWBS(); 
       UTL_API_Utility.CSRFAuthInfo csrfresponseUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_USBI);
       csrfresponseUS.csrfToken = 'token';
       csrfresponseUS.errorMessage = 'Error message';
       csrfresponseUS.isUserAuthorized = true;
       csrfresponseUS.sCookie = 'cookies';
       csrfresponseUS.status = 'OK';
       csrfresponseUS.statusCode = 200;
       UTL_API_Utility.HttpResponseWrapper responseWrapper = UTL_API_Utility.sendDataToSAPRequest(EXT_BI_CampaignHelper.prepareIOCampaignRequestJSON(camp1),UTL_API_Utility.CONTENT_TYPE_JSON, UTL_API_Utility.CONTENT_TYPE_JSON,csrfresponseUS); 
       HttpResponse resUS = responseWrapper.response;
       UTL_API_Utility.CSRFAuthInfo csrfresponseAUS = UTL_API_Utility.getCSRFToken_oAuth(UTL_API_Utility.APPNAME_AUSBI);
       csrfresponseAUS.csrfToken = 'token';
       csrfresponseAUS.errorMessage = 'Error message';
       csrfresponseAUS.isUserAuthorized = true;
       csrfresponseAUS.sCookie = 'cookies';
       csrfresponseAUS.status = 'OK';
       csrfresponseAUS.statusCode = 200;
       String requestBody = EXT_BI_CampaignHelper.prepareWBSCampaignRequestJSON(camp2); 
       UTL_API_Utility.HttpResponseWrapper responseWrapper2 = UTL_API_Utility.sendDataToSAPRequest(requestBody,UTL_API_Utility.CONTENT_TYPE_JSON, UTL_API_Utility.CONTENT_TYPE_JSON,csrfresponseAUS);      
       HttpResponse resAUS = responseWrapper2.response;
       Test.startTest();
       Campaign__c campUS = EXT_BI_CampaignHelper.updateCampaignsRecords(camp1.id,resUS,UTL_API_Utility.APPNAME_USBI);
       Campaign__c campAUS = EXT_BI_CampaignHelper.updateCampaignsRecords(camp2.id,resAUS,UTL_API_Utility.APPNAME_AUSBI); 
       Test.stopTest();
       System.assert(campUS==null);
       System.assert(campAUS==null); 
    }
    
    static testMethod void getCampaignFieldsHelperTest(){ 
       Test.startTest();
       List<Id> idListUS = new List<Id>();
       List<Id> idListAUS = new List<Id>();        
       Campaign__c camp1 = createCampaignForIO();
       Campaign__c camp2 = createCampaignForWBS(); 
       idListUS.add(camp1.Id);
       idListAUS.add(camp2.Id);
       String resultUS = EXT_BI_CampaignHelper.prepareCampaignQuery(UTL_API_Utility.APPNAME_USBI,idListUS);
       String resultAUS = EXT_BI_CampaignHelper.prepareCampaignQuery(UTL_API_Utility.APPNAME_AUSBI,idListAUS); 
       Test.stopTest();
       System.assert(resultUS!=null);
       System.assert(resultAUS!=null); 
    }
    
    static testMethod void getUserAuthenticationInfoTest(){            
       Test.startTest();
       UTL_API_Utility.CSRFAuthInfo csrfResultUS = EXT_BI_CampaignHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_USBI);
       UTL_API_Utility.CSRFAuthInfo csrfResultAUS = EXT_BI_CampaignHelper.getUserAuthenticationInfo(UTL_API_Utility.APPNAME_AUSBI); 
       Test.stopTest();
       System.assert(csrfResultUS!=null);
       System.assert(csrfResultAUS!=null); 
    }

    static testMethod void parseTest(){
       Test.startTest();
       BI_US_CampaignRequestModel modelUS = BI_US_CampaignRequestModel.parse(jsonStringUS);
       BI_AUS_CampaignRequestModel modelAUS = BI_AUS_CampaignRequestModel.parse(jsonStringAUS); 
       Test.stopTest();
       System.assert(modelUS!=null);
       System.assert(modelAUS!=null); 
    }    

}