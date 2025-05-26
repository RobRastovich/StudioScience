@isTest
public class SBP_NewPOSCustomizationCmpCtrlTest {
    @testSetup 
    static void setup() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        Account intAccount = new Account();
        intAccount.Name = 'Single Barrel International Account';
        intAccount.BillingState = 'IL';
        intAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();

        insert new List<Account> {testAccount, intAccount};

        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.Type__c = 'Trip and Tour';
        insert bg;

        Case c = new Case();
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
        c.Type = 'Trip and Tour';
        c.Barrel_Order_Group__c = bg.Id;
        c.Account_Missing__c = true;
        c.Retail_Account_Name__c = 'Missing Account Name';
        c.Retail_Account__c = intAccount.Id;
        c.Brand__c = 'Makers Mark';
        c.AccountId = testAccount.Id;
	    CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        insert c;

        Barrel__c makersMark = new Barrel__c();
        makersMark.Brand__c = 'Makers Mark';
        makersMark.Ship_Date__c = null;
        makersMark.Case__c = c.Id;
        makersMark.SKU__c = 'Test Barrel 2';
        makersMark.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark_Full_Barrel').getRecordTypeId();
        insert makersMark;
        
        POS_Customization__c pos1= new POS_Customization__c();
        pos1.Type__c= 'Bottle Plate Text';
        pos1.Insert_Text__c='test'; 
        pos1.Barrel__c= makersMark.Id;
        
        POS_Customization__c pos2= new POS_Customization__c();
        pos2.Type__c= 'Bottle Label Text City and State';
        pos2.Insert_Text__c='test'; 
        pos2.Barrel__c= makersMark.Id;
        insert new List<POS_Customization__c> {pos1, pos2};
    }
    
    public static testMethod void testClass1() {
        Case caserecord = [Select id from Case where Type = 'Trip and Tour' and Brand__c = 'Makers Mark' limit 1];
        Barrel__c barrelRecord = [Select id, name from Barrel__c where Brand__c = 'Makers Mark'limit 1];  
        SBP_NewPOSCustomizationCmpCtrl.getPOSItems(caserecord.Id);
        SBP_NewPOSCustomizationCmpCtrl.getRelatedBarrels(caserecord.Id);
        SBP_NewPOSCustomizationCmpCtrl.getPOSMetaData(caserecord.Id);
        SBP_NewPOSCustomizationCmpCtrl.insertPOSItem('Menu Insert Card', null, null, null, barrelRecord.Id, 1, null, null, null, null, 
                                                     false, null ,null , false, null, null, null, null, null, null, null, null);
    }
}