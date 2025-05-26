public without sharing class SBP_AccountApplicationCmpCtrl {
    
    /**************************************************************************************************************
Author:         Craig Austgen
Company:        Slalom, LLC
Description:    Checks to see if an application has already been submitted for this particular account
Inputs:         accountId : Id of the account an application is being created for
brand     : selected single barrel program brand
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getAccountStatus(String accountId, String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean accountPendingApproval = false;
        Boolean accountApproved = false;
        
        try {
            Account acct = [select Id, ShippingState, BillingState from Account where Id = : Id.valueOf(accountId) limit 1];
            for (Account_Application__c acctApp : [select id, Status__c from Account_Application__c where Account__c = :acct.Id AND Brand__c = :brand]) {
                if (acctApp.Status__c == 'Pending Approval') {
                    accountPendingApproval = true;
                }
                if (acctApp.Status__c == 'Approved') {
                    accountApproved = true;
                }
            }
            
            responseMap.put('accountPendingApproval', accountPendingApproval);
            responseMap.put('accountApproved', accountApproved);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    @AuraEnabled
    public static String getSObjectName(Id recordId) {
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        return sobjectType;
    }
    
    /**************************************************************************************************************
Author:         Craig Austgen
Company:        Slalom, LLC
Description:    For certain programs users must be appoved before they can participate in the program.  This 
method inserts the application they fill out which is sent to various people for approval via
an approval process
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation
1/2020      Jai Kumar Garg      Modified for SCTASK0016153
***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus insertAccountApplication(String questionMap, String jsonApplications,String userId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Account_Application__c app = new Account_Application__c();
        System.debug(jsonApplications);
        
        try {
            Account acct = [select id from Account where Name = 'Single Barrel International Account'];
            // build application
            List<Account_Application__c> applications = (List<Account_Application__c>)System.JSON.deserialize(jsonApplications, List<Account_Application__c>.Class);
            app = applications[0];
            
            app.Name = UserInfo.getName() + ' - ' + System.now();
            app.Status__c = 'New';
            app.Submitter__c = UserInfo.getUserId();
            app.Diplomat_Partner_for_Your_Barrel__c = (userId==null) ? null : Id.valueOf(userId); //Added by ajeeta
            app.Regional_Diplomat__c = userId == null ? null : Id.valueOf(userId);
            if(app.Brand__c == 'Baker\'s'){
                List<User> lstUser = [Select Id from User where username =: Single_Barrel_Bakers_Diplomat__c.getOrgDefaults().User_Name__c limit 1];
                if(!lstUser.isEmpty()){
                    app.Diplomat_Partner_for_Your_Barrel__c = lstUser[0].Id;
                    app.Regional_Diplomat__c = lstUser[0].Id;
                }
            }
            if (app.Account__c == null) {
                app.Account__c = acct.Id;
                app.Account_Missing__c = true;
            }
            
            insert app;
            // create responses
            List<Application_Response__c> responses = (List<Application_Response__c>)System.JSON.deserialize(questionMap, 
                                                          List<Application_Response__c>.Class);
            for (Application_Response__c ar : responses) {
                ar.Account_Application__c = app.Id;
            }
            insert responses;
            
            // update account application to kick of approval process
            app.Status__c = 'Pending Approval';
            //DI-193
            String loggedInUserType = SBP_CaseSearchController.getUserType();
            if(userId == UserInfo.getUserId() && (loggedInUserType == 'Diplomat' || loggedInUserType == 'Heritage Manager')){
                app.Status__c = 'Approved';
            }
            update app;
            responseMap.put('accountApplication', app);
            responseMap.put('questionMap', questionMap);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
            
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, 
                                                                    responseMap);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:         Craig Austgen
Company:        Slalom, LLC
Description:    If the account has already completed an application then they will not have to answer
the questions again, they will be pulled from the previous application and sent to
the regional diplomat.
Inputs:         accountId : Id of the account an application is being created for
brand     : selected single barrel program brand
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus sendRequestWithPreviousAnswers(String accountId, String brand, 
                                                                                            String distributorAccountId, 
                                                                                            String distributorContactId, 
                                                                                            String NationalAccountFlag,
                                                                                         	String ConciergeAccountFlag,
                                                                                            String userId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Application_Response__c> responses = new List<Application_Response__c>();
        
        try {
            List<Application_Question_Set__c> appQuestionSet = [select id, name, Brand__c 
                                                                   from Application_Question_Set__c 
                                                                   where Brand__c = :brand limit 1];
            
            Account_Application__c accountApplication = new Account_Application__c();
            accountApplication.Name = UserInfo.getName() + ' - ' + System.now();
            accountApplication.Account__c = Id.valueOf(accountId);
            accountApplication.Submitter__c = UserInfo.getUserId();
            accountApplication.Application_Question_Set__c = appQuestionSet[0].Id;
            accountApplication.Status__c = 'New';
            accountApplication.Brand__c = brand;
            //Added by sripal on 08/03 for national account flag update
            if(NationalAccountFlag=='Yes'){
                accountApplication.National_Account_flag__c = true;
                if(ConciergeAccountFlag=='Yes'){
            		accountApplication.Concierge_Barrel_Flag__c = true;
                }
                else {
                    accountApplication.Concierge_Barrel_Flag__c = false;
                }
            }
            accountApplication.Distributor_Account__c = (distributorAccountId==null) ? null : Id.valueOf(distributorAccountId);
            accountApplication.Distributor_Contact__c = (distributorContactId==null) ? null : Id.valueOf(distributorContactId);
            accountApplication.Diplomat_Partner_for_Your_Barrel__c = (userId==null) ? null : Id.valueOf(userId);  //Added by ajeeta
            accountApplication.Regional_Diplomat__c = userId == null ? null : Id.valueOf(userId);
            if(accountApplication.Brand__c == 'Baker\'s'){
                List<User> lstUser = [Select Id from User where username =: Single_Barrel_Bakers_Diplomat__c.getOrgDefaults().User_Name__c limit 1];
                if(!lstUser.isEmpty()){
                    accountApplication.Diplomat_Partner_for_Your_Barrel__c = lstUser[0].Id;
                    accountApplication.Regional_Diplomat__c = lstUser[0].Id;
                }
            }
            insert accountApplication;
            for (Account_Application__c acctApp : [select id, Status__c, 
                                                   (Select Id, Answer_Text__c, Application_Question__c from Application_Responses__r) 
                                                   from Account_Application__c 
                                                   where Account__c = :Id.valueOf(accountId) AND 
                                                   Brand__c = :brand AND Status__c = 'Approved' limit 1]) {
                                                       for (Application_Response__c appResponse : acctApp.Application_Responses__r) {
                                                           Application_Response__c clonedResponse = appResponse.clone();
                                                           clonedResponse.Account_Application__c = accountApplication.Id;
                                                           responses.add(clonedResponse);
                                                       }
                                                   }
            
            insert responses;
            
            accountApplication.Status__c = 'Pending Approval';
            
            String loggedInUserType = SBP_CaseSearchController.getUserType();
            if(userId == UserInfo.getUserId() && (loggedInUserType == 'Diplomat' || loggedInUserType == 'Heritage Manager')){
                accountApplication.Status__c = 'Approved';
            }
            System.debug('accountApplication-->'+accountApplication);
            
            update accountApplication;
            
            responseMap.put('accountApplication', accountApplication);
            responseMap.put('responses', responses);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
            
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, 
                                                                    responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus sendRequestWithPreviousAnswersForMM(String jsonApplications,String userId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Application_Response__c> responses = new List<Application_Response__c>();
        Account_Application__c app = new Account_Application__c();
        System.debug(jsonApplications);
        
        try {
            Account acct = [select id from Account where Name = 'Single Barrel International Account'];
            // build application
            List<Account_Application__c> applications = (List<Account_Application__c>)System.JSON.deserialize(jsonApplications, 
                                                            List<Account_Application__c>.Class);
            
            app = applications[0];
            app.Name = UserInfo.getName() + ' - ' + System.now();
            app.Status__c = 'New';
            app.Submitter__c = UserInfo.getUserId();
            app.Diplomat_Partner_for_Your_Barrel__c = (userId==null) ? null : Id.valueOf(userId); //Added by ajeeta
            app.Regional_Diplomat__c = userId == null ? null : Id.valueOf(userId);
            if(app.Brand__c == 'Baker\'s'){
                List<User> lstUser = [Select Id from User where username =: Single_Barrel_Bakers_Diplomat__c.getOrgDefaults().User_Name__c limit 1];
                if(!lstUser.isEmpty()){
                    app.Diplomat_Partner_for_Your_Barrel__c = lstUser[0].Id;
                    app.Regional_Diplomat__c = lstUser[0].Id;
                }
            }
            if (app.Account__c == null) {
                app.Account__c = acct.Id;
                app.Account_Missing__c = true;
            }
            
            insert app;
            
            for (Account_Application__c acctApp : [select id, Status__c, 
                                                   (Select Id, Answer_Text__c, Application_Question__c 
                                                   from Application_Responses__r) 
                                                   from Account_Application__c 
                                                   where Account__c = :Id.valueOf(app.Account__c) AND Brand__c = 'Makers Mark' 
                                                   AND Status__c = 'Approved' limit 1]) {
                                                       for (Application_Response__c appResponse : acctApp.Application_Responses__r){
                                                           Application_Response__c clonedResponse = appResponse.clone();
                                                           clonedResponse.Account_Application__c = app.Id;
                                                           responses.add(clonedResponse);
                                                       }
                                                   }
            insert responses;
            
            // update account application to kick of approval process
            app.Status__c = 'Pending Approval';
            //DI-193
            String loggedInUserType = SBP_CaseSearchController.getUserType();
            if(userId == UserInfo.getUserId() && (loggedInUserType == 'Diplomat' || loggedInUserType == 'Heritage Manager')){
                app.Status__c = 'Approved';
            }
            
            update app;
            
            responseMap.put('accountApplication', app);
            responseMap.put('responses', responses);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
            
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, 
                                                                    responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    
    /**************************************************************************************************************
Author:         Craig Austgen
Company:        Slalom, LLC
Description:    pulls in the application questions
Inputs:         brand     : selected single barrel program brand
isInternational  : true if it is Makers Mark International ,else false
recordId : recordId of current account application
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation
5/2021      Yash Jain           Modified for Question Answer Map
***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getAccountApplicationData(String brand, Boolean isInternational,
                                                                                       Id recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Application_Question_Set__c> appQuestionSet = new List<Application_Question_Set__c>();
        Map<Id,String> appQuestionAnswer = new Map<Id,String>();
        
        //Added by Nishant Khandal
        Map<String, Map<String, String>> 
            mapHoldParentQuestioWithAnswerWithChildQuestion = new Map<String, Map<String, String>>();
        try {
            
            Map<String, List<String>> picklistValues = SBP_AccountInfoCmpCtrl.getSingleBarrelPicklistValues();
            
            if (isInternational && brand == 'Makers Mark') {
                appQuestionSet = [select id, name, Brand__c from Application_Question_Set__c where 
                                     Name = 'Makers Mark International' limit 1];
            } else {
                appQuestionSet = [select id, name, Brand__c from Application_Question_Set__c where Brand__c = :brand limit 1];
            }
            
            //Added by Nishant Khandal Application_Question__c and inner query of Application_Questions__r LSB-7
            List<Application_Question__c> appQuestions = [SELECT ID, (SELECT ID, Parent_Answer__c FROM Application_Questions__r ),
                                                             Application_Question__c, 
                                                          Question__c, Application_Question_Set__c, Order__c, Type__c, 
                                                          (select id, Answer__c, Order__c from Application_Answers__r 
                                                          order by Order__c asc) 
                                                          FROM Application_Question__c 
                                                          WHERE Application_Question_Set__c = :appQuestionSet[0].Id 
                                                          order by Order__c asc];
            //Added by Nishant Khandal LSB-7
            for(Application_Question__c appQues : appQuestions){
                if(appQues.Application_Question__c == null && !appQues.Application_Questions__r.isEmpty()){
                    mapHoldParentQuestioWithAnswerWithChildQuestion.put(appQues.Id, new Map<String, String>());
                    mapHoldParentQuestioWithAnswerWithChildQuestion.get(appQues.Id).put(appQues.Application_Questions__r[0].
                    Parent_Answer__c, String.valueof(appQues.Application_Questions__r[0].Id));
                }
            }
            //End By Nishant Khandal
            for(Application_Response__c s: [Select id,Answer_Text__c,Application_Question__c,Question_Text__c from 
                                               Application_Response__c where Account_Application__c =: recordId])
            {
                appQuestionAnswer.put(s.Application_Question__c,s.Answer_Text__c);
            }
             responseMap.put('appQuestionSet', appQuestionSet);
            responseMap.put('appQuestionAnswer', appQuestionAnswer);
            responseMap.put('appQuestions', appQuestions);
            responseMap.put('questionSetId', appQuestionSet[0].Id);
            responseMap.put('picklistValues', picklistValues);
            responseMap.put('mapHoldParentQuestioWithAnswerWithChildQuestion', 
                            mapHoldParentQuestioWithAnswerWithChildQuestion);//Added by Nishant Khandal LSB-7
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
            
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, 
                                                                    responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    /**************************************************************************************************************
Author:         Craig Austgen
Company:        Slalom, LLC
Description:    checks to see whether or not the selected brand program is available
Inputs:         brand     : selected single barrel program brand

History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus isProgramAvailable(String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean isActiveProgram = true;
        
        try {
            List<Time_Interval__c> timeIntervals = [select id from Time_Interval__c where Brand__c = :brand and isActive__c = true and Application_Deadline__c > TODAY];
            if (timeIntervals.isEmpty()) {
                isActiveProgram = false;
            }
            
            responseMap.put('isActiveProgram', isActiveProgram);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getStackTraceString());
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
        }
        
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
        /*
Author:			Naman Jangid
Company:		Metacube
Description:	it is used to fetch HM name from diplomatic hierarchy object

History
<Date>           <Authors Name>    <Brief Description of Change>
05,2021    Naman Jangid       fetching HM name 
*/
    @AuraEnabled
    public static sObject getHeritageManager(String userId){       
        String hmUserId = userId;      
        List<Diplomatic_Hierarchy__c> hierarchyList = new  List<Diplomatic_Hierarchy__c>();
        List<Diplomatic_Hierarchy__c> hierarchyManagerList = new  List<Diplomatic_Hierarchy__c>();
        hierarchyList = [SELECT Diplomat__r.Name,Diplomat__c,Id,Manager__r.Name,Manager__c,Name,User_Type__c FROM Diplomatic_Hierarchy__c WHERE Diplomat__c = :userId];       
        if(!hierarchyList.isEmpty()){                      
            if(hierarchyList.size() == 1) {
                hmUserId = hierarchyList[0].Manager__r.Id;                
            }else{                                   
                return null;
            }           
        }
        if(hierarchyList.isEmpty()){          
            hierarchyManagerList = [SELECT Diplomat__r.Name,Diplomat__c,Id,Manager__r.Name,Manager__c,Name,User_Type__c FROM Diplomatic_Hierarchy__c WHERE Manager__c = :userId];              
        }
        if(!hierarchyManagerList.isEmpty()){           
            hmUserId = hierarchyManagerList[0].Manager__r.Id;                
        } 
        List<User> userHM = [SELECT Id, Name, Email from User where Id  = :hmUserId];        
        if(!userHM.isEmpty()){                                 
            return userHM[0];
        }                
        return null;
    }
        /*
    Author:			Nishant Khandal
    Company:		Metacube
    Description:	This method insert Account Application record when brand was
                    selected as Laphroaig Single Cask
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    07,2022          Nishant Khandal     
    */
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus insertAccountApplicationForLSC(String questionMap, 
                                                                                         String jsonApplications,
                                                                                         String userId){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Account_Application__c> applications = new List<Account_Application__c>();
        List<User> users = new List<User>();
        Account_Application__c app = new Account_Application__c();
        try {
            Account acct = SLT_Account.getAccountsByName(SBP_Constants.SINGLE_BARREL_INT_ACCOUNT);
            // build application
            If(jsonApplications != null){
                applications = (List<Account_Application__c>)System.JSON.deserialize
                                   (jsonApplications, List<Account_Application__c>.Class);
            }
            if(!applications.isEmpty())
                app = applications[0];
            String username = SLT_SBP_SBP_Approvers_CS.getUsernameOfApprovers(SBP_Constants.LAPHROAIG_SINGLE_CASK);
            if(!String.isEmpty(username)){
                users = SLT_User.getUserDetailUsername(username);
            }
            app.Name = UserInfo.getName() + ' - ' + System.now();
            app.Status__c = SBP_Constants.NEW_STATUS;
            app.Submitter__c = UserInfo.getUserId();
            app.Diplomat_Partner_for_Your_Barrel__c = (users.size() > 0) ? users[0].Id : null;
            app.Regional_Diplomat__c = (users.size() > 0) ? users[0].Id : null;
            if(users.size() > 0){
                app.Heritage_Manager__c = SBP_AccountApplicationCmpCtrl.getHeritageManager(users[0].Id).Id;
            }
            if (app.Account__c == null) {
                if(acct != null)
                    app.Account__c = acct.Id;
                app.Account_Missing__c = true;
            }
            insert app;
            List<Application_Response__c> responses = (List<Application_Response__c>)System.JSON.deserialize(questionMap, 
                                                          List<Application_Response__c>.Class);
            for (Application_Response__c ar : responses) {
                ar.Account_Application__c = app.Id;
            }
            if(!responses.isEmpty()){
                insert responses;
            }
            // update account application to kick of approval process
            app.Status__c = SBP_Constants.ACCOUNT_APPLICATION_STATUS_PENDING;
            String loggedInUserType = SBP_CaseSearchController.getUserType();
            if(userId == UserInfo.getUserId() && (loggedInUserType == SBP_Constants.USER_TYPE_DIPLOMAT || 
                loggedInUserType == SBP_Constants.USER_TYPE_HERITAGE_MANAGER)){
                app.Status__c = SBP_Constants.ACCOUNT_APPLICATION_STATUS_APPROVED;
            }
            update app;
            responseMap.put('accountApplication', app);
            responseMap.put('questionMap', questionMap);
        } catch (Exception e) {
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, 
                                                                    responseMap);
        return requestStatus;
    }
    
    /*
    Author:			Nishant Khandal
    Company:		Metacube
    Description:	This method insert Account Application record when brand was
                    selected as Laphroaig Single Cask and attached previous Question sets.
    History
    <Date>           <Authors Name>    <Brief Description of Change>
    07,2022          Nishant Khandal     
    */
    
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus sendRequestWithPreviousAnswersForLSC(String jsonApplications, 
                                                                                               String userId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Application_Response__c> responses = new List<Application_Response__c>();
        List<Account_Application__c> applications = new List<Account_Application__c>();
        List<User> users = new List<User>();
        Account_Application__c app = new Account_Application__c();
        try {
            Account acct = SLT_Account.getAccountsByName(SBP_Constants.SINGLE_BARREL_INT_ACCOUNT);
            // build application
            if(jsonApplications != null){
                applications = (List<Account_Application__c>)System.JSON.deserialize
                                   (jsonApplications, List<Account_Application__c>.Class); 
            }
            if(!applications.isEmpty())
                app = applications[0];
            String username = SLT_SBP_SBP_Approvers_CS.getUsernameOfApprovers(SBP_Constants.LAPHROAIG_SINGLE_CASK);
            if(!String.isEmpty(username)){
                users = SLT_User.getUserDetailUsername(username);
            }
            app.Name = UserInfo.getName() + ' - ' + System.now();
            app.Status__c = SBP_Constants.NEW_STATUS;
            app.Submitter__c = UserInfo.getUserId();
            app.Diplomat_Partner_for_Your_Barrel__c = (users.size() > 0) ? users[0].Id : null;
            app.Regional_Diplomat__c = (users.size() > 0) ? users[0].Id : null;
            if(users.size() > 0){
                app.Heritage_Manager__c = SBP_AccountApplicationCmpCtrl.getHeritageManager(users[0].Id).Id;
            }
            if (app.Account__c == null) {
                if(acct != null)
                    app.Account__c = acct.Id;
                app.Account_Missing__c = true;
            }
            insert app;
            if(app.Account__c != null){
                List<Account_Application__c> accountApplications = SLT_Account_Application.getAccountAppByAccountBrandStatus(
                                                                   Id.valueOf(app.Account__c), 
                                                                   SBP_Constants.LAPHROAIG_SINGLE_CASK,
                                                                   SBP_Constants.ACCOUNT_APPLICATION_STATUS_APPROVED);
                if(!accountApplications.isEmpty()){
                    for(Account_Application__c acctApp : accountApplications){
                        for(Application_Response__c appResponse : acctApp.Application_Responses__r){
                            Application_Response__c clonedResponse = appResponse.clone();
                            clonedResponse.Account_Application__c = app.Id;
                            responses.add(clonedResponse); 
                        }
                    }
                }
                if(!responses.isEmpty()){
                    insert responses;
                }
            }
            // update account application to kick of approval process
            app.Status__c = SBP_Constants.ACCOUNT_APPLICATION_STATUS_PENDING;
            String loggedInUserType = SBP_CaseSearchController.getUserType();
            if(userId == UserInfo.getUserId() && (loggedInUserType == SBP_Constants.USER_TYPE_DIPLOMAT || 
                loggedInUserType == SBP_Constants.USER_TYPE_HERITAGE_MANAGER)){
                app.Status__c = SBP_Constants.ACCOUNT_APPLICATION_STATUS_APPROVED;
            }
            update app;
            responseMap.put('accountApplication', app);
            responseMap.put('responses', responses);
        } catch (Exception e) {
            message = e.getMessage() + ' \n ' + e.getStackTraceString();
            success = false;
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, 
                                                                    responseMap);
        return requestStatus;
    }
}