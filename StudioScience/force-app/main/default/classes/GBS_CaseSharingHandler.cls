/**************************************************************************************************************
    Description:	Handles sharing of GBS Cases.  Primary criteria driving visibility is the GBS Center
                    for the Case and the Type (Payroll vs. Non-Payroll).  Based on these, a CaseShare
                    is created and thus opens up the visibility to that Case by sharing it with the
                    appropriate Public Group.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    8/2019     	Connor Gallaher    Initial Creation

***************************************************************************************************************/

public without sharing class GBS_CaseSharingHandler {

    /**
    * Entry point for GBS_CaseSharingHandler class.  Does initial processing around what cases to handle
    * and creates CaseShare objects for each case.
    **/
    public static void shareCaseWithGroup(List<Case> cases) {

        //Only want to process GBS Cases
        List<Case> casesToShare = new List<Case>();
        Set<Id> submitterIds = new Set<Id>();
        for (Case c : cases) {
            // 11-11-2020 ref: Jira story #SAL-420 -- commented by #Arun Sharma
            casesToShare.add(c);
            if (c.Submitter__c != null) {
                submitterIds.add(c.Submitter__c);
            }
        }
        
        //No cases to process, so break.
        if (casesToShare.isEmpty()) {
            return;
        }

        //Get Map of the Id -> User for the Submitters for each case
        Map<Id, User> subIdToSubmitter = new Map<Id, User>([SELECT Id, Country FROM User WHERE Id IN :submitterIds AND Country != null]);
    
        Map<String, Id> groupNameToGroupId = getGBSPublicGroups();

        //Need to delete old CaseShare(s), if applicable
        deleteOldCaseShares(casesToShare, groupNameToGroupId.values());
        
        Map<String, String> sharingExceptions = buildSharingExceptionsMap();

        List<CaseShare> caseShares = new List<CaseShare>();
        for (Case caseToShare : casesToShare) {
            //Create CaseShare obj
            CaseShare cs = new CaseShare();
            cs.CaseId = caseToShare.Id;
            cs.UserOrGroupId = getGroupIdForCaseShare(sharingExceptions, groupNameToGroupId, caseToShare.GBS_Center__c, caseToShare.Type, caseToShare.Category_1__c, subIdToSubmitter.get(caseToShare.Submitter__c));
            cs.CaseAccessLevel = 'Edit';
            cs.RowCause = Schema.CaseShare.RowCause.Manual;
			caseShares.add(cs);
            
            // 11-11-2020 ref: Jira story #SAL-420 -- added by #Arun Sharma
            // It concludes the case is being shared and will never picked up through scheduler class. 
            caseToShare.GBS_Sharing__c = true;
        }
        //So that if there is a bad CaseShare, the rest can still get inserted.
        Database.SaveResult[] insertedResults = Database.insert(caseShares, false);
        // 11-11-2020 ref: Jira story #SAL-420 -- added by #Arun Sharma
        //if there is a bad Case, the rest can still get updated.
        Database.SaveResult[] updateResults = Database.update(casesToShare, false);

        //Check successes/failures.
        DatabaseTransactionHandler(insertedResults);
        DatabaseTransactionHandler(updateResults);
    }

    // 11-11-2020 ref: Jira story #SAL-420 -- added by #Arun Sharma
    public static void DatabaseTransactionHandler(Database.SaveResult[] results){

        List<Custom_Exception_Logs__c> exceptionLogs = new List<Custom_Exception_Logs__c>();

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted/updated operation on CaseShare/Case object resp. : ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors   
                String errorMessage;
                for (Database.Error err : sr.getErrors()) {
                    errorMessage = 'Error: ' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                    errorMessage = 'Caused by field(s): \n';
                    for (String errorField : err.getFields()) {
                        errorMessage += errorField;
                        errorMessage += '\n';
                    }
                }
                Custom_Exception_Logs__c exceptionLog = CreateExceptionLog.createExceptionLog('GBS_CaseSharingHandler', 'shareCaseWithGroup', String.valueOf(errorMessage), 'Fatal', false);
                exceptionLogs.add(exceptionLog);
            }
        }

        if (!exceptionLogs.isEmpty()) {
            insert exceptionLogs;
        }
    }
    
    /**
    * Returns Map of the Group Name to the Group Id for the new GBS Public Groups
    * which are used to share with and thus open up visibility to the right users.
    **/
    public static Map<String, Id> getGBSPublicGroups() {
        Map<String, Id> groupNameToGroupId = new Map<String, Id>();
        for (Group g : [SELECT Id, Name From Group WHERE Name LIKE 'GBS:%']) {
            groupNameToGroupId.put(g.Name, g.Id);
        }
        return groupNameToGroupId;
    }

    /**
    * Deletes old Share objects for Cases which are shared with one of the GBS Public Groups.
    **/
    public static void deleteOldCaseShares(List<Case> cases, List<Id> groupIds) {
        //Delete old manual, GBS CaseShares for Case, if applicable
        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
        }
        if (!caseIds.isEmpty()) {
            List<CaseShare> oldGBSCaseShares = [SELECT Id, CaseId, UserOrGroupId FROM CaseShare WHERE (CaseId IN :caseIds AND UserOrGroupId IN :groupIds)];
            if (!oldGBSCaseShares.isEmpty()) {
                try {
                    delete oldGBSCaseShares;
                }
                catch (DMLException ex) {
                    String errorMessage = 'Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString();
            		CreateExceptionLog.insertErrorLog('GBS_CaseSharingHandler', 'deleteOldCaseShares', String.valueOf(errorMessage), 'Fatal');
                }
            }
        }
    }

    /**
    * Returns the Id of the GBS Public Group for which the case will be shared, based on specific criteria of the Case.
    * Certain sharing exceptions exist; these are handled via Custom Metadata types.
    **/
    public static Id getGroupIdForCaseShare(Map<String, String> sharingExceptions, Map<String, Id> groupNameToGroupId, String gbsCenter, String type, String category1, User u) {
        
        if (u != null) {
            //Start with most detailed potential key
            String key = u.Country + ' ' + gbsCenter + ' ' + type + ' ' + category1;
            //2nd most detailed key
            String key2 = u.Country + ' ' + gbsCenter + ' ' + type;
            //3rd most detailed key
            String key3 = gbsCenter + ' ' + type + ' ' + category1;
            //4th most detailed key
            String key4 = gbsCenter + ' ' + type;
            //Check if the exception exists
            if (sharingExceptions.containsKey(key)) {
                return groupNameToGroupId.get(sharingExceptions.get(key));
            }
            else if (sharingExceptions.containsKey(key2)) {
                return groupNameToGroupId.get(sharingExceptions.get(key2));
            }
            else if (sharingExceptions.containsKey(key3)) {
                return groupNameToGroupId.get(sharingExceptions.get(key3));
            }
            else if (sharingExceptions.containsKey(key4)) {
                return groupNameToGroupId.get(sharingExceptions.get(key4));
            }
            //Non-exception, so use "standard" Payroll vs. Non-Payroll group
            else {
                if (type.equalsIgnoreCase(System.Label.Payroll)) {
                    return groupNameToGroupId.get('GBS: ' + gbsCenter + ' ' + type);
                }
                else {
                    return groupNameToGroupId.get('GBS: ' + gbsCenter + ' ' + 'Non-Payroll');
                }
            }
        }
        else {
            //No user country available, so try 3rd and 4th most detailed keys
            String key3 = gbsCenter + ' ' + type + ' ' + category1;
            String key4 = gbsCenter + ' ' + type;
            if (sharingExceptions.containsKey(key3)) {
                return groupNameToGroupId.get(sharingExceptions.get(key3));
            }
            else if (sharingExceptions.containsKey(key4)) {
                return groupNameToGroupId.get(sharingExceptions.get(key4));
            }
            //Non-exception, so use "standard" Payroll vs. Non-Payroll group
            else {
                if (type.equalsIgnoreCase(System.Label.Payroll)) {
                    return groupNameToGroupId.get('GBS: ' + gbsCenter + ' ' + type);
                }
                else {
                    return groupNameToGroupId.get('GBS: ' + gbsCenter + ' ' + 'Non-Payroll');
                }
            }
        }
    }

    /**
    * Queries the Sharing Exception custom metadata types and builds a map where the key is one of the following:
    * 1. Country + GBS Center + Team + Primary Category
    * 2. Country + GBS Center + Team
    * 3. GBS Center + Team + Primary Category
    * 4. GBS Center + Team
    * 
    * Returns a map of one of the above keys to the corresponding Group name, which is the group to be shared with. 
   	**/
    public static Map<String, String> buildSharingExceptionsMap() {
        Map<String, String> sharingExceptions = new Map<String, String>();
        for (GBS_Sharing_Exception__mdt sharingException : [SELECT Id, Countries__c, GBS_Center__c, GBS_Team__c, Primary_Category__c, GBS_Group__c FROM GBS_Sharing_Exception__mdt]) {
            String key;
            //Primary category is null value
            if (String.isBlank(sharingException.Primary_Category__c)) {
                //Country values exist for this record
                if (!String.isBlank(sharingException.Countries__c)) {
                    for (String country : sharingException.Countries__c.split(',')) {
                        key = country + ' ' + sharingException.GBS_Center__c + ' ' + sharingException.GBS_Team__c;
                        sharingExceptions.put(key, sharingException.GBS_Group__c);
                    }
                }
                //Country values do not exist for this record
                else {
                    key = sharingException.GBS_Center__c + ' ' + sharingException.GBS_Team__c;
                    sharingExceptions.put(key, sharingException.GBS_Group__c);
                }
            }
            //No Primary category value
            else {
                //Country values exist for this record
                if (!String.isBlank(sharingException.Countries__c)) {
                    for (String country : sharingException.Countries__c.split(',')) {
                        key = country + ' ' + sharingException.GBS_Center__c + ' ' + sharingException.GBS_Team__c + ' ' + sharingException.Primary_Category__c;
                        sharingExceptions.put(key, sharingException.GBS_Group__c);
                    }
                }
                //Country values do not exist for this record
                else {
                    key = sharingException.GBS_Center__c + ' ' + sharingException.GBS_Team__c + ' ' + sharingException.Primary_Category__c;
                    sharingExceptions.put(key, sharingException.GBS_Group__c);
                }
            }
        }
        return sharingExceptions;
    }
}