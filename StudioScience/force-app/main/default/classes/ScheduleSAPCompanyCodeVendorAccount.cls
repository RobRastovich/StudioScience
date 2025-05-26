global class ScheduleSAPCompanyCodeVendorAccount implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        Map<id,SAP_Company_Code__c> IdSAPCodeBatch = new Map<id,SAP_Company_Code__c>([Select Id, SAP_Vendor__c, Account__c From SAP_Company_Code__c Where  Account__c = Null AND SAP_Vendor__c!= Null]);
        BatchSAPCompanyCodeVendorAccount batchSapAccount = new BatchSAPCompanyCodeVendorAccount(IdSAPCodeBatch);
        database.executeBatch(batchSapAccount,50);
    } 
    
}