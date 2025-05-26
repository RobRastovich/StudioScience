/**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used for State managers application and case grid view in portal
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       application and case grid view for State managers

***************************************************************************************************************/
public class SBP_SMApplicationCmpCtrl {
    
                        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used to get list of cases based on user state
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       fetch list of cases based on user state

***************************************************************************************************************/
    @AuraEnabled
    public static List<Case> getSMCase() { 
        List<User> u = [Select id,Represented_States__c from User where id = :UserInfo.getUserId()];
        String states = u[0].Represented_States__c ;
        if(states != null){
            List<String> stateString = states.split(';');
            List<Case> cas = [Select id,CaseNumber,Retail_Account__r.State__c,Brand__C,Status,ClosedDate from Case where Retail_Account__r.State__c IN :stateString AND Status = 'Closed' AND ClosedDate = LAST_N_DAYS:60];
            return cas;
        }
        return null;
    }
    
                            /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used to get list of application based on user state
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       fetch list of applications based on user state

***************************************************************************************************************/
    
    @AuraEnabled
    public static List<Account_Application__c> getSMApplication() { 
        List<User> u = [Select id,Represented_States__c from User where id = :UserInfo.getUserId()];
        String states = u[0].Represented_States__c ;
        if(states != null){
            List<String> stateString = states.split(';');
            List<Account_Application__c> app = [Select id,State__C,Name,Brand__C,Status__C,Account__r.Name,CreatedDate from Account_Application__c where State__C IN :stateString order by CreatedDate DESC];
            return app;
        }
        return null;
    }
    
                            /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used to get community portal link
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       fetch portal link

***************************************************************************************************************/
    @AuraEnabled
    public static String fetchPortalLink()
    {
        String name = Label.Single_Barrel_Portal_Name;        
        Site site = [SELECT Id FROM Site WHERE Name = :name];
        SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :site.Id];
        return mySiteDetail.SecureURL;
    }
    
}