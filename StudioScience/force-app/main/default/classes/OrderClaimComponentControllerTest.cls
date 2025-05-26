@isTest
public class OrderClaimComponentControllerTest {
    
    
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com',
                              EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US', ProfileId = p.Id,
                              TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
            insert u;
        }
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
        
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        insert c;
        
        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
        
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        
    }
    
    public static List<Case> createChildCaseRecords(String recordTypeName, String status, Id parentId, Integer numOfChildRecords, Boolean autoCreate) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<Case> casesToInsert = new List<Case>();
        Case parentCase = new Case();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        
        for (Integer i = 0; i < numOfChildRecords; i++) {
            Case c = new Case();
            c.Status = status;
            c.ParentId = parentId;
            c.RecordTypeId = recordTypeId;
            //c.setOptions(dmo);
            casesToInsert.add(c);
        }
        
        if (autoCreate) {
            insert casesToInsert;
        }
        
        return casesToInsert;
    }
    
    public static List<Case> getCasesById(Set<Id> caseIds) {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , OwnerId
                , State__c
                , Carrier__c
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case where Id IN :caseIds];
    }
    
    public static List<Case> getChildCasesByParentId(Id parentId) {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , OwnerId
                , State__c
                , Carrier__c
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case where ParentId = :parentId];
    }
    
    public static List<Case> getCasesByBeamItemNumber(String orderNumber) {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , OwnerId
                , State__c
                , Carrier__c
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case where Beam_Suntory_Item_Number__c = :orderNumber];
    }
    
    public static List<Case> getAllCases() {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , OwnerId
                , State__c
                , Carrier__c
                , Subject
                , Beam_Suntory_Item_Number__c
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , ccEmail__c
                , Entitlement.Name from Case];
    }
    
    public static testMethod void testGetLabelMap() {
        LightningComponentUtility.RequestStatus requestStatus;
        
        Test.startTest();
        
        requestStatus = OrderClaimComponentController.getClaimsIdLabelMap();
        
        Test.stopTest();
        
        System.assertEquals(true, requestStatus.responseMap.containsKey('labelMap'));
    }
    
    public static testMethod void testGetPickListValues() {
        Map<String, List<String>> requestStatus;
        
        Test.startTest();
        
        requestStatus = OrderClaimComponentController.getPicklistValues();
        
        Test.stopTest();
        
        System.assertEquals(true, requestStatus.containsKey('shipping_plant'));
    }
    
    public static testMethod void testGetRadioPickListValues() {
        Map<String, List<String>> requestStatus;
        
        Test.startTest();
        
        requestStatus = OrderClaimComponentController.getRadioPicklistValues();
        
        Test.stopTest();
        
        System.assertEquals(true, requestStatus.containsKey('quantity_type'));
    }
    
    public static testMethod void testGetRelatedCases() {
        LightningComponentUtility.RequestStatus requestStatus;
        
        Test.startTest();
        Case cc = getCasesByBeamItemNumber('111')[0];
        
        
        requestStatus = OrderClaimComponentController.getRelatedCases(cc.Id);
        
        Test.stopTest();
        Map<Id, Case> relatedCases = (Map<Id, Case>) requestStatus.responseMap.get('caseMap');
        
        System.assertEquals(2, relatedCases.size());
    }
    
    public static testMethod void testUpsertClaimSubCases() {
        LightningComponentUtility.RequestStatus requestStatus;
        
        Test.startTest();
        
        Case cc = getCasesByBeamItemNumber('111')[0];
        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', cc.Id, 2, false);
        
        requestStatus = OrderClaimComponentController.upsertClaimSubCase(childCases[0], null);
        
        Test.stopTest();
        Id newSubCase = (id) requestStatus.responseMap.get('caseId');
        
        System.assertNotEquals(NULL, newSubCase);
    }
    
    public static testMethod void testUpdateParentCaseBailment() {
        LightningComponentUtility.RequestStatus requestStatus;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Orders_Label).getRecordTypeId();
        
        Test.startTest();
        
        Case cc = getCasesByBeamItemNumber('111')[0];
        requestStatus = OrderClaimComponentController.updateParentCase(cc.Id, '1234', '4444', true, false, false, 'US', 'test', 'Indiana');
        
        Test.stopTest();
        
        Case newSubCase = (Case) requestStatus.responseMap.get('parentCase');
        
        System.assertNotEquals(NULL, newSubCase);
        
    }
    
    public static testMethod void testUpdateParentCaseGtr() {
        LightningComponentUtility.RequestStatus requestStatus;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Orders_Label).getRecordTypeId();
        
        Test.startTest();
        
        Case cc = getCasesByBeamItemNumber('111')[0];
        requestStatus = OrderClaimComponentController.updateParentCase(cc.Id, '1234', '4444', false, true, false, 'US', 'test', 'Indiana');
        
        Test.stopTest();
        
        Case newSubCase = (Case) requestStatus.responseMap.get('parentCase');
        
        System.assertNotEquals(NULL, newSubCase);
        
    }
    
    public static testMethod void testUpdateParentCaseSingleBarrel() {
        LightningComponentUtility.RequestStatus requestStatus;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Orders_Label).getRecordTypeId();
        
        Test.startTest();
        
        Case cc = getCasesByBeamItemNumber('111')[0];
        requestStatus = OrderClaimComponentController.updateParentCase(cc.Id, '1234', '4444', false, false, true, 'US', 'test', 'Indiana');
        
        Test.stopTest();
        
        Case newSubCase = (Case) requestStatus.responseMap.get('parentCase');
        
        System.assertNotEquals(NULL, newSubCase);
        
    }
    
    public static testMethod void testRemoveClaimSubCase() {
        LightningComponentUtility.RequestStatus requestStatus;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Orders_Label).getRecordTypeId();
        
        Test.startTest();
        
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.ccEmail__c = 'test@test.com';
        c.Beam_Suntory_Item_Number__c = '111';
        c.Beam_Suntory_Order_Number__c = '123';
        c.Purchase_Order_Number__c = '123';
        insert c;
        
        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
        
        requestStatus = OrderClaimComponentController.removeClaimSubCase(childCases[0].Id);
        
        Test.stopTest();
        
        List<Case> updatedCases = getChildCasesByParentId(c.Id);
        
        System.assertEquals(1, updatedCases.size());
        
    }
    
    public static testMethod void testGetParentCase() {
        LightningComponentUtility.RequestStatus requestStatus;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Orders_Label).getRecordTypeId();
        
        Test.startTest();
        
        Case cc = getCasesByBeamItemNumber('111')[0];
        requestStatus = OrderClaimComponentController.getParentCase(cc.Id);
        
        Test.stopTest();
        
        Map<Id, Case> caseMap = (Map<Id, Case>) requestStatus.responseMap.get('parentCase');
        for (Case c : caseMap.values()) {
            System.assertEquals(cc.Id, c.Id);
        }
        
    }
    
    
}