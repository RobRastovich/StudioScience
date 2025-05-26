public class SLT_Account_Application {
    /**
    *  @description : This method is use to fetch Account Application by AccountId, Brand, Status.
    *  @args        : Id accountId, String brand, String status
    *  @return      : List<Account_Application__c>
    *  Author      :  Nishant Khandal LSB-7
    **/
    public static List<Account_Application__c> getAccountAppByAccountBrandStatus(Id accountId, String brand, 
                                                                                              String status){
        List<Account_Application__c> getAccountApplications = new List<Account_Application__c>();
        getAccountApplications = [SELECT ID, Status__c, 
                                    (SELECT ID, Answer_Text__c, Application_Question__c 
                                    FROM Application_Responses__r) 
                                    FROM Account_Application__c 
                                    WHERE Account__c = :Id.valueOf(accountId) AND 
                                    Brand__c =: brand AND Status__c =: status 
                                    LIMIT 1];
        return getAccountApplications;
    }
     //added by nishant khandal for LSB-69
     public static Account_Application__c getAccountApplicationByCaseId(String recordId) {
        Account_Application__c app = [SELECT Id, Submitter__c 
                                        FROM Account_Application__c 
                                        WHERE Case__c =: recordId];
        if(app != null) {
            return app;
        }
        return null;
    }
}