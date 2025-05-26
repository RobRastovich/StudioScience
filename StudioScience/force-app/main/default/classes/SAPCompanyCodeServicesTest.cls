@IsTest
public class SAPCompanyCodeServicesTest {

    @testSetup
    public static void testUpdateAccountOnInsert(){
        //insert Account
        Account a = new Account();
        a.Name='testAccount';
        a.SAP_Vendor_ID__c='testVendor';
        insert a;
        //insert SAP Company Code
        SAP_Company_Code__c sapCompanyCode = new SAP_Company_Code__c();
        sapCompanyCode.Name = 'TestSapCompanyCode';
        sapCompanyCode.VendorCompanycodeKey__c='testVendorTestSapCompanyCode';
        sapCompanyCode.SAP_Vendor__c = 'testVendor';
        insert sapCompanyCode;
        
        
        list <SAP_Company_Code__c> sapCC = [select Id, Name, Account__c, SAP_Vendor__c,VendorCompanycodeKey__c from SAP_Company_Code__c where Name='TestSapCompanyCode'];
        Map<id,SAP_Company_Code__c> IdcodeMap=new Map<Id,SAP_Company_Code__c>();
        for (SAP_Company_Code__c cc : sapCC) {  
               if(cc.Account__c== Null){
                   idcodeMap.put(cc.Id, cc);
               }   
           } 
        database.executeBatch(new BatchSAPCompanyCodeVendorAccount(idcodeMap)); 
    }
    
    @IsTest
    public static void testUpdateAccountOnUpdate(){
        //insert new Account
        Account a = new Account();
        a.Name='testAccount1';
        a.SAP_Vendor_ID__c='testVendor1';
        insert a;
        
        SAP_Company_Code__c sap = [select Id, Name, Account__c, SAP_Vendor__c,VendorCompanycodeKey__c from SAP_Company_Code__c where Name='TestSapCompanyCode'];
        System.debug('SAP Deta:::'+sap.Account__c);
        sap.SAP_Vendor__c = 'testVendor1';
        sap.VendorCompanycodeKey__c = 'testVendor1TestSapCompanyCode';
        update sap;
        System.assert(sap.Account__c!=null, 'Account field should not be null');
    }
}