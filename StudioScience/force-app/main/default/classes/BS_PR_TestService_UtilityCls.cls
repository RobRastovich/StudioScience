@isTest
public class BS_PR_TestService_UtilityCls {

    private BS_PR_TestService_UtilityCls() {}

    public static BS_PR_TestService_UtilityCls getInstance() {
        return new BS_PR_TestService_UtilityCls();
    }
    
    public static user adminUserSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u1 = new User(Alias = 'standt11', Email='adminuser1@testorg.com', 
                EmailEncodingKey='UTF-8',FirstName='PRAutomation', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='BSPRAutomationTestAdmin1@beamsuntory.com');              
        insert new List<User> {u1};
        List<User> UserList=[select id,IsActive FROM User Where ID=:u1.id];        
        System.assertEquals(true, UserList[0].IsActive);
        return u1;
    }
    
    public static List<Campaign__c> setupCampaignData() {        
        //Create test data
        TestDataFactory.createMarketingPlanHierarchy();
        Map<String, ID> tagsMap = TestDataFactory.GetTagsMap();
        list<Tags__c> TagsList=[SELECT ID FROM Tags__c];
        for(Tags__c TagsRec:TagsList){
            TagsRec.SAP_Sales_District__c='097';
            TagsRec.Territory_Abbreviation__c='AZ';
            TagsRec.SAP_Product_Hierarchy__c='AZ';
            //TagsRec.RecordTypeId = '012o0000000oaxn';//Added by Mahesh            
        }
        Update TagsList;
        //Below lines Added by Sripal 04/18/2020
        Tags__c territory = new Tags__c();
        territory.Name = 'Alabama';
        territory.IOCodeSegment__c = '51';
        territory.SAP_Sales_District__c ='051';
        territory.Active__c= true;
        territory.Territory_Abbreviation__c = 'AL';
        insert territory;
        list<Program__c> Program_List=testPopulateProgramAndPlatformsPositiveRelatedPlatform();
        
        List<String> planNames = new List<String>();
        planNames.add('2018 US JBW American AMR SDP Legacy Missouri $20K');
        
        Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
        MarketingPlan__c mplan = plans.get('2018 US JBW American AMR SDP Legacy Missouri $20K');        
        mplan.Year__c=string.valueof(System.Today().year());
        mplan.SAP_Company_Code__c='USC0';
        mplan.SAP_Controlling_Area__c='2000';
        mplan.SAP_Cost_Center__c='Test';
        //mplan.Territory__c = 'a07o0000004zXbi';//Added by Mahesh  
        mplan.Territory__c = territory.id; //Added by Sripal 04/18/2020     
        update mplan;
        
        //Below lines added by Sripal 04/18/2020
        Program__c otherprogram = new Program__c();
        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        otherprogram.name= 'Other';
        otherprogram.recordTypeId= programRecordTypeId;
        insert otherprogram;
        
        List<Campaign__c> insertCampaign = new List<Campaign__c>();          
        Campaign__c camp1 = TestDataFactory.MapCampaign(mplan.Id, 3000.00, date.newinstance(System.Today().year(), 1, 5), date.newinstance(System.Today().year(), 1, 27), 'AUD', tagsMap.get('BQ_Jim Beam White'));        
        camp1.IOCode__c='ITJBV1901114';
        camp1.Related_Priority__c = Program_List[0].Id;
        camp1.ParticipatingStates__c = 'test1';//Added by Mahesh 
        camp1.ParentMarketingPlan__c= mplan.id;   // Added by sripal 04/18/2020
        insertCampaign.add(camp1);
        
        Campaign__c camp2 = TestDataFactory.MapCampaign(mplan.Id, 3000.00, date.newinstance(System.Today().year(), 1, 5), date.newinstance(System.Today().year(), 1, 27), 'AUD', tagsMap.get('BQ_Jim Beam White'));        
        camp2.IOCode__c='ITJBV1901115';
        camp2.Related_Priority__c = Program_List[0].Id;
        camp2.ParticipatingStates__c = 'test2';//Added by Mahesh  
        camp2.ParentMarketingPlan__c= mplan.id;  // Added by sripal 04/18/2020 
        insertCampaign.add(camp2);
        insert insertCampaign;
        
        
        return insertCampaign;
    }
       
    public static list<Program__c> testPopulateProgramAndPlatformsPositiveRelatedPlatform(){
        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        
        Program__c testProgram = new Program__c(Name = 'Other',RecordTypeId = platformRecordTypeId);        
        Program__c testProgram2 = new Program__c(Name = 'Bourbon Legends',RecordTypeId = platformRecordTypeId);        
        Program__c testProgram3 = new Program__c(Name = 'Other',RecordTypeId = programRecordTypeId);        
        list<Program__c> Program_List=new list<Program__c>{testProgram,testProgram2,testProgram3};
        return Program_List;
    }
     
    public static List<Account> setupAccountData() {
        Map<String, Schema.RecordTypeInfo> accrecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();                  
        Account distAccount = new Account();
        distAccount.Name = 'Test Distributor Account 01';        
        distAccount.RecordTypeId = accrecordTypes.get('Distributor').getRecordTypeId();
        
        Account distAccount2 = new Account();
        distAccount2.Name = 'Test Distributor Account 02';
        distAccount2.RecordTypeId = accrecordTypes.get('Distributor').getRecordTypeId();
                
        //insert Vendor Account for PR Header
        Account objVendorAccount = new Account();
        objVendorAccount.Name = 'Test Vendor Account';
        objVendorAccount.SAP_Vendor_ID__c='48057Test';
        objVendorAccount.RecordTypeId = accrecordTypes.get('Vendor').getRecordTypeId();
        
        List<Account> insertAccount = new List<Account>{distAccount,distAccount2,objVendorAccount};
        insert insertAccount;
        List<Account> AccountList=[select id FROM Account];
        System.assert(AccountList.size()>=3);
        return insertAccount;
    }
    public static List<SAP_Company_Code__c> setupSAPCompanyCodeData(id vendorAccountId) {
        //insert SAP Company Code for PR Header creation
        SAP_Company_Code__c sapCode1 = new SAP_Company_Code__c(
            Name = 'USC0',
            Status__c = 'Active',
            SAP_Vendor__c='1234U301234',
            VendorCompanycodeKey__c='1234U301234',
            Account__c = vendorAccountId);        
        SAP_Company_Code__c sapCode2 = new SAP_Company_Code__c(
            Name = 'USC0',
            Status__c = 'Active',
            SAP_Vendor__c='1234U3012345',
            VendorCompanycodeKey__c='1234U3012345',
            Account__c = vendorAccountId);        
        List<SAP_Company_Code__c> SAP_Company_CodeInsertList=new List<SAP_Company_Code__c>{sapCode1,sapCode2};
        insert SAP_Company_CodeInsertList;
        List<SAP_Company_Code__c> SAP_Company_CodeList=[select id FROM SAP_Company_Code__c where Account__c=:vendorAccountId];
        System.assertEquals(2, SAP_Company_CodeList.size());
        return SAP_Company_CodeInsertList;
    }
    public static PR_Header__c setupPRHeaderData(id vendorAccountId,id SAPCompanyCodeId) {
        //insert PR Header Record
        PR_Header__c prHeader = new PR_Header__c(
            Vendor_Name__c = vendorAccountId,
            SAP_Company_Code__c = SAPCompanyCodeId,
            Payment_Terms__c = 'Standard Terms',
            PR_Currency__c = 'USD',
            Request_Date__c = Date.today(),
            SAP_Support__c = 'XHPOTRU');
        insert prHeader;
        List<PR_Header__c> PR_HeaderRecordsList=[select id FROM PR_Header__c where id=:prHeader.id];
        System.assertEquals(1, PR_HeaderRecordsList.size());
        return prHeader;
    }
    
    public static list<PR_Detail__c> setupPRDetailsData(id PRHeaderId,list<Campaign__c> CampaignList) {
        list<PR_Detail__c> PR_Detail_InsertList=new list<PR_Detail__c>();
        for(Campaign__c cm:CampaignList){
            PR_Detail__c prd=new PR_Detail__c(
                    PR_Header__c=PRHeaderId,
                    Campaign__c=cm.Id,
                    Campaign_ID__c=cm.Id,
                    Campaign_Name__c=cm.Name,
                    Brand__c=cm.Brand__c,                    
                    IOCode__c=cm.IOCode__c,
                    Territory__c=cm.Territory__c,
                    GLAccountType__c=cm.GLAccountType__c,
                    GL_Code2__c=cm.GLCode__c,
                    GLDescription2__c=cm.GLDescription__c,
                    GL_Details__c='Music',
                    Description__c='Test Description',
                    Account_Assignment_Category2__c='S',
                    Material_Group__c='32010000',
                    Plant__c='US50',
                    Unique_Key__c=PRHeaderId+''+cm.Id+''+cm.IOCode__c+''+cm.GLCode__c);           
            PR_Detail_InsertList.add(prd);
        }
        if(PR_Detail_InsertList.size()>0){
            Schema.SObjectField f = PR_Detail__c.Fields.Unique_Key__c;
            Database.upsert(PR_Detail_InsertList,f,false);            
        }
        List<PR_Detail__c> PR_DetailList=[select id, name from PR_Detail__c where id IN:PR_Detail_InsertList];
        System.assert(PR_DetailList.size()>0); 
        return PR_Detail_InsertList;
    }        

    public static list<PR_Detail__c> update_PRDetails_Create_Update_Phasing(list<PR_Detail__c>  PR_DetailList,string PHASING_TYPE){     
        for(PR_Detail__c eachprd: PR_DetailList){
                eachprd.StartMonth__c=string.valueOf(system.today().month());               
                eachprd.EndMonth__c=(system.today().month()<11)? (string.valueOf(system.today().month()+2)) : '12';
                eachprd.PR_Amount__c=100;
                eachprd.Phasing_Type__c=PHASING_TYPE;               
        }
        update PR_DetailList;
        return PR_DetailList;
    }
    
    public static Attachment setupPRAttachments(id PRHeaderId){     
        Attachment attach=new Attachment();     
        attach.Name='PRHeader Unit Test Attachment';        
        attach.body=Blob.valueOf('Unit Test Attachment Body');
        attach.parentId=PRHeaderId;
        insert attach;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:PRHeaderId];
        System.assertEquals(1, attachments.size());
        return attach;
    }
    
    public static PR_Attachment__C Create_PR_Attachment(id PRHeaderId, Attachment att){     
        PR_Attachment__C pa=new PR_Attachment__C(
            Name=att.Name,
            Attachment_Id__c=att.id,
            PR_Header__c=PRHeaderId
        );
        insert pa;
        List<PR_Attachment__C> PR_Attachments_QueryList=[select id, name from PR_Attachment__C where PR_Header__c=:PRHeaderId];
        System.assertEquals(1, PR_Attachments_QueryList.size());
        return pa;
    }
    public static list<PR_Phasing__c> createPhasingRecords(list<PR_Detail__c> PR_Details){
        list<PR_Phasing__c> PR_Phasing_CreateList=new list<PR_Phasing__c>();
        for(PR_Detail__c prd: PR_Details){            
            if(prd.StartMonth__c!=null && prd.EndMonth__c!=null && prd.PR_Amount__c!=null){
                integer Start_Month_Value=integer.valueof(prd.StartMonth__c);
                integer End_Month_Value=integer.valueof(prd.EndMonth__c);                
                integer loopvar=End_Month_Value-Start_Month_Value+1;
                decimal avg_PR_Amount=(prd.PR_Amount__c/loopvar).setScale(2);                
                decimal sumAmount=0;                
                for(integer i=Start_Month_Value;i<=End_Month_Value;i++){                    
                    integer monthNum=(i>12)? i-12 : i;
                    integer actual_monthNum=i;                    
                    PR_Phasing__c ph=new PR_Phasing__c(
                        PR_Detail__c=prd.id
                        ,Month__c=string.valueOf(monthNum)
                        ,Phasing_Amount__c=avg_PR_Amount
                        ,Delivery_Date__c=PRDetail_TriggerHandler.calculatelastDayOfMonth(actual_monthNum)
                        ,Unique_ID__c=prd.id+string.valueOf(monthNum)
                        ,PR_Header__c=prd.PR_Header__c
                    );                    
                    if(loopvar==1) ph.Phasing_Amount__c=prd.PR_Amount__c-sumAmount;
                    loopvar--;
                    sumAmount+=avg_PR_Amount;                    
                    PR_Phasing_CreateList.add(ph);
                }
            }
        }        
        if(PR_Phasing_CreateList.size()>0) insert PR_Phasing_CreateList;
        list<PR_Phasing__c> PR_Phasing_QueryResults=[SELECT id FROM PR_Phasing__c];
        System.assert(PR_Phasing_QueryResults.size()>0); 
        return PR_Phasing_CreateList;
    }
    
    public static list<Campaign_Spend__c> createCampaignSpends(id PR_Headerid,set<id> phasingIds) {
        map<id,PR_Phasing__c> PR_Phasing_Map=new map<id,PR_Phasing__c>([SELECT id,Campaign_Spend__c,Month__c,Phasing_Amount__c,Phasing_Amount_USD__c,PR_Detail__c,Delivery_Date__c,
                              PR_Detail__r.Name,PR_Detail__r.Campaign__c,PR_Detail__r.Campaign_Balance__c,PR_Detail__r.GLAccountType__c,IO_Code__c,Campaign__c,
                              PR_Detail__r.GL_Code2__c,PR_Detail__r.GL_Code_Description__c,PR_Detail__r.GL_Code_Options__c,PR_Header__c,PR_Header__r.name,
                              PR_Detail__r.GL_Comments__c,PR_Detail__r.GLDescription2__c,PR_Detail__r.GL_Details__c,PR_Detail__r.IOCode__c
                              FROM PR_Phasing__c WHERE PR_Header__c =: PR_Headerid OR ID IN:phasingIds]);
        map<string,string> monthmap=new map<string,string>{'1'=>'Jan','2'=>'Feb','3'=>'Mar','4'=>'Apr',
        '5'=>'May','6'=>'Jun','7'=>'Jul','8'=>'Aug','9'=>'Sep','10'=>'Oct','11'=>'Nov','12'=>'Dec'};        
        Id CSRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Pending').getRecordTypeId();                        
        list<Campaign_Spend__c> Campaign_Spend_CreateList=new list<Campaign_Spend__c>();        
        for(PR_Phasing__c ph:PR_Phasing_Map.values()){
            Campaign_Spend__c cs=new Campaign_Spend__c(
                Amount_USD__c=ph.Phasing_Amount_USD__c,
                Amount__c=ph.Phasing_Amount_USD__c,
                IOCode__c=ph.IO_Code__c,
                ParentCampaign__c=ph.Campaign__c,
                Forecast_Month__c=monthmap.get(ph.Month__c),                
                RecordTypeID=CSRecordTypeId,
                CurrencyIsoCode='USD',                
                Status__c='New',
                Document_Number__c=ph.PR_Header__r.name,
                //Posting_Date__c=lastDayOfMonth,
                Posting_Date__c=system.today(),
                Debit_Date__c=ph.Delivery_Date__c,
                Document_Date__c=ph.Delivery_Date__c,
                PR_Unique_key__c=ph.id,
                PR_Header__c=ph.PR_Header__c,
                PR_Phasing__c=ph.id);
            Campaign_Spend_CreateList.add(cs);
        }
        if(Campaign_Spend_CreateList.size()>0){
            Schema.SObjectField f = Campaign_Spend__c.Fields.PR_Unique_key__c;
            Database.upsertResult [] upsertResultList = Database.upsert(Campaign_Spend_CreateList,f,false);
        }
        list<Campaign_Spend__c> Campaign_Spend_QueryResults=[SELECT id FROM Campaign_Spend__c];
        //System.assert(Campaign_Spend_QueryResults.size()>0); 
        for(Campaign_Spend__c cs:Campaign_Spend_CreateList){
            PR_Phasing_Map.get(cs.PR_Phasing__c).Campaign_Spend__c=cs.id;
            PR_Phasing_Map.get(cs.PR_Phasing__c).Campaign_Spend_Created__c=true;
            PR_Phasing_Map.get(cs.PR_Phasing__c).Campaign_Spend_Creation_Error__c=null;
        }
        update PR_Phasing_Map.values();
        return Campaign_Spend_CreateList;
    }
    
    public static void createPRStoredCredentials(){     
        //list<StoredCredentials__c> StoredCredentialsList=;
        StoredCredentials__c sc1=new StoredCredentials__c(
            Name='SAP_PR_Settings_oAuth',
            Username__c='SYS_BISF',
            Password__c='Beam@1234',
            Full_Endpoint__c='https://mobiled.beamsuntory.com:44381/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderSet',
            Full_Endpoint_2__c='https://mobiled.beamsuntory.com:44381/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRAttachSet'
        );
        StoredCredentials__c sc2=new StoredCredentials__c(
            Name='SAP_PR_Settings_oAuth_QA',
            Username__c='SYS_BISF',
            Password__c='Beam@1234',
            Full_Endpoint__c='https://mobiled.beamsuntory.com:44381/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderSet',
            Full_Endpoint_2__c='https://mobiled.beamsuntory.com:44381/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRAttachSet'
        );
        insert (new list<StoredCredentials__c>{sc1,sc2});
    }
}