/**************************************************************************************
Apex Class Name     : caseServices
Created Date        : 1/2016
Function            : Methods called from the caseTriggerhandler handlers
*************************************************************************************/

public class caseServices {
    
    public static string testDay;
    public static Integer thirdPartyExecutionCount = 0;
    //A cached stop status set that will not be re-queried if already populated
    public static Set<String> staticStopStatusSet = new Set<String>();
    public static Set<String> closedStatusSet = new Set<String>();
    // added to reduce recursion
    public static Boolean runTrigger = true;
    public static Boolean eskerEmailSent = false;
    public static Entitlement orderClaimEntitlement;
    
    public static Map <String, BusinessHours> businessHoursMap = new Map <String, BusinessHours>();
    public static Map<String, SlaProcess> slaProcessMap = new Map<String, SlaProcess>();
    public static Boolean isRecursiveCall = false;
    
    public static Account defaultGBSAccount {
        get {
            if (defaultGBSAccount == null) {
                List<Account> accts = [select id from Account where name = :GBS_Constants.DEFAULT_ACCOUNT_NAME AND RecordTypeId = :GBS_Constants.vendorAccountRecordTypdId limit 1];
                if (!accts.isEmpty()) {
                    defaultGBSAccount = accts[0];
                }
            }
            return defaultGBSAccount;
        }
        set;
    }
    
    public static Map<String, BusinessHours> getBusinessHours() {
        if (businessHoursMap.isEmpty()) {
            for (BusinessHours bh : [select id, Name from BusinessHours]) {
                businessHoursMap.put(bh.Name, bh);
            }
        }
        return businessHoursMap;
    }
    
    /**************************************************************************************************************
Method name:    getSlaProcessMap
Object:         Entitlement Process(SlaProcess)
Date:           2/2018
Details and Notes: 
Get map of all the Entitlement processes
***************************************************************************************************************/
    public static Map<String, SlaProcess> getSlaProcessMap() {
        
        if (slaProcessMap.isEmpty()) {
            for (SlaProcess sla : [select id, Name, IsVersionDefault, IsActive from SlaProcess where IsActive = true AND IsVersionDefault = true]) {
                slaProcessMap.put(sla.Name , sla);
            }
        }
        
        return slaProcessMap;
    }
    
    /**************************************************************************************************************
Method name:    calculateBusinessHoursAgesOnInsert
Object:         Case
Date:           1/2016
Details and Notes:
Modification of the Case Age in Business Hours app from Salesforce Labs; calculates Start and End Times
on Case Creation
***************************************************************************************************************/
    
    public static void calculateBusinessHoursAgesOnInsert(List<Case> cases) {
        
        //Pull the default business hours
        BusinessHours bh = [Select Id, TimeZoneSidKey, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime From BusinessHours Where IsDefault = TRUE];
        Time BHStartTime;
        Time BHEndTime;
        
        for (Case updatedCase : cases) {
            updatedCase.Time_With_Customer__c = 0;
            updatedCase.Time_With_Support__c = 0;
            
            //Pull the timezone for the organization
            Timezone tz = Timezone.getTimeZone(bh.TimeZoneSidKey);
            
            //Pull the timezone for the current user
            String uTzId = UserInfo.getTimeZone().getID();
            Timezone tzU = Timezone.getTimeZone(uTzId);
            
            //Calculate the offset between organization's timezone and GMT
            Integer Offset = tz.getOffset(system.now());
            //Calculate the offset between current user's timezone and GMT
            Integer OffsetU = tzU.getOffset(system.now());
            
            //Calculate the offset between organization's and current user's timezones
            //Take ABS(A)-ABS(B); IF NEGATIVE, add the absolute value to formatted time; if POSITIVE, add the value (multiplied by -1)
            Integer tzDiff = math.abs(Offset / 3600000) - math.abs(OffsetU / 3600000);
            if (tzDiff < 1) {
                tzDiff = math.abs(tzDiff);
            } else {
                tzDiff = tzDiff * -1;
            }
            
            //Get next business day
            DateTime todaysDateGMT = system.now();
            DateTime nextStartDateGMT = BusinessHours.nextStartDate(bh.Id, todaysDateGMT);
            DateTime nextStartDate = nextStartDateGMT.addHours(Offset / 3600000);
            
            string day;
            
            if (Test.isRunningTest()) {
                day = testDay;
            } else {
                day = ((nextStartDateGMT).addHours(tzDiff)).format('u');
            }
            
            //Pull the business hours for the next business day
            if (day == '1') {
                BHStartTime = bh.MondayStartTime;
                BHEndTime = bh.MondayEndTime;
            } else if (day == '2') {
                BHStartTime = bh.TuesdayStartTime;
                BHEndTime = bh.TuesdayEndTime;
            } else if (day == '3') {
                BHStartTime = bh.WednesdayStartTime;
                BHEndTime = bh.WednesdayEndTime;
            } else if (day == '4') {
                BHStartTime = bh.ThursdayStartTime;
                BHEndTime = bh.ThursdayEndTime;
            } else if (day == '5') {
                BHStartTime = bh.FridayStartTime;
                BHEndTime = bh.FridayEndTime;
            } else if (day == '6') {
                BHStartTime = bh.SaturdayStartTime;
                BHEndTime = bh.SaturdayEndTime;
            } else {
                BHStartTime = bh.SundayStartTime;
                BHEndTime = bh.SundayEndTime;
            }
            
            if (BHStartTime != null && BHEndTime != null) {
                
                //Build SLA Start and End Times in GMT
                DateTime SLAStartTime = DateTime.newInstanceGMT(nextStartDateGMT.year(), nextStartDateGMT.month(), nextStartDateGMT.day(), BHStartTime.hour(), BHStartTime.minute(), 0);
                DateTime SLAEndTime = DateTime.newInstanceGMT(nextStartDateGMT.year(), nextStartDateGMT.month(), nextStartDateGMT.day(), BHEndTime.hour(), BHEndTime.minute(), 0);
                
                //Build SLA Start and End Times in organization's default timezone
                DateTime SLAStartTimeGMT = SLAStartTime.addHours(math.abs(Offset / 3600000));
                DateTime SLAEndTimeGMT = SLAEndTime.addHours(math.abs(Offset / 3600000));
                
                //Set the Case's SLA Start and End Times
                updatedCase.SLA_Start_Time__c = SLAStartTimeGMT;
                updatedCase.SLA_End_Time__c = SLAEndTimeGMT;
                
                if (system.now() < SLAStartTimeGMT) {
                    updatedCase.Last_Status_Change__c = SLAStartTimeGMT;
                } else {
                    updatedCase.Last_Status_Change__c = system.now();
                }
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    calculateBusinessHoursAgesOnUpdate
Object:         Case
Date:           1/2016
Details and Notes:
Modification of the Case Age in Business Hours app from Salesforce Labs; calculates Start and End Times
on Case Update (end of business day); update SLA clocks on status update.
***************************************************************************************************************/
    public static void calculateBusinessHoursAgesOnUpdate(List<Case> cases, Map<Id, Case> oldCases) {
        //Get the stop statuses
        Set<String> stopStatusSet = new Set<String>();
        for (Stop_Status__c stopStatus : [Select Name From Stop_Status__c]) {
            stopStatusSet.add(stopStatus.Name);
        }
        
        //Get the default business hours
        //BusinessHours defaultHours = [select Id from BusinessHours where IsDefault = true]; //Un-necessary SOQL commented as part of Code Optimization
        
        //Pull the default business hours
        BusinessHours bh = [Select Id, TimeZoneSidKey, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime From BusinessHours Where IsDefault = TRUE];
        Time BHStartTime;
        Time BHEndTime;
        
        //Get the closed statuses
        if (closedStatusSet.isEmpty()) {
            for (CaseStatus status : [Select MasterLabel From CaseStatus where IsClosed = true]) {
                closedStatusSet.add(status.MasterLabel);
            }
        }
        
        //At close of business each night, update the case with the next business day's SLA Start and End Times
        for (Case updatedCase : cases) {
            
            Case oldCase = oldCases.get(updatedCase.Id);
            
            //Is it the end of the business day?
            if (updatedCase.Update_SLA_Times__c == TRUE) {
                
                //Is the case still open?
                if (!oldCase.IsClosed) {
                    
                    //On the off-chance that the business hours on the case are null, use the default ones instead
                    Id hoursToUse = updatedCase.BusinessHoursId != null ? updatedCase.BusinessHoursId : bh.Id;
                    
                    if (updatedCase.SLA_Start_Time__c != null && updatedCase.SLA_End_Time__c != null) {
                        
                        //Find the time in business hours between last status change and tonight's close of business
                        Double timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, updatedCase.SLA_End_Time__c) / 3600000.0;
                        
                        //We decide which clock to add the time to depending on current case status
                        if (stopStatusSet.contains(oldCase.Status)) {
                            updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                        } else {
                            updatedCase.Time_With_Support__c += timeSinceLastStatus;
                        }
                        
                        if (closedStatusSet.contains(updatedCase.Status)) {
                            updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                        }
                    }
                }
                
                /*-- Code Commented as SOQL is inside FOR Loop
//Pull the default business hours
BusinessHours bh = [Select Id, TimeZoneSidKey, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime From BusinessHours Where IsDefault = TRUE];
Time BHStartTime;
Time BHEndTime;*/
                
                //Pull the timezone for the organization
                Timezone tz = Timezone.getTimeZone(bh.TimeZoneSidKey);
                
                //Pull the timezone for the current user
                String uTzId = UserInfo.getTimeZone().getID();
                Timezone tzU = Timezone.getTimeZone(uTzId);
                
                //Calculate the offset between organization's timezone and GMT
                Integer Offset = tz.getOffset(system.now());
                //Calculate the offset between current user's timezone and GMT
                Integer OffsetU = tzU.getOffset(system.now());
                
                //Calculate the offset between organization's and current user's timezones
                //Take ABS(A)-ABS(B); IF NEGATIVE, add the absolute value to formatted time; if POSITIVE, add the value (multiplied by -1)
                Integer tzDiff = math.abs(Offset / 3600000) - math.abs(OffsetU / 3600000);
                if (tzDiff < 1) {
                    tzDiff = math.abs(tzDiff);
                } else {
                    tzDiff = tzDiff * -1;
                }
                
                //Get next business day
                DateTime todaysDateGMT = system.now();
                DateTime nextStartDateGMT = BusinessHours.nextStartDate(bh.Id, todaysDateGMT);
                DateTime nextStartDate = nextStartDateGMT.addHours(Offset / 3600000);
                
                string day;
                
                if (Test.isRunningTest()) {
                    day = testDay;
                } else {
                    day = ((nextStartDateGMT).addHours(tzDiff)).format('u');
                }
                
                //Pull the business hours for the next business day
                if (day == '1') {
                    BHStartTime = bh.MondayStartTime;
                    BHEndTime = bh.MondayEndTime;
                } else if (day == '2') {
                    BHStartTime = bh.TuesdayStartTime;
                    BHEndTime = bh.TuesdayEndTime;
                } else if (day == '3') {
                    BHStartTime = bh.WednesdayStartTime;
                    BHEndTime = bh.WednesdayEndTime;
                } else if (day == '4') {
                    BHStartTime = bh.ThursdayStartTime;
                    BHEndTime = bh.ThursdayEndTime;
                } else if (day == '5') {
                    BHStartTime = bh.FridayStartTime;
                    BHEndTime = bh.FridayEndTime;
                } else if (day == '6') {
                    BHStartTime = bh.SaturdayStartTime;
                    BHEndTime = bh.SaturdayEndTime;
                } else {
                    BHStartTime = bh.SundayStartTime;
                    BHEndTime = bh.SundayEndTime;
                }
                
                if (BHStartTime != null && BHEndTime != null) {
                    
                    //Build SLA Start and End Times in GMT
                    DateTime SLAStartTime = DateTime.newInstanceGMT(nextStartDateGMT.year(), nextStartDateGMT.month(), nextStartDateGMT.day(), BHStartTime.hour(), BHStartTime.minute(), 0);
                    DateTime SLAEndTime = DateTime.newInstanceGMT(nextStartDateGMT.year(), nextStartDateGMT.month(), nextStartDateGMT.day(), BHEndTime.hour(), BHEndTime.minute(), 0);
                    
                    //Build SLA Start and End Times in organization's default timezone
                    DateTime SLAStartTimeGMT = SLAStartTime.addHours(math.abs(Offset / 3600000));
                    DateTime SLAEndTimeGMT = SLAEndTime.addHours(math.abs(Offset / 3600000));
                    
                    //Set the Case's SLA Start and End Times
                    updatedCase.SLA_Start_Time__c = SLAStartTimeGMT;
                    updatedCase.SLA_End_Time__c = SLAEndTimeGMT;
                    
                    //Set the Case's Last Status Change to the next business day's start time
                    updatedCase.Last_Status_Change__c = SLAStartTimeGMT;
                }
            }
        }
        
        //Whenever there is a status change, update the Case's SLA clocks
        for (Case updatedCase : cases) {
            Case oldCase = oldCases.get(updatedCase.Id);
            
            if (oldCase.Status != updatedCase.Status && updatedCase.Last_Status_Change__c != null) {
                if (!oldCase.IsClosed) {
                    
                    //On the off-chance that the business hours on the case are null, use the default ones instead
                    Id hoursToUse = updatedCase.BusinessHoursId != null ? updatedCase.BusinessHoursId : bh.Id;
                    
                    //Find the time in business hours between last status change and tonight's close of business
                    Double timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now()) / 3600000.0;
                    
                    //We decide which clock to add the time to depending on current case status
                    if (stopStatusSet.contains(oldCase.Status)) {
                        updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                    } else {
                        updatedCase.Time_With_Support__c += timeSinceLastStatus;
                    }
                    
                    if (closedStatusSet.contains(updatedCase.Status)) {
                        updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                    }
                }
                
                //Set the Case's Last Status Change Date to right now (the time of status change)
                if (system.now() >= updatedCase.SLA_Start_Time__c && system.now() <= updatedCase.SLA_End_Time__c) {
                    updatedCase.Last_Status_Change__c = system.now();
                }
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    setCaseValues
Object:         Case
Date:           4/2016
Details and Notes:
Sets the Case submitter's email to which workflow notifications should be delivered. Also set the case
lanuage
***************************************************************************************************************/
    public static void setCaseValues(List<Case> cases) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, User> contactIdToUser = new Map<Id, User>();
        
        for (Case c : cases) {
            if (c.ContactId != null) {
                contactIds.add(c.ContactId);
            }
        }
        
        if (!contactIds.isEmpty()) {
            for (User u : [select id, ContactId, Email, LanguageLocaleKey from User where ContactId IN :contactIds]) {
                contactIdToUser.put(u.ContactId, u);
            }
        }
        
        for (Case c : cases) {
            // set case Email
            if (String.isBlank(c.Automated_Notification_Email__c)) {
                if (c.SuppliedEmail != null) {
                    c.Automated_Notification_Email__c = c.SuppliedEmail;
                } else if (c.ContactId == null) {
                    c.Automated_Notification_Email__c = UserInfo.getUserEmail();
                    c.SuppliedEmail = UserInfo.getUserEmail();
                } else {
                    if (contactIdToUser.containsKey(c.ContactId)) {
                        if (String.isNotBlank(contactIdToUser.get(c.ContactId).Email)) {
                            c.Automated_Notification_Email__c = contactIdToUser.get(c.ContactId).Email;
                            c.SuppliedEmail = contactIdToUser.get(c.ContactId).Email;
                        }
                        
                    }
                }
            }
            // set case language
            if (String.isBlank(c.Case_Language__c)) {
                if (c.ContactId == null) {
                    c.Case_Language__c = UserInfo.getLocale();
                } else {
                    if (contactIdToUser.containsKey(c.ContactId)) {
                        c.Case_Language__c = contactIdToUser.get(c.ContactId).LanguageLocaleKey;
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    updateNumTimesIn3rdParty
Object:         Case
Date:           3/2017
Details and Notes:
When Status is changed to any of the 3rd Party statuses, a counter on the Case will be increased
***************************************************************************************************************/
    public static void updateNumTimesIn3rdParty(List<Case> newCases, Map<Id, Case> oldMap) {
        Set<Id> nullCases = new Set<Id>();
        Map<Id, List<CaseHistory>> caseHistoryMap = new Map<Id, List<CaseHistory>>();
        if (staticStopStatusSet.isEmpty()) {
            List<Stop_Status__c> stopStatusList = [SELECT Name FROM Stop_Status__c];
            for (Stop_Status__c stopStatus : stopStatusList) {
                staticStopStatusSet.add(stopStatus.Name);
            }
        }
        for (Case currCase : newCases) {
            if (currCase.Number_of_Times_in_3rd_Party__c == null) {
                nullCases.add(currCase.Id);
            }
        }
        if (nullCases.size() > 0) {
            List<CaseHistory> relatedCaseHistory = [SELECT Id, CaseId, Field, OldValue, NewValue FROM CaseHistory WHERE CaseId IN: nullCases AND (Field = 'Status')];
            for (CaseHistory historyValue : relatedCaseHistory) {
                if (!caseHistoryMap.containsKey(historyValue.CaseId)) {
                    caseHistoryMap.put(historyValue.CaseId, new List<CaseHistory>());
                }
                caseHistoryMap.get(historyValue.CaseId).add(historyValue);
            }
        }
        for (Case currCase : newCases) {
            if (caseHistoryMap.containsKey(currCase.Id)) {
                Integer statusCounter = 0;
                for (CaseHistory historyValue : caseHistoryMap.get(currCase.Id)) {
                    if (!staticStopStatusSet.contains((String) historyValue.OldValue) && staticStopStatusSet.contains((String) historyValue.NewValue)) {
                        statusCounter++;
                    }
                }
                currCase.Number_of_Times_in_3rd_Party__c = statusCounter;
            }
            if (currCase.Number_of_Times_in_3rd_Party__c == null) {
                currCase.Number_of_Times_in_3rd_Party__c = 0;
            }
            if (oldMap.get(currCase.Id).Status != currCase.Status && !staticStopStatusSet.contains(oldMap.get(currCase.Id).Status) && staticStopStatusSet.contains(currCase.Status) && thirdPartyExecutionCount == 0) {
                currCase.Number_of_Times_in_3rd_Party__c = currCase.Number_of_Times_in_3rd_Party__c + 1;
                thirdPartyExecutionCount++;
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    updateCaseTypeAndReassign
Object:         Case
Date:           3/2017
Details and Notes:
- When Record Type changes, Assignment Rules will be re-evaluated.
- Case Type will be changed accordingly
- Runs after update
***************************************************************************************************************/
    public static void updateCaseTypeAndReassign(List<Case> newCases, Map<Id, Case> oldMap) {
        Set<Id> changedRTCaseIds = new Set<Id>();
        Set<Id> rtIdSet = new Set<Id>();
        Set<Id> businessProcessIdSet = new Set<Id>();
        Map<Id, String> rtIdBusinessProcessMap = new Map<Id, String>();
        if (closedStatusSet.isEmpty()) {
            for (CaseStatus status : [Select MasterLabel From CaseStatus where IsClosed = true]) {
                closedStatusSet.add(status.MasterLabel);
            }
        }
        
        for (Case currCase : newCases) {
            if (oldMap.get(currCase.Id).RecordTypeId != currCase.RecordTypeId) {
                changedRTCaseIds.add(currCase.Id);
                rtIdSet.add(currCase.RecordTypeId);
            }
        }
        if (!rtIdSet.isEmpty()) {
            List<RecordType> caseRecordTypes = [SELECT Id, Name, BusinessProcessId FROM RecordType WHERE Id IN: rtIdSet];
            List<AssignmentRule> caseAssignment = [SELECT Id, Name FROM AssignmentRule WHERE SobjectType = 'Case' AND Name = 'Case Transfer Rules' LIMIT 1];
            if (caseAssignment.size() > 0) {
                for (RecordType rt : caseRecordTypes) {
                    businessProcessIdSet.add(rt.BusinessProcessId);
                }
                Map<Id, BusinessProcess> businessProcessMap = new Map<Id, BusinessProcess>([SELECT Id, Name FROM BusinessProcess WHERE Id IN: businessProcessIdSet]);
                for (RecordType rt : caseRecordTypes) {
                    rtIdBusinessProcessMap.put(rt.Id, businessProcessMap.get(rt.BusinessProcessId).Name);
                }
                
                
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = caseAssignment[0].Id;
                
                Map<String, String> businessProcessTypeMap = new Map<String, String>();
                for (CaseTypeForDept__c val : CaseTypeForDept__c.getAll().values()) {
                    businessProcessTypeMap.put(val.Business_Process_Name__c, val.Default_Type__c);
                }
                
                List<Case> updatedCaseList = [SELECT Id, Status, RecordType.Name, BSI_Function__c FROM Case WHERE Id IN: changedRTCaseIds AND BSI_Function__c = 'GBS'];
                for (Case c : updatedCaseList) {
                    if (businessProcessTypeMap.containsKey(rtIdBusinessProcessMap.get(c.RecordTypeId))) {
                        c.Type = businessProcessTypeMap.get(rtIdBusinessProcessMap.get(c.RecordTypeId));
                    }
                    if (!closedStatusSet.contains(c.Status)) {
                        c.Status = 'Logged';
                    }
                    c.setOptions(dmlOpts);
                }
                update updatedCaseList;
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    updateFlagsOnStatusChange
Object:         Case
Date:           3/2017
Details and Notes:
When Status changes in specific ways, "New Activity" is checked or unchecked
- Any Status --> Closed         = Flag Off
- Any Closed --> Open           = Flag On
- Any Status --> Stop Status    = Flag Off
***************************************************************************************************************/
    public static void updateFlagsOnStatusChange(List<Case> newCases, Map<Id, Case> oldMap) {
        
        if (staticStopStatusSet.isEmpty()) {
            List<Stop_Status__c> stopStatusList = [SELECT Name FROM Stop_Status__c];
            for (Stop_Status__c stopStatus : stopStatusList) {
                staticStopStatusSet.add(stopStatus.Name);
            }
        }
        
        if (closedStatusSet.isEmpty()) {
            for (CaseStatus status : [Select MasterLabel From CaseStatus where IsClosed = true]) {
                closedStatusSet.add(status.MasterLabel);
            }
        }
        
        for (Case currCase : newCases) {
            if (oldMap.get(currCase.Id).Status != currCase.Status) {
                //Any Status --> Closed
                if (!closedStatusSet.contains(oldMap.get(currCase.Id).Status) && closedStatusSet.contains(currCase.Status)) {
                    currCase.New_Activity__c = false;
                }
                //Any Closed --> Open/Assigned
                else if (closedStatusSet.contains(oldMap.get(currCase.Id).Status) && !closedStatusSet.contains(currCase.Status)) {
                    currCase.New_Activity__c = true;
                }
                //Any Non-Stop-Status to Stop-Status
                else if (!staticStopStatusSet.contains(oldMap.get(currCase.Id).Status) && staticStopStatusSet.contains(currCase.Status)) {
                    currCase.New_Activity__c = false;
                }
            }
        }
    }
    
/**************************************************************************************************************
Method name:    updateFlagsOnCICaseChange
Object:         Case
Date:           11/2021
Details and Notes:
When a case is updated the flag will be reset if it is set
***************************************************************************************************************/  
    
    public static void updateFlagsOnCICaseChange(List<Case> newCases, Map<Id, Case> oldMap) {
       
        for (Case currCase : newCases) {
            Case oldCase = oldMap.get(currCase.Id);
            if(currCase.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID && oldCase.New_Activity__c){
                currCase.New_Activity__c = false;
            }
        }
    }
    /**************************************************************************************************************
Method name:    updateCaseClosedFieldsOnStatusChanged
Object:         Case
Date:           27/12/2021
Details and Notes:
Update CaseClosedType to AgentClosed whenever case resolved
***************************************************************************************************************/  
    
    public static void updateCaseClosedFieldsOnStatusChanged(List<Case> newCases, Map<Id, Case> oldMap) {
        String closingStatus = System.Label.Case_CI_Closing_Status;
        for (Case currCase : newCases) {
            if ((currCase.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID || currCase.RecordTypeId == CSConstants.QC_RT_ID) && 
                oldMap.get(currCase.Id).Status != currCase.Status && 
                closingStatus.containsIgnoreCase(currCase.Status)) 
            {
                if(currCase.Actual_Closed_Date__c == null){
                    currCase.Actual_Closed_Date__c = System.now();
                }
                if(currCase.CaseClosedType__c =='' || currCase.CaseClosedType__c == null)
                {
                    currCase.CaseClosedType__c ='Auto Closed';
                }
                if(currCase.Actual_Closed_Date__c != null){
                    Decimal businessHours;
                    if(currCase.Date_Time_Assigned__c != null){
                        businessHours = EmailMessageServices.calculateFirstResponseTime(currCase.Date_Time_Assigned__c, 
                                                                                            currCase.Actual_Closed_Date__c);
                    }else{
                        businessHours = EmailMessageServices.calculateFirstResponseTime(currCase.CreatedDate, 
                                                                                            currCase.Actual_Closed_Date__c);
                    }
                    if(businessHours != null && currCase.Business_Hours_To_Resolve__c == null){
                        currCase.Business_Hours_To_Resolve__c = businessHours;
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    handleBookingUpdate
Object:         Case
Date:           7/2021
Details and Notes:
When a case's is delinked from Plant Event , case__c from Plant Event should be blank
***************************************************************************************************************/    
    public static void handleBookingUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        List<Plant_Event__c> plantEventList = new List<Plant_Event__c>();
        for (Case currentCase : newCases) {
            Case oldCase = oldMap.get(currentCase.Id);
            if (currentCase.Brand__c == SBP_Constants.BRAND_MAKERS_MARK 
                && oldCase.Plant_Event__c != null 
                && oldCase.Plant_Event__c != currentCase.Plant_Event__c) {
                    //remove CaseId from older Plant Event
                    plantEventList.add(new Plant_Event__c( Id = oldCase.Plant_Event__c, Case__c = null) );
                }
            
            //Update CaseId on newly attached Plant Event
            if(currentCase.Plant_Event__c != null){
                plantEventList.add(new Plant_Event__c(Id = currentCase.Plant_Event__c, Case__c = currentCase.Id));
            }          
        }
        System.debug('recursive value '+ isRecursiveCall);
        if(!plantEventList.isEmpty() && !isRecursiveCall){
            //isRecursiveCall = true;
            try{
               update plantEventList; 
            }
            catch(Exception e){
                System.debug('Error Occured: ' + e.getMessage());
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    removeAbandonedCases
Object:         Case
Date:           4/2017
Details and Notes:
When a case's status changes to "Closed - Abandoned", it should be deleted
***************************************************************************************************************/
    public static void removeAbandonedCases(List<Case> newCases, Map<Id, Case> oldMap) {
        List<Id> casesToDelete = new List<Id>();
        
        for (Case currCase : newCases) {
            if (oldMap.get(currCase.Id).Status != currCase.Status) {
                if (currCase.Status == 'Closed - Abandoned') {
                    casesToDelete.add(currCase.Id);
                }
            }
        }
        
        try {
            if(!casesToDelete.isEmpty())
                Database.delete([SELECT Id FROM Case WHERE Id IN: casesToDelete AND BSI_Function__c = 'GBS'], false);
        } catch (Exception e) {
            System.debug('Insufficient Privilege Error: ' + e.getMessage());
        }
    }
    
    /**************************************************************************************************************
Method name:    syncSelfRegistrationOwnership
Object:         Case
Date:           4/2017
Details and Notes:
As part of the Registration Approval Operating Procedure, the user taking the Case must also take Ownership
of the related Contact. This method automatically assigns the Contact to the user that picks up the Case
***************************************************************************************************************/
    
    public static void syncSelfRegistrationOwnership(List<Case> newCases, Map<Id, Case> oldMap) {
        Id registrationApprovalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Registration Approval').getRecordTypeId();
        //Id: ContactId, Id: new OwnerId
        List<Contact> changedContacts = new List<Contact>();
        for (Case currCase : newCases) {
            //Confirm that this is an Update, not an Insert (The Case already exists)
            if (oldMap.containsKey(currCase.Id) && currCase.RecordTypeId == registrationApprovalCaseRecordTypeId) {
                //Determine whether or not the owner is a User without having to query User.Type
                if (((String) currCase.OwnerId).startsWith('005')) {
                    //Owner has changed and we know it's a user. Therefore, assign to the Contact, if it exists
                    if (oldMap.get(currCase.Id).OwnerId != currCase.OwnerId && currCase.ContactId != null) {
                        changedContacts.add(new Contact(Id = currCase.ContactId, OwnerId = currCase.OwnerId));
                    }
                }
            }
        }
        if (!changedContacts.isEmpty()) {
            update changedContacts;
        }
    }
    
    @InvocableMethod(label = 'Send "Cannot be Reopened" email' description = 'Sends an email to the sender of the "REOPEN" email, stating that the case could not be reopened')
    public static void sendEmail(List<Id> emailIdList) {
        String CASE_REF_FORMAT = 'ref:{0}.{1}:ref';
        String orgId = UserInfo.getOrganizationId().substring(0, 15);
        String shortenedOrgId = '';
        Pattern orgPattern = Pattern.compile('^([A-Za-z0-9]{5})([A-Za-z0-9]*)$');
        Pattern casePattern = Pattern.compile('^([A-Za-z0-9]{5})([A-Za-z0-9]*)([A-Za-z0-9]{5})$');
        Matcher orgMatcher = orgPattern.matcher(orgId);
        if (orgMatcher.matches()) {
            shortenedOrgId = '_' + orgMatcher.group(1) + orgMatcher.group(2).replace('0', '');
        }
        
        Map<Id, String> caseSenderAddressMap = new Map<Id, String>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Case_Unable_to_Reopen_Template' LIMIT 1];
        List<EmailMessage> emailMessages = [SELECT Id, ParentId, FromAddress FROM EmailMessage WHERE Id IN :emailIdList];
        for (EmailMessage em : emailMessages) {
            if (((String) em.ParentId).startsWith('500')) {
                caseSenderAddressMap.put(em.ParentId, em.FromAddress);
            }
        }
        List<Case> parentCases = [SELECT Id, CaseNumber, Subject, Submitter_First_Name__c FROM Case WHERE Id IN :caseSenderAddressMap.keySet()];
        for (Case parentCase : parentCases) {
            String caseId = ((String) parentCase.Id).substring(0, 15);
            String shortenedCaseId = '';
            Matcher caseMatcher = casePattern.matcher(caseId);
            if (caseMatcher.matches()) {
                shortenedCaseId = '_' + caseMatcher.group(1) + caseMatcher.group(2).replace('0', '') + caseMatcher.group(3);
            }
            String caseThreadId = '';
            if (String.isNotBlank(shortenedCaseId) && String.isNotBlank(shortenedOrgId)) {
                caseThreadId = String.format(CASE_REF_FORMAT, new List<String> {shortenedOrgId, shortenedCaseId});
            }
            
            String subject = template.Subject;
            subject = subject.replace('{!Case.CaseNumber}', parentCase.CaseNumber);
            subject = subject.replace('{!Case.Subject}', parentCase.Subject);
            
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Submitter_First_Name__c}', parentCase.Submitter_First_Name__c);
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', parentCase.CaseNumber);
            htmlBody = htmlBody.replace('{!Case.Id}', parentCase.Id);
            htmlBody = htmlBody.replace('{!$Label.Base_Company_Community_URL}', System.Label.Base_Company_Community_URL);
            htmlBody = htmlBody.replace('{!Case.Thread_Id}', caseThreadId);
            
            String plainBody = template.Body;
            plainBody = plainBody.replace('{!Case.Submitter_First_Name__c}', parentCase.Submitter_First_Name__c);
            plainBody = plainBody.replace('{!Case.CaseNumber}', parentCase.CaseNumber);
            plainBody = plainBody.replace('{!Case.Id}', parentCase.Id);
            plainBody = plainBody.replace('{!$Label.Base_Company_Community_URL}', System.Label.Base_Company_Community_URL);
            plainBody = plainBody.replace('{!Case.Thread_Id}', caseThreadId);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> {caseSenderAddressMap.get(parentCase.Id)});
            email.setSenderDisplayName('gbs@beamsuntory.com');
            email.setTargetObjectId(UserInfo.getUserId());
            email.setTreatTargetObjectAsRecipient(false);
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
            emails.add(email);
            if(!Test.isRunningTest()){
                Messaging.reserveSingleEmailCapacity(emails.size());
                Messaging.sendEmail(emails);
            }
        }
    }
    
    /**************************************************************************************************************
Description:     For Order Claims, multiple sub cases will be related to one parent case.  Once all the sub cases are closed a flag
on the parent case will be updated to reflect that all sub cases have been closed.

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateParentCase(List<Case> cases, Map<Id, Case> oldCases) {
        Set<Id> parentIds = new Set<Id>();
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        List<Case> subCasesClosed = new List<Case>();
        
        for (Case c : cases) {
            if (oldCases != null) {
                Case oldCase = oldcases.get(c.Id);
                if (c.Status != oldCase.Status) {
                    if (c.ParentId != null && (c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID || c.RecordTypeId == CSConstants.LOGISTICS_REQUEST_RT_ID
                                               || (c.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID) || (c.RecordTypeId == CSConstants.CUSTOMER_DATA_SUB_CASE_RT_ID)) && CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                                                   parentIds.add(c.ParentId);
                                               }
                }
            }
        }
        
        if (parentIds.isEmpty()) {
            return;
        }
        
        // pull parent case alang with child cases
        for (Case c : [select Id, Parent.All_Sub_Cases_Closed__c, AccountId, RecordTypeId, SLA_Start__c, EntitlementId, ParentId, Status, (select id, Status from Cases) from Case where Id IN : parentIds]) {
            Boolean allSubCasesAreClosed = true;
            for (Case subCase : c.Cases) {
                
                if (!CSConstants.CLOSED_STATUS_VARIATIONS.contains(subCase.Status)) {
                    allSubCasesAreClosed = false;
                    break;
                }
            }
            
            if (allSubCasesAreClosed) {
                c.All_Sub_Cases_Closed__c = true;
                subCasesClosed.add(c);
            } else {
                c.All_Sub_Cases_Closed__c = false;
            }
            casesToUpdateMap.put(c.Id, c);
        }
        
        if (!subCasesClosed.isEmpty()) {
            addEntitlementToQualityClaimParentCase(subCasesClosed);
        }
        
        if (!casesToUpdateMap.isEmpty()) {
            try {
                update casesToUpdateMap.values();
            } catch (Exception e) {
                String errorMessage = 'Error updating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'updateParentCase', String.valueOf(errorMessage), 'Fatal');
                
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:     For Customer Data cases, multiple sub cases will be related to one parent case.  Once the Customer Data parent case is closed then
all the subcases related to it should get closed.
History
<Date>      <Authors Name>     		<Brief Description of Change>
4/2024      Shubham Khandelwal       Process builder Conversion to Trigger

***************************************************************************************************************/
    public static void updateCustomerDataSubCase(List<Case> cases, Map<Id, Case> oldCases) {
        List<String> parentCaseId = new List<String>();
        for (Case c : cases){
            if(c.Status == 'Closed' && c.KickoffCustomerdata__c) {
                parentCaseId.add(c.Id);
            }
        }
        if(parentCaseId.size()>0){
        List<Case> customerDataSubcase = [Select id from Case where ParentId IN : (parentCaseId) AND status != 'Closed'];
        if(!customerDataSubcase.isEmpty()){
            for (Case c : customerDataSubcase){
                c.Status = 'Closed';
            }
        }
        system.debug('customerDataSubcase  852');
        system.debug(customerDataSubcase);
        caseServices.runTrigger = false;
        try {
            update customerDataSubcase;
        } catch (Exception e) {
                String errorMessage = 'Error updating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'updateParentCase', String.valueOf(errorMessage), 'Fatal');
        }
        } 
    }
    
    /**************************************************************************************************************
Description:    Checks whether a case was changed from a closed variation status to anything else

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void checkIfCaseWasReopened(List<Case> cases, Map<Id, Case> oldMap) {
        Entitlement caseReOpenEntitlement = new Entitlement();
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        Set<Id> parentIds = new Set<Id>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.Status != oldCase.Status && c.ParentId == null) {
                
                if (CSConstants.CLOSED_STATUS_VARIATIONS.contains(oldCase.Status) && !CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status) &&
                    (c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID || c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID)) {
                        
                        parentIds.add(c.Id);
                    }
            }
        }
        
        if (parentIds.isEmpty()) {
            return;
        }
        //Added below statement by Sangeet on 17/11/2022
        Group subCaseDefaultQueue = [select id, DeveloperName from Group where Type = 'Queue' AND DeveloperName = 'Order_Claim_Sub_Case_Queue'];
        
        // reopen child cases if the parent record is reopened
        for (Case c : [select id
                       , Status
                       , isReOpened__c
                       , SLA_Start__c
                       , All_Sub_Cases_Closed__c
                       , RecordTypeId,
                       (Select id
                        , Financial_Disposition__c
                        , Return_SAP_Number__c
                        , ParentId
                        , OwnerId
                        , Assign_Queue_to_Case__c
                        , Status from Cases where RecordType.Name != 'Order Claim Sub Case')
                       from Case where Id IN :parentIds]) {
                           c.isReOpened__c = true;
                           // once the case is reopened the entitlement will restart
                           c.SLA_Start__c = null;
                           c.All_Sub_Cases_Closed__c = false;
                           casesToUpdateMap.put(c.Id, c);
                           
                           
                           for (Case childCase : c.Cases) {
                               childCase.isReOpened__c = true;
                               childCase.Status = CSConstants.NEW_STATUS;
                               childCase.SLA_Start__c = null;
                               childCase.OwnerId = subCaseDefaultQueue.Id;
                               childCase.Assign_Queue_to_Case__c = false;
                               casesToUpdateMap.put(childCase.Id, childCase);
                           }
                       }
        
        if (!casesToUpdateMap.isEmpty()) {
            try {
                update casesToUpdateMap.values();
            } catch (Exception e) {
                String errorMessage = 'Error updating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'checkIfCaseWasReopened', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:    Checks if an account record has any entitlments attached to it and returns the map of entitlements

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static Map < Id, Account > getEntitlementsFromAccount(List < Account > accts, String nameOfEntitlement) {
        Map < Id, Account > defaultEntitlementForAccount = new Map < Id, Account > ();
        Map < Id, Account > allAccounts = new Map < Id, Account > ();
        
        for (Account acct : accts) {
            allAccounts.put(acct.Id, acct);
            if (acct.Entitlements.isEmpty()) {
                // create both entitlements for this account
                defaultEntitlementForAccount.put(acct.Id, acct);
            } else {
                defaultEntitlementForAccount.put(acct.Id, acct);
                for (Entitlement em : acct.Entitlements) {
                    
                    if (em.Name == nameOfEntitlement) {
                        // removed the entitlement because it already exists for this account
                        defaultEntitlementForAccount.remove(acct.Id);
                    }
                }
            }
        }
        
        return defaultEntitlementForAccount;
    }
    
    public static Map <Id, Map <String, Entitlement>> mapAccountToEntitlements(Set <Id> acctIds) {
        Map <Id, Map <String, Entitlement>> accountIdToEntitlements = new Map <Id, Map <String, Entitlement>>();
        
        for (Account acct : [select id, (Select Id, Name from Entitlements) from Account where Id IN: acctIds]) {
            Map <String, Entitlement> entitlementMap = new Map <String, Entitlement>();
            for (Entitlement em : acct.Entitlements) {
                entitlementMap.put(em.Name, em);
            }
            accountIdToEntitlements.put(acct.Id, entitlementMap);
        }
        
        return accountIdToEntitlements;
    }
    
    /**************************************************************************************************************
Description:    Creates default entitlement for accounts that don't have the default entitlement

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void createEntitlementsForAccount(Map<Id, Account> defaultEntitlementMap, Map<Id, Account> allAccounts, String nameOfEntitlement, String nameOfEntitlementProcess ) {
        Map<String, SlaProcess> allSlaProcessesMap = getSlaProcessMap();
        List<Entitlement> entitlementsToInsert = new List<Entitlement>();
        system.debug('=========defaultEntitlementMap========'+defaultEntitlementMap);
        system.debug('============all account record values==='+allAccounts);
        system.debug('==========nameOfEntitlement==='+nameOfEntitlement);
        // create default entitlement
        for (Account acct : allAccounts.values()) {
            
            if (defaultEntitlementMap.containsKey(acct.Id)) {
                Entitlement entitlement = new Entitlement();
                
                entitlement.Name = nameOfEntitlement;
                entitlement.AccountId = acct.Id;
                entitlement.SlaProcessId = allSlaProcessesMap.get(nameOfEntitlementProcess).Id;
                entitlement.StartDate = Date.today();
                entitlementsToInsert.add(entitlement);
                system.debug('==========entitlementsToInsert==='+entitlementsToInsert);
            }
        }
        if (!entitlementsToInsert.isEmpty()) {
            insert entitlementsToInsert;
        }
    }
    
    /**************************************************************************************************************
Description:    Once a case of record type order claim(parent case) has be set to expedited then the
child cases need to also be set to expedited this will trigger a new milestone to be attached to all cases

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void setChildCaseToExpeditedOrderClaim(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> parentCaseIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (oldCase.Expedited_Claim__c == false && c.Expedited_Claim__c) {
                if (c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID && c.ParentId == null) {
                    parentCaseIds.add(c.Id);
                }
            }
        }
        
        if (parentCaseIds.isEmpty()) {
            return;
        }
        
        for (Case c : [select id, Expedited_Claim__c from Case where ParentId IN :parentCaseIds ]) {
            c.Expedited_Claim__c = true;
            casesToUpdate.put(c.Id, c);
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
        }
    }
    
    /**************************************************************************************************************
Description:    Once cases of record type order claim sub case(sub case) are created, they need to be hidden from the plant users until
the parent case has been prepared properly by a coordinator.  In order to achieve this sub cases have a default owner
of "Order CLaim Sub Case Queue" which is set by a workflow.  Once the parent case moves the status to "Pending Sub-Case"
a field is updated "Assign_Queue_to_Case__c" which triggers the case assignment rules to assign the case to the correct
queue which gives the plant users access to it.

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void setChildCasesToBePickedUpByAssignmentRules(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> parentCaseIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        
        for (Case c : cases) {
            
            Case oldCase = oldMap.get(c.Id);
            
            if (c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID
                && c.ParentId == null
                && c.Status == CSConstants.PENDING_SUB_CASE
                && oldCase.Status != CSConstants.PENDING_SUB_CASE) {
                    parentCaseIds.add(c.Id);
                }
        }
        
        if (parentCaseIds.isEmpty()) {
            return;
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        
        // get all child cases from parent cases
        for (Case c : [select id, Assign_Queue_to_Case__c from Case where ParentId IN : parentCaseIds]) {
            c.Assign_Queue_to_Case__c = true;
            c.SLA_Start__c = null;
            casesToUpdate.put(c.Id, c);
        }
        
        // update all child cases
        if (!casesToUpdate.isEmpty()) {
            Database.update(casesToUpdate.values(), dmo);
        }
    }
    
    /**************************************************************************************************************
Description:    before a case of record type order claim can be closed all of it child cases must be closed
AND have "Financial_Disposition__c" and "Return_SAP_Number__c" filled in.  However if the
child case status is "Closed - Rejected" then it is ignored.  This method updates a field to
indicate that the child fields are missing and that triggers a validation rule to fire and be visible to the user.

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void checkRequiredFieldsOnChildForClosingParentCase(List<Case> cases, Map<Id, Case> oldMap) {
        
        Set<Id> parentIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        // get parent ids
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID && c.ParentId != null && CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status) ||
                ((oldCase.Financial_Disposition__c == null && c.Financial_Disposition__c != null) || (oldCase.Return_SAP_Number__c == null && c.Return_SAP_Number__c != null) || (oldCase.Billing_SAP_Number__c == null && c.Billing_SAP_Number__c != null))) {
                    parentIds.add(c.ParentId);
                }
        }
        
        if (parentIds.isEmpty()) {
            return;
        }
        
        // check all child records
        for (Case c : [select id, Child_case_fields_missing__c, Billing_SAP_number_missing__c, Return_SAP_number_missing__c,  (Select id, Financial_Disposition__c, Return_SAP_Number__c, Billing_SAP_Number__c, Type, ParentId, Status from Cases) from Case where Id IN :parentIds]) {
            Boolean childBillingFieldsMissing = false;
            Boolean childReturnFieldsMissing = false;
            for (Case subCase : c.Cases) {
                
                // if the status is "closed - rejected" Or Claim type is Freight Claim or State Code Claim then it does not need to be validated by the parent case
                if (subCase.Status != CSConstants.DUP_NO_ACTION && subCase.Status != CSConstants.CLOSED_REJECTED && subCase.Type != 'Freight Claim' && subCase.Type != 'State Code Claim') {
                    // if claim type is Shortage claim or Damage claim
                    // then return sap number is required
                    if ((subCase.Type == 'Damage Claim' || subCase.Type == 'Shortage Claim') && subCase.Return_SAP_Number__c == null) {
                        childReturnFieldsMissing = true;
                    }
                    
                    // if overage or mis shipment claim
                    // then billing sap number and financial disposition are required
                    if ((subCase.Type == 'Mis-Shipment Claim' || subCase.Type == 'Overage Claim') && (subCase.Financial_Disposition__c == null || subCase.Billing_SAP_Number__c == null)) {
                        childBillingFieldsMissing = true;
                    }
                }
            }
            
            if (childReturnFieldsMissing) {
                c.Return_SAP_number_missing__c = true;
            } else {
                c.Return_SAP_number_missing__c = false;
            }
            
            if (childBillingFieldsMissing) {
                c.Billing_SAP_number_missing__c = true;
            } else {
                c.Billing_SAP_number_missing__c = false;
            }
            
            casesToUpdate.put(c.Id, c);
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
        }
    }
    
    /**************************************************************************************************************
Description:    This method updates a custom object that stores identical data from the standard CaseMilestone object.
Once the case is closed then the custom object will be updated to reflect the most recent data.

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateClonedCaseMilestoneOnCaseClosed(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.Status != oldCase.Status) {
                // only pull in statuses that have moved to the closed status from any other non closed status
                if (!CSConstants.CLOSED_STATUS_VARIATIONS.contains(oldCase.Status) && CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status) &&
                    (c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID || c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID)) {
                        caseIds.add(c.Id);
                    }
            }
        }
        
        if (caseIds.isEmpty()) {
            return;
        }
        
        // get milestones related to cases
        List<CaseMilestone> caseMilestones = EntitlementsServices.getCaseMilestoneByCaseId(caseIds);
        
        // created/update the Cloned Milestone records
        List<Cloned_Milestone__c> clonedMilestones = ClonedMilestone.buildAndUpdateClonedMilestones(caseMilestones);
        
        if (!clonedMilestones.isEmpty()) {
            upsert clonedMilestones;
        }
    }
    
    /**************************************************************************************************************
Description:    Order Claims and Quality Claims will require an Account so that an Entitlement can be added to the case.

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void setDefaultAccountForCSClaims(List<Case> cases) {
        Account defaultAccount = new Account();
        Set<Id> acceptedRecordTypeIds = new Set<Id>();
        
        acceptedRecordTypeIds.addAll(CSConstants.orderClaimRecordTypeIds);
        //acceptedRecordTypeIds.addAll(CSConstants.qualityClaimRecordTypeIds);
        Id DEFAULT_ACCOUNT_DISTRIBUTOR_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        List<Account> accts = [select Id, RecordTypeId, Name
                               from Account
                               where Name = :CSConstants.DEFAULT_ACCOUNT_NAME
                               AND RecordTypeId = :DEFAULT_ACCOUNT_DISTRIBUTOR_RT_ID limit 1];
        
        User u = [select Id, ContactId from User where Id = : UserInfo.getUserId() limit 1];
        
        // Commenting out this condition and will setup Account in test classes
        /*if (Test.isRunningTest()) {
Account a = new Account();
a.Name = CSConstants.DEFAULT_ACCOUNT_NAME;
a.RecordTypeId = CSConstants.DEFAULT_ACCOUNT_RT_ID;
insert a;
defaultAccount = a;
} else {*/
        if(!accts.isEmpty()) defaultAccount = accts[0];
        //}
        
        for (Case c : cases) {
            if (acceptedRecordTypeIds.contains(c.RecordTypeId)) {
                if (u.ContactId == null) {
                    if (c.AccountId == null) {
                        c.AccountId = defaultAccount.Id;
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:    Account creation for the Consumer Inquiry case record type using email to case.

History
<Date>      <Authors Name>     <Brief Description of Change>
03-04-2020      Saurabh       Initial Creation

***************************************************************************************************************/
    public static void setDefaultAccountForCSConsumer(List<Case> cases) {
        List<Account> defaultAccount = new List<Account>();
        
        /* Below added the Consumer Inquiry and Quality Claim record type into Set of Id */
        Set<Id> acceptedRecordTypeIds = new Set<Id>();
        acceptedRecordTypeIds.add(CSConstants.CONSUMER_INQUIRY_RT_ID);
        acceptedRecordTypeIds.addAll(CSConstants.qualityClaimRecordTypeIds);
        acceptedRecordTypeIds.add(DTC_Constants.CASE_DTC_RECORDTYPEID);
        /*Set for Email Ids to store the all the email ids of case*/
        Set<String> emailIds = new Set<String>();
        for(Case c : cases) {
            emailIds.add(c.SuppliedEmail);
        }
        /*Fetching all the account records of person account related */
        List<Account> acc = new List<Account>();
        if(!emailIds.isEmpty())
            acc = [Select id from account where RecordTypeId = :CSConstants.CONSUMER_ACCOUNT_RT_ID and personemail IN: emailIds];
        for (Case c : cases) {
            /* Preparing the consumer account record insertion below when case is getting created */
            if (acc.isEmpty() && c.AccountId == null) {
                if ((acceptedRecordTypeIds.contains(c.RecordTypeId)) && (c.origin == 'Email' || c.origin == 'Phone')) {
                    Account accInfo = new Account();
                    accInfo.lastname = c.SuppliedName;
                    if(c.SuppliedName == null)
                        accInfo.lastname = 'testName';
                    accInfo.personemail = c.SuppliedEmail;
                    emailIds.add(c.SuppliedEmail);
                    accInfo.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
                    defaultAccount.add(accInfo);
                }
            }
        }
        
        /* Below inserting the list of account records */
        Set<Id> insertedIds = new Set<Id>();
        if(!defaultAccount.isEmpty()){
            insert defaultAccount;
            for(Account a : defaultAccount) {
                insertedIds.add(a.Id);
            }
        }
        
        /* Below querying the person account based on all inserted accounts */
        List<Account> personAccount = new List<Account>();
        if(!insertedIds.isEmpty())
            personAccount = [Select id, personemail, personContactId from account where RecordTypeId = :CSConstants.CONSUMER_ACCOUNT_RT_ID AND Id IN: insertedIds];
        
        /* Map for put the personemail and its associated Account record information */
        Map<String, Account> accMapInfo = new Map<String, Account>();
        for(Account a : personAccount){
            accMapInfo.put(a.personemail, a);
        }
        
        /* Below setup the case account Id and contact Id */
        for (Case c : cases) {
            if (acc.isEmpty() && c.AccountId == null) {
                if ((acceptedRecordTypeIds.contains(c.RecordTypeId)) && (c.origin == 'Email' || c.origin == 'Phone') && accMapInfo.containsKey(c.SuppliedEmail)) {
                    c.AccountId = accMapInfo.get(c.SuppliedEmail).Id;
                    c.ContactId = accMapInfo.get(c.SuppliedEmail).PersonContactId;
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:    Address details from Account for the Consumer Inquiry/Quality Claim case record type.

History
<Date>      <Authors Name>     <Brief Description of Change>
22-Apr-2020     Chirag               Initial Creation

***************************************************************************************************************/
    public static void setDefaultAccountAddressForCSConsumer(List<Case> cases) {       
        /* Below added the Consumer Inquiry and Quality Claim record type into Set of Id */
        Set<Id> acceptedRecordTypeIds = new Set<Id>();
        acceptedRecordTypeIds.add(CSConstants.CONSUMER_INQUIRY_RT_ID);
        acceptedRecordTypeIds.addAll(CSConstants.qualityClaimRecordTypeIds);
        
        Set<Id> accountIds = new Set<Id>();
        for(Case c : cases) {
            if(c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }
        Map<Id,Account> personAccountMap = new Map<Id,Account>();
        if(!accountIds.isEmpty()){
            personAccountMap = new Map<Id,Account>([Select Id,PersonMailingStreet,PersonMailingCity,PersonMailingState
                                                                    ,PersonMailingPostalCode,PersonMailingCountry 
                                                                    FROM account 
                                                                    WHERE RecordTypeId = :CSConstants.CONSUMER_ACCOUNT_RT_ID AND Id IN: accountIds]);
            
            //Add address fields for Consumer Inquiry and Quality Claim records
            for(Case c : cases) {
                if(acceptedRecordTypeIds.contains(c.RecordTypeId) && personAccountMap.get(c.AccountId) != null) {
                    Account acc = personAccountMap.get(c.AccountId);
                    if(c.Consumer_Country__c == null) c.Consumer_Country__c = acc.PersonMailingCountry;
                    if(c.Consumer_Street__c == null) c.Consumer_Street__c = acc.PersonMailingStreet;
                    if(c.Consumer_City__c == null) c.Consumer_City__c = acc.PersonMailingCity;
                    if(c.Consumer_State__c == null) c.Consumer_State__c = acc.PersonMailingState;
                    if(c.Consumer_Postal_Code__c == null) c.Consumer_Postal_Code__c = acc.PersonMailingPostalCode;
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description: Account creation for the Market Readiness Inquiry record type cases

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2022         Sahana              Initial Creation
***************************************************************************************************************/
    public static void setDefaultAccountForMarketReadiness(List<Case> cases) {
        List<Account> defaultAccount = new List<Account>();
        Set<Id> recordTypeId = new Set<Id>();
        
        recordTypeId.add(CSConstants.MARKET_READINESS_RT_ID);
        
        List<Account> accts = [Select Id, RecordTypeId from Account
                               where Name = :CSConstants.DEFAULT_MARKET_READINESS
                               AND RecordTypeId = :CSConstants.CONSUMER_ACCOUNT_RT_ID limit 1];
        System.debug('account details' + accts);
        
        for (Case c : cases) {          
            if (recordTypeId.contains(c.RecordTypeId) && (c.origin == 'Email')) {
                if(!accts.isEmpty() && c.AccountId == null){ 
                    c.AccountId = accts[0].Id;
                }
                else if(accts.isEmpty() && c.AccountId == null) {
                    Account accInfo = new Account();
                    accInfo.lastname = CSConstants.DEFAULT_MARKET_READINESS;
                    accInfo.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
                    defaultAccount.add(accInfo); 
                }
            }
        }       
        
        if(!defaultAccount.isEmpty()){
            insert defaultAccount;
            System.debug('default account is ' + defaultAccount );
        } 
        
        for (Case c : cases) {
            if(accts.isEmpty() && c.AccountId == null) {
                if ((recordTypeId.contains(c.RecordTypeId)) && (c.origin == 'Email')) {
                    c.AccountId = defaultAccount[0].Id;
                } 
            }
        }
    }
    
    /**************************************************************************************************************
Description:    A milestone can be closed manually in the ui, but in case the user forgets, this method will complete the milestone
for them once it matches specific criteria that moves it to the next milestone

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void markPreparePlantMilestoneAsCompleted(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        List<CaseMilestone> caseMilestonesToUpdate = new List<CaseMilestone>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID  && (c.Status == CSConstants.PENDING_SUB_CASE && (oldCase.Status == CSConstants.NEW_STATUS || oldCase.Status == 'Working'))) {
                caseIds.add(c.Id);
            }
        }
        
        if (caseIds.isEmpty()) {
            return;
        }
        
        // find the case milestone attached to the case of the correct milestone type
        for (CaseMilestone caseMilestone : [select id, IsCompleted, MilestoneType.Name from CaseMilestone where CaseId IN :caseIds]) {
            if (CSConstants.PREPARE_FOR_PLANT_MILESTONES.contains(caseMilestone.MilestoneType.Name)) {
                caseMilestone.CompletionDate = System.now();
                caseMilestonesToUpdate.add(caseMilestone);
            }
        }
        
        if (!caseMilestonesToUpdate.isEmpty()) {
            Database.update(caseMilestonesToUpdate, false);
        }
    }
    
    /* Logic for GreatVines process to create a new case for the Sales Order */
    
    public static void CreateCaseFromSalesOrder(List<gvp__Sales_Order__c> salesOrders, Map<Id, gvp__Sales_Order__c> oldOrders ) {
        List <case> casesToCreate = new List <case>();
        List <Group> lstGroup = [SELECT Id, Name, DeveloperName FROM Group where Type = 'Queue' and Name = 'Mexico'];
        Map <id, id> checkExistingCases = getCaseForSalesOrders(salesOrders);
        Set<String> checkDup = new Set<String>();
        
        for (gvp__Sales_Order__c order : salesOrders) {
            system.debug(salesOrders);
            system.debug(order.gvp__ERP_Id__c);
            system.debug(checkExistingCases);
            if (order.gvp__ERP_Id__c != null && checkExistingCases.get(order.id) == null) {
                
                case theCase = new case ();
                theCase.AccountId    = order.gvp__Account__c;
                theCase.recordtypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
                theCase.Claim_Description__c = 'Related to sales order: ' + order.id;
                theCase.Subject =  'Order - ' +  order.id;
                theCase.sales_Order__c  = order.id;
                theCase.type = 'Standard';
                theCase.OwnerID = lstGroup.get(0).Id;
                if (order.gvp__Sold_To__c != null) {
                    theCase.ContactId = order.gvp__Sold_To__c;
                }
                if (!checkDup.contains(order.id)) {
                    System.debug(casesToCreate);
                    casesToCreate.add(theCase);
                    checkDup.add(order.id);
                }
            }
        }
        try {
            insert casesToCreate;
        } catch (Exception e) {
            System.debug('Error creating a case ' + e.getMessage());
            CreateExceptionLog.insertErrorLog('caseServices', 'CreateCaseFromSalesOrder', String.valueOf(e), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
    }
    
    
    public  static Map <Id, Id> getCaseForSalesOrders(List<gvp__Sales_Order__c> salesOrders) {
        Map<Id, gvp__Sales_Order__c> mSalesOrders = new Map<Id, gvp__Sales_Order__c>(salesOrders);
        List<Case> lstCases =  [select id, sales_Order__c from Case where sales_Order__c in: mSalesOrders.keySet()];
        
        Map <Id, Id> mapSalesOrderToCase = new Map<Id, Id>();
        for (case theCase : lstCases) {
            mapSalesOrderToCase.put(theCase.sales_Order__c, theCase.id);
        }
        
        return mapSalesOrderToCase;
    }
    
    /**************************************************************************************************************
Description:    When a case moves from any status to "Dup - No Action" , the case milestones attached to the case should be removed
because the case is no longer actionable

History
<Date>      <Authors Name>     <Brief Description of Change>
2/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void removeSLAFromCase(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> parentIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        
        for (Case c : cases) {
            if (c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID && c.Status == CSConstants.DUP_NO_ACTION) {
                parentIds.add(c.ParentId);
            } else if (c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID && c.Status == CSConstants.DUP_NO_ACTION) {
                parentIds.add(c.Id);
            }
        }
        
        if (parentIds.isEmpty()) {
            return;
        }
        
        // get parent and child ids
        for (Case c : [select id, Status, EntitlementId, (Select id, Status, EntitlementId from Cases) from Case where Id IN :parentIds]) {
            c.EntitlementId = null;
            c.Status = CSConstants.DUP_NO_ACTION;
            c.SlaStartDate = null;
            casesToUpdate.put(c.Id, c);
            for (Case subCase : c.Cases) {
                subCase.Status = CSConstants.DUP_NO_ACTION;
                subCase.EntitlementId = null;
                subCase.SlaStartDate = null;
                casesToUpdate.put(subCase.Id, subCase);
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
        }
        
        // remove any cloned milestones related to the cases so they do not show up in reports
        delete [select id from Cloned_Milestone__c where Case__c IN :casesToUpdate.keySet()];
    }
    
    /**************************************************************************************************************
Description:    Moves the status of a single barrel order once all items have been completed/uploaded

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void moveSingleBarrelCaseStatus(List<Case> cases) {
        Set<Id> caseIdsToUpdate = new Set<Id>();
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id, Barrel__c> barrelsToUpdate = new Map<Id, Barrel__c>();
        
        for (Case c : cases) {
            if (c.RecordTypeId == SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID) {
                if (c.Barrel_selected__c &&
                    c.Purchase_Order_Uploaded__c && c.Bottle_Text_Entered__c &&
                    c.POS_Items_Selected__c &&
                    (c.Status == SBP_Constants.PENDING_DOCUMENTATION) &&
                    String.isNotBlank(c.SAP_Number__c)) {
                        c.Status = SBP_Constants.PREPARING_BARREL;
                        caseIds.add(c.Id);
                    }
            }
        }
    }
    
    /**************************************************************************************************************
Description:    auto completes milestones for the single barrel program

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void markSingleBarrelMilestonesAsComplete(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        List<CaseMilestone> caseMilestonesToUpdate = new List<CaseMilestone>();
        Map<Id, List<String>> caseIdToMilestoneNames = new Map<Id, List<String>>();
        
        for (Case c : cases) {
            if (SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId)) {
                Case oldCase = oldMap.get(c.Id);
                if (c.POS_Items_Selected__c && !oldCase.POS_Items_Selected__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.POS_ITEM_MILESTONE );
                }
                // complete preparing barrel milestone
                if (c.Barrel_selected__c && !oldCase.Barrel_selected__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.SELECT_BARREL_MILESTONE );
                }
                
                if (c.Type == 'Sample Kit' && c.Barrel_selected__c && !oldCase.Barrel_selected__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.SELECT_SAMPLE_MILESTONE );
                }
                // complete enter bottle text milestone
                if (c.Bottle_Text_Entered__c && !oldCase.Bottle_Text_Entered__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.ENTER_BOTTLE_TEXT_MILESTONE );
                }
                // complete upload PO milestone
                if (c.Purchase_Order_Uploaded__c && !oldCase.Purchase_Order_Uploaded__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.UPLOAD_PO_MILESTONE );
                }
                // complete Enter SAP Number milestone
                if (String.isNotBlank(c.SAP_Number__c) && String.isBlank(oldCase.SAP_Number__c)) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.ENTER_SAP_NUMBER_MILESTONE );
                }
                // complete enter barrel detail milestone for makers mark
                // once status moves from preparing barrel => pending purchase order then complete the milestone
                if (c.Status == SBP_Constants.PENDING_PURCHASE_ORDER && oldCase.Status == SBP_Constants.PREPARING_BARREL) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.ENTER_BARREL_DETAIL_MILESTONE );
                }
                
                if (c.Trip_Scheduled__c && !oldCase.Trip_Scheduled__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.SCHEDULE_TRIP_MILESTONE );
                }

                if (c.STO_Created__c && !oldCase.STO_Created__c) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, SBP_Constants.STO_CREATED_MILESTONE );
                }
            }
        }
        
        // find the case milestone attached to the case of the correct milestone type
        if(!caseIdToMilestoneNames.isEmpty()){
            for (CaseMilestone caseMilestone : [select id, IsCompleted, MilestoneType.Name, CaseId from CaseMilestone where CaseId IN :caseIdToMilestoneNames.keySet()]) {
                if (caseIdToMilestoneNames.containsKey(caseMilestone.CaseId)) {
                    for (String milestoneName : caseIdToMilestoneNames.get(caseMilestone.CaseId)) {
                        if (milestoneName == caseMilestone.MilestoneType.Name) {
                            caseMilestone.CompletionDate = System.now();
                            caseMilestonesToUpdate.add(caseMilestone);
                        }
                    }
                }
            }
        }
        if (!caseMilestonesToUpdate.isEmpty()) {
            Database.update(caseMilestonesToUpdate, false);
        }
    }
    
    public static Map<Id, List<String>> addMilestoneToMap(Id caseId, Map<Id, List<String>> milestoneMap, String milestoneName) {
        if (milestoneMap.containsKey(caseId)) {
            milestoneMap.get(caseId).add(milestoneName);
        } else {
            milestoneMap.put(caseId, new List<String> {milestoneName});
        }
        
        return milestoneMap;
    }
    
    /**************************************************************************************************************
Description:    If the Submitter field is missing then it needs to be updated for emails that go out for the
Single Barrel Program

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateCaseSubmitterForSingleBarrelCases(List<Case> cases) {
        
        for (Case c : cases) {
            if (SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId) && c.Submitter__c == null) {
                c.Submitter__c = Userinfo.getUserId();
            }
        }
    }
    
    /**************************************************************************************************************
Description:    A regional diplomat should exist for the brand Makers Mark for the Single Barrel Program
The regional diplomat field is used in an apporval process for a Remote Selection.

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateRegionalDiplomat(List<Case> cases) {
        Set<Id> accountIds = new Set<Id>();
        List<String> accountStates = new List<String>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<String, User> stateToUserMap = new Map<String, User>();
        String accountStatesString;
        
        for (Case c : cases) {
            if (c.Regional_Diplomat__c == null && SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId) && c.Brand__c == 'Makers Mark') {
                // if there is no account found in salesforce then the Account Name field will be populated
                // will need to add missing account's state to list
                if (c.Retail_Account__c != null && String.isBlank(c.Retail_Account_Name__c)) {
                    accountIds.add(c.Retail_Account__c);
                } else if (String.isNotBlank(c.Retail_Account_Name__c) && String.isNotBlank(c.State__c)) {
                    accountStates.add(c.State__c);
                }
            }
        }
        
        if(!accountIds.isEmpty()){
            for (Account acc : [select id, BillingState, ShippingState from Account where Id IN :accountIds]) {
                if (String.isNotBlank(acc.BillingState)) {
                    accountMap.put(acc.Id, acc);
                    accountStates.add(SBP_Constants.stateMap.get(acc.BillingState));
                }
            }
        }
        
        accountStatesString = String.join(accountStates, ',');
        if (!accountStates.isEmpty()) {
            for (User u : [select id, Regional_Diplomat_Regions__c from User where Regional_Diplomat_Regions__c includes ( :accountStatesString)]) {
                List<String> userStates = u.Regional_Diplomat_Regions__c.Split(';');
                for (String s : userStates) {
                    stateToUserMap.put(s, u);
                }
            }
        }
        
        for (Case c : cases) {
            String state;
            
            if (c.Retail_Account__c != null && String.isBlank(c.Retail_Account_Name__c)) {
                if (accountMap.containsKey(c.Retail_Account__c)) {
                    String fullStateName = accountMap.get(c.Retail_Account__c).BillingState;
                    state = SBP_Constants.stateMap.get(fullStateName);
                }
            } else if (String.isNotBlank(c.Retail_Account_Name__c) && String.isNotBlank(c.State__c)) {
                state = c.State__c;
            }
            if (stateToUserMap.containsKey(state)) {
                c.Regional_Diplomat__c = stateToUserMap.get(state).Id;
            }
            
        }
    }
    
    /**************************************************************************************************************
Description:    Once the SAP number is entered then the expected ship date for a barrel should be automatically updated
to give the plant an idea of when the barrel is expected to ship.

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateBarrelExpectedShipDate(List<Case> cases, Map<Id, Case> oldMap) {
        List<Barrel__c> barrels = new List<Barrel__c>();
        Set<Id> caseIds = new Set<Id>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId) && (String.isBlank(oldCase.SAP_Number__c) && String.isNotBlank(c.SAP_Number__c))) {
                caseIds.add(c.Id);
            }
        }
        
        if (caseIds.isEmpty()) {
            return;
        }
        
        for (Barrel__c barrel : [select id, Expected_Ship_Date__c, RecordTypeId from Barrel__c where Case__c IN :caseIds]) {
            if (SBP_Constants.clermontBarrelRtIds.contains(barrel.RecordTypeId)) {
                barrel.Expected_Ship_Date__c = Date.today().addDays(84);
                barrels.add(barrel);
            }
        }
        
        if (!barrels.isEmpty()) {
            try {
                update barrels;
            } catch (Exception e) {
                String errorMessage = 'Error updating barrels ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'updateBarrelExpectedShipDate', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
    }
    
    
    /**************************************************************************************************************
Description:    Once an event is assigned to a case then a field is updated which triggers a milestone to end

History
<Date>      <Authors Name>     <Brief Description of Change>
6/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void tripHasBeenScheduled(List<Case> cases, Map<Id, Case> oldMap) {
        List<Barrel__c> barrels = new List<Barrel__c>();
        Set<Id> caseIds = new Set<Id>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId) && (oldCase.Plant_Event__c == null && c.Plant_Event__c != null)) {
                c.Trip_Scheduled__c = true;
            }
        }
    }
    
    /**************************************************************************************************************
Description:    Once the purchase order is updated then the status should be updated

History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void singleBarrelPurchaseOrderUploaded(List<Case> cases, Map<Id, Case> oldMap) {
        List<Barrel__c> barrels = new List<Barrel__c>();
        Set<Id> caseIds = new Set<Id>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.RecordTypeId == SBP_Constants.SINGLE_BARREL_PROOF_SPECIFIC_RT_ID && (!oldCase.Purchase_Order_Uploaded__c && c.Purchase_Order_Uploaded__c)) {
                c.Status = SBP_Constants.PENDING_SHIP_DATE;
            }
        }
    }
    
    /**************************************************************************************************************
Description:    Once the SAP number is entered for the barrel orders they will be sent out to the Sales Rep,
Distributor Contact and any additional people that are listed in the ccEmail field

History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void emailInitialSAPNumberEntered(List<Case> cases, Map<Id, Case> oldMap) {
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :SBP_Constants.SAP_NUMBER_ENTERED_EMAIL_TEMPLATE_NAME limit 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> casesToSendMarketReadiness = new Map<Id, Case>();
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId)) {
                if (String.isBlank(oldCase.SAP_Number__c) && String.isNotBlank(c.SAP_Number__c)) {
                    List<String> emailsToSendTo = new List<String>();
                    // add submitter email(Sales Rep)
                    if (String.isNotBlank(oldMap.get(c.Id).Submitter__r.Email)) {
                        emailsToSendTo.add(oldMap.get(c.Id).Submitter__r.Email);
                    }
                    // add contact email
                    if (String.isNotBlank(oldMap.get(c.Id).Contact.Email)) {
                        emailsToSendTo.add(oldMap.get(c.Id).Contact.Email);
                    }
                    
                    if (String.isNotBlank(oldMap.get(c.Id).CcEmail__c)) {
                        String ccEmails = oldMap.get(c.Id).CcEmail__c;
                        List<String> emailAddresses = ccEmails.split(',');
                        emailsToSendTo.addAll(emailAddresses);
                    }
                    if (oldMap.get(c.Id).Submitter__c != null) {
                        //Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                        Messaging.SingleEmailMessage singleMail = Messaging.renderStoredEmailTemplate(template.Id, oldMap.get(c.Id).Submitter__c, c.Id);
                        singleMail.setToAddresses(emailsToSendTo);
                        singleMail.setTargetObjectId(oldMap.get(c.Id).Submitter__c);
                        singleMail.setTemplateId(template.Id);
                        singleMail.setWhatId(c.Id);
                        singleMail.setSaveAsActivity(false);
                        singleMail.setReplyTo('cs@beamsuntory.com');
                        singleMail.setSenderDisplayName('Beam Suntory Customer Service');
                        emails.add(singleMail);
                    }
                    if('Kansas'.equalsIgnoreCase(SBP_Constants.stateMap.get(c.Account_State__c)) && ('Knob Creek'.equalsIgnoreCase(c.Brand__c) || 'Baker\'s'.equalsIgnoreCase(c.Brand__c))) {
                        casesToSendMarketReadiness.put(c.Id, c);
                    }
                }
            }
        }
        if(!casesToSendMarketReadiness.isEmpty()) {
            List<Barrel__c> barrelRecordsForKansas = [SELECT Id, Case__c FROM Barrel__c WHERE Case__c IN :casesToSendMarketReadiness.keySet()];
            List<EmailTemplate> lstEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :SBP_Constants.REGISTERING_CASE_WITH_COMPLIANCE_EMAIL_TEMPLATE];
            if(!lstEmailTemplate.isEmpty() && SBP_Constants.singleBarrelOWEA != null) {
                for(Barrel__c barrel : barrelRecordsForKansas) {
                    Case barrelParentCase = casesToSendMarketReadiness.get(barrel.Case__c);
                    if(barrelParentCase != null) {
                        Messaging.SingleEmailMessage singleMail = Messaging.renderStoredEmailTemplate(lstEmailTemplate[0].Id, null, barrel.Id);
                        singleMail.setToAddresses(new List<String>{'MarketReadiness@BeamSuntory.com'});
                        singleMail.setOrgWideEmailAddressId(SBP_Constants.singleBarrelOWEA.Id);
                        singleMail.setTemplateId(lstEmailTemplate[0].Id);
                        singleMail.setWhatId(barrel.Id);
                        singleMail.setSaveAsActivity(false);
                        emails.add(singleMail);
                    }
                }
            }
        }
        // check to avoid unnecessary Email Invocation. <Jai Kumar Garg>
        if(!emails.isEmpty())
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
    }
    
    /**************************************************************************************************************
Description:    Update time stamp fields for reporting on when steps were completed

History
<Date>      <Authors Name>     <Brief Description of Change>
10/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateTimeStampsForSingleBarrelTracker(List<Case> cases, Map<Id, Case> oldMap) {
        List<Barrel__c> barrels = new List<Barrel__c>();
        Set<Id> caseIds = new Set<Id>();
        
        for (Case c : cases) {
            
            if (SBP_Constants.caseSingleBarrelRtIds.contains(c.RecordTypeId)) {
                
                if (oldMap != null) {
                    Case oldCase = oldMap.get(c.Id);
                    if (!oldCase.POS_Items_selected__c && c.POS_Items_selected__c) {
                        c.POS_Items_selected_Date__c = Datetime.now();
                    }
                    
                    if (!oldCase.Bottle_Text_Entered__c && c.Bottle_Text_Entered__c) {
                        c.Bottle_Text_Entered_Date__c = Datetime.now();
                    }
                    
                    if (!oldCase.Purchase_Order_Uploaded__c && c.Purchase_Order_Uploaded__c) {
                        c.Purchase_Order_Uploaded_Date__c = Datetime.now();
                    }
                    
                    if (!oldCase.Barrel_Selected__c && c.Barrel_Selected__c) {
                        c.Barrel_Selected_Date__c = Datetime.now();
                    }
                    
                    if (!oldCase.Bottle_Text_Approved__c && c.Bottle_Text_Approved__c) {
                        c.Bottle_Text_Approval_Date__c = Datetime.now();
                    }
                    
                    if (oldCase.POS_Items_selected__c && !c.POS_Items_selected__c) {
                        c.POS_Items_selected_Date__c = null;
                    }
                    
                    if (oldCase.Bottle_Text_Entered__c && !c.Bottle_Text_Entered__c) {
                        c.Bottle_Text_Entered_Date__c = null;
                    }
                    
                    if (oldCase.Purchase_Order_Uploaded__c && !c.Purchase_Order_Uploaded__c) {
                        c.Purchase_Order_Uploaded_Date__c = null;
                    }
                    
                    if (oldCase.Barrel_Selected__c && !c.Barrel_Selected__c) {
                        c.Barrel_Selected_Date__c = null;
                    }
                    
                    if (oldCase.Bottle_Text_Approved__c && !c.Bottle_Text_Approved__c) {
                        c.Bottle_Text_Approval_Date__c = null;
                    }
                } else {
                    if (c.POS_Items_selected__c) {
                        c.POS_Items_selected_Date__c = Datetime.now();
                    }
                    
                    if (c.Bottle_Text_Entered__c) {
                        c.Bottle_Text_Entered_Date__c = Datetime.now();
                    }
                    
                    if (c.Purchase_Order_Uploaded__c) {
                        c.Purchase_Order_Uploaded_Date__c = Datetime.now();
                    }
                    
                    if (c.Barrel_Selected__c) {
                        c.Barrel_Selected_Date__c = Datetime.now();
                    }
                    
                    if (c.Bottle_Text_Approved__c) {
                        c.Bottle_Text_Approval_Date__c = Datetime.now();
                    }
                }
                
            }
        }

        
    }
    
    /**************************************************************************************************************
Method name:    emailEskerPDFs
Object:         Case
RecordType:     Orders - Standard
Date:           11/2018
Details and Notes:  Auto-forward email to Esker (beamsuntory.nobailment.us.sop.qa@process.esker.net) from salesforce
when cases are landed in orders queue.

***************************************************************************************************************/
    /*public static void emailEskerPDFs(List<Case> cases) {
List<Group> QueueId = new List<Group>();
QueueId = [select Id from Group where Type = 'Queue' AND NAME = 'Orders Queue'];
//Map for list of Orders cases
List<Id> caseIdsList = new List<Id>();
List<Messaging.SendEmailResult> emailResult = new List<Messaging.SendEmailResult>();
for (Case c : cases) {
if (c.RecordTypeId == CSConstants.ORDERS_RT_ID &&
c.BSI_Function__c == 'CS' &&
c.OwnerId == QueueId[0].Id &&
c.IsClosed == false &&
(c.Type == 'Standard' || c.Type == null) &&
(c.Origin == 'Customer Portal' || c.Origin == 'Email') &&
c.Email_Sent_to_Esker__c == false
) {
caseIdsList.add(c.Id);
}
}

if (eskerEmailSent == false && caseIdsList!=null && !caseIdsList.isEmpty())
emailEskerPDFsFutureMethod(caseIdsList);
}*/
    /*
@future
public static void emailEskerPDFsFutureMethod(List<Id> caseIdsList) {
runTrigger = false;
Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
Set<Id> caseIdSet = new Set<Id>(caseIdsList);

Map<Id, Case> actionableCaseMap = new Map<Id, Case>([Select Id, Email_Sent_to_Esker__c, CreatedDate from Case Where CreatedDate > 2018-12-13T00:00:00Z AND Id IN :caseIdSet]);
Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();

if (!caseIdSet.isEmpty() ) {
List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId
FROM ContentDocumentLink WHERE LinkedEntityId IN: caseIdSet];
for (ContentDocumentLink cdl : cdLinkList) {
contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
}


Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId, ContentSize, FileExtension, FileType FROM ContentVersion WHERE
FileExtension = 'pdf' AND ContentSize < 10000000 AND
ContentDocumentId IN: contentDocumentToLinkMap.keySet()]);
for (ContentVersion cv : cvMap.values()) {
Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
if (!caseToCVMap.containsKey(entityId)) {
caseToCVMap.put(entityId, new List<Id> {cv.Id});
} else {
caseToCVMap.get(entityId).add(cv.Id);
}
}


Integer size = 0;

String eskerEmailAddress = CSConstants.Esker_EmailAddress;
String systemUserId = CSConstants.SYSTEM_EMAIL_USER_ID;
String OrdersCaseCreationforEskerTemplateName = CSConstants.Orders_Case_Creation_for_Esker;
EmailTemplate OrdersCaseCreationforEskerTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : OrdersCaseCreationforEskerTemplateName LIMIT 1];

for (Id caseId : actionableCaseMap.keySet()) {
Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(OrdersCaseCreationforEskerTemplate.Id, eskerEmailAddress, caseId);
mail.setSaveAsActivity(false);
mail.setToAddresses(new List<String> {eskerEmailAddress});
mail.setWhatId(caseId);

if (caseToCVMap.containsKey(caseId)) {
List<Id> attachmentList = caseToCVMap.get(caseId);
size = 0;
for (ID cv : attachmentList){
size += cvMap.get(cv).ContentSize;
}
if (size > 28000000) break;
mail.setEntityAttachments(attachmentList);
//allMails.add(mail);
try {
Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
if (results[0].success) {
System.debug('The email was sent successfully.');
actionableCaseMap.get(caseId).Email_Sent_to_Esker__c = true;
eskerEmailSent = true;
}
} catch (Exception e) {
CreateExceptionLog.insertErrorLog('caseServices', 'emailEskerPDFs', String.valueOf(e), 'Fatal');
// throw so that we can detect issues before deploying
if (Test.isRunningTest()) {
throw new CS_CustomException(e.getMessage());
}
}
}
}

update actionableCaseMap.values();

}
}*/
        
    /**************************************************************************************************************
Description:    Assign a default account for GBS cases if there is not already an account
Accounts are required on a case in order to use an Entitlement Process

History
<Date>      <Authors Name>     <Brief Description of Change>
12/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void assignAccountToGbsCase(List<Case> cases, Map<Id, Case> oldMap) {
        
        Account acct;
        User u; 
        boolean isUpdate = false;
        
		if (Test.isRunningTest()) {
            	Account a = new Account();
            	a.Name = GBS_Constants.DEFAULT_ACCOUNT_NAME;
            	a.RecordTypeId = GBS_Constants.vendorAccountRecordTypdId;
            	System.debug('name: '+a.Name);
            	System.debug('RecordTypeId: '+a.RecordTypeId);
            	insert a;
            	System.debug('Inserted');
            	acct = a;
        	}
			
		
	    for(Case c: cases){
			if((oldMap==null && c.AccountId==null) || (oldMap!=null && c.AccountId != oldMap.get(c.Id).AccountId && c.AccountId == null)){
				isUpdate = true;
			}
		}
		
			
		if(isUpdate){
			u = [select Id, ContactId from User where Id = : UserInfo.getUserId() limit 1];
			acct = defaultGBSAccount;

			for (Case c : cases) {
            	if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId)) {
                	System.debug('First If');
                	if (u.ContactId == null) {
                    	System.debug('Second If');
					
                    	if ((oldMap==null && c.AccountId==null) || (c.AccountId != oldMap.get(c.Id).AccountId && c.AccountId == null)) {
                        	System.debug('Third If');
                        	if (acct.Id == null) {
                            acct.Id = '0018G000002VvD2QAK';
                        	}
                        	c.AccountId = acct.Id;
                        	System.debug(c.To_Address__c);
                    	}
					
            	}
        	}
    	}
   }
 }
    
    /**************************************************************************************************************
Description:        Once the case is closed all milestones that have not already been completed will be completed and
if necessary a cloned milestone record will be created/updated

History
<Date>      <Authors Name>     <Brief Description of Change>
12/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void completeGBSMilestones(List<Case> cases, Map<Id, Case> oldMap) {
        Map<Id, List<String>> caseIdToMilestoneNames = new Map<Id, List<String>>();
        Map<Id, CaseMilestone> caseMilestoneMap = new Map<Id, CaseMilestone>();
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId)) {
                if (oldCase.Status.equalsIgnoreCase(GBS_Constants.LOGGED) && !(c.Status.equalsIgnoreCase(GBS_Constants.LOGGED))) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, GBS_Constants.LOGGED_MILESTONE );
                } else if (oldCase.Status.equalsIgnoreCase(GBS_Constants.IN_PROGRESS) && !(c.Status.equalsIgnoreCase(GBS_Constants.IN_PROGRESS))) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, GBS_Constants.IN_PROGRESS_MILESTONE );
                } else if (oldCase.Status.equalsIgnoreCase(GBS_Constants.WAITING) && !(c.Status.equalsIgnoreCase(GBS_Constants.WAITING))) {
                    caseIdToMilestoneNames = addMilestoneToMap(c.Id, caseIdToMilestoneNames, GBS_Constants.WAITING_MILESTONE );
                }
            }
        }
        
        if (caseIdToMilestoneNames.isEmpty()) {
            return;
        }
        
        for (CaseMilestone caseMilestone : [select id, IsCompleted, MilestoneType.Name, CaseId from CaseMilestone where CaseId IN :caseIdToMilestoneNames.keySet()]) {
            if (caseIdToMilestoneNames.containsKey(caseMilestone.CaseId)) {
                for (String milestoneName : caseIdToMilestoneNames.get(caseMilestone.CaseId)) {
                    if (milestoneName == caseMilestone.MilestoneType.Name) {
                        caseMilestone.CompletionDate = System.now();
                        caseMilestoneMap.put(caseMilestone.Id, caseMilestone);
                    }
                }
            }
        }
        
        if (caseMilestoneMap.isEmpty()) {
            return;
        }
        
        EntitlementsServices.updateClonedMilestones(caseMilestoneMap.keySet(), null);
        
        if (!caseMilestoneMap.isEmpty()) {
            try {
                update caseMilestoneMap.values();
            } catch (Exception e) {
                String errorMessage = 'Error updating milestones ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'completeGBSMilestones', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
    }
    
    
    /**************************************************************************************************************
Description:        Once a GBS case has been reOpened, the Entitlement process must be reset

History
<Date>      <Authors Name>     <Brief Description of Change>
12/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void checkForReOpenedGBSCase(List<Case> cases, Map<Id, Case> oldMap) {
        for (Case c : cases) {
            if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId) && oldMap != null) {
                Case oldCase = oldMap.get(c.Id);
                // case has been reopened for GBS
                if (GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(oldCase.Status) && !GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                    // reset Entitlement Process
                    c.SLA_Start__c = null;
                    c.isReOpened__c = true;
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:        After a GBS case has been reOpened, a new milestone start and this method updates a flag on the
cloned milestone object indicating that this milestone is the result of a reOpened case
History
<Date>      <Authors Name>     <Brief Description of Change>
12/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateReOpenedMilestones(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId) && oldMap != null) {
                Case oldCase = oldMap.get(c.Id);
                // only pull in statuses that have moved to the closed status from any other non closed status
                if (GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(oldCase.Status) && !GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                    caseIds.add(c.Id);
                }
            }
        }
        
        if (caseIds.isEmpty()) {
            return;
        }
        
        EntitlementsServices.updateClonedMilestonesFuture(null, caseIds);
    }
    
    
    /**************************************************************************************************************
Description:   If a GBS case is reassigned from a User to a Queue, then the status must be reset to "Logged"

History
<Date>      <Authors Name>     <Brief Description of Change>
1/2019      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateGBSStatusOnOwnerChange(List<Case> cases, Map<Id, Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case> casesToUpdate = new List<Case>();
        for (Case c : cases) {
            if (oldMap != null) {
                Case oldCase = oldMap.get(c.Id);
                
                if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId) && (c.OwnerId != oldCase.OwnerId) && !GBS_Constants.CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                    String currentOwnerType = c.OwnerId.getSObjectType().getDescribe().getName();
                    String oldOwnerType = oldCase.OwnerId.getSObjectType().getDescribe().getName();
                    
                    // if the owner goes from a User => Queue
                    if (oldOwnerType != 'Group' && currentOwnerType == 'Group') {
                        c.Status = 'Logged';
                    }
                    // if the owner goes from a Queue => User
                    else if (oldOwnerType == 'Group' && currentOwnerType != 'Group') {
                        c.Status = 'In Progress';
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:        Assigns business hours to all GBS cases to drive the case milestone times on the case records

History
<Date>      <Authors Name>     <Brief Description of Change>
1/2019      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void assignGBSBusinessHoursToCase(List<Case> cases, Map<Id, Case> oldMap) {
        Map<String, GBS_Business_Hours_Setting__mdt> gbsCenterToSetting = new Map<String, GBS_Business_Hours_Setting__mdt>();
        Map<String, BusinessHours> businessHoursMap = new Map<String, BusinessHours>();
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : cases) {
            if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId)) {
                if (oldMap != null) {
                    Case oldCase = oldMap.get(c.Id);
                    if (oldCase.GBS_Center__c != c.GBS_Center__c) {
                        casesToUpdate.add(c);
                    }
                } else {
                    casesToUpdate.add(c);
                }
            }
        }
        
        if (!casesToUpdate.isEmpty()) {
            businessHoursMap = getBusinessHours();
            //Code Added by Deekshika 14-2-2023 - Add SOQL query under if block
            for (GBS_Business_Hours_Setting__mdt gbsSetting : [Select id, Business_Hours__c, GBS_Center__c from GBS_Business_Hours_Setting__mdt]) {
                gbsCenterToSetting.put(gbsSetting.GBS_Center__c, gbsSetting);
            }
        }
        
        for(Case c: casesToUpdate) {
            String businessHoursName;
            if (GBS_Constants.gbsRecordTypeIds.contains(c.RecordTypeId)) {
                if (gbsCenterToSetting.containsKey(c.GBS_Center__c)) {
                    businessHoursName = gbsCenterToSetting.get(c.GBS_Center__c).Business_Hours__c;
                    
                    if (businessHoursMap.containsKey(businessHoursName)) {
                        c.BusinessHoursId = businessHoursMap.get(businessHoursName).Id;
                    }
                }
            }
        }
    }
    /**************************************************************************************************************
Method name:    caseSetStatusChangeWithSLA
Object:         Case
Date:           01/04/2019
Details and Notes: SAL-135
Sets the Status Changed Within SLA to true for record type EDI Orders, Orders, Changes, Inquiry, Quality Claim, Order Claim & Escalated Form.
Added by: Priyankar Saha
Company: TCS
*****************************************************************************************************************************/
    /*---Start SAL-135---*/
    public static void caseSetStatusChangeWithSLA(List<Case> newCases, Map<Id, Case> oldMap) {
        System.debug('---Trigger fired---' + newCases);
        for (Case currCase : newCases) {
            String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(currCase.recordtypeid).getname();
            System.debug('---Record Type Information---' + recordtypename);
            if ((recordtypename == 'EDI Order') || (recordtypename == 'Orders') || (recordtypename == 'Quality Claim') || (recordtypename == 'Order Claim') || (recordtypename == 'Inquiry')) {
                if ((currCase.Running_Case_Time__c > 0) && (currCase.Running_Case_Time__c <= 10)) {
                    String newStatus = currCase.Status;
                    String oldStatus = oldMap.get(currCase.Id).Status;
                    System.debug('---New Status--- ' + newStatus + '---Old Status---' + oldStatus);
                    if (oldStatus == 'New' && newStatus != 'New') {
                        currCase.Status_Changed_Within_SLA__c = true;
                    }
                }
            } else if (recordtypename == 'Changes') {
                if ((currCase.Running_Case_Time__c > 0) && (currCase.Running_Case_Time__c <= 4)) {
                    String newStatus = currCase.Status;
                    String oldStatus = oldMap.get(currCase.Id).Status;
                    System.debug('---New Status--- ' + newStatus + '---Old Status---' + oldStatus);
                    if (oldStatus == 'New' && newStatus != 'New') {
                        currCase.Status_Changed_Within_SLA__c = true;
                    }
                }
            } else if (recordtypename == 'Escalated Form') {
                if ((currCase.Running_Case_Time__c > 0) && (currCase.Running_Case_Time__c <= 2)) {
                    String newStatus = currCase.Status;
                    String oldStatus = oldMap.get(currCase.Id).Status;
                    System.debug('---New Status--- ' + newStatus + '---Old Status---' + oldStatus);
                    if (oldStatus == 'New' && newStatus != 'New') {
                        currCase.Status_Changed_Within_SLA__c = true;
                    }
                }
            }
        }
    }
    /*---End SAL-135---*/
    
    /**************************************************************************************************************
Description:    Once the Recommendation for the sub case of a quality claim has been entered
then an email will go out to the owner of the parent case notifying them
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2019      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void emailQualityRecommendationToParentCaseOwner(List<Case> cases, Map<Id, Case> oldMap) {
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Quality_Sub_Case_Recommendation'
                                  limit 1
                                 ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> updatedCaseMap = new Map<Id, Case> ([select Id, Parent.Owner.Email, Parent.OwnerId from Case where Id IN: oldMap.keySet()]);
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID) {
                if (String.isBlank(oldCase.Recommendation__c) && String.isNotBlank(c.Recommendation__c)) {
                    List<String> emailsToSendTo = new List<String> ();
                    
                    Messaging.SingleEmailMessage singleMail = Messaging.renderStoredEmailTemplate(template.Id, c.Parent.OwnerId, c.Id);
                    singleMail.setToAddresses(new List <String> {
                        updatedCaseMap.get(c.Id).Parent.Owner.Email
                            });
                    singleMail.setSaveAsActivity(false);
                    singleMail.setReplyTo('cs@beamsuntory.com');
                    singleMail.setSenderDisplayName('Beam Suntory Customer Service');
                    emails.add(singleMail);
                }
            }
        }
        // check to avoid unnecessary Email Invocation. <Jai Kumar Garg>
        if(!emails.isEmpty() && !Test.isRunningTest())
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
    }
    
    /**************************************************************************************************************
Description:    Once the Non-Technical response for the sub case of a quality claim has been entered
then an email will go out to the owner of the parent case notifying them that they can
communicate the issue out and close the parent case
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2019      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void emailNonTechnicalResponseToParentCaseOwner(List<Case> cases, Map<Id, Case> oldMap) {
        List<EmailTemplate> templates = new List<EmailTemplate>();
        templates = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Quality_Sub_Case_Completed' OR DeveloperName='Order_Claim_Sub_Case_Completed' ORDER BY DeveloperName ASC];
        
        /*EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Quality_Sub_Case_Completed'
limit 1
];*/
        
        List<Messaging.SingleEmailMessage> emails = new List< Messaging.SingleEmailMessage > ();
        Map<Id, Case> updatedCaseMap = new Map<Id, Case> ([select Id, Parent.Owner.Email, Parent.OwnerId from Case where Id IN: oldMap.keySet()]);
        
        for (Case c : cases) {
            Case oldCase = oldMap.get(c.Id);
            if (c.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID || c.RecordtypeId==CSConstants.ORDER_CLAIM_SUBCASE_RT_ID ) {
                if (String.isBlank(oldCase.Non_Technical_Response__c) && String.isNotBlank(c.Non_Technical_Response__c)) {
                    List<String> emailsToSendTo = new List<String> ();
                    String templateID;
                    if(c.RecordtypeId==CSConstants.ORDER_CLAIM_SUBCASE_RT_ID && templates.size()>0)
                        templateID = templates[0].Id;
                    else
                        templateID = templates[1].Id;
                    //Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    Messaging.SingleEmailMessage singleMail = Messaging.renderStoredEmailTemplate(templateID, c.Parent.OwnerId, c.Id);
                    singleMail.setToAddresses(new List <String> {
                        updatedCaseMap.get(c.Id).Parent.Owner.Email
                            });
                    singleMail.setSaveAsActivity(false);
                    singleMail.setReplyTo('cs@beamsuntory.com');
                    singleMail.setSenderDisplayName('Beam Suntory Customer Service');
                    emails.add(singleMail);
                }
            }
        }
        // check to avoid unnecessary Email Invocation. <Jai Kumar Garg>
        if(!emails.isEmpty() && !Test.isRunningTest())
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
    }
    
    /**************************************************************************************************************
Description:    Once a parent case with the record type "Quality Claim" has been created, a sub case needs to be
created.  The Customer Service team will work on the parent case while a Plant team will work
on the sub case.
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2019      Craig Austgen       Initial Creation
<Jai Kumar Garg>
***************************************************************************************************************/
    public static void createQualityClaimSubCase(List <Case> cases, Map<Id, Case> oldMap) {
        List <Case> casesToInsert = new List<Case>();
        
        /*---Optimized Patch Added By Priyankar Saha(TCS)*/
        for(Case c : [Select Id, RecordTypeId, CaseNumber, Status, Sub_Status__c,Bottling_Plant__c,(Select Id, CaseNumber From Cases) From Case Where Id IN: oldMap.keySet()]){
            
            if (c.RecordTypeId == CSConstants.QC_RT_ID && c.Cases.isEmpty() && 'Pending with Quality'.equalsIgnoreCase(c.Sub_Status__c) && 'In Progress'.equalsIgnoreCase(c.Status)) {
                
                //Case newSubCase = c.clone(false, false, false, false);
                System.debug('Trigger New Map:::'+Trigger.newMap.get(c.Id));
                Case newSubCase = (Case) Trigger.newMap.get(c.Id).clone(false, false, false, false);
                newSubCase.ParentId = c.Id;
                newSubCase.Status = 'New';
                newSubCase.Sub_Status__c = null;
                newSubCase.RecordTypeId = CSConstants.QC_SUBCASE_RT_ID;
                //newSubCase.EntitlementId = null; // 04/09/2020 Priyankar
                //newSubCase.AccountId = AccountIdvalue;
                //newSubCase.Bottling_Plant__c = c.Bottling_Plant__c;
                casesToInsert.add(newSubCase);
                
            }
        }
        /* -- Code commented as SOQL Query was inside for loop--
for (Case c : cases) {
List<Case> lstCases = [SELECT Id FROM Case Where ParentId = :c.Id];
if (c.RecordTypeId == CSConstants.QC_RT_ID && lstCases.isEmpty() && 'Pending with Quality'.equalsIgnoreCase(c.Sub_Status__c) && 'In Progress'.equalsIgnoreCase(c.Status)) {
Case newSubCase = c.clone(false, false, false, false);
newSubCase.ParentId = c.Id;
newSubCase.Status = 'New';
newSubCase.Sub_Status__c = null;
newSubCase.RecordTypeId = CSConstants.QC_SUBCASE_RT_ID;
casesToInsert.add(newSubCase);
}
}*/    
        if (!casesToInsert.isEmpty()) {
            try {
                addEntitlementToQualityClaimSubCase(casesToInsert);
                System.debug('New Version Of Sub Case:::'+casesToInsert);
                insert casesToInsert;
            } catch (Exception e) {
                String errorMessage = 'Error creating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'createQualityClaimSubCase', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:    Once a case with the record type of "Quality Claim" moves to the status of "Pending Sub-Case"
then the sub case will be assigned to the correct bottling plant queue so that it can we worked
on by the members of that bottling plant.
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2019      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateQualityClaimSubCase(List <Case> cases, Map <Id, Case> oldMap) {
        Set <Id> parentsIds = new Set <Id> ();
        Map <Id, Case> casesToUpdate = new Map <Id, Case> ();
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        
        for (Case c : cases) {
            if (oldMap != null) {
                Case oldCase = oldMap.get(c.Id);
                /*Below case added by Metacube Side due to not update the sub case owner based on the parent case update*/
                //if (c.RecordTypeId == CSConstants.QC_RT_ID && ((c.Status == CSConstants.PENDING_SUB_CASE && oldCase.Status != CSConstants.PENDING_SUB_CASE) || (CSConstants.PENDING_WITH_QUALITY.equalsIgnoreCase(c.Sub_Status__c) && 'In Progress'.equalsIgnoreCase(c.Status)))) {
                if (c.RecordTypeId == CSConstants.QC_RT_ID && oldCase.Sub_Status__c != CSConstants.PENDING_WITH_QUALITY && (CSConstants.PENDING_WITH_QUALITY.equalsIgnoreCase(c.Sub_Status__c) && CSConstants.CASE_IN_PROGRESS.equalsIgnoreCase(c.Status))) {
                    parentsIds.add(c.Id);
                }
            }
        }
        
        if(!parentsIds.isEmpty()){
            for (Case c : [select Id, Assign_Queue_to_Case__c, EntitlementId, Status from Case where ParentId IN: parentsIds]) {
                System.debug('Entitlement Id after Update:::'+c.EntitlementId);
                c.Assign_Queue_to_Case__c = true;
                c.setOptions(dmo);
                casesToUpdate.put(c.Id, c);
            }
        }
        if (!casesToUpdate.isEmpty()) {
            try {
                update casesToUpdate.values();
            } catch (Exception e) {
                String errorMessage = 'Error updating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'updateQualityClaimSubCase', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:        Assigns the Entitlement associated with the account on the case record to the case, if there is no entitlement
then one will be created for that account and assigned to the case record
History
<Date>      <Authors Name>     <Brief Description of Change>
2/2019      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void addEntitlementToQualityClaimCase(List <Case> cases) {
        Set <Id> accountIds = new Set <Id>();
        Map <Id, Map <String, Entitlement>> accountIdToEntitlementMap = new Map <Id, Map <String, Entitlement>>();
        for (Case c : cases) {
            System.debug('Entitlement Id here:::'+c.EntitlementId);
            if ((CSConstants.qualityClaimRecordTypeIds.contains(c.RecordTypeId) || CSConstants.CONSUMER_INQUIRY_RT_ID == c.RecordTypeId) && !CSConstants.QC_CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                // check for AccountId on Case
                if (c.AccountId != null) {
                    accountIds.add(c.AccountId);
                }
            }
        }
        if (accountIds.isEmpty()) {
            return;
        }
        Map <Id, Account> acctMap = new Map <Id, Account> ([select id, (Select Id, Name, SlaProcessId from Entitlements Where Name =: CSConstants.SLA_COMPLAINT_AND_INQUIRY_ENTITLEMENT OR Name =: CSConstants.QUALITY_CLAIM_ENTITLEMENT) from Account where Id IN: accountIds]);
        //Map <Id, Account> defaultEntitlementForAccount = getEntitlementsFromAccount(acctMap.values(), CSConstants.QUALITY_CLAIM_ENTITLEMENT);
        Map <Id, Account> defaultEntitlementForAccount = new Map<Id,Account>();
        List<Entitlement> entitlementsToCreate = new List <Entitlement>();
        ContactUs_Setting__c mc = ContactUs_Setting__c.getValues('Default');
        String entitlementProcessID = mc != null ? mc.EntitlementProcess__c : null;
        ContactUs_Setting__c mcq = ContactUs_Setting__c.getValues('QualityClaim'); // Added by Priyankar
        String entitlementProcessQualityID = mcq != null ? mcq.EntitlementProcess__c : null; // Added by Priyankar
        
        /*---Modified by Priyankar Saha Start---*/
        for(Account accInstance : acctMap.values()) {
            if(accInstance.Entitlements.size() < 2) {
                if(accInstance.Entitlements.size() == 0){
                    Entitlement entitlementInstance = new Entitlement(Name = CSConstants.SLA_COMPLAINT_AND_INQUIRY_ENTITLEMENT, AccountId = accInstance.ID, StartDate = system.today(), SlaProcessId = entitlementProcessID);
                    entitlementsToCreate.add(entitlementInstance);
                    Entitlement entitlementInstanceQuality = new Entitlement(Name = CSConstants.QUALITY_CLAIM_ENTITLEMENT, AccountId = accInstance.ID, StartDate = system.today(), SlaProcessId = entitlementProcessQualityID);
                    entitlementsToCreate.add(entitlementInstanceQuality);
                }
                else if(accInstance.Entitlements.size() == 1){
                    String entName = accInstance.Entitlements[0].Name;
                    if(entName != CSConstants.QUALITY_CLAIM_ENTITLEMENT){
                        Entitlement entitlementInstanceQuality = new Entitlement(Name = CSConstants.QUALITY_CLAIM_ENTITLEMENT, AccountId = accInstance.ID, StartDate = system.today(), SlaProcessId = entitlementProcessQualityID);
                        entitlementsToCreate.add(entitlementInstanceQuality);
                    } else if(entName != CSConstants.SLA_COMPLAINT_AND_INQUIRY_ENTITLEMENT){
                        Entitlement entitlementInstance = new Entitlement(Name = CSConstants.SLA_COMPLAINT_AND_INQUIRY_ENTITLEMENT, AccountId = accInstance.ID, StartDate = system.today(), SlaProcessId = entitlementProcessID);
                        entitlementsToCreate.add(entitlementInstance);
                    }
                }
            } /*else if(accInstance.Entitlements[0].SlaProcessId != entitlementProcessID) {
accInstance.Entitlements[0].SlaProcessId = entitlementProcessID;
entitlementsToCreate.add(accInstance.Entitlements[0]);
}*/
        }
        //check added by Sangeet on 18-04-2023
        if(!entitlementsToCreate.isEmpty()){
            upsert entitlementsToCreate;
        }
        /*---Modified by Priyankar Saha End---*/
        
        accountIdToEntitlementMap = mapAccountToEntitlements(acctMap.keySet());
        System.debug('Account Id to entitlement map:::'+accountIdToEntitlementMap);
        
        for (Case c : cases) {
            if (CSConstants.qualityClaimRecordTypeIds.contains(c.RecordTypeId) ||  CSConstants.CONSUMER_INQUIRY_RT_ID == c.RecordTypeId) {
                if (accountIdToEntitlementMap.containsKey(c.AccountId)) {
                    c.SLA_Start__c = null; 
                    // added by sripal (added by Priyankar:- Quality Claim Record Type Id along with Consumer Inqueries)
                    if( CSConstants.QC_RT_ID == c.RecordTypeId || CSConstants.CONSUMER_INQUIRY_RT_ID == c.RecordTypeId){
                        c.EntitlementId = accountIdToEntitlementMap.get(c.AccountId).get(CSConstants.SLA_COMPLAINT_AND_INQUIRY_ENTITLEMENT).Id;
                    } // added by Priyankar
                    else if(CSConstants.QC_SUBCASE_RT_ID ==c.RecordTypeId && c.Status==CSConstants.NEW_STATUS){
                        continue;
                    }
                    // added by sripal
                    else if(CSConstants.QC_SUBCASE_RT_ID ==c.RecordTypeId && c.Status==CSConstants.WORKING){
                        c.EntitlementId = accountIdToEntitlementMap.get(c.AccountId).get(CSConstants.QUALITY_CLAIM_ENTITLEMENT).Id;
                    }
                    System.debug('Case Record Type Id:::'+c.RecordTypeId);
                    System.debug('Case Entitlement Id:::'+c.EntitlementId);
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:        Assigns the Entitlement for qulaity claim sub case associated with the account on the case record, if there is no entitlement
then one will be created for that account and assigned to the case record
History
<Date>      <Authors Name>     <Brief Description of Change>
9/2019      Sripal Kotha       Initial Creation

*************************************************************************************************/
    public static void addEntitlementToQualityClaimSubCase(List <Case> cases) {
        Set <Id> accountIds = new Set <Id>();
        Map <Id, Map <String, Entitlement>> accountIdToEntitlementMap = new Map <Id, Map <String, Entitlement>>();
        for (Case c : cases) {
            if ((CSConstants.QC_SUBCASE_RT_ID.equals(c.RecordTypeId)) && !CSConstants.QC_CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                // check for AccountId on Case;
                if (c.AccountId != null) { // Code changed Priyankar removed (&& c.EntitlementId == null)
                    accountIds.add(c.AccountId);
                }
            }
        }
        System.debug('Account Id set:::'+accountIds);
        if (accountIds.isEmpty()) {
            return;
        }
        
        Map <Id, Account> acctMap = new Map <Id, Account> ([select id, (Select Id, Name from Entitlements) from Account where Id IN: accountIds]);      
        Map <Id, Account> defaultEntitlementForAccount = getEntitlementsFromAccount(acctMap.values(), CSConstants.QUALITY_CLAIM_SUB_CASE_ENTITLEMENT);
        createEntitlementsForAccount(defaultEntitlementForAccount, acctMap, CSConstants.QUALITY_CLAIM_SUB_CASE_ENTITLEMENT, CSConstants.QUALITY_CLAIM_SUB_CASE_ENTITLEMENT_PROCESS);
        accountIdToEntitlementMap = mapAccountToEntitlements(acctMap.keySet());
        System.debug(':::Account Id Entitlement Map:::'+accountIdToEntitlementMap);
        
        for (Case c : cases) {
            if ((CSConstants.QC_SUBCASE_RT_ID.equals(c.RecordTypeId))) {
                //if (c.EntitlementId == null) { // Code Changed Priyankar
                if (accountIdToEntitlementMap.containsKey(c.AccountId)) {
                    c.SLA_Start__c = null;
                    c.EntitlementId = accountIdToEntitlementMap.get(c.AccountId).get(CSConstants.QUALITY_CLAIM_SUB_CASE_ENTITLEMENT).Id;
                    System.debug('Subcase Entitlement Id:::'+c.EntitlementId);
                }
                //} Code Changed Priyankar
            }
        }
    }

    /**************************************************************************************************************
<Date>      <Authors Name>     <Brief Description of Change>
9/2019      Sripal Kotha       Initial Creation

*************************************************************************************************/
    public static void addEntitlementToQualityClaimParentCase(List <Case> cases) {
        Set <Id> accountIds = new Set <Id>();
        Map <Id, Map <String, Entitlement>> accountIdToEntitlementMap = new Map <Id, Map <String, Entitlement>>();
        for (Case c : cases) {
            if ((CSConstants.QC_RT_ID.equals(c.RecordTypeId)) && !CSConstants.QC_CLOSED_STATUS_VARIATIONS.contains(c.Status)) {
                // check for AccountId on Case
                if (c.AccountId != null) {
                    accountIds.add(c.AccountId);
                }
            }
        }
        if (accountIds.isEmpty()) {
            return;
        }
        Map <Id, Account> acctMap = new Map <Id, Account> ([select id, (Select Id, Name from Entitlements) from Account where Id IN: accountIds]);
        Map <Id, Account> defaultEntitlementForAccount = getEntitlementsFromAccount(acctMap.values(), CSConstants.QUALITY_CLAIM_PARENT_CASE_ENTITLEMENT);
        createEntitlementsForAccount(defaultEntitlementForAccount, acctMap, CSConstants.QUALITY_CLAIM_PARENT_CASE_ENTITLEMENT, CSConstants.QUALITY_CLAIM_PARENT_CASE_ENTITLEMENT_PROCESS);
        accountIdToEntitlementMap = mapAccountToEntitlements(acctMap.keySet());
        
        
        for (Case c : cases) {
            if (CSConstants.qualityClaimRecordTypeIds.contains(c.RecordTypeId)) {
                if (accountIdToEntitlementMap.containsKey(c.AccountId)) {
                    c.SLA_Start__c = null;
                    c.EntitlementId = accountIdToEntitlementMap.get(c.AccountId).get(CSConstants.QUALITY_CLAIM_PARENT_CASE_ENTITLEMENT).Id;
                }
            }
        }
    }
        
    /**************************************************************************************************************
Description:        Set time stamp for when the non technical response is entered
History
<Date>      <Authors Name>     <Brief Description of Change>
3/2019      Craig Austgen       Initial Creation

*************************************************************************************************/
    public static void setQualityClaimTimeStamp(List <Case> cases, Map<Id,Case> oldMap) {
        
        for (Case c : cases) {
            if (c.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID) {
                Case oldCase = oldMap.get(c.Id);
                
                if(String.isBlank(oldCase.Non_Technical_Response__c) && !String.isBlank(c.Non_Technical_Response__c)){
                    c.Non_Technical_Response_Time_Stamp__c = System.now();
                }
                else if(!String.isBlank(oldCase.Non_Technical_Response__c) && String.isBlank(c.Non_Technical_Response__c)){
                    c.Non_Technical_Response_Time_Stamp__c = null;
                }
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    setGBSOutlookCasestoRecordType
Object:         Case
Date:           07/24/2019
Details and Notes: SR_146951
Salesforce - Updates to case record type: logistics request. Whenever a GBS Outlook Case is created from Outlook Salesforce Addin this method
will move the case to correct record type based on Type
Added by: Priyankar Saha
Company: TCS
*****************************************************************************************************************************/
    /*---Start SR_146951---*/
    public static void setGBSOutlookCasestoRecordType(List<Case> newCases){
        for(Case c1 : newCases){
            string recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(c1.recordtypeid).getname();
            if(recordtypename =='GBS Outlook'){
                if(c1.Type == 'Global Master Data Management'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Human Resources'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HR').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Order to Cash / Billing'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OTC Billing').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Payroll'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Payroll').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Procure to Pay / Accounts Payable'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PTP/AP').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Record to Report'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RTR').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Travel & Entertainment'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('T&E').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Claims'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claims').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
                else if(c1.Type == 'Tax'){
                    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Tax').getRecordTypeId();
                    c1.RecordTypeId = caseRecordTypeId;
                }
            }  
        }
    }
    /*---End SR_146951---*/
    
    /**************************************************************************************************************
Description:        Set case priority to critical or high based on provided commnent
History
<Date>         <Authors Name>     <Brief Description of Change>
4/12/2019      Jai Kumar Garg       Initial Creation

*************************************************************************************************/
    public static void setCasePriority(List<Case> cases) {
        if(!cases.isEmpty()) {
            List<TriggerWords__c> lstTriggerWord = SLT_TriggerWord.getAllTriggerWords();
            Set<String> caseBrands = new Set<String>();
            List<Case> priorityNotSetByTriggerWordCases = new List<Case>();
            Boolean isPrioritySetByTriggerWord = false;
            
            for(Case currentCaseInfo : cases) {
                isPrioritySetByTriggerWord = false;
                caseBrands.add(currentCaseInfo.Brand__c);
                if((CSConstants.EMAIL.equalsIgnoreCase(currentCaseInfo.Origin) || CSConstants.WEB.equalsIgnoreCase(currentCaseInfo.Origin)) && (currentCaseInfo.RecordTypeId == CSConstants.QC_RT_ID || currentCaseInfo.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID)) {
                    Integer inquiryCount = 0;
                    Integer complaintCount = 0;
                    Integer lowPriorityInquiryCount = 0;
                    Integer highPriorityInquiryCount = 0;
                    String caseSubject = String.isNotEmpty(currentCaseInfo.Subject) ? ' ' + currentCaseInfo.Subject.replaceAll('[^a-zA-Z0-9 ]', ' ') + ' ' : null;
                    String caseDescription = String.isNotEmpty(currentCaseInfo.Description) ? ' ' + currentCaseInfo.Description.replaceAll('[^a-zA-Z0-9 ]', ' ') + ' ' : null;
                    for(TriggerWords__c triggerWord : lstTriggerWord) {
                        //check to find whether case subject or description contains trigger word
                        if((caseSubject != null && caseSubject.containsIgnoreCase(' ' + triggerWord.name + ' ')) || 
                           (caseDescription != null && caseDescription.containsIgnoreCase(' ' + triggerWord.name + ' '))) {
                               if(CSConstants.CRITICAL.equalsIgnoreCase(triggerWord.Priority__c)) { 
                                   currentCaseInfo.RecordTypeId = CSConstants.QC_RT_ID;
                                   currentCaseInfo.Priority = triggerWord.Priority__c;
                                   isPrioritySetByTriggerWord = true;
                               }
			       currentCaseInfo.trigger_word__c=true;
                               inquiryCount = CSConstants.INQUIRY.equalsIgnoreCase(triggerWord.Type__c) ? ++inquiryCount : inquiryCount;
                               complaintCount = CSConstants.COMPLAINT.equalsIgnoreCase(triggerWord.Type__c) ? ++complaintCount : complaintCount;
                               lowPriorityInquiryCount = CSConstants.INQUIRY.equalsIgnoreCase(triggerWord.Type__c) &&  CSConstants.LOW.equalsIgnoreCase(triggerWord.Priority__c) ? ++lowPriorityInquiryCount : lowPriorityInquiryCount; 
                               highPriorityInquiryCount = CSConstants.INQUIRY.equalsIgnoreCase(triggerWord.Type__c) &&  CSConstants.HIGH.equalsIgnoreCase(triggerWord.Priority__c) ? ++highPriorityInquiryCount : highPriorityInquiryCount; 
                           }
                    }
                    
                    if(!isPrioritySetByTriggerWord && complaintCount > 0 || CSConstants.PRODUCT_PACKAGING_ISSUE.equalsIgnoreCase(currentCaseInfo.How_can_we_help__c)) {
                        currentCaseInfo.RecordTypeId = CSConstants.QC_RT_ID;
                        currentCaseInfo.Priority = !CSConstants.CRITICAL.equalsIgnoreCase(currentCaseInfo.Priority) ? CSConstants.HIGH : CSConstants.CRITICAL;
                        isPrioritySetByTriggerWord = true;
                    } else if(!isPrioritySetByTriggerWord && inquiryCount > 0 && highPriorityInquiryCount > 0) {
                        currentCaseInfo.Priority = CSConstants.HIGH;
                        isPrioritySetByTriggerWord = true;
                    } else if(!isPrioritySetByTriggerWord && inquiryCount > 0 && lowPriorityInquiryCount > 0) {
                        currentCaseInfo.Priority = CSConstants.LOW;
                        isPrioritySetByTriggerWord = true;
                    } else if(!isPrioritySetByTriggerWord && String.isNotEmpty(currentCaseInfo.How_can_we_help__c)) {
                        /**
* Check for "Visiting the distillery" help option, if case description contains keywords
* like "Today, Tomorrow or This Week" than case priority should be "HIGH"
*/
                        if(CSConstants.VISITING_THE_DISTILLERY.equalsIgnoreCase(currentCaseInfo.How_can_we_help__c) &&
                           (currentCaseInfo.Description.containsIgnoreCase(CSConstants.TODAY) || 
                            currentCaseInfo.Description.containsIgnoreCase(CSConstants.TOMORROW) || 
                            currentCaseInfo.Description.containsIgnoreCase(CSConstants.THIS_WEEK))) {
                                currentCaseInfo.Priority = CSConstants.HIGH;
                                isPrioritySetByTriggerWord = true;
                            }
                    }
                    if(!isPrioritySetByTriggerWord) {
                        priorityNotSetByTriggerWordCases.add(currentCaseInfo);
                    }
                }  
            }
            
            //Logic to setup priority if no trigger word found in case description
            if(!priorityNotSetByTriggerWordCases.isEmpty()) {
                Map<String, String> howCanIHelpAddtionalInfoPriorityMap = new Map<String, String>();
                if(!caseBrands.isEmpty())
                    howCanIHelpAddtionalInfoPriorityMap = SLT_CustomMetadata.getBrandCategoryMappingByBrand(caseBrands);
                for(Case currentCaseInfo : priorityNotSetByTriggerWordCases) {
                    String key = String.isNotEmpty(currentCaseInfo.AdditionalInformation__c) ? 
                        currentCaseInfo.How_can_we_help__c + ' - ' + currentCaseInfo.AdditionalInformation__c + ' - ' + currentCaseInfo.Brand__c: 
                    currentCaseInfo.How_can_we_help__c + ' - ' + currentCaseInfo.Brand__c;
                    String priority = howCanIHelpAddtionalInfoPriorityMap.get(key);
                    if(String.isNotEmpty(priority)) {
                        currentCaseInfo.Priority = priority;
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************************
Description:  When a lot code number is entered it should be added to the look up lot code field  
<Date>         <Authors Name>      <Company>   <Brief Description of Change>
3/06/2020      Sripal Kotha          TCS            Initial Creation   
*************************************************************************************************/
    public static void AddingLotCode(List<Case>newCases){
        Set<String>LotCodes = new Set<String>();
        Set<Id>CaseIDs = new Set<Id>();
        for(case caserecord: newCases){
            if(caserecord.Lot_Code__c!=null){
                LotCodes.add(caserecord.Lot_Code__c);
            }
        }
        
        List<Lot_Codes__c>LotCodeRecords = new List<Lot_Codes__c>();
        Map<String,Lot_Codes__c> LotCodeMap = new Map<String,Lot_Codes__c>();
        if(LotCodes.size()>0)
            LotCodeRecords = [SELECT id,name from Lot_Codes__c WHERE Name IN:LotCodes];
        for(Lot_Codes__c ltcode: LotCodeRecords){
            if(!LotCodeMap.Containskey(ltcode.Name))
                LotCodeMap.put(ltcode.name,ltcode);
        }
        
        for(Case carec : newCases){
            string recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(carec.recordtypeid).getname();
            if(carec.Lot_Code__c!=null){
                If(LotCodeMap.Containskey(carec.Lot_Code__c) && (recordtypename == 'Quality Claim')){
                    carec.LotCode__c = LotCodeMap.get(carec.Lot_Code__c).id;
                    
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description:    This method will be used to allocated barrel from barrel allocation process or to update case 
status if allocation is not avaiable
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
12/2022 	Sahana S S			Metacube	   Modified for SAL-3293
**************************************************************************************************************/
    public static void updateBrandAllocationForSingleBarrel(List <Case> lstCase, Map<Id, Case> mapOldCase) {
        //Added by Deekshika 23-3-2023 - created all list above for loop
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc;
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc;
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc;

        try {
            List <Case> casesToInsert = new List<Case>();
            List<String> lstCaseStatus = new List<String>{'New','Pending Documentation', 'Preparing Barrel', 'Pending Final Details', 'Order Shipped'};
                for(Case newCase :lstCase){
                    if(((newCase.Case_Record_Type__c == CSConstants.SINGLE_BARREL_STANDARD || newCase.Case_Record_Type__c == CSConstants.SINGLE_BARREL_PROOF_SPECIFIC)&& (newCase.Status == CSConstants.NEW_STATUS ||
                                                                                                                                                                          newCase.Status == CSConstants.CANCELLED_KIT_NOT_SELECTED || newCase.Status == CSConstants.CANCELED || newCase.Status == CSConstants.PENDING_DOCUMENTATION ) && 
                        newCase.Flow_Completed__c && mapOldCase.containsKey(newCase.Id) && !String.isEmpty(newCase.Allocation_Allocated_From__c) && newCase.Brand__c != 'Makers Mark') || (newCase.Brand__c == 'Makers Mark' && newCase.Barrel_Selected__c && mapOldCase.containsKey(newCase.Id) && !String.isEmpty(newCase.Allocation_Allocated_From__c))) {                          
                            if(newCase.Allocation_Allocated_From__c == CSConstants.DISTRIBUTOR) {                             
                                lstDistAlloc = SLT_SB2_BrandCountryRegionStateDistAlloc.getDistAllocByAccountAndBrandAlloc(String.valueOf(newCase.Brand_Allocation__c).subString(0,15), newCase.AccountId);
                                if(!lstDistAlloc.isEmpty()){
                                    if(((newCase.Status == CSConstants.NEW_STATUS || newCase.Status == CSConstants.PENDING_DOCUMENTATION) && !mapOldCase.get(newCase.Id).Flow_Completed__c && newCase.Brand__c != 'Makers Mark') || (newCase.Brand__c == 'Makers Mark' && !mapOldCase.get(newCase.Id).Barrel_Selected__c)) {
                                        if(lstDistAlloc[0].Used_Allocations__c != null) {
                                            lstDistAlloc[0].Used_Allocations__c += 1;
                                        } else {
                                            lstDistAlloc[0].Used_Allocations__c = 1;
                                        }
                                    } else if(newCase.Status == CSConstants.CANCELLED_KIT_NOT_SELECTED && lstCaseStatus.contains(mapOldCase.get(newCase.Id).status) && newCase.Brand__c != 'Makers Mark'){
                                        if(lstDistAlloc[0].Cancelled_Allocations__c != null && 
                                           lstDistAlloc[0].Cancelled_Allocations__c > lstDistAlloc[0].Used_Allocations__c){
                                               lstDistAlloc[0].Cancelled_Allocations__c +=1;       
                                           } else{
                                               lstDistAlloc[0].Cancelled_Allocations__c =1;   
                                           }
                                        if(lstDistAlloc[0].Used_Allocations__c != null && lstDistAlloc[0].Used_Allocations__c > 0) {
                                            lstDistAlloc[0].Used_Allocations__c -= 1;
                                        }
                                    }
                                }
                            }
                            if(newCase.Allocation_Allocated_From__c == CSConstants.STATE){                            
                                lstStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
                                if(newCase.National_Account_Flag__c){
                                    lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithRegion(
                                        newCase.Single_Barrel_State__c, newCase.Single_Barrel_Region__c, String.valueOf(newCase.Brand_Allocation__c).subString(0,15));
                                } else {
                                    lstStateAlloc = 
                                        SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationByBrandAllocationAndState(
                                            newCase.Single_Barrel_State__c,String.valueOf(newCase.Brand_Allocation__c).subString(0,15),
                                            newCase.Single_Barrel_Country__c);
                                }
                                if(!lstStateAlloc.isEmpty()){ 
                                    if(((newCase.Status == CSConstants.NEW_STATUS || newCase.Status == CSConstants.PENDING_DOCUMENTATION) && !mapOldCase.get(newCase.Id).Flow_Completed__c && newCase.Brand__c != 'Makers Mark') || (newCase.Brand__c == 'Makers Mark' && !mapOldCase.get(newCase.Id).Barrel_Selected__c)){ 
                                        if(lstStateAlloc[0].Used_Allocations__c != null) {
                                            lstStateAlloc[0].Used_Allocations__c += 1;
                                        } else {
                                            lstStateAlloc[0].Used_Allocations__c = 1;
                                        }
                                    } else if(newCase.Status == CSConstants.CANCELLED_KIT_NOT_SELECTED && lstCaseStatus.contains(mapOldCase.get(newCase.Id).status) && newCase.Brand__c != 'Makers Mark'){
                                        if(lstStateAlloc[0].Cancelled_Allocations__c != null && 
                                           lstStateAlloc[0].Cancelled_Allocations__c > lstStateAlloc[0].Used_Allocations__c){
                                               lstStateAlloc[0].Cancelled_Allocations__c +=1;       
                                           } else{
                                               lstStateAlloc[0].Cancelled_Allocations__c =1;   
                                           }
                                        if(lstStateAlloc[0].Used_Allocations__c != null && lstStateAlloc[0].Used_Allocations__c >0) {
                                            lstStateAlloc[0].Used_Allocations__c -= 1;
                                        } 
                                    }
                                }    
                            }
                            if(newCase.Allocation_Allocated_From__c == CSConstants.REGION){
                                lstRegionAlloc = SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationByCountryAndRegionAndBrand(
                                        newCase.Single_Barrel_Region__c, newCase.Single_Barrel_Country__c,
                                        String.valueOf(newCase.Brand_Allocation__c).subString(0,15)
                                    );
                                if(!lstRegionAlloc.isEmpty()){ 
                                    if(((newCase.Status == CSConstants.NEW_STATUS || newCase.Status == CSConstants.PENDING_DOCUMENTATION) && !mapOldCase.get(newCase.Id).Flow_Completed__c && newCase.Brand__c != 'Makers Mark') || (newCase.Brand__c == 'Makers Mark' && !mapOldCase.get(newCase.Id).Barrel_Selected__c)){
                                        if(lstRegionAlloc[0].Used_Allocations__c != null) {
                                            lstRegionAlloc[0].Used_Allocations__c += 1;
                                        } else {
                                            lstRegionAlloc[0].Used_Allocations__c = 1;
                                        }
                                    } else if(newCase.Status == CSConstants.CANCELLED_KIT_NOT_SELECTED && lstCaseStatus.contains(mapOldCase.get(newCase.Id).status) && newCase.Brand__c != 'Makers Mark'){
                                        if(lstRegionAlloc[0].Cancelled_Allocations__c != null && 
                                           lstRegionAlloc[0].Cancelled_Allocations__c > lstRegionAlloc[0].Used_Allocations__c){
                                               lstRegionAlloc[0].Cancelled_Allocations__c +=1;       
                                           } else{
                                               lstRegionAlloc[0].Cancelled_Allocations__c =1;   
                                           }
                                        if(lstRegionAlloc[0].Used_Allocations__c != null && lstRegionAlloc[0].Used_Allocations__c >0) {
                                            lstRegionAlloc[0].Used_Allocations__c -= 1;
                                        } 
                                    }
                                }  
                            }
                        }  else if(((newCase.Case_Record_Type__c == CSConstants.SINGLE_BARREL_STANDARD || newCase.Case_Record_Type__c == CSConstants.SINGLE_BARREL_PROOF_SPECIFIC)&& (newCase.Status == CSConstants.NEW_STATUS 
                                                                                                                                                                                      || newCase.Status == CSConstants.PENDING_DOCUMENTATION)                                                                                                                                                     
                                    && newCase.Flow_Completed__c && mapOldCase.containsKey(newCase.Id) && !mapOldCase.get(newCase.Id).Flow_Completed__c &&
                                    String.isEmpty(newCase.Allocation_Allocated_From__c) && newCase.Brand__c != 'Makers Mark') || (newCase.Brand__c == 'Makers Mark' && newCase.Barrel_Selected__c && mapOldCase.containsKey(newCase.Id) && !mapOldCase.get(newCase.Id).Barrel_Selected__c && 
                                                                                                                                   String.isEmpty(newCase.Allocation_Allocated_From__c))){                                                         
                                     Case updatedCase = checkAllocationValidation(newCase);
                                     if(!String.isEmpty(updatedCase.Single_Barrel_State__c))                                     
                                     newCase.Single_Barrel_State__c = updatedCase.Single_Barrel_State__c;
                                     if(!String.isEmpty(updatedCase.Single_Barrel_Region__c))
                                     newCase.Single_Barrel_Region__c = updatedCase.Single_Barrel_Region__c;
                                     if(!String.isEmpty(updatedCase.Single_Barrel_Country__c))
                                     newCase.Single_Barrel_Country__c = updatedCase.Single_Barrel_Country__c;
                                     newCase.Allocation_Allocated_From__c = updatedCase.Allocation_Allocated_From__c;
                                     newCase.State_Allocation_From__c = updatedCase.State_Allocation_From__c;
                                     newCase.Region_Allocation_From__c = updatedCase.Region_Allocation_From__c;
                                     newCase.Brand_Allocation__c = updatedCase.Brand_Allocation__c;  
                                     newCase.status =  updatedCase.status;   
                                  if(newCase.Brand__c == 'Makers Mark' && String.isEmpty(newCase.Allocation_Allocated_From__c) && newCase.Barrel_Selected__c){
                                    	 newCase.addError('No barrel available to allocate');                                    
                                	}                                                                                                                                                                                                       
                                }
                }
            //Added by Deekshika - 23-3-2023 - updated all list outside for loop
            if(lstDistAlloc != null && lstDistAlloc.size() > 0) {
                update lstDistAlloc;
            } 
            if(lstStateAlloc != null && lstStateAlloc.size() > 0) {
                update lstStateAlloc;
            }
            if(lstRegionAlloc != null && lstRegionAlloc.size() > 0) {
                update lstRegionAlloc;
            }
      }
        catch (Exception e) {
            String errorMessage = 'Error creating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('caseServices', 'createSingleBarrelCase', String.valueOf(errorMessage), 'Fatal');
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
    }
    
    /**************************************************************************************************************
Description:    This method is used to get selected brand allocation
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
12/2020     Jai Kumar Garg      Metacube       Modified for INC0013705
12/2022 	Sahana S S			Metacube	   Modified for SAL-3293/SAL-3768 
**************************************************************************************************************/
    public static String getSelectedBrandAllocation(Case existingCase){
        String brandName = existingCase.Brand__c;
        if(!String.isEmpty(existingCase.Product_Type__c)){
            brandName += ' '+ existingCase.Product_Type__c;
        }
        String yearOfCaseCreation = String.valueOf(existingCase.CreatedDate.year());
        String monthOfCaseCreation = CSConstants.mapOfMonth.get(existingCase.CreatedDate.month());
        String qarterOfCaseCreation = CSConstants.mapOfMonthQuarter.get(monthOfCaseCreation);
        if(existingCase.Plant_Event__c != null && existingCase.Brand__c != 'Makers Mark'){
            List<Plant_Event__c > lstPlantEvent = [select Id, Scheduled_Date__c  from Plant_Event__c  where Id =: existingCase.Plant_Event__c];
            yearOfCaseCreation = String.valueOf(lstPlantEvent[0].Scheduled_Date__c.year());
            monthOfCaseCreation = CSConstants.mapOfMonth.get(lstPlantEvent[0].Scheduled_Date__c.month());
            qarterOfCaseCreation = CSConstants.mapOfMonthQuarter.get(monthOfCaseCreation);
        }
        String selectedBrandAllocation;
	if(brandName == 'Makers Mark'){
		yearOfCaseCreation = String.valueOf(Date.today().year());
		monthOfCaseCreation = CSConstants.mapOfMonth.get(Date.today().Month());
		qarterOfCaseCreation = CSConstants.mapOfMonthQuarter.get(monthOfCaseCreation);          
	}
        
        List<Case> casetype = [select id, Type, Recent_Recipes_Selected__c from Case where Id =:existingCase.Id limit 1];
        for(Case c : casetype){         
            if(brandName == 'Makers Mark' && existingCase.Type == null && c.Recent_Recipes_Selected__c == true &&
               existingCase.Type != 'Remote Selection' && existingCase.Type != 'Trip and Tour'){
                   existingCase.Type = 'Recent Recipes';
               } 
        }
        
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(brandName, existingCase.Type, yearOfCaseCreation);
        if(!lstBrandAllocation.isEmpty()){
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
                if(brandAlloc.Is_Active__c && brandAlloc.Time_Period__c == CSConstants.YEARLY){
                    selectedBrandAllocation = brandAlloc.Id;
                } else if(brandAlloc.Is_Active__c && brandAlloc.Time_Period__c == CSConstants.QUARTERLY && 
                          brandAlloc.Time_Interval__c == qarterOfCaseCreation) {
                              selectedBrandAllocation = brandAlloc.Id;
                          } else if(brandAlloc.Is_Active__c && brandAlloc.Time_Period__c == CSConstants.MONTHLY && 
                                    brandAlloc.Time_Interval__c == monthOfCaseCreation){
                                        selectedBrandAllocation = brandAlloc.Id;
                                    }
            }
        }
        return selectedBrandAllocation;
    }
    
    /**************************************************************************************************************
Description:    This method is used to allocate allocation when case is created for national account
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
**************************************************************************************************************/
    public static Case checkForNationalAccount(Account retailorAccount, String selectedBrandAllocation, 
                                               Case existingCase){
                                                   List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = 
                                                       SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithRegion(retailorAccount.PremiseType__c, 
                                                                                                                         'National Accounts', selectedBrandAllocation);
                                                   Boolean isValid = true;
                                                   if(!lstStateAlloc.isEmpty()){
                                                       for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
                                                           if(stateAlloc.Is_Leaf_Node__c && stateAlloc.Is_Active__c && 
                                                              stateAlloc.Allocations_Per_Interval__c != stateAlloc.Used_Allocations__c){
                                                                  if(stateAlloc.Used_Allocations__c != null) {
                                                                      stateAlloc.Used_Allocations__c += 1;
                                                                  } else {
                                                                      stateAlloc.Used_Allocations__c = 1;
                                                                  }
                                                                  existingCase.Allocation_Allocated_From__c = 'State';
                                                              } else if(stateAlloc.Is_Leaf_Node__c && stateAlloc.Is_Active__c && 
                                                                        stateAlloc.Allocations_Per_Interval__c == stateAlloc.Used_Allocations__c){
                                                                            existingCase.status = 'Closed - Abandoned';
                                                                        }
                                                           
                                                           existingCase.Brand_Allocation__c = selectedBrandAllocation;
                                                           existingCase.Single_Barrel_State__c = stateAlloc.State__r.Name;
                                                           existingCase.Single_Barrel_Region__c = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
                                                           existingCase.Single_Barrel_Country__c = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                                                           existingCase.State_Allocation_From__c = stateAlloc.Id;
                                                           existingCase.Region_Allocation_From__c = stateAlloc.Brand_Country_Region_Allocation__r.Id;
                                                       }
                                                       update lstStateAlloc;
                                                   }
                                                   return existingCase;
                                               }
    
    /**************************************************************************************************************
Description:    This method is used to allocate allocation when case is created for military 
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
**************************************************************************************************************/
    public static case checkForMilitary(Account distributorAccount, String selectedBrandAllocation, Case existingCase){
        List<Brand_Country_Region_State_Allocation__c> brandStateList = new List<Brand_Country_Region_State_Allocation__c>();
        List<Brand_Country_Region_Allocation__c> brandRegionList = new List<Brand_Country_Region_Allocation__c>();
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationByBrandAllocationAndState(
            'USA Military', selectedBrandAllocation, distributorAccount.BillingCountry);
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc = SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationByCountryAndRegionAndBrand(
            'Military',distributorAccount.BillingCountry,selectedBrandAllocation);
        Boolean isValid = true;
        if(!lstStateAlloc.isEmpty()) {
            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc) {
                if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && (stateAlloc.Allocations_Per_Interval__c == stateAlloc.Used_Allocations__c || stateAlloc.Allocations_Per_Interval__c == 0)){
                    existingCase.status = 'Closed - Abandoned';
                } else if (stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && stateAlloc.Allocations_Per_Interval__c != stateAlloc.Used_Allocations__c && stateAlloc.Allocations_Per_Interval__c != 0){
                    existingCase.Allocation_Allocated_From__c = 'State';
                    if(stateAlloc.Used_Allocations__c != null) {
                        stateAlloc.Used_Allocations__c += 1;
                    } else {
                        stateAlloc.Used_Allocations__c = 1;
                    }
                    brandStateList.add(stateAlloc);
                } 
                else if(stateAlloc.Is_Active__c && !stateAlloc.Is_Leaf_Node__c && 
                          (stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c || 
                           stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == 0))
                {
                    existingCase.status = 'Closed - Abandoned';
                }
                else if (stateAlloc.Is_Active__c && !stateAlloc.Is_Leaf_Node__c && 
                         stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c && 
                         stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 0)
                {
                    existingCase.Allocation_Allocated_From__c = 'Region';
                    Brand_Country_Region_Allocation__c regionAlloc = new Brand_Country_Region_Allocation__C(Id = stateAlloc.Brand_Country_Region_Allocation__c);
                    if(stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c != null) 
                    {
                        regionAlloc.Used_Allocations__c = stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c + 1;
                    } 
                    else 
                    {
                        regionAlloc.Used_Allocations__c = 1;
                    }
                    brandRegionList.add(regionAlloc);
                }
                existingCase.Single_Barrel_State__c = stateAlloc.State__r.Name;
                existingCase.Single_Barrel_Region__c = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
                existingCase.Single_Barrel_Country__c = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.Region_Allocation_From__c = stateAlloc.Brand_Country_Region_Allocation__r.Id;
                existingCase.State_Allocation_From__c = stateAlloc.Id;
            }
        } 
        else
        {
            for(Brand_Country_Region_Allocation__c regionAlloc : lstRegionAlloc)
            {
                if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Allocations_Per_Interval__c != regionAlloc.Used_Allocations__c)
                {
                    if(regionAlloc.Used_Allocations__c != null) 
                    {
                        regionAlloc.Used_Allocations__c += 1;
                    } 
                    else 
                    {
                        regionAlloc.Used_Allocations__c = 1;
                    }
                    existingCase.Allocation_Allocated_From__c = 'Region';
                    brandRegionList.add(regionAlloc);
                } 
                else if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Allocations_Per_Interval__c == regionAlloc.Used_Allocations__c)
                {
                    existingCase.status = 'Closed - Abandoned';
                }
                existingCase.Single_Barrel_Region__c = regionAlloc.Region__r.Name;
                existingCase.Single_Barrel_Country__c = regionAlloc.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.Region_Allocation_From__c = regionAlloc.Id;
            }
        }
        if(brandStateList != null && brandStateList.size() > 0) {
            update brandStateList;
        }
        if(brandRegionList != null && brandRegionList.size() > 0) {
            update brandRegionList;
        }
        existingCase.Brand_Allocation__c = selectedBrandAllocation;
        return existingCase;
    }
    
    /**************************************************************************************************************
Description:    This method is used to allocate allocation when case will be allocated from distributor
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
**************************************************************************************************************/
    public static case checkForDistAllocIsAvailable(
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAlloc, Case existingCase, String selectedBrandAllocation){
            //Added by Deekshika - 23-3-2023 - created all list above for loop
            List<Brand_Country_Region_State_Dist_Alloc__c> brandDistList = new List<Brand_Country_Region_State_Dist_Alloc__c>();
            List<Brand_Country_Region_State_Allocation__c> brandStateList = new List<Brand_Country_Region_State_Allocation__c>();
            List<Brand_Country_Region_Allocation__c> brandRegionList = new List<Brand_Country_Region_Allocation__c>();
            
            Boolean isValid = true;
            if(!lstDistributorAlloc.isEmpty()){
                for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : lstDistributorAlloc){
                    if(distAlloc.Is_Active__c && distAlloc.Is_Leaf_Node__c && 
                        (distAlloc.Allocations_Per_Interval__c == 0 || 
                        distAlloc.Allocations_Per_Interval__c == distAlloc.Used_Allocations__c)) {
                            existingCase.status = 'Closed - Abandoned';
                    } else if(distAlloc.Is_Active__c && distAlloc.Is_Leaf_Node__c && 
                        distAlloc.Allocations_Per_Interval__c != 0 && 
                        distAlloc.Allocations_Per_Interval__c != distAlloc.Used_Allocations__c){
                            if(distAlloc.Used_Allocations__c != null) {
                                distAlloc.Used_Allocations__c += 1;
                            } else {
                                distAlloc.Used_Allocations__c = 1;
                            }
                            brandDistList.add(distAlloc);
                            existingCase.Allocation_Allocated_From__c = 'Distributor';
                    }
                    if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c && 
                        (distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c == distAlloc.Brand_Country_Region_State_Allocation__r.Used_Allocations__c ||
                        distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c == 0)) {
                            existingCase.status = 'Closed - Abandoned';
                    } else if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c != 0 &&
                        distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c && distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c != distAlloc.Brand_Country_Region_State_Allocation__r.Used_Allocations__c){
                            Brand_Country_Region_State_Allocation__c stateAlloc = new Brand_Country_Region_State_Allocation__c(Id = distAlloc.Brand_Country_Region_State_Allocation__c);
                            if(distAlloc.Brand_Country_Region_State_Allocation__r.Used_Allocations__c != null) {
                                stateAlloc.Used_Allocations__c = distAlloc.Brand_Country_Region_State_Allocation__r.Used_Allocations__c+1;
                            } else {
                                stateAlloc.Used_Allocations__c = 1;
                            }
                            brandStateList.add(stateAlloc);
                            existingCase.Allocation_Allocated_From__c = 'State';
                    }
                    if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c && 
                        !distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c) {
                            existingCase.status = 'Closed - Abandoned';
                    } else if(distAlloc.Is_Active__c && !distAlloc.Is_Leaf_Node__c && distAlloc.Brand_Country_Region_State_Allocation__r.Is_Active__c && 
                        !distAlloc.Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c && 
                        distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 0){
                            existingCase.Allocation_Allocated_From__c = 'Region';
                            Brand_Country_Region_Allocation__c regionAlloc = new Brand_Country_Region_Allocation__c(Id = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__c);
                            if(distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c != null) {
                                regionAlloc.Used_Allocations__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c+1;
                            } else {
                                regionAlloc.Used_Allocations__c = 1;
                            }
                            brandRegionList.add(regionAlloc);
                    }
                    existingCase.Brand_Allocation__c = selectedBrandAllocation;
                    existingCase.Single_Barrel_State__c = distAlloc.Brand_Country_Region_State_Allocation__r.State__r.Name;
                    existingCase.Single_Barrel_Region__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name;
                    existingCase.Single_Barrel_Country__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                    existingCase.State_Allocation_From__c = distAlloc.Brand_Country_Region_State_Allocation__r.Id;
                    existingCase.Region_Allocation_From__c = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Id;
                    existingCase.Distributor_Allocation_From__c = distAlloc.Id;
                }
            }
            
            //Added by Deekshika - 23-3-2023 - updated all list outside for loop
            if(brandDistList != null && brandDistList.size() > 0) {
                update brandDistList;
            } 
            if(brandStateList != null && brandStateList.size() > 0) {
                update brandStateList;
            }
            if(brandRegionList != null && brandRegionList.size() > 0) {
                update brandRegionList;
            }
            return existingCase;
        }
    
    /**************************************************************************************************************
Description:    This method is used to allocate allocation when case will be allocated from State
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
**************************************************************************************************************/
    public static Case checkForStateAllocIsAvailable(
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc, Case existingCase, String selectedBrandAllocation){
            //Added by Deekshika - 23-3-2023 - created all list above for loop
            List<Brand_Country_Region_State_Allocation__c> brandStateList = new List<Brand_Country_Region_State_Allocation__c>();
            List<Brand_Country_Region_Allocation__c> brandRegionList = new List<Brand_Country_Region_Allocation__c>();

            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
                if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && 
                   (stateAlloc.Allocations_Per_Interval__c == stateAlloc.Used_Allocations__c || 
                    stateAlloc.Allocations_Per_Interval__c == 0)){
                        existingCase.status = 'Closed - Abandoned';
                } else if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && 
                    (stateAlloc.Allocations_Per_Interval__c != stateAlloc.Used_Allocations__c ||
                    stateAlloc.Allocations_Per_Interval__c != 0)){
                        existingCase.Allocation_Allocated_From__c = 'State';
                        if(stateAlloc.Used_Allocations__c != null) {
                            stateAlloc.Used_Allocations__c += 1;
                        } else {
                            stateAlloc.Used_Allocations__c = 1;
                        }
                        brandStateList.add(stateAlloc);
                } else if(stateAlloc.Is_Active__c && !stateAlloc.Is_Leaf_Node__c && stateAlloc.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c &&
                    (stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c
                    || stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c == 0)){
                        existingCase.status = 'Closed - Abandoned';
                } else if(stateAlloc.Is_Active__c && !stateAlloc.Is_Leaf_Node__c && stateAlloc.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c &&
                    stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c
                    && stateAlloc.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c != 0){
                        existingCase.Allocation_Allocated_From__c = 'Region';
                        Brand_Country_Region_Allocation__c regionAlloc = new Brand_Country_Region_Allocation__C(Id = stateAlloc.Brand_Country_Region_Allocation__c);
                        if(stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c != null) {
                            //Added by Deekshika 3-4-2023 - increased used allocation of state's region record
                            regionAlloc.Used_Allocations__c = stateAlloc.Brand_Country_Region_Allocation__r.Used_Allocations__c + 1;
                        } else {
                            regionAlloc.Used_Allocations__c = 1;
                        }
                        brandRegionList.add(regionAlloc);
                }
                existingCase.Brand_Allocation__c = selectedBrandAllocation;
                existingCase.Single_Barrel_State__c = stateAlloc.State__r.Name;
                existingCase.Single_Barrel_Region__c = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
                existingCase.Single_Barrel_Country__c = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.Region_Allocation_From__c = stateAlloc.Brand_Country_Region_Allocation__r.Id;
                existingCase.State_Allocation_From__c = stateAlloc.Id;
            }
            
            //Added by Deekshika - 23-3-2023 - updated all list outside for loop
            if(brandStateList != null && brandStateList.size() > 0) {
                update brandStateList;
            }
            if(brandRegionList != null && brandRegionList.size() > 0) {
                update brandRegionList;
            }
            return existingCase;
        }
    
    /**************************************************************************************************************
Description:    This method is used to allocate allocation when case will be allocated from Region
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
**************************************************************************************************************/
    public static case checkForRegionAllocIsAvailable(Account distributorAccount, String selectedBrandAllocation, case existingCase){
        //Added by Deekshika - 23-3-2023 - created list above for loop
        List<Brand_Country_Region_Allocation__c> brandRegionList = new List<Brand_Country_Region_Allocation__c>();
        List<State__c> lstState = SLT_SB2_State.getStateInfoFromAccount(distributorAccount.BillingState.toUpperCase());
        Boolean isvalid = true;
        if(!lstState.isEmpty()){
            List<Brand_Country_Region_Allocation__c> lstRegionAlloc = 
                SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationByCountryAndRegionAndBrand(lstState[0].Region__r.Name,
                distributorAccount.BillingCountry, selectedBrandAllocation);
            for(Brand_Country_Region_Allocation__c regionAlloc : lstRegionAlloc){
                if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Allocations_Per_Interval__c == regionAlloc.Used_Allocations__c){
                    existingCase.status = 'Closed - Abandoned';
                } else if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Allocations_Per_Interval__c != regionAlloc.Used_Allocations__c){
                    existingCase.Allocation_Allocated_From__c = 'Region';
                    if(regionAlloc.Used_Allocations__c != null) {
                        regionAlloc.Used_Allocations__c += 1;
                    } else {
                        regionAlloc.Used_Allocations__c = 1;
                    }
                    brandRegionList.add(regionAlloc);
                }
                existingCase.Brand_Allocation__c = selectedBrandAllocation;
                existingCase.Single_Barrel_Region__c = regionAlloc.Region__r.Name;
                existingCase.Single_Barrel_Country__c = regionAlloc.Brand_Country_Allocation__r.Country__r.Name;
                existingCase.Region_Allocation_From__c = regionAlloc.Id;
            }
        }
        
        //Added by Deekshika - 23-3-2023 - updated list outside for loop
        if(brandRegionList != null && brandRegionList.size() > 0) {
            update brandRegionList;
        }
        return existingCase;
    }
    
    /**************************************************************************************************************
Description:    This method is used to check allocation validation for case, either allocation from distributor 
or state or region
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
5/2020      Sumitra Kumari      Metacube       Initial Creation
**************************************************************************************************************/
    public static Case checkAllocationValidation(Case newCase){
        Boolean isValid = true;
        List<Case> lstCase = SLT_Case.getCaseByIDs(new List<Id> {newCase.Id});
        List<Account> lstRetailorAccount = SLT_Account.getAccountsByIDs(new Set<Id> {newCase.Retail_Account__c});
        List<Account> lstDistributorAccount = SLT_Account.getAccountsByIDs(new Set<Id> {newCase.AccountId});
        Case existingCase;
        if(!lstCase.isEmpty()){
            existingCase = lstCase[0];
        }
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        String selectedBrandAllocation;
        
        selectedBrandAllocation = getSelectedBrandAllocation(existingCase);
        if(!String.isEmpty(selectedBrandAllocation)){
            selectedBrandAllocation = selectedBrandAllocation.substring(0,15);
            isValid = true;
        }           
        existingCase.Brand_Allocation__c = selectedBrandAllocation;
        if(!lstDistributorAccount.isEmpty() && lstDistributorAccount[0].Military__c == 'Military' || 
           lstDistributorAccount[0].Military__c == 'Military Export'){
               newCase = checkForMilitary(lstDistributorAccount[0], selectedBrandAllocation, existingCase);
               
           } else if(newCase.National_Account_Flag__c) {
               if(!lstRetailorAccount.isEmpty()){
                   newCase = checkForNationalAccount(lstRetailorAccount[0], selectedBrandAllocation, existingCase);
               }
           } else{
               lstDistributorAlloc = SLT_SB2_BrandCountryRegionStateDistAlloc.getDistAllocByAccountAndBrandAlloc(selectedBrandAllocation, newCase.AccountId);
               if(!lstDistributorAlloc.isEmpty()){
                   newCase = checkForDistAllocIsAvailable(lstDistributorAlloc, existingCase, selectedBrandAllocation);
               }
               else{
                   if(!lstDistributorAccount.isEmpty()){
                       List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationByBrandAllocationAndState(
                           lstDistributorAccount[0].BillingState.toUpperCase(), selectedBrandAllocation, lstDistributorAccount[0].BillingCountry);
                       if(!lstStateAlloc.isEmpty()) {
                           newCase = checkForStateAllocIsAvailable(lstStateAlloc, existingCase, selectedBrandAllocation);
                       } else{
                           newCase = checkForRegionAllocIsAvailable(lstDistributorAccount[0], selectedBrandAllocation, existingCase);
                       }
                   }
               }
           }
        return newCase;
    }
    
    /**************************************************************************************************************    
Description: SR-179687 Added By Ajeeta Soni(TCS)
History : 
6/2020     Ajeeta       Initial Creation
***************************************************************************************************************/
    public static void updateSingleBarrelParentCaseWithSubcase(List<Case> newCases) {
        Id BarrelReadyRId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Ready_to_Enter').getRecordTypeId();
        //Id singleBarrelStandardRId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        map<string,case> case_map = new map<String,Case>();
        boolean isUpdateOnChildCase = false;
        for(Case c : newCases){
            
            if((c.RecordTypeId == BarrelReadyRId) ){
                case_map.put(string.valueof(c.ParentId),c);
            }   
        }
        
        if(case_map.size() > 0){
            //changes by Badri-start
            for(case cc : [Select id,Status,Order_Ready_To_Enter__c,Barrel_Ready_to_Enter_Case_Number__c,Order_Ready_To_Enter_Checked_Date__c,SAP_Number__c,CaseNumber,RecordTypeId,Barrel_Selected__c,Purchase_Order_Uploaded__c,Bottle_Text_Entered__c,POS_Items_Selected__c from case where id in: case_map.keySet()]){
                case c = case_map.get(cc.id);
                
                if(String.isBlank(cc.SAP_Number__c) && String.isNotBlank(c.SAP_Number__c)){ // if parent SAP is empty and Child's in not empty
                    if((cc.RecordTypeId == SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID) && cc.Barrel_Selected__c &&
                       cc.Purchase_Order_Uploaded__c && cc.Bottle_Text_Entered__c && cc.POS_Items_Selected__c &&
                       (cc.Status == SBP_Constants.PENDING_DOCUMENTATION)){
                           
                        cc.Status = SBP_Constants.PREPARING_BARREL;
                        isUpdateOnChildCase = true;
                    }
                }
                //end
                if(cc.SAP_Number__c != c.SAP_Number__c){
                    cc.SAP_Number__c = c.SAP_Number__c;
                    isUpdateOnChildCase = true;
                }
                if(cc.Barrel_Ready_to_Enter_Case_Number__c != c.CaseNumber){
                    cc.Barrel_Ready_to_Enter_Case_Number__c = c.CaseNumber;
                    isUpdateOnChildCase = true;
                }
                
                if(isUpdateOnChildCase){
                    caseList.add(cc);
                }
                
            }
            if(!caseList.isEmpty()){
                update caseList;
            }
            
            // case_map.clear();
        }
    }
    
    public static void addEntitlementProcessForConsole(List<Case> newCases) {
        Set<Id> setOfContactId = new Set<Id>();
        set<Id> setCaseId = new Set<Id>();
        for(Case newCase : newCases) {
            if((newCase.recordTypeId == CSConstants.CSG_QUALITY_CLAIM_RT_ID ||
                newCase.recordTypeId == CSConstants.CSG_BILLING_CLAIM_RT_ID || 
                newCase.recordTypeId == CSConstants.CSG_ORDER_CLAIM_RT_ID) && 
               newCase.Origin == 'Console') {
                   setOfContactId.add(newCase.contactId);
               }
        }
        Set<Id> setOfAccountId = new Set<Id>();
        map<String, String> mapOfCOntactAccount = new map<String, String>();
        if(!setOfContactId.isEmpty()){
            for(Contact newContact :[select Id, accountId from Contact where Id IN : setOfContactId]) {
                setOfAccountId.add(newContact.accountId);
                mapOfCOntactAccount.put(newContact.Id, newContact.accountId);
            }
        }
        
        map<String, String> mapOfAccountIdEntitlment = new map<String, String>();
        if(!setOfAccountId.isEmpty()){
            for(Entitlement entitlementProcess :[SELECT Id, Account.Id
                                                FROM Entitlement 
                                                WHERE  SlaProcess.Name = 'CSG Order Claim' 
                                                AND  Account.Id IN: setOfAccountId  
                                                AND SlaProcess.isActive = true]){
                mapOfAccountIdEntitlment.put(entitlementProcess.Account.Id, entitlementProcess.Id);
            }
        }
        for(Case newCase : newCases) {
            if((newCase.recordTypeId == CSConstants.CSG_QUALITY_CLAIM_RT_ID ||
                newCase.recordTypeId == CSConstants.CSG_BILLING_CLAIM_RT_ID || 
                newCase.recordTypeId == CSConstants.CSG_ORDER_CLAIM_RT_ID) && 
               newCase.Origin == 'Console') {
                   if(mapOfCOntactAccount.containsKey(newCase.contactId)){
                       if(mapOfAccountIdEntitlment.containsKey(mapOfCOntactAccount.get(newCase.contactId))){
                           System.debug('--');
                           newCase.EntitlementId = mapOfAccountIdEntitlment.get(mapOfCOntactAccount.get(newCase.contactId));
                       }
                   }
                   if(newCase.recordTypeId == CSConstants.CSG_QUALITY_CLAIM_RT_ID) {
                       newCase.Change_Reason__c = 'CSG Quality Claim';
                   }
                   if(newCase.recordTypeId == CSConstants.CSG_BILLING_CLAIM_RT_ID) {
                       newCase.Change_Reason__c = 'CSG Billing Claim';
                   }
                   if(newCase.recordTypeId == CSConstants.CSG_ORDER_CLAIM_RT_ID) {
                       newCase.Change_Reason__c = 'CSG Order Claim';
                   }
               }
        }
    }
    
    /**************************************************************************************************************
Description:    This method is used to send email to ids which are present in CcEmail__c field.
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
2/2021      Jai Kumar Garg     Metacube       Initial Creation
**************************************************************************************************************/
    public static void sendEmailToCollaborators(List<Case> newCases, Map<Id, Case> mapOfOldCases) {
        try{
            Boolean isAfterInsert = Trigger.isInsert && Trigger.isAfter;
            Boolean isAfterUpdate = Trigger.isUpdate && Trigger.isAfter;
            List<EmailTemplate> lstEmailTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :CSConstants.CSG_ACKNOWLEDGMENT.values()];
            List<OrgWideEmailAddress> lstOWEA = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'reklamationen@beamsuntory.com'];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            if(!(lstOWEA.isEmpty() && lstEmailTemplate.isEmpty())) {
                Map<String, Id> developerNameToIdMap = new Map<String, Id>();
                for(EmailTemplate template : lstEmailTemplate) {
                    developerNameToIdMap.put(template.DeveloperName, template.Id);
                }
                if(!developerNameToIdMap.isEmpty()) {
                    for(Case newCase : newCases) {
                        Case oldCase = mapOfOldCases?.get(newCase.Id);
                        if((isAfterInsert && newCase.Origin == 'Console') ||
                           (isAfterUpdate && 
                            newCase.Flow_Completed__c &&
                            newCase.Origin == 'Portal' &&
                            oldCase != null && 
                            !oldCase.Flow_Completed__c)) {
                                if(String.isNotBlank(newCase.CcEmail__c)) {
                                    List<String> validEmailAddresses = new List<String>();
                                    for(String emailAddress : newCase.CcEmail__c.split(';')) {
                                        if (Pattern.matches('^([0-9a-zA-Z+_.-]*[0-9a-zA-Z]+[@][0-9a-zA-Z+_.-]+\\.[0-9a-zA-Z+_.-]*)$', emailAddress)) {
                                            validEmailAddresses.add(emailAddress);
                                        } else {
                                            CreateExceptionLog.createExceptionLog('caseServices', 
                                                                                  'sendEmailToCollaborators', 
                                                                                  'Case has invalid email in "CcEmail__c" field: ' + newCase, 
                                                                                  'Warning', 
                                                                                  false);
                                        }
                                    }
                                    if(!validEmailAddresses.isEmpty()) {
                                        String templateDeveloperName = CSConstants.CSG_ACKNOWLEDGMENT.get(newCase.RecordTypeId);
                                        if(developerNameToIdMap.containsKey(templateDeveloperName)) {
                                            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                                            singleMail.setToAddresses(validEmailAddresses);
                                            singleMail.setTargetObjectId(newCase.ContactId);
                                            singleMail.setTreatTargetObjectAsRecipient(false);
                                            singleMail.setTemplateId(developerNameToIdMap.get(templateDeveloperName));
                                            singleMail.setWhatId(newCase.Id);
                                            singleMail.setSaveAsActivity(false);
                                            singleMail.setReplyTo(lstOWEA[0].Address);
                                            singleMail.setOrgWideEmailAddressId(lstOWEA[0].Id);
                                            emails.add(singleMail);
                                        }
                                    }
                                }
                            }
                    }
                }
            }
            if(!emails.isEmpty()) {
                List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
            }
        } catch (Exception e) {
            String errorMessage = 'Error sending email to collaborators ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('caseServices', 'sendEmailToCollaborators', String.valueOf(errorMessage), 'Fatal');
        }
    }
   
    /**************************************************************************************************************
Description:    This method is used to update the record type of cases of CSG that are coming through email.
<Date>          <Authors Name>     <Company>     <Brief Description of Change>
3/2021          Jai Kumar Garg     Metacube       Initial Creation
**************************************************************************************************************/
    public static void updateRecordTypeOfCSGCases(List<Case> newCases) {
        for(Case newCase : newCases) {
            Boolean isRecordTypeUpdated = false;
            if(CSConstants.CSG_RT_IDs.contains(newCase.RecordTypeId) && CSConstants.EMAIL.equalsIgnoreCase(newCase.Origin)) {
                String caseSubject = String.isNotBlank(newCase.Subject) ? ' ' + newCase.Subject.replaceAll('[^a-zA-Z0-9ÄäÖöÜü ]', ' ') + ' ' : null;
                String caseDescription = String.isNotBlank(newCase.Description) ? ' ' + newCase.Description.replaceAll('[^a-zA-Z0-9ÄäÖöÜü ]', ' ') + ' ' : null;
                if(String.isNotBlank(caseSubject) || String.isNotBlank(caseDescription)) {
                    for(String keyword : CSConstants.QUALITY_TRIGGER_WORDS) {
                        if((String.isNotBlank(caseSubject) && caseSubject.containsIgnoreCase(keyword)) || 
                           (String.isNotBlank(caseSubject) && caseDescription.containsIgnoreCase(keyword))) {
                               newCase.RecordTypeId = CSConstants.CSG_QUALITY_CLAIM_RT_ID;
                               isRecordTypeUpdated = true;
                               break;
                           }
                    }
                    if(!isRecordTypeUpdated) {
                        for(String keyword : CSConstants.BILLING_TRIGGER_WORDS) {
                            if((String.isNotBlank(caseSubject) && caseSubject.containsIgnoreCase(keyword)) || 
                               (String.isNotBlank(caseDescription) && caseDescription.containsIgnoreCase(keyword))) {
                                   newCase.RecordTypeId = CSConstants.CSG_BILLING_CLAIM_RT_ID;
                                   break;
                               }
                        }
                    }
                }
            }
        }
    }
    
    /*******************************************************************************************************************************
Description:    This method is used to delete the plant events when the case status is changed to Cancelled-Allocation or 
Canceled or Closed - Abandoned
<Date>          <Authors Name>     <Company>     <Brief Description of Change>
10/2021             Sahana S S     Metacube       Initial Creation
******************************************************************************************************************************/
    public static void deletePlantEventsFromCase(List<Case> newCases, Map<Id, Case> oldMap){
        List<Id> caseIds = new List<Id>();
        
        for(Case currCase : newCases){
            if (oldMap.get(currCase.Id).Status != currCase.Status) {
                if(currCase.Status == 'Cancelled-Allocation' || currCase.Status == 'Canceled' || currCase.Status == 'Closed - Abandoned' ){
                    caseIds.add(currCase.id);
                    System.debug('case id' + caseIds);
                }            
            }
            
        } 
        if(!caseIds.isEmpty()){       
            delete [SELECT Id 
                    FROM Plant_Event__c 
                    where Case__c IN :caseIds 
                    AND (Brand__c = 'Knob Creek' 
                         OR Brand__c = 'Makers Mark' 
                         OR Brand__c =: SBP_Constants.LAPHROAIG_SINGLE_CASK)];      
        }       
    }
    
       /**************************************************************************************************************
Method name:    sendSurveyEmail
Object:         Case
Date:           4/2023       Nishant Khandal     Metacube  
Details and Notes:
Used to send survey email to consumer inquiry case once the case got closed.
***************************************************************************************************************/
    public static void sendSurveyEmail(List<Case> newCases, Map<Id, Case> oldMap){
        ConsumerServices__c consumerServices = ConsumerServices__c.getOrgDefaults();
        Boolean enableSurvey = consumerServices.Enable_Survey__c;
        if(enableSurvey == true){
        for(Case currCase : newCases){
                    Map<String, Object> inputs = new Map<String, Object>();
                    inputs.put('caseId', currCase.Id);
                    inputs.put('communityName', 'Contact Us Community');
                    inputs.put('surveyName', 'Consumer Inquiry Survey');
                    Flow.Interview.Survey_Flow surveyflow = new Flow.Interview.Survey_Flow(inputs);
                    surveyflow.start();  
                }
        }
    }

    public static void updateCaseStatusToClosed(List<Case> newCases){
        ConsumerServices__c consumerServices = ConsumerServices__c.getInstance();
        String voiceServerEmail = consumerServices.virtualVoiceToCaseEmail__c; 
        
        List<Contact> contactList = [SELECT id FROM Contact WHERE email =:voiceServerEmail];
        
        for(Case currCase : newCases){            
            if( currCase.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID && currCase.origin == 'Email' && 
               currCase.Case_Owner__c == 'CC_GENERAL_QUEUE' && 
               (contactList.size() == 0 || (contactList.size() > 0 && currCase.ContactId != contactList.get(0).Id))){
                currCase.status = CSConstants.CLOSED;                 
                EmailMessageServices.skipForGeneralQueue=false;
            }            
        }
    }
/*******************************************************************************************************************************
Description:    This method is used to update Case Type field based on a User Submitter case type field for record types Control Collaboration, Franchise Collaboration and SGWS Collaboration
<Date>          <Authors Name>     <Company>     <Brief Description of Change>
11/2022         Ankit Kumar       Metacube       Initial Creation
******************************************************************************************************************************/
    public static void updateCaseTypePicklist(List<Case> caseList){
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.case.getRecordTypeInfosById();
        Map<String,String> mapUser = new Map<String,String>();
        list<case>newCaseList=new list<case>();
        list<string>emailList=new list<string>();
        for (Case currCase : caseList) {
              if(currCase.RecordTypeId == CSConstants.Franchise_Collaboration_RT_ID || 
            	 currCase.RecordTypeId == CSConstants.SGWS_Collaboration_RT_ID || 
            	 currCase.RecordTypeId == CSConstants.Control_Collaboration_RT_ID){
                newCaseList.add(currCase);
                emailList.add(currCase.SuppliedEmail);
            }
        }
        if(newCaseList.size()>0 && !emailList.isEmpty())
        {
            for(User us : [Select Id, Submitter_Case_Type__c,Email from User where email in:emailList]){
                mapUser.put(us.Email,us.Submitter_Case_Type__c);
            }
            for(Case cs : newCaseList){
                cs.type =mapUser.get(cs.SuppliedEmail);
            }
        }
    }
	
    /*******************************************************************************************************************************
    Description:    This method is used to implement trigger word functionality for Order Claim, which assign case owner to US Complaints queue.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    01/2023          Vikash Kumar       Metacube       Initial Creation
    ******************************************************************************************************************************/  
    public static void setOrderClaimTriggerWordChecked(List<Case> cases){
        if(!cases.isEmpty()) {
            List<TriggerWords__c> lstTriggerWord = new List<TriggerWords__c>();
            List<Case> orderClaimCasesList = new List<Case>();
            for(Case currCaseInfo : cases){
	        if((CSConstants.CUSTOMER_PORTAL.equalsIgnoreCase(currCaseInfo.Origin) || CSConstants.EMAIL.equalsIgnoreCase(currCaseInfo.Origin) || CSConstants.WEB.equalsIgnoreCase(currCaseInfo.Origin)) && (currCaseInfo.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID)){
	           orderClaimCasesList.add(currCaseInfo);
	        }
            }
            if(orderClaimCasesList.size() > 0){
	        lstTriggerWord = SLT_TriggerWord.getAllTriggerWords();
            }
            for(Case currentCaseInfo : orderClaimCasesList) {
	        String caseSubject = String.isNotEmpty(currentCaseInfo.Subject) ? ' ' + currentCaseInfo.Subject.replaceAll('[^a-zA-Z0-9 ]', ' ') + ' ' : null;
	        String caseDescription = String.isNotEmpty(currentCaseInfo.Description) ? ' ' + currentCaseInfo.Description.replaceAll('[^a-zA-Z0-9 ]', ' ') + ' ' : null;

	        for(TriggerWords__c triggerWord : lstTriggerWord) {
	            if((caseSubject != null && caseSubject.containsIgnoreCase(' ' + triggerWord.name + ' ')) || 
	               (caseDescription != null && caseDescription.containsIgnoreCase(' ' + triggerWord.name + ' '))){
		           currentCaseInfo.trigger_word__c=true;
	            }
	        } 
            }
        }
     }
	
    //Added By Sangeet for caseTrigger optimization
    public static void addEntitlementToCaseDynamic(List<Case> cases, Id recordTypeId ) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Map<String, Entitlement>> accountIdToEntitlementMap = new Map<Id, Map<String, Entitlement>>();
        
        //set entitlement dynamic values
        String entitlementName;
        String entitlementProcess;
        if(CSConstants.orderClaimRecordTypeIds.contains(recordTypeId)){
            entitlementName =  CSConstants.ORDER_CLAIMS_ENTITLEMENT;
            entitlementProcess = CSConstants.ORDER_CLAIMS_ENTITLEMENT_PROCESS;
        } else if(SBP_Constants.caseSingleBarrelRtIds.contains(recordTypeId)){
            entitlementName =  SBP_Constants.SINGLE_BARREL_ENTITLEMENT;
            entitlementProcess = SBP_Constants.SINGLE_BARREL_ENTITLEMENT_PROCESS;
        }
        else if(CSConstants.LOGISTICS_REQUEST_RT_ID.equals(recordTypeId)){
            entitlementName = CSConstants.LOGISTICS_REQUEST_ENTITLEMENT;
            entitlementProcess = CSConstants.LOGISTICS_REQUEST_ENTITLEMENT_PROCESS;
        }
        else if(GBS_Constants.gbsRecordTypeIds.contains(recordTypeId)){
            entitlementName = GBS_Constants.STANDARD_ENTITLEMENT;
            entitlementProcess = GBS_Constants.STANDARD_ENTITLEMENT_PROCESS;
        }
        else if(CSConstants.MARKET_READINESS_RT_ID.equals(recordTypeId)){
            entitlementName = CSConstants.MARKET_READINESS_RT_ID;
            entitlementProcess = CSConstants.MARKET_READINESS_ENTITLEMENT_PROCESS;
        }

        for (Case c : cases) {
            if (c.AccountId != null && c.EntitlementId == null) {
                if ((CSConstants.orderClaimRecordTypeIds.contains(c.RecordTypeId))){
                    if(!CSConstants.CLOSED_STATUS_VARIATIONS.contains(c.Status)){
                        accountIds.add(c.AccountId);
                    }
                } 
                else if(CSConstants.LOGISTICS_REQUEST_RT_ID.equals(c.RecordTypeId)){
                    if(!CSConstants.QC_CLOSED_STATUS_VARIATIONS.contains(c.Status)){
                        accountIds.add(c.AccountId);
                    }
                }
                else{
                    accountIds.add(c.AccountId);
                }
            }
        }
        
        if (accountIds.isEmpty()) {
            return;
        }
        
        //accountIdToEntitlementMap = getEntitlementsFromAccount(accountIds, CSConstants.ORDER_CLAIMS_ENTITLEMENT, CSConstants.ORDER_CLAIMS_ENTITLEMENT_PROCESS);
        Map <Id, Account> acctMap = new Map <Id, Account> ([select id, (Select Id, Name from Entitlements) from Account where Id IN: accountIds]);
        Map <Id, Account> defaultEntitlementForAccount = getEntitlementsFromAccount(acctMap.values(), entitlementName);
        createEntitlementsForAccount(defaultEntitlementForAccount, acctMap, entitlementName, entitlementProcess);
        accountIdToEntitlementMap = mapAccountToEntitlements(acctMap.keySet());
        
        for (Case c : cases) {
                if (c.EntitlementId == null) {
                    if (accountIdToEntitlementMap.containsKey(c.AccountId)) {
                        if(CSConstants.LOGISTICS_REQUEST_RT_ID.equals(c.RecordTypeId) || CSConstants.MARKET_READINESS_RT_ID.equals(c.RecordTypeId)){
                            c.SLA_Start__c = null;
                        }
                        else{
                            c.SLA_Start__c = System.now();
                        }
                        c.EntitlementId = accountIdToEntitlementMap.get(c.AccountId).get(entitlementName).Id;
                    }
                }
        }
    }
    
    //Added by Deekshika 23-11-2022 - Case Trigger Optimization
    public static void assignBusinessHoursToCases(List<Case> cases) {
        Map<String, CS_Country_Setting__mdt> countryNameToSettingGTR = new Map<String, CS_Country_Setting__mdt>();
        Map<String, CS_Country_Setting__mdt> countryNameToSetting = new Map<String, CS_Country_Setting__mdt>();
        Map<String, CS_Plant_Setting__mdt> plantNameToSetting = new Map<String, CS_Plant_Setting__mdt>();
        Map<String, BusinessHours> businessHoursMap = getBusinessHours();
        List<Case> parentCases = new List<Case>();
        List<Case> childCases = new List<Case>();
        
        for (Case c : cases) {
            if(c.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID) {
                parentCases.add(c);
            } else if(c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID 
              || c.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID) {
                childCases.add(c);
            }
        }
        
        if(parentCases.size() > 0) {
            for (CS_Country_Setting__mdt countrySetting : [Select id, Business_Hours__c, Country__c, isGTR__c, Region__c  from CS_Country_Setting__mdt]) {
                if (countrySetting.isGTR__c) {
                    countryNameToSettingGTR.put(countrySetting.Country__c, countrySetting);
                } else {
                    countryNameToSetting.put(countrySetting.Country__c, countrySetting);
                }
            }
        }
        if(childCases.size() > 0) {
            for (CS_Plant_Setting__mdt plantSetting : [Select id, Plant__c, Country__r.Business_Hours__c, Country__r.Country__c from CS_Plant_Setting__mdt]) {
                plantNameToSetting.put(plantSetting.Plant__c, plantSetting);
            }
        }
        
        for(Case c: parentCases) {
            String businessHoursName;
            if(c.Is_GTR_Distributor__c) {
                if(countryNameToSettingGTR.containsKey(c.Product_Destination_Country__c)) {
                    businessHoursName = countryNameToSettingGTR.get(c.Product_Destination_Country__c).Business_Hours__c;
                }
            } else if(countryNameToSetting.containsKey(c.Product_Destination_Country__c)) {
                if(CSConstants.COUNTRIES_USING_US_BUSINESS_HOURS.contains(c.Product_Destination_Country__c)) {
                    businessHoursName = CSConstants.US_PRODUCT_DESTINATION_COUNTRY_VALUE;
                } else {
                    businessHoursName = countryNameToSetting.get(c.Product_Destination_Country__c).Business_Hours__c;
                }
            }
            
            if (businessHoursMap.containsKey(businessHoursName)) {
                c.BusinessHoursId = businessHoursMap.get(businessHoursName).Id;
            }
        }
        
        for(Case c: childCases) {
            String businessHoursName;
            if(c.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID
              && plantNameToSetting.containsKey(c.Bottling_Plant__c)) {
                  businessHoursName = plantNameToSetting.get(c.Bottling_Plant__c).Country__r.Business_Hours__c;
            } else if(c.RecordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID
              && plantNameToSetting.containsKey(c.Shipping_Plant__c)) {
                  businessHoursName = plantNameToSetting.get(c.Shipping_Plant__c).Country__r.Business_Hours__c;
            }
            
            if (businessHoursMap.containsKey(businessHoursName)) {
                c.BusinessHoursId = businessHoursMap.get(businessHoursName).Id;
            }
        }
    }

    /*******************************************************************************************************************************
    Description:    This method is created against a process builder(Update Sub Status on Case). This will update Sub Status of a case to null if the case's Status field
                    is updated to 'Closed' or 'Resolved'.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    01/02/2023         Akshat Jain      Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static void updateSubStatusOnCase(List<Case> cases, Map<Id, Case> oldMap){
        for(Case cse: cases){
            if((cse.RecordTypeId == CSConstants.QC_RT_ID || cse.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID) && cse.Status != oldMap.get(cse.Id).Status && cse.Sub_Status__c != null){
                if(cse.Status == CSConstants.CLOSED || cse.Status == CSConstants.RESOLVED){
                    cse.Sub_Status__c = null;
                }
            }
        }
     }
    
    /*******************************************************************************************************************************
    Description:    This method is created against a process builder(Update Priority based on the Type field value). This will update priority of a case based on its Type field.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    19/01/2023         Akshat Jain      Metacube       Initial Creation
    ******************************************************************************************************************************/

    public static void updatePriorityBasedOnTheTypeFieldValue(List<Case> cases){
        for(Case cse : cases){
            if(cse.RecordTypeId == CSConstants.MARKET_READINESS_RT_ID){
                if(cse.Type == ComplianceConstants.BRAND_REGISTRATIONS_TYPE || cse.Type == ComplianceConstants.LICENSING_TYPE || cse.Type == ComplianceConstants.SPECS_TYPE){
                    cse.Priority = ComplianceConstants.MEDIUM_PRIORITY;
                }else if(cse.Type == ComplianceConstants.NEWSLETTERS_TYPE || cse.Type == ComplianceConstants.MISSING_PRICING_TYPE){
                    cse.Priority = ComplianceConstants.HIGH_PRIORITY;
                }
            }
        }
    }

    /*******************************************************************************************************************************
    Description:    This method is created against a process builder(Automated Case Status Updates for Single Barrel Cases). This method is updating status of case.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    19/01/2023         Sangeet Joshi      Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static void updateCaseStatus(List<Case> caseList){
        Id barrelreadyToEnterId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Ready_to_Enter').getRecordTypeId();
        Set<Id> setOfAccountIds = new Set<Id>();
        for(Case cse: caseList){
            setOfAccountIds.add(cse.AccountId);
        }
        
        Map<Id, Account> mapIdToAccount = new Map<Id, Account>([SELECT Id, RecordTypeId FROM Account WHERE Id IN: setOfAccountIds]);
        
        for(Case cse: caseList){
            if(cse.RecordTypeId!= barrelreadyToEnterId && cse.Status==SBP_Constants.NEW_STATUS && cse.Retail_Account__c!=null 
                && cse.AccountId!=null && mapIdToAccount.get(cse.AccountId).RecordTypeId != CSConstants.CONSUMER_ACCOUNT_RT_ID  && cse.Type!=null){
                    if(cse.Brand__c == SBP_Constants.BRAND_KNOB_CREEK && cse.Product_Type__c!=null){
                        cse.Status = SBP_Constants.PENDING_DOCUMENTATION;
                    }
                    if(cse.Brand__c == SBP_Constants.BRAND_MAKERS_MARK){
                        cse.Status = SBP_Constants.NEW_STATUS;
                    }
                    if(cse.Brand__c == SBP_Constants.BRAND_BAKERS){
                        cse.Status = SBP_Constants.PENDING_DOCUMENTATION;
                    }
            }
        }
    }
    
    /*******************************************************************************************************************************
    Description:    This method is created to update Type Edrington for Edrington Cases having Edrington Queue and Origin as Email.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    27/06/2023      Deekshika Sharma      Metacube       Initial Creation
	******************************************************************************************************************************/
    public static void updateCaseType(List<Case> cases) {
        Group edringtonQueue = [select Id from Group where Type = 'Queue' AND NAME = 'Edrington Queue'];
        for(Case c: cases) {
            if(c.OwnerId != null && c.OwnerId == edringtonQueue.Id 
               && CSConstants.EMAIL.equalsIgnoreCase(c.Origin)) {
               c.Type = CSConstants.EDRINGTON_Type;
            }
        }
    }
    
    /*******************************************************************************************************************************
    Description:    This method is updating SKU and Quantity on Barrel, created against a process builder(Update SKU and Quantity).
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    26/01/2024       Vikash Kumar       Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static void updateSKUAndQuantityOnRelatedBarrels(List<Case> cases, Map<Id, Case> oldMap){
        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            if(c.Brand__c == CSConstants.BRAND_CRUZAN && (c.Product_Type__c == CSConstants.PRODUCT_TYPE_HALF_BARREL || c.Product_Type__c == CSConstants.PRODUCT_TYPE_FULL_BARREL)
               && c.status == SBP_Constants.PREPARING_BARREL && c.SAP_Number__c != null && 
               (c.Status != oldMap.get(c.Id).status) || c.SAP_Number__c != oldMap.get(c.Id).SAP_Number__c){ 
                   caseIds.add(c.Id);
               }
        }
        
        if (caseIds.size() > 0) {
            List<Barrel__c> barrels = [SELECT Id, SKU__c,Quantity__c,Product_Type__c FROM Barrel__c WHERE Case__c IN :caseIds];
            for (Barrel__c barrel : barrels) {
                if(barrel.Product_Type__c == CSConstants.PRODUCT_TYPE_HALF_BARREL){
                    if(barrel.SKU__c == null){
                        barrel.SKU__c = System.Label.HalfBarrelSKU;
                    }
                    if(barrel.Quantity__c == null){
                        barrel.Quantity__c = Integer.valueOf(System.Label.HalfBarrelQuantity);
                    }
                }else if(barrel.Product_Type__c == CSConstants.PRODUCT_TYPE_FULL_BARREL){
                    if(barrel.SKU__c == null){
                        barrel.SKU__c = System.Label.FullBarrelSKU;
                    }
                    if(barrel.Quantity__c == null){
                        barrel.Quantity__c = Integer.valueOf(System.Label.FullBarrelQuantity);
                    }
                }
            }
            if(!barrels.isEmpty()){
                update barrels;
            }
        }   
    }
   /*******************************************************************************************************************************
    Description:    This method will pause/unpause milestone timer for 'Order Claim' cases whenever it's status toggles to/from 'Pending Activity'.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    26/01/2024     Badri Vishal Soni    Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static void pauseUnpauseMilestoneOnStatusChange(List<Case> cases, Map<Id,Case> oldMap){
        for(Case c : cases){
            Case oldCase = oldMap.get(c.Id);
            if(c.Status == 'Pending Activity' && oldCase.Status != 'Pending Activity' && oldCase.IsStopped == false && c.IsStopped == false ){
                c.IsStopped = true;
            } else if(c.Status != 'Pending Activity' && oldCase.Status == 'Pending Activity' && oldCase.IsStopped == true ){
                c.IsStopped = false;
            }
        }
    }
    /*******************************************************************************************************************************
    Description:    These methods will update the barrel laid down date and aging completed on the parent case and status of the subcase to "closed"
					on child case.		
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    26/01/2024     Surbhi & Pavan    Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static void updateBarrelLaidDownDates(List<Case> cases, Map<Id,Case> oldMap){
        if(!cases.isEmpty()){
            for(Case c : cases){
                if(c.Barrel_has_been_laid_down__c == 'Yes' && c.ParentId != NULL){  
                    if(c.Barrel_has_been_laid_down__c != oldMap.get(c.id).Barrel_has_been_laid_down__c){
                        if(c.Barrel_Laid_Down_On__c   != oldMap.get(c.id).Barrel_Laid_Down_On__c ){
                            if(c.Barrel_Laid_Down_On__c == NULL){
                                c.Aging_Complete_On__c = NULL;
                            }else{
                                c.Aging_Complete_On__c = c.Barrel_Laid_Down_On__c.addDays(63);   
                            }
                        }else{
                            c.Barrel_Laid_Down_On__c = Date.today();
                            c.Aging_Complete_On__c   = Date.today().addDays(63);
                            c.status 				 = 'closed';
                        } 
                    }else{
                        if(c.Barrel_Laid_Down_On__c != oldMap.get(c.id).Barrel_Laid_Down_On__c){
                            if(c.Barrel_Laid_Down_On__c == NULL){
                                c.Aging_Complete_On__c  = NULL;
                            }else{
                                c.Aging_Complete_On__c  = c.Barrel_Laid_Down_On__c.addDays(63);   
                            }
                        }
                    }
                }
            }
        }  
    }
    
	public static void updateBarrelLaidDownDatesOnParent(List<Case> cases, Map<Id,Case> oldMap){
          Set<Id> caseIds = new Set<Id>();
          List<Case> parentCaseToBeUpdated = new List<Case>();
          if(!cases.isEmpty()){
              for(Case c : cases){
                  if(c.Barrel_has_been_laid_down__c == 'Yes' && c.ParentId != NULL){
                             caseIds.add(c.ParentId);
                        }
               }
          }
          Map<Id, Case> parentCaseMap = new Map<Id, Case>([select id,caseNumber, Barrel_Laid_Down_On__c, Aging_Complete_On__c 
                                            from case where Id IN: caseIds]);
        
        if(!CaseIds.isempty() && !parentCaseMap.isEmpty()){
            for(Case c: cases){
                if(parentCaseMap.containsKey(c.parentId)){
                    	 Case parentDetails  = parentCaseMap.get(c.parentId);
                         parentDetails.Barrel_Laid_Down_On__c = c.Barrel_Laid_Down_On__c;
                         parentDetails.Aging_Complete_On__c   = c.Aging_Complete_On__c;
                         parentCaseToBeUpdated.add(parentDetails);
                }       
            }
        }
        if(!parentCaseToBeUpdated.isEmpty()){
                 update parentCaseToBeUpdated;
        }
	}
     /*******************************************************************************************************************************
    Description:    These methods will update the Case Status of the Sample Kit Related to case.		
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    13/09/2024     Surbhi & Pavan    Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static void updateSampleKitRelatedToCase(List<Case> cases, Map<Id,Case> oldMap){
    	Set<String> validStatuses = new Set<String>{'Closed', 'Closed - Abandoned', 'Canceled', 
          'Cancelled - Kit Not Selected', 'Preparing Barrel', 'Canceled - Age/Variety'};
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Sample_Kit__c> listToUpdateSampleKit = new List<Sample_Kit__c>();
        
        for (Case c : cases) {
            if (validStatuses.contains(c.Status)) {
                caseMap.put(c.Id, c);
            }
        } 
        
        if (!caseMap.isEmpty()) {
            List<Sample_Kit__c> sampleKitsToUpdate = [SELECT Id, Delivery_Status__c, Sample_Selected__c, Tracking_Number__c, Status_of_Case__c, Case__c 
                                                     FROM Sample_Kit__c 
                                                     WHERE Case__c IN :caseMap.keySet() 
                                                     AND Delivery_Status__c = 'Delivered'
                                                     AND Sample_Selected__c = false 
                                                     AND Tracking_Number__c != null];

            for (Sample_Kit__c sk : sampleKitsToUpdate) {
                Case relatedCase = caseMap.get(sk.Case__c);
                if (relatedCase != null) {
                    sk.Status_of_Case__c = relatedCase.Status;
                    listToUpdateSampleKit.add(sk);
                }
            }
        }
        if (!listToUpdateSampleKit.isEmpty()) {
            try {
                update listToUpdateSampleKit;
            } catch (DmlException e) {
                System.debug('Error updating SampleKit records: ' + e.getMessage());
            }
        } 
    } 
}