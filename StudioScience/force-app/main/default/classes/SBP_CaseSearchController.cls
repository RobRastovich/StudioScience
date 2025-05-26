public class SBP_CaseSearchController {
    
    /**************************************************************************************************************
Author:        Priyankar Saha
Company:       TCS
Description:   List view of My Single Barrel Orders
parameters:    strQuery: keyword in search box on basis of which list will be filtered 
brand: brand selected in brand filter
toggle: used to store toggle off/on value
selectedStates: used to store selected states of state filter(for heritage manager)
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2020      Priyankar Saha       Initial Creation
5/2021     Yash Jain            Modified to search the results on diplomat name
5/2021     Yash Jain            Added a method to get regional diplomat regions for current user

***************************************************************************************************************/
    
    @AuraEnabled 
    public static List<Case> fetchCaseRecords(String strQuery, String brand, Boolean toggle, List<String> selectedStates){ 
        System.debug('Str Query:::'+strQuery);
        System.debug('Brand:::'+brand);
        System.debug('Toggle:::'+toggle);
        String searchQuery = '%'+strQuery+'%';
        Id singleBarrelProofSpecific = SBP_Constants.SINGLE_BARREL_PROOF_SPECIFIC_RT_ID;
        Id singleBarrelStandard = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        Id singleBarrelSplitBarrel = SBP_Constants.SINGLE_BARREL_SPLIT_BARREL_RT_ID; 
        Id singleBarrelLaphroaigCask = SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID;
        List<Case> listCaseRecords = new List<Case>();
        String soqlQuery = '';
        soqlQuery += 'SELECT Id,Retail_Account__r.State__c,CaseNumber,Regional_Diplomat__r.Name,Brand__c,Status,Type,CreatedDate,Submitter__r.Name,Barrel_Selected__c,Barrel_Selected_Date__c,Purchase_Order_Uploaded__c,Purchase_Order_Number__c,POS_Items_Selected__c,STO_Created__c,Bottle_Text_Entered__c, Account.Name, Retail_Account__r.Name FROM Case'
            + ' WHERE (RecordTypeId =: singleBarrelProofSpecific OR RecordTypeId =: singleBarrelStandard OR RecordTypeId =: singleBarrelSplitBarrel OR RecordTypeId =: singleBarrelLaphroaigCask) '
            +   ' AND Status Not IN (\'Closed\',\'Closed - Abandoned\',\'Canceled\',\'Cancelled-Allocation\',\'Cancelled - Kit Not Selected\')';
        
        if(getUserType() == 'Plant Team Member'){
            soqlQuery += ' AND Brand__c =\'Makers Mark\' ';          
            soqlQuery += ' AND Type = \'Trip and Tour\' ';
        } 
        
        if(toggle){
            System.debug('---Inside Toggle---');
            soqlQuery += ' AND (Barrel_Selected__c = false OR Purchase_Order_Uploaded__c = false OR POS_Items_Selected__c = false OR Bottle_Text_Entered__c  = false OR STO_Created__c = false)';
        }
        
        if(brand != null || !String.isEmpty(brand) && (getUserType() != 'Plant Team Member')){
            System.debug('---Inside Brand---');
            soqlQuery += ' AND Brand__c =:brand';
        }
        
        //Gregs Test change start
        /*User loggedInUser = fetchUser();
String[] gregsUserList = new String[]{'Elba Giron','Josh Pearson','Kristi Marski'}; 
String makersMarkBrand = SBP_Constants.BRAND_MAKERS_MARK;
if(brand == null && !gregsUserList.contains(loggedInUser.Name)){
soqlQuery += ' AND Brand__c != :makersMarkBrand';
}*/
        //Gregs Test change end
        
        if(getUserType() != 'State Manager' && getUserType() != 'Plant Team Member')
        {
            soqlQuery += ' AND My_Case__c = True';
        }
        if(getUserType() == 'State Manager')
        {
            List<String> s = getStates();
            soqlQuery += ' AND Retail_Account__r.State__c IN:s ';
        }
        if(selectedStates != null && selectedStates.size()>0 && getUserType() == 'Heritage Manager'){
            System.debug('---Inside State---');
            soqlQuery += ' AND Retail_Account__r.State__c IN:selectedStates';
            System.debug('soql'+soqlQuery);
        }
        if(!String.isBlank(strQuery)){
            System.debug('---Inside SearchQuery---');
            if(getUserType() == 'Heritage Manager')
                soqlQuery +=  ' AND (CaseNumber like \'' +searchQuery + '\' OR Account.Name like \'' +searchQuery + '\' OR Retail_Account__r.Name like \'' +searchQuery + '\' OR Submitter__r.Name like \'' +searchQuery + '\' OR Regional_Diplomat__r.Name like \'' +searchQuery + '\')';
            else
                soqlQuery +=  ' AND (CaseNumber like \'' +searchQuery + '\' OR Account.Name like \'' +searchQuery + '\' OR Retail_Account__r.Name like \'' +searchQuery + '\' OR Submitter__r.Name like \'' +searchQuery + '\')';
        }
        soqlQuery += ' ORDER BY CreatedDate DESC limit '+ Limits.getLimitQueryRows();
        System.debug('SOQL:::'+soqlQuery);
        listCaseRecords = Database.Query(soqlQuery);
        
        return listCaseRecords;
        
    }
    /*
Author:         Yash Jain
Company:        Metacube
Description:    it is used to find user type of current user

History
<Date>           <Authors Name>    <Brief Description of Change>
05,2021    Yash Jain      finding user type of current user
*/ 
    @AuraEnabled 
    public static String getUserType(){ 
        List<User> loggedInUser =  [Select Id,User_Type__c from User where Id = :UserInfo.getUserId()];
        List<PermissionSetAssignment> superUser = [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Single_Barrel_Super_Heritage_Manager_Permission' and AssigneeId = :UserInfo.getUserId()];
        if(!superUser.isEmpty())
            return 'Super Heritage Manager';
        if(!loggedInUser.isEmpty())
            return loggedInUser[0].User_Type__c;
        else
            return null;
    }
    
    //method to get regional diplomat regions for a user
    @AuraEnabled 
    public static List <String> getStates(){ 
        List<User> loggedInUser =  [Select Id,User_Type__c,Represented_States__c from User where Id = :UserInfo.getUserId()];
        String regionString = loggedInUser[0].Represented_States__c;
        if(regionString != null)
        {
            List<String > states = regionString.split(';');
            List<String> stateList = new List<String>();
            for(String state: states) {
                stateList.add(state);
            }
            stateList.sort();
            return stateList;
        }
        return null;
    }
    
    //Gregs Test changes start
    /*@AuraEnabled 
public static user fetchUser(){
User u = [select id,Name,UserName from User where id =: userInfo.getUserId()];
return u;
}*/
    //Gregs Test changes start
    
}