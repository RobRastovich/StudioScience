public without sharing class SBP_BarrelSelectionCmpCtrl {    
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:    Creates a barrel record based on what is selected in the Single Barrel Flow
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus createBarrelRecord(String caseId, String brand, String flavor) {
        Boolean success = true;
        String message = null;
        String Status;
        Map<String, Object> responseMap = new Map<String, Object>();
        Barrel__c barrel = new Barrel__c();
        
        try {
            List<Barrel__c> barrels = [select id,Case__r.Status from Barrel__c where Case__c = :Id.valueOf(caseId)];
            if (barrels.isEmpty()) {
                barrel.Case__c = Id.valueOf(caseId);
                barrel.Brand__c = brand;
                barrel.RecordTypeId = SBP_Constants.fullBarrelBrandRTIdMap.get(brand);
                barrel.Product_Type__c = flavor;
                insert barrel;
            } else {
                barrel = barrels[0];
            }
            
            Case c = new Case();
            c.put('Id', Id.valueOf(caseId));
            c.put('Product_Type__c', flavor);
            update c;
            
            responseMap.put('barrelId', barrel.Id);
            responseMap.put('Status', barrel.Case__r.Status); //added by ajeeta
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:    queries for the barrel related to the case
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getRelatedBarrel(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            Barrel__c b = [select id from Barrel__c where Case__c = :Id.valueOf(recordId) limit 1];
            
            responseMap.put('recordId', b.Id);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:        Abhishek
Company:       TCS
Description:   Updates the Sample Kit Details on the case in the Single Barrel Flow
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2019      Abhishek       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateSampleKitDetails(String caseId, String sampleKitCompany, String sampleKitStreet, String sampleKitCity, String sampleKitZip, String sampleKitState, String sampleKitPhone) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        System.debug('---Data Recieved--- Case Id---'+caseId+' ---SampleKit Company---'+SampleKitCompany);
        
        try {
            Case sampleKitCase = [select id,Status from Case where Id = :Id.valueOf(caseId) Limit 1];
            if(sampleKitCase.id != null){
                sampleKitCase.Sample_Kit_Attention__c = SampleKitCompany;
                sampleKitCase.Sample_Kit_Street__c = sampleKitStreet;
                sampleKitCase.Sample_Kit_City__c = sampleKitCity;
                sampleKitCase.Sample_Kit_Zip__c = sampleKitZip;
                sampleKitCase.Sample_Kit_State__c = sampleKitState;
                sampleKitCase.Sample_Kit_Phone__c = sampleKitPhone;    
            }
            update sampleKitCase;
            responseMap.put('SampleKit', sampleKitCase.Sample_Kit_Attention__c);
            responseMap.put('Status', sampleKitCase.Status);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
            CreateExceptionLog.insertErrorLog('SBP_BarrelSelectionCmpCtrl', 'updateSampleKitDetails', String.valueOf(e), 'Fatal');
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    /**************************************************************************************************************
Author:        Priyankar
Company:       TCS
Description:   Gets Distributor Account Record From the Case
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2020      Priyankar       	Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static Case getCaseDistributorAccountRecord(String caseId){
        if(caseId == null){
            System.debug('AccountId null:::');
            return null;
        }else{
            Case objCase = [Select Id, Account.Name, Account.Attention__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Phone From Case Where Id =: caseId];
            System.debug('Returned Account:::'+objCase);
            return objCase;
        }
    }
    /**************************************************************************************************************
Author:        Priyankar
Company:       TCS
Description:   Gets Sample Kit Shipping Address based on zipcode
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2020      Priyankar       	Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Sample_Kit_Shipping_Address__c> getSampleKitShippingAddress(String searchKey){
        List<Country_State__c> csList = Country_State__c.getall().values();
        Map<String,String> stateAbbvMap = new Map<String,String>();
        for(Country_State__c cs : csList){
            stateAbbvMap.put(cs.Name.toLowerCase(),cs.Abbreviations__c); 
        }
        Map<String,Sample_Kit_Shipping_Address__c> shippingAddressMap = new Map<String,Sample_Kit_Shipping_Address__c>();
        try{
            if(searchKey != null){             
                if(searchKey.length() == 2){
                    String searchQuery = '%'+searchKey+'%';    
                    for(Sample_Kit_Shipping_Address__c sshd : [Select Name, Id, City__c, Company__c, Country__c, State__c, 
                                                               Street__c, Zip_Code__c, Legal_to_receive_Sample_Kit__c From Sample_Kit_Shipping_Address__c Where State__c Like : searchQuery AND Legal_to_receive_Sample_Kit__c = true]){
                                                                   shippingAddressMap.put(sshd.Id, sshd);
                                                               }
                }
                else if(searchKey.length() > 2){
                    if(stateAbbvMap.containsKey(searchKey.toLowerCase())){
                        String searchQuery = stateAbbvMap.get(searchKey.toLowerCase());
                        for(Sample_Kit_Shipping_Address__c sshd : [Select Name, Id, City__c, Company__c, Country__c, State__c, 
                                                                   Street__c, Zip_Code__c, Legal_to_receive_Sample_Kit__c From Sample_Kit_Shipping_Address__c Where State__c =: searchQuery AND Legal_to_receive_Sample_Kit__c = true]){
                                                                       shippingAddressMap.put(sshd.Id, sshd);
                                                                   }
                    }
                    else{
                        return null;
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Error Occured:::'+e.getMessage());
        }
        System.debug('Return Map:::'+shippingAddressMap);
        return shippingAddressMap;
    }
}