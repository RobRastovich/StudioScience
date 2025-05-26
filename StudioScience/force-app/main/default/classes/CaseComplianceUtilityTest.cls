@isTest (SeeAllData=false)
public class CaseComplianceUtilityTest {
    
    @testSetup static void setup() {
        insertStateMetadataCustomSetting();
    }

    public static void insertStateMetadataCustomSetting(){
        Schema.DescribeFieldResult fieldResult = Case.Available_States__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        List<String> picklistValues = new List<String>();
        for(Schema.PicklistEntry entry: ple){
            picklistValues.add(entry.getLabel());
        }

        List<Compliance_State_Metadata__c> stateMetadataList = new List<Compliance_State_Metadata__c>();
        for(String state: picklistValues){
            Compliance_State_Metadata__c stateMetadata = new Compliance_State_Metadata__c();
            stateMetadata.Name = state;
            stateMetadata.State_Manager_Name__c = 'Test StateManager';
            stateMetadata.State_Manager_Email__c = 'test-state-manager=example@beamsuntory.com';
            stateMetadata.State_Type__c = 'Auto Approval;';
            stateMetadata.Abbreviation__c = 'NA';
            stateMetadataList.add(stateMetadata);
        }
        Database.insert(stateMetadataList,false);
    
    }

    public static User createComplianceTestUser(String profileName, String userName){
        Profile currProfile = [SELECT Id, Name FROM Profile WHERE Name=:profileName LIMIT 1];
        User complianceUser = new User(firstname = 'BI', lastname = 'User', profileid = currProfile.Id, Customer_priority__c = 'VIP', Username = userName,
           Email = 'Compliance-test-user@test.com', Alias = 'CompUser' , Access_Group__c ='EXTERNAL', TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', 
           EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US', CurrencyIsoCode='USD');
        return complianceUser;
    }
    
    public static Case createStateLicenseCase(){
        String stateLicenseRTName = ComplianceConstants.RECORDTYPE_STATE_LICENSE;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(stateLicenseRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = recordTypeId;
        testCase.State__c = 'Arizona';
        testCase.Due_Date__c = System.Today()+7;
        testCase.Expiration_Date__c = System.Today()+30;
        testCase.Pending_3rd_party__c = false;
        testCase.Submitted_Date__c = System.Today()+10;
        return testCase;
    }
    
    public static Case createBrandRegistrationCase(){
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = recordTypeId;
        testCase.Status = 'Waiting for Kickoff';
        testCase.Priority = 'Medium';
        testCase.Origin = 'Console';
        testCase.Due_Date__c = System.today() + 30;
        testCase.In_field_Date__c = System.today() + 90;
        testCase.Brand__c = 'Cruzan';
        testCase.Project_Description__c = 'Flavor - Size';
        testCase.Project_Number__c = '1234';
        testCase.Type = 'Innovation-New Brand';
        testCase.Available_States__c = 'Connecticut;Massachusetts;Minnesota;';
        testCase.Number_of_COLAs__c = 5;
        return testCase;
    }

    public static Case createBrandRegistrationComplianceSubCase(Id parentCaseId, String state){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        String typeBrandRegistration = ComplianceConstants.SUB_CASE_TYPE_BRAND_REGISTRATION;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = recordTypeId;
        testCase.Status = 'Not Submitted';
        testCase.Priority = 'High';
        testCase.Origin = 'Console';
        testCase.Due_Date__c = System.today() + 30;
        testCase.Type = typeBrandRegistration;
        testCase.State__c = state;
        testCase.ParentId = parentCaseId;
        return testCase;
    }

    public static Case createQuoteRequestCase(String submitterType){
        String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
        Case quoteRequestCase = new Case();
        quoteRequestCase.RecordTypeId = quoteRequestRecordTypeId;
        quoteRequestCase.Type = submitterType;
        quoteRequestCase.Status = 'New';
        quoteRequestCase.Origin = 'Portal';
        quoteRequestCase.Priority = 'High';
        quoteRequestCase.State__c = 'Arizona';
        quoteRequestCase.State_Manager_Email__c = Compliance_State_Metadata__c.getAll().get('Arizona').State_Manager_Email__c;
        return quoteRequestCase;
    }

    public static Case createPricePostingCase(){
        String pricePostingRTName = ComplianceConstants.RECORDTYPE_PRICE_POSTING;
        Id pricePostingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(pricePostingRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = pricePostingRecordTypeId;
        testCase.State__c = 'Connecticut';
        testCase.Due_Date__c = System.today()+30;
        testCase.Posting_Date__c = System.today()+90;
        testCase.Type = 'Monthly Price Posting';
        testCase.Status = 'Working';
        testCase.Origin = 'Console';
        return testCase;
    }

    public static Case createPriceFilingCase(){
        String priceFilingRTName = ComplianceConstants.RECORDTYPE_PRICE_FILING;
        Id priceFilingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(priceFilingRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = priceFilingRecordTypeId;
        testCase.Related_Month__c = 'January';
        testCase.Year__c = '2018';
        testCase.State__c = 'Alabama';
        testCase.Due_Date__c = System.today()+45;
        testCase.State_Manager_Due_Date__c = System.today()+30;
        testCase.Type = 'Quarterly Price Filing';
        testCase.Status = 'New';
        testCase.Origin = 'Console';
        testCase.State_Manager_Email__c = Compliance_State_Metadata__c.getAll().get('Alabama').State_Manager_Email__c;
        return testCase;
    }

    public static Case createDiscountCase(){
        String discountRTName = ComplianceConstants.RECORDTYPE_DISCOUNT;
        Id discountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(discountRTName).getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = discountRecordTypeId;
        testCase.Origin = 'Console';
        testCase.Priority = 'High';
        testCase.Status = 'New';
        testCase.Related_Month__c = 'January';
        testCase.Year__c = '2018';
        testCase.State__c = 'Alabama';
        testCase.Due_Date__c = System.today()+30;
        testCase.State_Manager_Due_Date__c = System.today()+15;
        testCase.State_Manager_Email__c = Compliance_State_Metadata__c.getAll().get('Alabama').State_Manager_Email__c;
        return testCase;
    }

    public static Quote_Request__c createQuoteRequest(Id parentCaseId){
        Quote_Request__c qr = new Quote_Request__c();
        qr.Case__c = parentCaseId;
        qr.Item_Name__c = 'Test Item';
        qr.Item_Price__c = 99.99;
        qr.Item_Size__c = '1.75L';
        qr.Quote_Type__c = 'State Stock';
        qr.Priority__c = 'High';
        qr.State__c = 'Alabama';
        return qr;
    }

    public static ContentVersion createContentVersion(String documentType){
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion testContentVersion = new ContentVersion(
            Title='Attachment Name: ' + String.valueOf(System.now()), 
            PathOnClient ='/Header_Picture1'+String.valueOf(System.now())+'.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            Document_Type__c = documentType
        );
        insert testContentVersion;
        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion.Id FOR UPDATE];
        return testContentVersion;
    }

    public static ContentDocumentLink createContentDocumentLink(Id entityId, Id contentDocumentId){
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = entityId;
        contentlink.ContentDocumentId = contentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;
        return contentlink;
    }

    public static Entitlement createQuoteRequestEntitlement(String entitlementName){
        String slaProcessName = ComplianceConstants.ENTITLEMENT_QUOTE_REQUEST;
        Account testAccount = new Account(name='Beam Suntory SLA');
        insert testAccount;
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=TRUE LIMIT 1];
        // We have to rely on the set up and query for the SLA process since DML operation INSERT not allowed on SlaProcess.
        SLAProcess sla = [SELECT Id FROM SlaProcess WHERE Name=:slaProcessName and isActive = true LIMIT 1];

        Entitlement ent = new Entitlement(Name=entitlementName,
                                            AccountId = testAccount.Id, 
                                            SlaProcessId = sla.Id,
                                            StartDate = system.Today(),
                                            Type = 'Phone Support',
                                            BusinessHoursId = bh.Id);
        return ent;
    }

    /* Brand Registration Tests */

    public static testMethod void testDoBrandRegistrationBlankProjectNumber(){
        Test.startTest();

        Case brandRegCase = createBrandRegistrationCase();
        brandRegCase.Project_Number__c = null;
        insert brandRegCase;

        brandRegCase = [SELECT Id, Project_Number__c FROM Case WHERE Id =: brandRegCase.Id];
        System.assertEquals('N/A', brandRegCase.Project_Number__c, 'A null Project Number should be corrected to "N/A"');

        Test.stopTest();
    }

    public static testMethod void testDoComplianceKickoff(){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id subCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();

        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;

        caseServices.runTrigger = false;

        brandRegCase = [SELECT Id, Status, Kick_Off_Brand_Registration__c FROM Case WHERE Id =: brandRegCase.Id];
        Integer subCaseCount1 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        System.assertEquals('Waiting for Kickoff', brandRegCase.Status, 'Case should still be marked "Waiting for Kickoff"');
        System.assertEquals(false, brandRegCase.Kick_Off_Brand_Registration__c, 'Case should not have been marked "Kicked Off" yet');
        System.assertEquals(0, subCaseCount1, 'Subcases should not have been created yet.');

        Test.startTest();

        brandRegCase.Kick_Off_Brand_Registration__c = true;
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        update brandRegCase;
        brandRegCase = [SELECT Id, Status, Kick_Off_Brand_Registration__c FROM Case WHERE Id =: brandRegCase.Id];
        Integer subCaseCount2 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        System.assertEquals(true, brandRegCase.Kick_Off_Brand_Registration__c, 'Case should have been marked "Kicked Off"');
        //System.assertEquals(3, subCaseCount2, '3 subcases should have been created.');

        Test.stopTest();
    }

    //TBD Compliance Kickoff with Kickoff Document

    public static testMethod void testSendEmailOnBrandRegistrationKickoff(){
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;
        caseServices.runTrigger = false;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent yet.');
        CaseComplianceUtility.sendEmailOnBrandRegistrationKickoff(caseMap);
        System.assertEquals(1, Limits.getEmailInvocations(), 'Kickoff Email should have been sent.');

        Test.stopTest();
    }

    public static testMethod void testCreateBrandRegistrationSubCases(){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id subCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;
        //caseServices.runTrigger = false;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};

        Test.startTest();

        Integer subCaseCount1 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        System.assertEquals(0, subCaseCount1, 'Subcases should not have been created yet.');
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());
        Integer subCaseCount2 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        //System.assertEquals(3, subCaseCount2, '3 subcases should have been created.');

        Test.stopTest();
    }
    
     public static testMethod void testCreateBrandRegistrationSubCases2(){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id subCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        
        Case brandRegCase = createBrandRegistrationCase();
        brandRegCase.Traypack_Audit_picklist__c = 'No';
        brandRegCase.VAP_LTO_Allocation_picklist__c = 'No';
        brandRegCase.Giftshop_Pricing__c = 'No'; 
        brandRegCase.Pallet_Moving_for_France_SKU__c = true;
        insert brandRegCase;
        //caseServices.runTrigger = false;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};

        Test.startTest();

        Integer subCaseCount1 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        System.assertEquals(0, subCaseCount1, 'Subcases should not have been created yet.');
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());
        Integer subCaseCount2 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        //System.assertEquals(3, subCaseCount2, '3 subcases should have been created.');

        Test.stopTest();
    }



    public static testMethod void testCreateBrandRegistrationSubCasesBadDueDate(){
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id subCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;
        caseServices.runTrigger = false;
        brandRegCase.Due_Date__c = System.today() - 30;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};

        Test.startTest();

        Integer subCaseCount1 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        System.assertEquals(0, subCaseCount1, 'Subcases should not have been created yet.');
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());
        Integer subCaseCount2 = [SELECT COUNT() FROM Case WHERE RecordTypeId =: subCaseRecordTypeId];
        
        Test.stopTest();
        System.assertEquals(0, subCaseCount2, 'No subcases should have been created, due date is invalid.');

    }

    public static testMethod void testSetComplianceSubCaseStateType(){
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;
        caseServices.runTrigger = false;

        Test.startTest();

        Case subCase = createBrandRegistrationComplianceSubCase(brandRegCase.Id, 'Connecticut');
        System.assertEquals(subCase.State_Type__c, null, 'State Type should not be declared.');     
        insert subCase;
        subCase = [SELECT Id, State_Type__c FROM Case WHERE Id =: subCase.Id];
        System.assert(subCase.State_Type__c.contains('Auto Approval'), 'State Type have been set on insert.');      

        Test.stopTest();
    }

    public static testMethod void testDoAllChildCasesClosed(){
        Case brandRegCase = createBrandRegistrationCase();
        brandRegCase.Item_in_Z2_status__c=True;
        insert brandRegCase;
        caseServices.runTrigger = false;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};
        Test.startTest();
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());

        

        List<Case> subcaseList = [SELECT Id FROM Case WHERE ParentId =: brandRegCase.Id];
        for(Case subCase: subcaseList){
            subCase.Status = 'Closed - No Action';
            subCase.Closed_No_Action_Reason__c  = 'Reason: Testing';
            subCase.OwnerId = UserInfo.getUserId();
        }
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        update subcaseList;
        brandRegCase = [SELECT Status FROM Case WHERE Id =: brandRegCase.Id];
        System.debug(LoggingLevel.INFO, brandRegCase);
        
        Test.stopTest();
        //System.assertEquals( 'Closed', brandRegCase.Status,'Case should be in the "Closed" status.');
    }

    public static testMethod void testCalculateNumberOfRegistrationsOnSubmissionNoRegistrations(){
        caseServices.runTrigger = false;
        Test.startTest();
        Case brandRegCase = createBrandRegistrationCase();
        brandRegCase.Item_in_Z2_status__c=True;
        insert brandRegCase;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());

        List<Case> subcaseList = [SELECT Id FROM Case WHERE ParentId =: brandRegCase.Id];
        for(Case subCase: subcaseList){
            subCase.Status = 'Closed - No Action';
            subCase.Closed_No_Action_Reason__c  = 'Reason: Testing';
            subCase.OwnerId = UserInfo.getUserId();
        }
        update subcaseList;
        

            brandRegCase = [SELECT Number_of_Registrations__c FROM Case WHERE Id =: brandRegCase.Id];
            Integer myInt = 0;
            if (brandRegCase.Number_of_Registrations__c != null){
                myInt = brandRegCase.Number_of_Registrations__c.intValue();
            }
            
        Test.stopTest();
        System.assertEquals(0, myInt, 'There were no registrations.');
        caseServices.runTrigger = true;

    }

    public static testMethod void testCalculateNumberOfRegistrationsOnSubmissionWithRegistrations(){
        caseServices.runTrigger = false;
        Test.startTest();
        Case brandRegCase = createBrandRegistrationCase();
        brandRegCase.Submitted_Compliance__c = false;
        brandRegCase.Item_in_Z2_status__c=True;
        insert brandRegCase;
      
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());

        List<Case> subcaseList = [SELECT Id FROM Case WHERE ParentId =: brandRegCase.Id];
        Integer numberOfSubCases = subcaseList.size();
        for(Case subCase: subcaseList){
            subCase.Status = 'Closed';
            subCase.Submitted_Compliance__c = true;
            subCase.OwnerId = UserInfo.getUserId();
        }
        
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        update subcaseList;
        
        brandRegCase = [SELECT Number_of_COLAs__c, Number_of_Registrations__c FROM Case WHERE Id =: brandRegCase.Id];
        Integer calculatedNumberOfRegistrations = Integer.valueOf(numberOfSubCases*brandRegCase.Number_of_COLAs__c);
        
        Test.stopTest();
        caseServices.runTrigger = true;
    }

    public static testMethod void testSendEmailOnInFieldDateChanged(){
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');

        brandRegCase.Explanation_of_Change__c = 'New reason value';
        brandRegCase.Kick_Off_Brand_Registration__c = true;
        brandRegCase.In_field_Date__c = System.today() + 120;
        system.debug(brandRegCase);
        update brandRegCase;
        Test.stopTest(); 
        //System.assert(Limits.getEmailInvocations()>0, 'The change Due Date email should have been sent.');
    }

    public static testMethod void testSendEmailOnDueDateChanged(){
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');

        brandRegCase.Explanation_of_Change__c = 'New reason value';
        brandRegCase.Due_Date__c = System.today() + 60;
        update brandRegCase;

        Test.stopTest(); 
        //System.assert(Limits.getEmailInvocations()>0, 'The change Due Date email should have been sent.');
    }
    /* Brand Registration Tests */

    /* Quote Request Tests */
    
    public static testMethod void testCreateQuoteRequest(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
    }

    public static testMethod void testSendNotificationOnQuoteRequestCreation(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
        Quote_Request__c qrItem1 = createQuoteRequest(quoteRequestCase.Id);
        qrItem1.Item_Available__c = 'Yes';
        qrItem1.Price_Needed__c = 'Yes';

        Quote_Request__c qrItem2 = createQuoteRequest(quoteRequestCase.Id);
        qrItem2.Item_Available__c = 'Yes';
        qrItem2.Price_Needed__c = 'No';

        Quote_Request__c qrItem3 = createQuoteRequest(quoteRequestCase.Id);
        qrItem3.Item_Available__c = 'No';
        qrItem3.Price_Needed__c = 'No';             
        insert new List<Quote_Request__c>{qrItem1, qrItem2, qrItem3};

        Test.startTest();
        CaseComplianceUtility.sendNotificationOnQuoteRequestCreation(quoteRequestCase.Id , 'test-email=beamsuntory@example.com');
        Test.stopTest();
    }
    
    public static testMethod void testSendEmailQuoteRequestItemAvailability(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
        quoteRequestCase.OwnerId = UserInfo.getUserId();
        
        List<Quote_Request__c> qrList = new List<Quote_Request__c>();
        for(Integer i = 0; i < 5; i++){
          qrList.add(CaseComplianceUtilityTest.createQuoteRequest(quoteRequestCase.Id));
        }
        insert qrList;
        update quoteRequestCase;

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        CaseComplianceUtility.sendEmailQuoteRequestItemAvailability(quoteRequestCase.Id);
        Test.stopTest(); 
        //System.assert(Limits.getEmailInvocations()>0, 'The change Due Date email should have been sent.');
    }

    public static testMethod void testSendEmailsOnQuoteRequestSubmissionOneOrMoreAvailable(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
        quoteRequestCase.OwnerId = UserInfo.getUserId();
        update quoteRequestCase;

        Quote_Request__c qrItem1 = createQuoteRequest(quoteRequestCase.Id);
        qrItem1.Item_Available__c = 'Yes';
        qrItem1.Price_Needed__c = 'Yes';

        Quote_Request__c qrItem2 = createQuoteRequest(quoteRequestCase.Id);
        qrItem2.Item_Available__c = 'Yes';
        qrItem2.Price_Needed__c = 'No';

        Quote_Request__c qrItem3 = createQuoteRequest(quoteRequestCase.Id);
        qrItem3.Item_Available__c = 'No';
        qrItem3.Price_Needed__c = 'No';             
        insert new List<Quote_Request__c>{qrItem1, qrItem2, qrItem3};

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        quoteRequestCase.Submitted_Compliance__c = true;
        update quoteRequestCase;
        Test.stopTest();
        //System.assert(Limits.getEmailInvocations()>0, 'The Approval Email should have been sent.');
    }   
        
    


    public static testMethod void testSendEmailsOnQuoteRequestSubmissionNoneAvailable(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
        quoteRequestCase.OwnerId = UserInfo.getUserId();
        update quoteRequestCase;

        Quote_Request__c qrItem1 = createQuoteRequest(quoteRequestCase.Id);
        qrItem1.Item_Available__c = 'No';
        qrItem1.Price_Needed__c = 'No';

        Quote_Request__c qrItem2 = createQuoteRequest(quoteRequestCase.Id);
        qrItem2.Item_Available__c = 'No';
        qrItem2.Price_Needed__c = 'No';

        Quote_Request__c qrItem3 = createQuoteRequest(quoteRequestCase.Id);
        qrItem3.Item_Available__c = 'No';
        qrItem3.Price_Needed__c = 'No';             
        insert new List<Quote_Request__c>{qrItem1, qrItem2, qrItem3};

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        quoteRequestCase.Submitted_Compliance__c = true;
        update quoteRequestCase;
        System.assertEquals(0, Limits.getEmailInvocations(), 'No Quote are available, no email should have been sent.');

        Test.stopTest();
    }

    public static testMethod void testSendEmailsOnQuoteRequestApproval(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
        quoteRequestCase.OwnerId = UserInfo.getUserId();
        update quoteRequestCase;

        Quote_Request__c qrItem = createQuoteRequest(quoteRequestCase.Id);
        qrItem.Item_Available__c = 'Yes';
        qrItem.Price_Needed__c = 'Yes';
        insert qrItem;

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        quoteRequestCase.Approved__c = true;
        update quoteRequestCase;
        Test.stopTest();
        //System.assert(Limits.getEmailInvocations()>0, 'The Approval Email should have been sent.');
    }

    /* Quote Request Tests */

    /* Price Filing Tests */

    public static testMethod void testSendEmailOnPriceFilingApprovalStatusChange(){
        Case priceFilingCase = createPriceFilingCase();

        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;

        System.runAs(noStateUser){
            insert priceFilingCase;
        }

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        CaseComplianceUtility.sendEmailOnPriceFilingApprovalStatusChange(priceFilingCase.Id, true);
        System.assertEquals(1, Limits.getEmailInvocations(), 'The Approval Status Change Email should have been sent.');

        Test.stopTest();
    }

    public static testMethod void testSendEmailOnPriceFilingBlankBookUpload(){
        Case priceFilingCase = createPriceFilingCase();

        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;

        System.runAs(noStateUser){
            insert priceFilingCase;
        }

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        CaseComplianceUtility.sendEmailOnPriceFilingBlankBookUpload(new Map<Id, Case>{priceFilingCase.Id => priceFilingCase});
        System.assertEquals(1, Limits.getEmailInvocations(), 'The Blank Book Email should have been sent.');

        Test.stopTest();
    }

    public static testMethod void testSendEmailOnPriceFilingFinalizedBookUpload(){
        Case priceFilingCase = createPriceFilingCase();

        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;

        System.runAs(noStateUser){
            insert priceFilingCase;
        }

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        CaseComplianceUtility.sendEmailOnPriceFilingFinalizedBookUpload(new Map<Id, Case>{priceFilingCase.Id => priceFilingCase});
        System.assertEquals(1, Limits.getEmailInvocations(), 'The Blank Book Email should have been sent.');

        Test.stopTest();
    }

    /* Price Filing Tests */

    /* Discount Tests */

    public static testMethod void testEvaluateDiscountApprovalNeeded(){
        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;

        Case discountCase;
        System.runAs(noStateUser){  
            discountCase = createDiscountCase();
            insert discountCase;
        }

        String discountDocType = ComplianceConstants.DOCUMENT_TYPE_DISCOUNTS_DOCUMENT;
        ContentVersion discountDoc = createContentVersion(discountDocType);
        discountDoc = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :discountDoc.Id LIMIT 1];
        ContentDocumentLink docLink = createContentDocumentLink(discountCase.Id, discountDoc.ContentDocumentId);

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        discountCase.Approval_Needed__c = 'Yes';
        update discountCase;

        Test.stopTest();
        //System.assert(Limits.getEmailInvocations()>0, 'The Approval Email should have been sent.');
    }

    public static testMethod void testSendEmailOnDiscountApprovalStatusChange(){
        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;

        Case discountCase;
        System.runAs(noStateUser){  
            discountCase = createDiscountCase();
            insert discountCase;
        }

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        System.runAs(noStateUser){
            CaseComplianceUtility.sendEmailOnDiscountApprovalStatusChange(discountCase.Id, true);
        }
        System.assertEquals(1, Limits.getEmailInvocations(), 'The Approval/Rejection email should have been sent.');
        
        Test.stopTest();
    }

    /* Discount Tests */

    /* Utility Method Tests */

    public static testMethod void testRetrieveComplianceUserStateAffiliation(){
        String coordinatorProfile = ComplianceConstants.QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE;
        User illinoisUser = createComplianceTestUser(coordinatorProfile, 'test-compliance-user-1=beamsuntory@example.com');
        illinoisUser.Represented_States__c = 'Illinois';
        User californiaUser = createComplianceTestUser(coordinatorProfile, 'test-compliance-user-2=beamsuntory@example.com');
        californiaUser.Represented_States__c = 'California';
        insert new List<User>{illinoisUser, californiaUser};

        Boolean userInAffiliationMap = false;

        Test.startTest();

        Map<String, Map<String, Id> > affiliationMap = CaseComplianceUtility.retrieveComplianceUserStateAffiliation();
        for(String profileKey: affiliationMap.keySet()){
            for(String stateKey: affiliationMap.get(profileKey).keySet()){
                if(illinoisUser.Id == affiliationMap.get(profileKey).get(stateKey)){
                    userInAffiliationMap = true;
                }
            }
        }

        System.assertEquals(true, affiliationMap.containsKey(illinoisUser.Represented_States__c), 'The state Illinois should be present in the Affiliation Map.');
        System.assertEquals(true, affiliationMap.containsKey(californiaUser.Represented_States__c), 'The state California should be present in the Affiliation Map.');

        Test.stopTest();
    }

    public static testMethod void testRetrieveCurrentLoggedInUserStateAffiliationWithStates(){
        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User multiStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        multiStateUser.Represented_States__c = 'Illinois;California;Wyoming;';
        insert multiStateUser;

        Test.startTest();

        Set<String> affiliationSet = new Set<String>();
        System.runAs(multiStateUser){
            List<String> affiliationList = CaseComplianceUtility.retrieveCurrentLoggedInUserStateAffiliation();
            for(String state: affiliationList){
                affiliationSet.add(state);
            }
        }
        System.assertEquals(true, !affiliationSet.isEmpty(), 'The set should not be empty');
        System.assertEquals(3, affiliationSet.size(), 'The set should have 3 states in it.');
        System.assert(affiliationSet.contains('Illinois'), 'The current logged in user should have the state: Illinois.');
        System.assert(affiliationSet.contains('California'), 'The current logged in user should have the state: California.');
        System.assert(affiliationSet.contains('Wyoming'), 'The current logged in user should have the state: Wyoming.');
        
        Test.stopTest();
    }

    public static testMethod void testRetrieveCurrentLoggedInUserStateAffiliationNoStates(){
        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User noStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        noStateUser.Represented_States__c = '';
        insert noStateUser;

        Test.startTest();

        Set<String> affiliationSet = new Set<String>();
        System.runAs(noStateUser){
            List<String> affiliationList = CaseComplianceUtility.retrieveCurrentLoggedInUserStateAffiliation();
            for(String state: affiliationList){
                affiliationSet.add(state);
            }
        }
        System.assertEquals(true, affiliationSet.isEmpty(), 'The set should be empty');
        System.assertEquals(0, affiliationSet.size(), 'The set should have 0 states in it.');

        Test.stopTest();
    }

    public static testMethod void testGetComplianceCoordinatorByState(){
        String sysAdminProfile = ComplianceConstants.SYSTEM_ADMINISTRATOR_PROFILE;
        User alabamaStateUser = createComplianceTestUser(sysAdminProfile, 'test-compliance-user-1=beamsuntory@example.com');
        alabamaStateUser.Represented_States__c = 'Alabama';
        insert alabamaStateUser;

        Test.startTest();

        User retrievedUser = CaseComplianceUtility.getComplianceCoordinatorByState('Alabama', sysAdminProfile);

        Test.stopTest();
    }

    public static testMethod void testSetComplianceFlagsetValue(){
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;

        System.debug(LoggingLevel.INFO, brandRegCase);
        String kickedOffPicklistValue = ComplianceConstants.FLAG_BRAND_REG_KICKED_OFF;
        String allClosed = ComplianceConstants.FLAG_BRAND_REG_ALL_SUB_CASES_CLOSED;
        brandRegCase = CaseComplianceUtility.setcomplianceflagsetValue(brandRegCase, kickedOffPicklistValue);
        brandRegCase = CaseComplianceUtility.setcomplianceflagsetValue(brandRegCase, kickedOffPicklistValue);
        brandRegCase = CaseComplianceUtility.setcomplianceflagsetValue(brandRegCase, allClosed);
        System.debug(LoggingLevel.INFO, brandRegCase);
    }

   public static testMethod void testkickoffCustomerdata() {
     caseServices.runTrigger = false;
        Test.startTest();
         Id BrandRegCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Brand Registration').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Waiting for Sub Cases';
        c.New_Activity__c = true;
        c.RecordTypeId = BrandRegCaseRecordTypeId;
        c.Customer_Data__c =false;
        c.Type = 'Informational';
        insert c;
        caseServices.runTrigger = true;
        
         Test.stopTest();
         c.Customer_Data__c =true;
        update c;
        
    
    }
    public static testMethod void testsendNotificationOnComplianceInquiryCreation(){
    List<String>AddList = new List<String>();
    Addlist.add('test@gmail.com');
    Addlist.add('test2@gmail.com');
     caseServices.runTrigger = false;
        Test.startTest();
         Id BrandRegCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Brand Registration').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Waiting for Sub Cases';
        c.New_Activity__c = true;
        c.RecordTypeId = BrandRegCaseRecordTypeId;
        c.Customer_Data__c =false;
        c.Type = 'Informational';
        insert c;
        caseServices.runTrigger = true;
        
         Test.stopTest();
    CaseComplianceUtility.sendNotificationOnComplianceInquiryCreation(c.id,AddList);
  
    
    }
    
      public static testMethod void testSendEmailsOnQuoteRequestSubmissionNoneAvailable2(){
        Case quoteRequestCase = createQuoteRequestCase('State Contact');
        insert quoteRequestCase;
        quoteRequestCase.OwnerId = UserInfo.getUserId();
        update quoteRequestCase;

        Quote_Request__c qrItem1 = createQuoteRequest(quoteRequestCase.Id);
        qrItem1.Item_Available__c = 'Yes';
        qrItem1.Price_Needed__c = 'Yes';

        Quote_Request__c qrItem2 = createQuoteRequest(quoteRequestCase.Id);
        qrItem2.Item_Available__c = 'Yes';
        qrItem2.Price_Needed__c = 'Yes';

        Quote_Request__c qrItem3 = createQuoteRequest(quoteRequestCase.Id);
        qrItem3.Item_Available__c = 'Yes';
        qrItem3.Price_Needed__c = 'Yes';             
        insert new List<Quote_Request__c>{qrItem1, qrItem2, qrItem3};
        CaseComplianceUtility.sendEmailQuoteRequestItemAvailability(quoteRequestCase.Id);
        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should have been sent.');
        quoteRequestCase.Submitted_Compliance__c = true;
        update quoteRequestCase;
        System.assertEquals(0, Limits.getEmailInvocations(), 'No Quote are available, no email should have been sent.');

        Test.stopTest();
    }
    
    public static testMethod void testisDueDateChanged(){
        
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};
            
        Test.startTest();
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());
        
        brandRegCase.Due_Date__c = System.today() + 31;
        CaseComplianceUtility.runCaseComplianceTriggerLogic =true;
        update brandRegCase;
        
        Test.stopTest();
    }
    
    public static testMethod void testCloseComplianceSubcases(){
        
        Test.startTest();
        Case brandRegCase = createBrandRegistrationCase();
        insert brandRegCase;
        Map<Id, Case> caseMap = new Map<Id, Case>{brandRegCase.Id => brandRegCase};
            
        CaseComplianceUtility.createBrandRegistrationSubCases(caseMap.keySet());
        
        brandRegCase.Status = 'Closed';
        brandRegCase.Item_in_Z2_status__c = true;
        update brandRegCase;
        
        Test.stopTest();
    }

    public static testMethod void testStateLicenseStatusChange(){
        Test.startTest();
        Case StateLicenseCase = createStateLicenseCase();
        insert StateLicenseCase;
        caseServices.runTrigger = true;
        CaseComplianceUtility.runCaseComplianceTriggerLogic = true;
        StateLicenseCase.License_Received_Date__c = System.Today()+12;
        update StateLicenseCase;
        caseServices.runTrigger = true;
        CaseComplianceUtility.runCaseComplianceTriggerLogic = true;
        StateLicenseCase.License_Received_Audit__c = true;
        update StateLicenseCase;
         Test.stopTest();
    }
    
}