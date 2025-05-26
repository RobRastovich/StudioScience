@isTest (SeeAllData=false)

public class ComplianceKickoffAttachmentCntrlTest {
   
    public static testMethod void testGetDocumentTypePicklistValuesBrandReg(){
        Case brCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        insert brCase;
       
        Test.startTest();
        
        Id CustomerDataRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Data').getRecordTypeId();
        Case c3 = new Case();
        c3.Status = 'New';
        c3.New_Activity__c = true;
        c3.Type = 'Other';
        c3.RecordTypeId = CustomerDataRecordTypeId;
        c3.Customer_Data__c =true;
        c3.parentid= brCase.id;
        insert c3;
        
        ContentVersion testContentVersion1 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
        //ContentVersion testContentVersion2 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
        //ContentVersion testContentVersion3 = CaseComplianceUtilityTest.createContentVersion(ComplianceConstants.DOCUMENT_TYPE_OTHER);
        testContentVersion1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion1.Id];
        //testContentVersion2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion2.Id];
        //testContentVersion3 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: testContentVersion3.Id];
        ContentDocumentLink testDocumentLink1 = CaseComplianceUtilityTest.createContentDocumentLink(brCase.Id, testContentVersion1.ContentDocumentId);
        //ContentDocumentLink testDocumentLink2 = CaseComplianceUtilityTest.createContentDocumentLink(brCase.Id, testContentVersion2.ContentDocumentId);
        //ContentDocumentLink testDocumentLink3 = CaseComplianceUtilityTest.createContentDocumentLink(brCase.Id, testContentVersion3.ContentDocumentId);
		
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'testing.txt'; 
        conVer.Title = 'Testing Files';
        conVer.VersionData = EncodingUtil.base64Decode('testing here'); 
        insert conVer; 
        
        
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = c3.id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        ComplianceKickoffAttachmentCntrl.UpdateAttachments(brCase.id);
        Test.stopTest();
    }
    /*public static testMethod void SubCasesCreation(){
        Test.startTest();
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id subCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        Case brandRegCase = CaseComplianceUtilityTest.createBrandRegistrationCase();
        brandRegCase.Traypack_Audit__c = true;
        brandRegCase.VAP_LTO_Allocation__c = true;
        brandRegCase.Pallet_Moving_for_France_SKU__c = true;
        Insert brandRegCase;    
        ComplianceKickoffAttachmentCntrl.UpdateAttachments(brandRegCase.id);
        Test.stopTest();
    }
    public static testMethod void SubCasesTest2(){
        Id BrandRegCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Brand Registration').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Waiting for Sub Cases';
        c.New_Activity__c = true;
        c.RecordTypeId = BrandRegCaseRecordTypeId;
        c.Customer_Data__c =false;
        insert c;
        c.Customer_Data__c =true;
        update c;
        ComplianceKickoffAttachmentCntrl.UpdateAttachments(c.id);
        
    }
    public static testMethod void SubCasesTest3(){
        Id BrandRegCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Brand Registration').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Waiting for Sub Cases';
        c.New_Activity__c = true;
        c.RecordTypeId = BrandRegCaseRecordTypeId;
        c.Customer_Data__c =false;
        insert c;
        
        Id CustomerDataRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Data').getRecordTypeId();
        Case c3 = new Case();
        c3.Status = 'New';
        c3.New_Activity__c = true;
        c3.Type = 'Other';
        c3.RecordTypeId = CustomerDataRecordTypeId;
        c3.Customer_Data__c =true;
        c3.parentid= c.id;
        insert c3;
        
        ContentVersion testDoc = CaseServicesTest.createContentVersion();
        testDoc = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :testDoc.Id LIMIT 1];
        ContentDocumentLink docLink = CaseServicesTest.createContentDocumentLink(c.Id, testDoc.ContentDocumentId);
        
        ComplianceKickoffAttachmentCntrl.UpdateAttachments(c.id);
        
    }*/
}