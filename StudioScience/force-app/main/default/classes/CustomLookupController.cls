public with sharing class CustomLookupController {
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String objectName) {
        String searchKey = String.escapeSingleQuotes(searchKeyWord.trim()) + '%';
        
        List <sObject> returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 15
        
        String sQuery =  'select id, Name from ' + objectName + ' where RecordType.DeveloperName =  \'Distributor\' And Name LIKE: searchKey order by createdDate DESC limit 15';
        system.debug(sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj : lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static String getEnvironmentUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    
    // returns all "Distributor" accounts based on the search keyword
    @AuraEnabled
    public static List<sObject> getDistributorRecordType(String searchKeyWord, String objectName, Integer queryLimit,String accountbillingState) {
        String searchKey = searchKeyWord.trim() + '%';
        if (queryLimit == null || queryLimit == 0) {
            queryLimit = 30;
        }
        List<sObject> returnList = new List<sObject>();
        List<sObject> lstOfRecords = [SELECT 
                                      Id, Name, Attention__c, State__c, TDL_Match_Code__c, PremiseType__c, 
                                      BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone 
                                      FROM 
                                      Account 
                                      WHERE 
                                      RecordType.DeveloperName = 'Distributor' 
                                      AND
                                      Available_For_Single_Barrel__c = true
                                      AND
                                      (
                                          TDL_Match_Code__c = :searchKeyWord 
                                          OR 
                                          Name LIKE :searchKey
                                      ) 
                                      AND 
                                      BillingState = :accountbillingState 
                                      ORDER BY 
                                      CreatedDate DESC 
                                      LIMIT :queryLimit];
        for (sObject obj : lstOfRecords) {
            String oldName = (String) obj.get('Name');
            String billingCity = (String) obj.get('BillingCity');
            if(obj.get('BillingCity')!=null && !(oldName.contains('-') && oldName.contains(billingCity)) ){
                String newName = oldName +' - ' + billingCity ;
                obj.put('Name',newName);
            }
            returnList.add(obj);
        }
        return returnList;
    }
    
    // returns all "Retail" accounts based on the search keyword
    // recordTypeNames list<String> and QcInfoVar String parameter added for SAL-2083 & SAl-2193 by Mukul
    @AuraEnabled
    public static List <sObject> getPremiseRecordType(String searchKeyWord, String objectName, Integer queryLimit, String city, String state,Boolean AvailableForSingleBarrel, List<String> recordTypeNames, String QcInfoVar) {
        String searchKey = searchKeyWord.trim() + '%';
        if (queryLimit == null || queryLimit == 0) {
            queryLimit = 30;
        }
        List <sObject> returnList = new List < sObject > ();
        List <sObject> returnListNew = new List < sObject > ();
        List <sObject> returnListNew1 = new List < sObject > ();
        
        System.debug('city value is::'+city+'State value is:::'+state);
        system.debug('--->recordTypeNames '+recordTypeNames);
        //Added for SAL-2083 & SAL-2193 Account search functionality by Mukul
        if(QcInfoVar == 'true'){
            if(recordTypeNames.size() >= 0 && (city == null || city == '') && (state == null || state == '')){
                system.debug('recordTypeNames '+recordTypeNames);
                List <sObject> lstOfRecords = [select id, Name, PremiseType__c, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, RecordType.DeveloperName, State__c, Available_for_Single_barrel__c from Account where (RecordType.DeveloperName IN :recordTypeNames) AND (TDL_Match_Code__c = :searchKeyWord OR Name LIKE :searchKey) /*AND Available_for_Single_barrel__c=:AvailableForSingleBarrel*/ order by createdDate DESC limit :queryLimit];
                for (sObject obj : lstOfRecords) {
                    returnList.add(obj);
                }
                return returnList;
            }
        }
        
        else if((city == null || city == '') && (state == null || state == '')){
            List <sObject> lstOfRecords = [select id, Name, PremiseType__c, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, RecordType.DeveloperName, State__c, Available_for_Single_barrel__c from Account where (RecordType.DeveloperName = 'OffPremise' OR RecordType.DeveloperName = 'OnPremise') AND (TDL_Match_Code__c = :searchKeyWord OR Name LIKE :searchKey) /*AND Available_for_Single_barrel__c=:AvailableForSingleBarrel*/ order by createdDate DESC limit :queryLimit];
            for (sObject obj : lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
        
        else if(city != null && city != '' && state != null && state != ''){
            List <sObject> lstOfRecordsNew1 = [select id, Name, PremiseType__c, BillingStreet,BillingCountry, BillingCity, BillingState, BillingPostalCode, RecordType.DeveloperName, State__c, Available_for_Single_barrel__c from Account where (RecordType.DeveloperName = 'OffPremise' OR RecordType.DeveloperName = 'OnPremise') AND (TDL_Match_Code__c = :searchKeyWord OR Name LIKE :searchKey) AND BillingCity = :city AND BillingState = :state /* AND Available_for_Single_barrel__c=:AvailableForSingleBarrel */ order by createdDate DESC limit :queryLimit];
            for (sObject obj : lstOfRecordsNew1) {
                returnListNew1.add(obj);
            }
            return returnListNew1;
        }
        
        else if((city != null && city != '') || (state != null && state != '')){
            List <sObject> lstOfRecordsNew = new List <sObject> ();
            
            if(city != null && city != ''){
                lstOfRecordsNew = [select id, Name, PremiseType__c, BillingStreet, BillingCity,BillingCountry, BillingState, BillingPostalCode, RecordType.DeveloperName, State__c, Available_for_Single_barrel__c from Account where (RecordType.DeveloperName = 'OffPremise' OR RecordType.DeveloperName = 'OnPremise') AND BillingCity = :city AND (TDL_Match_Code__c = :searchKeyWord OR Name LIKE :searchKey) order by createdDate DESC limit :queryLimit];
            }else{
                lstOfRecordsNew = [select id, Name, PremiseType__c, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, RecordType.DeveloperName, State__c, Available_for_Single_barrel__c from Account where (RecordType.DeveloperName = 'OffPremise' OR RecordType.DeveloperName = 'OnPremise') AND BillingState = :state AND (TDL_Match_Code__c = :searchKeyWord OR Name LIKE :searchKey) order by createdDate DESC limit :queryLimit];
            }
            
            for (sObject obj : lstOfRecordsNew) {
                returnListNew.add(obj);
            }
            return returnListNew;
        }
        
        return returnList;
    }
    
    // returns all contacts related to a specific account id
    @AuraEnabled
    public static List <sObject> getDistributorContactForAccount(String searchKeyWord, String objectName, String parentId) {
        String searchKey = searchKeyWord.trim() + '%';
        Set<Id> contactIds = new Set<Id>();
        
        for (AccountContactRelation con : [select id, Contact.Name, Contact.LastName, Contact.Email, ContactId from AccountContactRelation where (AccountId = :Id.valueOf(parentId) AND Contact.Name LIKE :searchKey)]) {
            contactIds.add(con.ContactId);
        }
        return [select Id, Name, LastName from Contact where Id IN :contactIds order by LastName ASC];
    }
    
    // returns all accounts related to a specfic contact Id
    @AuraEnabled
    public static List <sObject> getMyAccounts(String searchKeyWord, String objectName, String parentId) {
        String searchKey = searchKeyWord.trim() + '%';
        Set<Id> accountIds = new Set<Id>();
        
        for (AccountContactRelation acct : [select id, AccountId, Account.Name, ContactId from AccountContactRelation where (ContactId = :Id.valueOf(parentId) AND Account.Name LIKE :searchKey)]) {
            accountIds.add(acct.AccountId);
        }
        return [select Id, Name from Account where Id IN :accountIds order by Name ASC limit 50];
    }
    
    //retuns all the list of diplomate users
    @AuraEnabled
    public static List <sObject> getUserRecord(String searchKeyWord, String objectName, Integer queryLimit, String state, String brand, String NationalAccount) {
        System.debug('State value is:::'+state);
        String searchKey = searchKeyWord.trim() + '%';
        if (queryLimit == null || queryLimit == 0) {
            queryLimit = 20;
        }
        List <sObject> returnList = new List < sObject > ();
        
        if( brand == 'Makers Mark' && NationalAccount == 'Yes' ){
            
            List <sObject> lstOfRecords = [SELECT Id, Username, FirstName, LastName, Name FROM User where isNationalAccountApprover__c = true];
        	for (sObject obj : lstOfRecords) {
            	returnList.add(obj);
        	}
            
        }
        else{
            List<User> userlist = [SELECT Id, Regional_Diplomat_Regions__c FROM User WHERE Regional_Diplomat_Regions__c INCLUDES (:state)];
            List<Id> userIds = new List<Id>();
        
        	for(User u:userlist){
            	if(u.Regional_Diplomat_Regions__c.contains(state)){
                	userIds.add(u.Id);
            	}
        	}
        
        	//List <sObject> lstOfRecords = [SELECT Id, Username, FirstName, LastName, Name, Regional_Diplomat_Regions__c FROM User where (FirstName = :searchKeyWord OR FirstName LIKE :searchKey) AND Regional_Diplomat_Regions__c =:state limit :queryLimit];
        	List <sObject> lstOfRecords = [SELECT Id, Username, FirstName, LastName, Name FROM User where Id IN:userIds];
        	for (sObject obj : lstOfRecords) {
            	returnList.add(obj);
        	}
        }
        
        return returnList;
    }
    
    // returns all heritagemanagers related to a specfic approver Id for makers mark brand
    @AuraEnabled
    public static List<sObject> getHeritageManager(String selectedApproverId, String brand){        
        List<String> hmuserIdList = new List<String>();
        String hmUserId = selectedApproverId;         
        List<Diplomatic_Hierarchy__c> hierarchyList = new  List<Diplomatic_Hierarchy__c>();
        hierarchyList = [SELECT Diplomat__r.Name,Diplomat__c,Id,Manager__r.Name,Manager__c,Name,User_Type__c FROM Diplomatic_Hierarchy__c WHERE Diplomat__c = :selectedApproverId];
        if(!hierarchyList.isEmpty() && brand == 'Makers Mark'){         
            for(Diplomatic_Hierarchy__c dc : hierarchyList){
                hmuserIdList.add(dc.Manager__r.Id);                                               
            }
        }       
        List<User> userHM = [SELECT Id, Name, Email from User where Id  = :hmuserIdList];       
        if(!userHM.isEmpty()){                                    
            return userHM;
        }                
        return null;
    }

    // returns all SAP Company records related to a specific account vendor id
    @AuraEnabled
    public static List <sObject> getSAPCompanyForVendorAccount(String parentId) {
        Set<Id> sapCompanyCodeRecordIds = new Set<Id>();
        for (Account acc : [Select id, Name, (Select Id, Name From SAP_Company_Codes__r) from Account where Id = :Id.valueOf(parentId)]) {
            for(SAP_Company_Code__c sapCode: acc.SAP_Company_Codes__r){
                sapCompanyCodeRecordIds.add(sapCode.Id);
            }
            
        }
        return [select Id, Name, Status__c,SAP_Company_Code_Name_Mask__c from SAP_Company_Code__c where Id IN :sapCompanyCodeRecordIds];
    }
    
    // returns account and SAP Company Code details for the respective PR Header
    @AuraEnabled
    public static Map<String, Object> getAccountAndSAPCompanyCodeDetails(String PRHederId) {
        system.debug('PRHederId: '+ PRHederId);
        Map<String, Object> responseMap = new Map<String, Object>();
        PR_Header__c prHeader = [select id, Vendor_Name__c, SAP_Company_Code__c from PR_Header__c where id =: PRHederId];
        if(prHeader.Vendor_Name__c != null){
            Account objAccount = [Select Id, Name from Account Where Id =: prHeader.Vendor_Name__c];
            responseMap.put('Account',objAccount);
        }           
        if(prHeader.SAP_Company_Code__c != null){
            SAP_Company_Code__c objSAPCode = [Select Id, Name, Status__c from SAP_Company_Code__c Where Id =: prHeader.SAP_Company_Code__c];
            responseMap.put('SapCompanyCode',objSAPCode);
        }       
        System.debug('Return Map Size:::'+responseMap.size());        
        return responseMap;
    }
    
    // update Method of PRHeader Record
    @AuraEnabled
    public static String updatePRHeader(String jsonPRHeaders) {
        String return_message = 'PR Record Saved Successfully';
        System.debug(jsonPRHeaders);
        try {
            List<PR_Header__c> prHeaderList = (List<PR_Header__c>)System.JSON.deserialize(jsonPRHeaders, List<PR_Header__c>.Class);
            PR_Header__c prHeaderFromComponent = prHeaderList[0];
            //Below lines added by Sripal on 7/20/2020
            /*PR_Header__c prhead = new PR_Header__c();
prhead = [select id,name,PR_Currency__c from PR_Header__c where id=:prHeaderFromComponent.Id ];
if(prhead.PR_Currency__c!=prHeaderFromComponent.PR_Currency__c){
prHeaderFromComponent.Currency_Changed__c = true;
}
else
prHeaderFromComponent.Currency_Changed__c = false;*/
            update prHeaderFromComponent;
            if(Test.isRunningTest())
            {
                throw new System.DmlException('test exception');
            }            
        }        
        catch(Exception e){  
            return_message = 'Failed to Save PR Record';
            System.debug('---Exception Thrown while updating the PR Header---'+e.getMessage());
        }
        return return_message;
    }
    
    //fetch picklist values for PR Header Record
    @AuraEnabled
    public static List<String> getPRPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();         
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();        
        if(nullRequired == true){
            optionlist.add('--None--');
        }        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    
    //retuns all the list of diplomate users and HMs
    @AuraEnabled
    public static List <sObject> getDiplomats(String searchKeyWord, Integer queryLimit) {
        String searchKey = searchKeyWord.trim() + '%';
        if (queryLimit == null || queryLimit == 0) {
            queryLimit = 20;
        }
        List <sObject> lstOfRecords = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND ( User_Type__c = 'Diplomat' OR User_Type__c = 'Heritage Manager' OR User_Type__c = 'Plant Team Member') AND Name LIKE :searchKey];
        return lstOfRecords;
    }
    // returns the list of single barrel proof specific cases
    @AuraEnabled
    public static List <sObject> searchCase(String searchKeyWord) {
        String searchKey = String.escapeSingleQuotes(searchKeyWord.trim()) + '%';
        
        List <sObject> returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 15
        
        String sQuery =  'select id, CaseNumber,Case_Record_Type__c from Case where Case_Record_Type__c =  \'Single Barrel - Proof Specific\' And CaseNumber LIKE: searchKey order by createdDate DESC limit 15';
        system.debug(sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj : lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    /* @AuraEnabled
public static List <sObject> searchCaseWithoutPlantEvent(String searchKeyWord) {
String searchKey = String.escapeSingleQuotes(searchKeyWord.trim()) + '%';

List <sObject> returnList = new List < sObject > ();

// Create a Dynamic SOQL Query For Fetch Record List with LIMIT 15

String sQuery =  'select id, CaseNumber,Case_Record_Type__c from Case where Case_Record_Type__c =  \'Single Barrel - Proof Specific\' And CaseNumber LIKE: searchKey AND Plant_Event__c = null order by createdDate DESC limit 15';
system.debug(sQuery);
List <sObject> lstOfRecords = Database.query(sQuery);

for (sObject obj : lstOfRecords) {
returnList.add(obj);
}
return returnList;
}*/
    //return the list of plant event
    @AuraEnabled
    public static List <sObject> searchPlantEvent(String searchKeyWord) {
        String searchKey = String.escapeSingleQuotes(searchKeyWord.trim()) + '%';
        
        List <sObject> returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 15
        
        String sQuery =  'select id, Name, Case__c from Plant_Event__c where Name LIKE: searchKey order by createdDate DESC limit 15';
        system.debug(sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj : lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    //return user record
    @AuraEnabled
    public static List <sObject> getCollaboratorUser(String searchKeyWord, Integer queryLimit) {
        String searchKey = searchKeyWord.trim() + '%';
        if (queryLimit == null || queryLimit == 0) {
            queryLimit = 20;
        }
        List <sObject> lstOfRecords = [SELECT Id,Name,Email FROM User WHERE (Name LIKE :searchKey OR Email Like :searchKey) AND IsActive = true  limit :queryLimit ];
        return lstOfRecords;
    }    
    
}