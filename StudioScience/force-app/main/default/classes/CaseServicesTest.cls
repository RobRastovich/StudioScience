/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-06-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(SeeAllData = false)
public class CaseServicesTest {
    public static final String CASE_RT_Standard = 'Standard Case';
    public static final String CASE_RT_BarrelReady = 'Barrel Ready to Enter';
    //public static final String CASE_RT_BarrelStandard = 'Single_Barrel_Standard';
    public static final String ACCOUNT_RT_Distributor = 'Distributor';
    public static final String Vendor_Community_Profile = 'Vendor Community';
    public static final String Admin_Profile = 'System Administrator';
    public static final String Admin_Role = 'Application Admin';
    public static final String Control_Collaboration = 'Control Collaboration';
    public static testMethod void updateCasePickList(){
        Test.startTest();
        List<Case> caseList = new List<Case>();
        Case cas = new Case();
        cas.Status = 'New';
        cas.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Control_Collaboration').getRecordTypeId();
        caseList.add(cas);
        insert caseList;
   		caseServices.updateCaseTypePicklist(caseList);
        Test.stopTest();
    }
    public static void insertAllocHierarchy(){
        Account retailAccount = new Account();
		retailAccount.Name = 'Retail Account';
		retailAccount.BillingState = 'IL';
		retailAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert new List<Account> {testAccount, retailAccount};
            
        Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
        bg.Type__c = 'Trip and Tour';
        
        insert new List<Barrel_Order_Group__c> {bg};
            CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
		c.Type = 'Trip and Tour';
		c.Barrel_Order_Group__c = bg.Id;
		c.Brand__c = 'Knob Creek';
		c.Barrel_Selected__c = false;
		c.Retail_Account__c = retailAccount.Id;
		c.Product_Type__c = 'Bourbon';
		c.ccEmail__c = 'test@test.com';
		c.AccountId = testAccount.Id;
        insert new List<Case> {c};
        
        List<Brand__c> lstBrand = new List<brand__c>();
        Brand__c newBrand = new Brand__c(Name = 'Knob Creek Bourbon',Is_Active__c = true);
        lstBrand.add(newBrand);
        insert lstBrand;
        String YearOfAlloc = String.valueOf(Date.today().year());
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c newAllocation = new Brand_Allocation__c(Brand__c = newBrand.Id, Is_Active__c=true, 
                                                                    Program_Type__c='Trip and Tour', Time_Interval__c ='Year',Time_Period__c='Yearly',
                                                                    Year_Of_Allocation__c = YearOfAlloc);
        lstBrandAllocation.add(newAllocation);
        insert lstBrandAllocation;
        List<Country__c> lstCountry = new List<Country__c>();
        Country__c newCountry = new Country__c(Name='US',IsActive__c= true,Alias__c='US');
        lstCountry.add(newCountry);
        insert lstCountry;
        List<Brand_Country_Allocation__c> lstCountryAllocation = new List<Brand_Country_Allocation__c>();
        Brand_Country_Allocation__c countryAlloc = new Brand_Country_Allocation__c(Brand_Allocation__c = newAllocation.Id,
                                                                                   Country__c = newCountry.Id,Is_Active__c= true);
        lstCountryAllocation.add(countryAlloc);
        insert lstCountryAllocation;
        List<Region__c> lstRegion = new List<Region__c>();
        Region__c newRegion = new Region__c(Name = 'Cental', Country__c = newCountry.Id, IsActive__c = true);
        Region__c nationalAccount = new Region__c(Name = 'National Accounts', Country__c = newCountry.Id, IsActive__c = true);
        Region__c militaryAccount = new Region__c(Name = 'Military', Country__c = newCountry.Id, IsActive__c = true);
        lstRegion.add(newRegion);
        lstRegion.add(nationalAccount);
        lstRegion.add(militaryAccount);
        insert lstRegion;
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
        Brand_Country_Region_Allocation__c newRegionAlloc = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = newRegion.Id);
        lstRegionAlloc.add(newRegionAlloc);
        Brand_Country_Region_Allocation__c newMilitaryRegionAlloc = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = militaryAccount.Id,
                                                                                                           Is_Leaf_Node__c = true, Allocations_Per_Interval__c = 10);
        Brand_Country_Region_Allocation__c newNationAlRegion = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = nationalAccount.Id);
        lstRegionAlloc.add(newMilitaryRegionAlloc);
        lstRegionAlloc.add(newNationAlRegion);
        insert lstRegionAlloc;
        List<State__c> lstState = new List<State__c>();
        State__c newState2 = new State__c(Name='IL', Region__c = newRegion.Id,country__c = newCountry.Id, IsActive__c = true,Alias__c='te',State_Manager__c = UserInfo.getUserId());
        State__c offPremiseState = new State__c(Name='Off Premise', Region__c = nationalAccount.Id,country__c = newCountry.Id, IsActive__c = true,Alias__c='Off',State_Manager__c = UserInfo.getUserId());
        lstState.add(newState2);
        lstState.add(offPremiseState);
        insert lstState;
        list<Brand_Country_Region_State_Allocation__c> lstStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
        Brand_Country_Region_State_Allocation__c newStateAlloc2 = new Brand_Country_Region_State_Allocation__c(Brand_Country_Region_Allocation__c = newRegionAlloc.Id, State__c = newState2.Id,
                                                                                                               Is_Leaf_Node__c = false, Is_Active__c = true);
        Brand_Country_Region_State_Allocation__c offPremiseStateAlloc = new Brand_Country_Region_State_Allocation__c(Brand_Country_Region_Allocation__c = newNationAlRegion.Id, State__c = offPremiseState.Id,
                                                                                                                     Is_Leaf_Node__c = true, Is_Active__c = true, Allocations_Per_Interval__c = 10);
        lstStateAlloc.add(newStateAlloc2);
        lstStateAlloc.add(offPremiseStateAlloc);
        insert lstStateAlloc;
        
        list<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        Brand_Country_Region_State_Dist_Alloc__c newDistAlloc = new Brand_Country_Region_State_Dist_Alloc__c(
            Account__c = getTestAccount().Id, Allocations_Per_Interval__c = 10, Brand_Country_Region_State_Allocation__c =newStateAlloc2.Id, 
            Is_Active__c=true,Is_Leaf_Node__c=true);
        lstDistAlloc.add(newDistAlloc);
        insert lstDistAlloc;
    }
    
    public static Account getTestAccount() {
        return [select id from Account where Name = 'Test Account'];
    }

    private static Id caseRTId {
        get{
            if (caseRTId == null) {
                caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RT_Standard).getRecordTypeId();
            }
            return caseRTId;
        }
        set;
    }
    private static Id accountRTId {
        get{
            if (accountRTId == null) {
                accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_RT_Distributor).getRecordTypeId();
            }
            return accountRTId;
        }
        set;
    }

    public static List<Case> createChildCaseRecords(String recordTypeName, String status, Id parentId, Integer numOfChildRecords, Boolean autoCreate) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<Case> casesToInsert = new List<Case>();
        Case parentCase = new Case();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;

        for (Integer i = 0; i < numOfChildRecords; i++) {
            Case c = new Case();
            c.Status = status;
            c.ParentId = parentId;
            c.RecordTypeId = recordTypeId;
            //c.setOptions(dmo);
            casesToInsert.add(c);
        }

        if (autoCreate) {
            insert casesToInsert;
        }

        return casesToInsert;
    }


    public static List<Case> getCasesById(Set<Id> caseIds) {
        return [select id
                , All_Sub_Cases_Closed__c
                , Shipping_Plant__c
                , AccountId
                , ParentId 
                , Status 
                , Product_Type__c
                , Retail_Account__c
                , ContactId 
                , Brand__c
                , isReOpened__c
                , Expedited_Claim__c
                , BusinessHoursId
                , BusinessHours.Name
                , Product_Destination_Country__c
                , Owner.Name
                , OwnerId
                , EntitlementId
                , Financial_Disposition__c
                , Return_SAP_Number__c
                , Return_SAP_number_missing__c
                , Billing_SAP_number_missing__c
                , Billing_SAP_Number__c
                , Order_Ready_To_Enter__c
                , Order_Ready_To_Enter_Checked_Date__c
                , Entitlement.Name from Case where Id IN :caseIds];
    }

    public static List<CaseMilestone> getCaseMilestoneByCaseId(Id caseId) {
        return [select Id
                , StartDate
                , TargetDate
                , CompletionDate
                , MilestoneTypeId
                , MilestoneType.Name
                , IsCompleted
                , BusinessHoursId
                , CaseId
                , Case.Status
                , Case.RecordTypeId
                , TargetResponseInMins
                , TargetResponseInHrs
                , TargetResponseInDays
                , TimeRemainingInMins
                , IsViolated FROM CaseMilestone where CaseId = :caseId];
    }

    public static List<Entitlement> getEntitlementsOnAccount(Id acctId) {
        return [select id from Entitlement where AccountId = :acctId];
    }

    public static testMethod void testBusinessHoursBucketerOnHold() {
        //Define the next business day (Monday)
        caseServices.testDay = '1';

        Test.startTest();
        //Setup the stop statuses
        Stop_Status__c ss = new Stop_Status__c(Name = 'On Hold');
        insert ss;
        caseServices.runTrigger = true;

        //Insert new case
        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;

        Test.stopTest();
    }

    public static testMethod void testBusinessHoursBucketerNew() {

        //Define the next business day (Monday)
        caseServices.testDay = '1';

        Test.startTest();
        //Setup the stop statuses
        Stop_Status__c ss = new Stop_Status__c(Name = 'On Hold');
        insert ss;
        caseServices.runTrigger = true;

        //Insert new case
        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;

        caseServices.runTrigger = false;

        c.Status = 'On Hold';
        update c;
        caseServices.runTrigger = false;

        Test.stopTest();
    }


    public static testMethod void testBusinessHoursBucketerClosed() {

        //Define the next business day (Monday)
        caseServices.testDay = '1';

        Test.startTest();
        //Setup the stop statuses
        Stop_Status__c ss = new Stop_Status__c(Name = 'On Hold');
        insert ss;
        caseServices.runTrigger = true;

        //Insert new case
        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;

        Case updatedCase = [select Time_With_Customer__c, Time_With_Support__c, Case_Age_In_Business_Hours__c from Case where Id = :c.Id];
        System.assert(updatedCase.Time_With_Customer__c != null);
        System.assert(updatedCase.Time_With_Support__c != null);
        System.assert(updatedCase.Case_Age_In_Business_Hours__c == null);

        //Update Case with Closed Status
        c.Status = 'Closed';
        update c;
        caseServices.runTrigger = true;

        Test.stopTest();

        updatedCase = [select Time_With_Customer__c, Time_With_Support__c, Case_Age_In_Business_Hours__c from Case where Id = :c.Id];
        System.assert(updatedCase.Time_With_Customer__c != null);
        System.assert(updatedCase.Time_With_Support__c != null);
        System.assert(updatedCase.Case_Age_In_Business_Hours__c == null);
    }

    public static testMethod void testSLATimesOnInsert() {

        //Setup default business hours
        BusinessHours bh = [Select Id, TimeZoneSidKey, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime From BusinessHours Where IsDefault = TRUE];

        //Setup test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');

        //Define the next business day (Monday)
        caseServices.testDay = '1';

        System.runAs(u) {

            //Insert a case
            Case c = new Case();
            c.Status = 'New';
            c.Last_Status_Change__c = System.Now();
            c.RecordTypeId = caseRTId;
            insert c;

            Case case_test = [select CaseNumber, CreatedDate, SLA_Start_Time__c, SLA_End_Time__c from Case where Id = :c.Id];
            System.assert(case_Test.SLA_Start_Time__c != null);
            System.assert(case_Test.SLA_End_Time__c != null);

        }
    }

    public static testMethod void testInsertUpdateWeekly_Monday() {
        caseServices.runTrigger = false;
        //Setup the stop statuses
        Stop_Status__c ss = new Stop_Status__c(Name = 'On Hold');
        insert ss;

        Test.startTest();
        //Define the next business day (Tuesday)
        caseServices.testDay = '1';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = false;

        c.Status = 'On Hold';
        c.Update_SLA_Times__c = TRUE;
        update c;
        caseServices.runTrigger = true;

        Test.stopTest();


        c.Status = 'Closed';
        c.Update_SLA_Times__c = TRUE;
        update c;
    }

    public static testMethod void testInsertUpdateWeekly_Tuesday() {

        //Define the next business day (Tuesday)
        caseServices.testDay = '2';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Test.startTest();

        c.Update_SLA_Times__c = TRUE;
        update c;

        Test.stopTest();
    }

    public static testMethod void testInsertUpdateWeekly_Wednesday() {

        //Define the next business day (Tuesday)
        caseServices.testDay = '3';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Test.startTest();

        c.Update_SLA_Times__c = TRUE;
        update c;

        Test.stopTest();
    }

    public static testMethod void testInsertUpdateWeekly_Thursday() {

        //Define the next business day (Tuesday)
        caseServices.testDay = '4';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Test.startTest();

        c.Update_SLA_Times__c = TRUE;
        update c;

        Test.stopTest();
    }

    public static testMethod void testInsertUpdateWeekly_Friday() {
        caseServices.runTrigger = false;
        //Define the next business day (Tuesday)
        caseServices.testDay = '5';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Test.startTest();

        c.Update_SLA_Times__c = TRUE;
        update c;

        Test.stopTest();
    }

    public static testMethod void testInsertUpdateWeekly_Saturday() {

        //Define the next business day (Tuesday)
        caseServices.testDay = '6';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Test.startTest();

        c.Update_SLA_Times__c = TRUE;
        update c;

        Test.stopTest();
    }

    public static testMethod void testInsertUpdateWeekly_Sunday() {

        //Define the next business day (Tuesday)
        caseServices.testDay = '7';

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Test.startTest();

        c.Update_SLA_Times__c = TRUE;
        update c;

        Test.stopTest();
    }

    public static testMethod void testCaseEmailSuppliedEmail() {

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        c.SuppliedEmail = 'test@testmailer.com';
        insert c;


    }

    public static testMethod void testCaseEmailNoContact() {

        Profile p0 = [SELECT Id FROM Profile WHERE Name = :Admin_Profile];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = :Admin_Role];
        User u0 = new User(Alias = 'beamtu2', Email = 'standarduser2@testorg22.com',
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US', ProfileId = p0.Id, UserRoleId = r.Id,
                           TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser2@test-user-system.com.test-only');
        insert u0;

        Test.startTest();

        System.runAs(u0) {
            Account a = new Account();
            a.RecordTypeId = accountRTId;
            a.Name = 'Test Account';
            insert a;

            system.debug('Account Owner: ' + a.OwnerId);

            Contact con = new Contact();
            con.LastName = 'Tester';
            con.AccountId = a.Id;
            con.Email = 'test@test.com';
            insert con;

            Profile p = [SELECT Id FROM Profile WHERE Name = :Vendor_Community_Profile];
            User u = new User(Alias = 'beamtu', ContactId = con.Id, Email = 'standarduser@testorg123.com',
                              EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US', ProfileId = p.Id,
                              TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
            insert u;

            Case c = new Case();
            c.Status = 'New';
            c.Last_Status_Change__c = System.Now();
            c.RecordTypeId = caseRTId;
            c.ContactId = con.Id;
            insert c;

            Test.stopTest();

            system.debug('Contact Id: ' + c.ContactId);
            system.debug('Supplied Email: ' + c.SuppliedEmail);

        }

    }

    public static testMethod void testCaseLanguageNoContact() {

        Test.startTest();
        Profile p0 = [SELECT Id FROM Profile WHERE Name = :Admin_Profile];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = :Admin_Role];
        User u0 = new User(Alias = 'beamtu2', Email = 'standarduser2@testorg.com',
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US', ProfileId = p0.Id, UserRoleId = r.Id,
                           TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser2@test-user-system.com.test-only');
        insert u0;

        System.runAs(u0) {
            Case c = new Case();
            c.Status = 'New';
            insert c;
        }

        Test.stopTest();
    }

    public static testMethod void testUpdateFlagsOnStatusChangeStopStatus() {
        caseServices.runTrigger = false;
        Stop_Status__c WOTP = new Stop_Status__c(Name = 'Waiting on 3rd Party', CurrencyISOCode = 'USD');
        insert WOTP;

        Test.startTest();

        List<CaseStatus> closedCaseStatusList = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = true];

        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Logged';
        c.New_Activity__c = true;
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Case currCase = [SELECT Id, New_Activity__c, Status FROM Case WHERE Id = : c.Id];
        System.assertEquals(1, [SELECT COUNT() FROM Case WHERE Id = : c.Id]);
        System.assertEquals('Logged', currCase.Status);
        System.assertEquals(true, currCase.New_Activity__c);

        currCase.Status = WOTP.Name;
        update currCase;
        currCase = [SELECT Id, New_Activity__c, Status FROM Case WHERE Id = : c.Id];
        System.assertEquals(WOTP.Name, currCase.Status);
        System.assertEquals(false, currCase.New_Activity__c);

        Test.stopTest();

    }

    public static testMethod void testUpdateFlagsOnStatusChangeClosedCaseStatus() {
        caseServices.runTrigger = false;
        Stop_Status__c WOTP = new Stop_Status__c(Name = 'Waiting on 3rd Party', CurrencyISOCode = 'USD');
        insert WOTP;

        Test.startTest();

        List<CaseStatus> closedCaseStatusList = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = true];

        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Logged';
        c.New_Activity__c = true;
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Case currCase = [SELECT Id, New_Activity__c, Status FROM Case WHERE Id = : c.Id];
        System.assertEquals(1, [SELECT COUNT() FROM Case WHERE Id = : c.Id]);
        System.assertEquals('Logged', currCase.Status);
        System.assertEquals(true, currCase.New_Activity__c);

        currCase.Status = 'Active';
        currCase.New_Activity__c = true;
        update currCase;
        caseServices.runTrigger = true;
        Test.stopTest();

        currCase.Status = closedCaseStatusList[0].MasterLabel;
        update currCase;
        caseServices.runTrigger = true;
        currCase = [SELECT Id, New_Activity__c, Status FROM Case WHERE Id = : c.Id];
        System.assertEquals(closedCaseStatusList[0].MasterLabel, currCase.Status);
        System.assertEquals(false, currCase.New_Activity__c);


    }

    public static testMethod void testUpdateFlagsOnStatusChangeActiveStatus() {
        caseServices.runTrigger = false;
        Stop_Status__c WOTP = new Stop_Status__c(Name = 'Waiting on 3rd Party', CurrencyISOCode = 'USD');
        insert WOTP;

        Test.startTest();

        List<CaseStatus> closedCaseStatusList = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = true];

        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Logged';
        c.New_Activity__c = true;
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Case currCase = [SELECT Id, New_Activity__c, Status FROM Case WHERE Id = : c.Id];
        System.assertEquals(1, [SELECT COUNT() FROM Case WHERE Id = : c.Id]);
        System.assertEquals('Logged', currCase.Status);
        System.assertEquals(true, currCase.New_Activity__c);

        currCase.Status = 'Active';
        update currCase;
        currCase = [SELECT Id, New_Activity__c, Status FROM Case WHERE Id = : c.Id];
        System.assertEquals('Active', currCase.Status);
        System.assertEquals(true, currCase.New_Activity__c);

        Test.stopTest();

    }

    public static testMethod void testUpdateNumTimesIn3rdParty() {
        caseServices.runTrigger = false;

        //NOTE: CaseHistory records are not created in Test context and cannot be created manually,
        //therefore a portion of the code cannot possibly be tested
        Test.startTest();
        Stop_Status__c WOTP = new Stop_Status__c(Name = 'Waiting on 3rd Party', CurrencyISOCode = 'USD');
        Stop_Status__c WFR = new Stop_Status__c(Name = 'Waiting for Requestor', CurrencyISOCode = 'USD');
        insert new List<Stop_Status__c> {WOTP, WFR};

        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Logged';
        c.New_Activity__c = true;
        c.RecordTypeId = caseRTId;
        insert c;
        caseServices.runTrigger = true;

        Case currCase = [SELECT Id, Status, Number_of_Times_in_3rd_Party__c FROM Case WHERE Id = : c.Id];

        System.assertEquals(0, currCase.Number_of_Times_in_3rd_Party__c);

        currCase.Number_of_Times_in_3rd_Party__c = null;
        currCase.Status = 'Waiting on 3rd Party';
        update currCase;

        currCase = [SELECT Id, Status, Number_of_Times_in_3rd_Party__c FROM Case WHERE Id = : currCase.Id];
        System.assertEquals(1, currCase.Number_of_Times_in_3rd_Party__c);

        currCase.Status = 'Waiting for Requestor';
        update currCase;

        currCase = [SELECT Id, Status, Number_of_Times_in_3rd_Party__c FROM Case WHERE Id = : currCase.Id];

        Test.stopTest();
        System.assertEquals(1, currCase.Number_of_Times_in_3rd_Party__c);
    }
    
    public static testMethod void testUpdateCaseTypeAndReassign() {
        CaseTypeForDept__c gmdmCaseType = new CaseTypeForDept__c(Name = 'GMDM', Business_Process_Name__c = 'GMDM', Default_Type__c = 'Global Master Data Management');
        CaseTypeForDept__c hrCaseType = new CaseTypeForDept__c(Name = 'HR', Business_Process_Name__c = 'HR', Default_Type__c = 'Human Resources');
        insert new List<CaseTypeForDept__c> {gmdmCaseType, hrCaseType};
            
        contact con = new contact(LastName='testCon');
        insert con;
        User submitter = [select id from user where isActive = false limit 1];

        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        Id hrCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HR').getRecordTypeId();
        String oldType, newType, oldOwner, newOwner;
        Case c = new Case();
        c.Status = 'Logged';
        c.RecordTypeId = gmdmCaseRecordTypeId;
        c.Submitter__c = submitter.Id;
        c.ContactId = con.id;
        insert c;
        caseServices.runTrigger = true;
        c = [SELECT Id, Type, OwnerId FROM Case WHERE Id = : c.Id];
        oldType = c.Type;
        oldOwner = c.OwnerId;

        c.RecordTypeId = hrCaseRecordTypeId;
        Test.startTest();
        //update c;
        c = [SELECT Id, Type, OwnerId FROM Case WHERE Id = : c.Id];
        newType = c.Type;
        newOwner = c.OwnerId;
        Test.stopTest();

        //System.assertNotEquals(oldType, newType);
        //System.assertNotEquals(oldOwner, newOwner);
    }

    @future
    public static void insertUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'beamtu', Email = 'standarduser@testorg.com',
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,
                          TimeZoneSidKey = 'America/Chicago', UserName = 'beamsuntorytestuser@test-user-system.com.test-only');
        insert u;
    }
    
    public static testMethod void testSyncSelfRegistrationOwnership() {
        insertUser();
        User u = [SELECT Id From User Limit 1];
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = false;

        Id registrationApprovalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Registration Approval').getRecordTypeId();
        Id standardCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RT_Standard).getRecordTypeId();
        Contact registrationContact = new Contact(FirstName = 'Registration', LastName = 'User');
        Contact standardContact = new Contact(FirstName = 'Standard', LastName = 'User');
        insert new List<Contact> {registrationContact, standardContact};
        Case registrationCase = new Case(RecordTypeId = registrationApprovalCaseRecordTypeId, ContactId = registrationContact.Id);
        registrationCase.setOptions(dmo);
        Case standardCase = new Case(RecordTypeId = standardCaseRecordTypeId, ContactId = standardContact.Id);
        standardCase.setOptions(dmo);
        insert new List<Case> {registrationCase, standardCase};
        caseServices.runTrigger = true;

        Test.startTest();
        //Testing scenario where record type is "Registration Approval"
        Case queriedRegCase = [SELECT Id, OwnerId, Submitter__c FROM Case WHERE Id = : registrationCase.Id];
        Contact queriedRegContact = [SELECT Id, OwnerId FROM Contact WHERE Id = : registrationContact.Id];
        //System.assertEquals(queriedRegCase.OwnerId, queriedRegContact.OwnerId);
        System.assertNotEquals(queriedRegCase.OwnerId, u.Id);
        System.assertNotEquals(queriedRegContact.OwnerId, u.Id);
        queriedRegCase.OwnerId = u.Id;
        update queriedRegCase;

        queriedRegCase = [SELECT Id, OwnerId FROM Case WHERE Id = : registrationCase.Id];
        queriedRegContact = [SELECT Id, OwnerId FROM Contact WHERE Id = : registrationContact.Id];
        System.assertEquals(queriedRegCase.OwnerId, queriedRegContact.OwnerId);
        System.assertEquals(queriedRegCase.OwnerId, u.Id);
        System.assertEquals(queriedRegContact.OwnerId, u.Id);

        //Testing scenario where record type is "Standard Case"
        Case queriedStandardCase = [SELECT Id, OwnerId FROM Case WHERE Id = : standardCase.Id];
        Contact queriedStandardContact = [SELECT Id, OwnerId FROM Contact WHERE Id = : standardContact.Id];
        //System.assertEquals(queriedStandardCase.OwnerId, queriedStandardContact.OwnerId);
        System.assertNotEquals(queriedStandardCase.OwnerId, u.Id);
        System.assertNotEquals(queriedStandardContact.OwnerId, u.Id);
        queriedStandardCase.OwnerId = u.Id;
        update queriedStandardCase;

        queriedStandardCase = [SELECT Id, OwnerId FROM Case WHERE Id = : standardCase.Id];
        queriedStandardContact = [SELECT Id, OwnerId FROM Contact WHERE Id = : standardContact.Id];
        System.assertNotEquals(queriedStandardCase.OwnerId, queriedStandardContact.OwnerId);
        System.assertEquals(queriedStandardCase.OwnerId, u.Id);
        System.assertNotEquals(queriedStandardContact.OwnerId, u.Id);
        Test.stopTest();
    }

    public static testMethod void testRemoveAbandonedCases() {
        caseServices.runTrigger = false;

        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
        
        
        contact con = new contact(LastName='testCon');
        insert con;
        User submitter = [select id from user where isActive = false limit 1];

        Test.startTest();

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;

        Case c = new Case();
        c.Status = 'New';
        c.Submitter__c = submitter.Id;
        c.ContactId = con.Id;
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = gmdmCaseRecordTypeId;
        c.setOptions(dmo);
        insert c;

        caseServices.runTrigger = true;

        System.assertEquals(1, [SELECT COUNT() FROM Case]);
        c.OwnerId = UserInfo.getUserId();
        c.Case_Resolution_Details__c = 'Case closed';
        c.Status = 'Closed - Abandoned';
        update c;

        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Case]);
    }
    
  /*  public static testMethod void testDeletePlantEventsFromCase(){
        
		Test.startTest();  
		caseServices.runTrigger = false;
        
        Id gmdmCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GMDM').getRecordTypeId();
     
        Plant_Event__c pe = new Plant_Event__c();
        pe.OwnerId = UserInfo.getUserId();
        pe.Plant__c = 'Clermont';
        pe.Brand__c = 'Knob Creek';
        pe.Status__c = 'Pending Approval';
       // pe.Case__c = c.id;
        insert pe;
        
        Case c = new Case();
        c.Status = 'New';
        c.RecordTypeId = gmdmCaseRecordTypeId;       
        c.Brand__c = 'Knob Creek' ;
        c.Plant_Event__c = pe.id;
        insert c;
       
        caseServices.runTrigger = true;
   
      System.assertEquals(1,[SELECT COUNT() FROM Plant_Event__c]); 
     
      c.OwnerId = UserInfo.getUserId();
      c.Case_Resolution_Details__c = 'Case closed';  
      c.Status = 'Closed - Abandoned';
      update c;  
        
      Plant_Event__c deletePlantEvent = [SELECT id FROM Plant_Event__c WHERE Case__c =:c.id];
     
      System.assertEquals(0, [SELECT COUNT() FROM Plant_Event__c]); 
      Test.stopTest();
    }*/

    public static testMethod void testSendEmail() {

        Test.startTest();
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.Last_Status_Change__c = System.Now();
        c.RecordTypeId = caseRTId;
        insert c;

        EmailMessage em = new EmailMessage(FromAddress = 'gbs@test.com', Incoming = False, ToAddress = 'cs@test.com', Subject = 'Test email', TextBody = 'Test body', ParentId = c.Id);
        insert em;

        caseServices.sendEmail(new List<Id> {em.Id});
        Test.stopTest();
    }


    public static testMethod void testUpdateParentCaseCloseAllSubCases() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];
        System.assertEquals(false, c.All_Sub_Cases_Closed__c, 'no child cases are closed, this value should be false');

        caseServices.runTrigger = true;

        Test.startTest();
        for (Case child : childCases) {
            child.Status = 'Closed';
            System.debug('>>> child case ' + child.Id);
        }
        update childCases;

        Test.stopTest();
        Case updatedParentCase = getCasesById(new Set<Id> {c.Id})[0];

        System.assertEquals(true, updatedParentCase.All_Sub_Cases_Closed__c, 'All Sub Cases closed field on the parent should be closed once child cases are closed');

    }

    public static testMethod void testUpdateParentCaseCloseOneSubCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];
        System.assertEquals(false, c.All_Sub_Cases_Closed__c, 'no child cases are closed, this value should be false');

        caseServices.runTrigger = true;

        Test.startTest();
        childCases[0].Status = 'Closed';
        update childCases[0];

        Test.stopTest();
        Case updatedParentCase = getCasesById(new Set<Id> {c.Id})[0];

        System.assertEquals(false, updatedParentCase.All_Sub_Cases_Closed__c, 'Only one sub case is closed, this should be false');

    }

    public static testMethod void testCheckIfCaseWasReopened() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Claim').getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'Closed';
        c.Subject = 'Test Case';
        c.Financial_Disposition__c = 'Credit';
        c.Return_SAP_Number__c = '111';
        c.Compliant_Pro_Number__c = '123';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        insert c;

        caseServices.runTrigger = true;

        Case updatedCase = [select Id, Status, EntitlementId from Case where Id = :c.Id];

        updatedCase.Status  = 'New';
        update updatedCase;

        Test.stopTest();
        Case caseUpdate = getCasesById(new Set<Id> {c.Id})[0];
        System.assertEquals(true, caseUpdate.isReOpened__c);

    }

    public static testMethod void testSetChildCaseToExpeditedOrderClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Claim').getRecordTypeId();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
        caseServices.runTrigger = true;


        Test.startTest();
        c.Expedited_Claim__c = true;
        update c;

        Test.stopTest();
        List<Case> updatedCases = getCasesById(new Set<Id> {c.Id});

        for (Case cc : updatedCases) {
            System.assertEquals(true, cc.Expedited_Claim__c);
        }

    }

    public static testMethod void testAddEntitlementToLogisticsRequestCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Logistics request').getRecordTypeId();

        Account acct = new Account();
        acct.Name = 'test Account';
        insert acct;

        List<Entitlement> entitlementsBefore = getEntitlementsOnAccount(acct.Id);

        System.assertEquals(true, entitlementsBefore.isEmpty(), 'No Entitlements should be associated with this Account');

        Test.starttest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.AccountId = acct.Id;
        insert c;
        c.Status= 'Working';
        update c;
        List<Entitlement> entitlementsAfter = getEntitlementsOnAccount(acct.Id);
        Case cc = getCasesById(new Set<Id> {c.Id})[0];

        Test.stopTest();

        System.assertEquals(1, entitlementsAfter.size(), 'The Account should have 1 Entitlement');
        System.assertEquals(CSConstants.LOGISTICS_REQUEST_ENTITLEMENT, cc.Entitlement.Name);

    }

    public static testMethod void testAddEntitlementToCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Account acct = new Account();
        acct.Name = 'test Account';
        insert acct;

        List<Entitlement> entitlementsBefore = getEntitlementsOnAccount(acct.Id);

        System.assertEquals(true, entitlementsBefore.isEmpty(), 'No Entitlements should be associated with this Account');

        Test.starttest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.AccountId = acct.Id;
        insert c;

        List<Entitlement> entitlementsAfter = getEntitlementsOnAccount(acct.Id);
        Case cc = getCasesById(new Set<Id> {c.Id})[0];

        Test.stopTest();

        System.assertEquals(1, entitlementsAfter.size(), 'The Account should have 1 Entitlement');
        System.assertEquals(CSConstants.ORDER_CLAIMS_ENTITLEMENT, cc.Entitlement.Name);

    }

    @isTest
    public static void testAssignBusinessHoursToCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim_Sub_Case).getRecordTypeId();
        Set<Id> caseIds = new Set<Id>();
        List<Case> cases = new List<Case>();
        Map<String, Case> plantToCaseMap = new Map<String, Case>();
        Test.startTest();
        // create one case for each shipping plant
        // custom metadata type CS Plant Setting stores the plant settings
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'ACCU-TEC', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'ADL', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Australia Bedfords', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Australia Pendulum', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Behror', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Blue Ocean', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Clermont', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Cooleys', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'CRS', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Frankfort', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Frankfort-DHL', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Fundador', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Germany BSI', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Glenturner', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Hooghoudt', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Jarnac', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Loretto', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Ned Cargo', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Onsort', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Pri-Pack', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Sauza', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Segovia', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Singapore BSI', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Suntory-Japanese Whiskey', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Tri-Link', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Western Wine Services', BusinessHoursId = null));
        cases.add(new Case(Status = 'New', RecordTypeId = recordTypeId, Shipping_Plant__c = 'Walkerville', BusinessHoursId = null));

        insert cases;

        Map<String, String> shippingPlantToBusinessHours = new Map<String, String> {
            'ADL'                       => 'Canada - MST',
            'ACCU-TEC'                  => 'US',
            'Australia Bedfords'        => 'Australia - EDT',
            'Australia Pendulum'        => 'Australia - EDT',
            'Behror'                    => 'India',
            'Blue Ocean'                => 'India',
            'Clermont'                  => 'US',
            'Cooleys'                   => 'UK',
            'CRS'                       => 'UK',
            'Frankfort-DHL'             => 'US',
            'Frankfort'                 => 'US',
            'Fundador'                  => 'Europe - CET',
            'Germany BSI'               => 'Germany',
            'Glenturner'                => 'UK',
            'Hooghoudt'                 => 'Europe - CET',
            'Jarnac'                    => 'Europe - CET',
            'Loretto'                   => 'US',
            'Ned Cargo'                 => 'Europe - CET',
            'Onsort'                    => 'Canada - CST',
            'Sauza'                     => 'Mexico',
            'Pri-Pack'                  => 'US',
            'Segovia'                   => 'Europe - CET',
            'Singapore BSI'             => 'Singapore',
            'Suntory-Japanese Whiskey'  => 'Japan',
            'Tri-Link'                  => 'US',
            'Walkerville'               => 'Canada - CST',
            'Western Wine Services'     => 'US'
        };

        for (Case c : cases) {
            caseIds.add(c.Id);
        }

        Test.stopTest();

        for (Case plantCase : getCasesById(caseIds)) {
            //System.assertEquals(shippingPlantToBusinessHours.get(plantCase.Shipping_Plant__c), plantCase.BusinessHours.Name, 'The shipping plant should be present in the shippingPlantToBusinessHours Map: ' + plantCase.Shipping_Plant__c);
        }
    }

    public static testMethod void testSetChildCasesToBePickedUpByAssignmentRules() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        insert c;

        Test.startTest();

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);
        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];
        List<Case> childCasesUpdated = getCasesById(new Set<Id> {childCases[0].Id, childCases[1].Id });
        Group defaultOrderClaimQueue = [select id from Group where Type = 'Queue' AND DeveloperName = 'Order_Claim_Sub_Case_Queue' limit 1];
        Group canadaPlantQueue = [select id from Group where Type = 'Queue' AND DeveloperName = 'Canada_Plant_Queue' limit 1];

        for (Case cc : childCasesUpdated) {
            System.assertEquals(defaultOrderClaimQueue.Id, cc.OwnerId, 'The Case should default to the "Order Claim Sub Case Queue" Queue');
            cc.Shipping_Plant__c = 'Walkerville';
        }
        caseServices.runTrigger = true;
        update childCasesUpdated;
        Test.stopTest();

        caseServices.runTrigger = true;
        parentCase.Status = 'Pending Sub-Case';
        update parentCase;

        List<Case> childCasesNewOwner = getCasesById(new Set<Id> {childCases[0].Id, childCases[1].Id });

        for (Case cc : childCasesNewOwner) {
            System.assertEquals(canadaPlantQueue.Id, cc.OwnerId, 'The Case should equal the canada queue');
        }
    }

    public static testMethod void testCheckRequiredFieldsOnChildForClosingParentCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        insert c;

        Test.startTest();

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);

        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];

        for (Case cc : childCases) {
            cc.Financial_Disposition__c = 'Credit';
            cc.Return_SAP_Number__c = '1234';
            cc.Status = 'Closed';
            cc.Type = 'Damage Claim';
        }

        caseServices.runTrigger = true;
        update childCases;

        Test.stopTest();

        caseServices.runTrigger = true;
        parentCase.Status = 'Closed';
        parentCase.Financial_Disposition__c = 'Credit';
        parentCase.Return_SAP_Number__c = '111';
        parentCase.Compliant_Pro_Number__c = '123';
        update parentCase;

        List<Case> childCasesUpdated = getCasesById(new Set<Id> {childCases[0].Id, childCases[1].Id });
    }

    public static testMethod void testCheckRequiredFieldsOnChildForClosingParentCaseForDamageClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Return_SAP_number_missing__c = false;
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, false);

        for (Case cc : childCases) {
            cc.Financial_Disposition__c = null;
            cc.Return_SAP_Number__c = null;
            cc.Type = 'Damage Claim';
        }
        caseServices.runTrigger = false;
        insert childCases;

        for (Case cc : childCases) {
            cc.Financial_Disposition__c = 'Credit';
            cc.Return_SAP_Number__c = null;
            cc.Status = 'Closed - Approved';
        }

        caseServices.runTrigger = true;
        update childCases;

        Test.stopTest();

        Case updatedParentCase = getCasesById(new Set<Id> {c.Id})[0];


        System.assertEquals(true, updatedParentCase.Return_SAP_number_missing__c, 'Child case is missing Return SAP number so flag should be set to true');
    }


    public static testMethod void testCheckRequiredFieldsOnChildForClosingParentCaseForOverageClaim() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        List<Case> childCases = new List<Case>();

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Return_SAP_number_missing__c = false;
        insert c;

        childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, false);

        for (Case cc : childCases) {
            cc.Financial_Disposition__c = null;
            cc.Return_SAP_Number__c = null;
            cc.Type = 'Overage Claim';
        }
        caseServices.runTrigger = false;
        insert childCases;

        for (Case cc : childCases) {
            cc.Financial_Disposition__c = 'Credit';
            cc.Return_SAP_Number__c = '12345';
            cc.Billing_SAP_Number__c = null;
            cc.Status = 'Closed - Approved';
        }
        caseServices.runTrigger = true;
        update childCases;
        Test.stopTest();



        Case updatedParentCase = getCasesById(new Set<Id> {c.Id})[0];



        System.assertEquals(true, updatedParentCase.Billing_SAP_number_missing__c, 'Child case is missing Billing SAP number so flag should be set to true');
    }

    @isTest(SeeAllData = false)
    public static void testSettingBusinessBasedOnCountryGTR() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = true;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Brazil';
        c.Is_GTR_Distributor__c = true;
        insert c;

        //List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);

        Test.stopTest();

        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];

        System.assertNotEquals(NULL, parentCase.BusinessHours.Name);
    }

    public static testMethod void testSettingBusinessBasedOnCountryNotGTRDefaultUS() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Brazil';
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);

        Test.stopTest();

        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];

        System.assertEquals('US', parentCase.BusinessHours.Name);
    }

    public static testMethod void testSettingBusinessBasedOnCountryNotGTRAndNotUS() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);

        Test.stopTest();

        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];

        System.assertEquals('UK', parentCase.BusinessHours.Name);
    }

    public static testMethod void testSetDefaultAccountIfBailmentOrderClaimCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        
        Test.startTest();
        Account a = new Account();
        a.Name = CSConstants.DEFAULT_ACCOUNT_NAME;
        a.RecordTypeId = CSConstants.DEFAULT_ACCOUNT_RT_ID;
        insert a;
        
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.Is_Bailment_Claims__c = true;
        c.AccountId = a.Id;
        insert c;

        Test.stopTest();

        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];
        List<Account> accts = [select Id, RecordTypeId, Name from Account where Name = :CSConstants.DEFAULT_ACCOUNT_NAME  AND RecordTypeId = :CSConstants.DEFAULT_ACCOUNT_RT_ID limit 1];
        System.assertEquals(accts[0].Id, parentCase.AccountId);
    }

    @isTest
    public static void testClosePreparePlantMilestone() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();

        Account acct = new Account();
        acct.Name = 'Beam Suntory';
        acct.RecordTypeId = acctRecordTypeId;
        insert acct;

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.Is_Bailment_Claims__c = true;
        c.AccountId = acct.Id;
        insert c;

        CaseMilestone preparePlantMilestone = new CaseMilestone();
        for (CaseMilestone caseMilestone : getCaseMilestoneByCaseId(c.Id)) {
            if (CSConstants.PREPARE_FOR_PLANT_MILESTONES.contains(caseMilestone.MilestoneType.Name)) {
                preparePlantMilestone = caseMilestone;
                break;
            }
        }

        System.assertEquals('Prepare for Plant', preparePlantMilestone.MilestoneType.Name);
        System.assertEquals(NULL, preparePlantMilestone.CompletionDate);

        caseServices.runTrigger = true;

        c.Status = 'Pending Sub-Case';
        update c;

        Test.stopTest();

        CaseMilestone updatedPreparePlantMilestone = new CaseMilestone();
        for (CaseMilestone caseMilestone : getCaseMilestoneByCaseId(c.Id)) {
            if (CSConstants.PREPARE_FOR_PLANT_MILESTONES.contains(caseMilestone.MilestoneType.Name)) {
                updatedPreparePlantMilestone = caseMilestone;
                break;
            }
        }
        System.assertNotEquals(NULL, updatedPreparePlantMilestone.CompletionDate);
    }

    @isTest(SeeAllData = false)
    public static void testCreateCasefromSalesOrder() {


        Account a = new Account();
        a.RecordTypeId = accountRTId;
        a.Name = 'Test Account';
        insert a;

        gvp__Sales_Order__c salesOrder  = new gvp__Sales_Order__c();
        salesOrder.gvp__Account__c = a.id;
        salesOrder.gvp__Order_Number__c = 'ORD-0000000500';
        salesOrder.gvp__Status__c = 'Open';
        salesOrder.gvp__Sales_Order_Key__c = '';
        salesOrder.gvp__Order_Date__c = system.today();
        salesOrder.gvp__ERP_Id__c = null;
        insert salesOrder;

        List <Case> lstCase = [select id, caseNumber, sales_Order__c from case where sales_Order__c = : salesOrder.id];

        system.debug('before Update' + lstCase.size());
        system.assert(lstCase.size() == 0);

        salesOrder.gvp__ERP_Id__c = '0000001234';
        update salesOrder;

        lstCase = [select id, caseNumber, sales_Order__c from case where sales_Order__c = : salesOrder.id];
        system.debug('after update' + lstCase.size());
        system.assert(lstCase.size() == 1);
    }

    @isTest
    public static void testRemoveSLAFromCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        
        Account acct = new Account();
        acct.Name = CSConstants.DEFAULT_ACCOUNT_NAME;
        acct.RecordTypeId = CSConstants.DEFAULT_ACCOUNT_RT_ID;
        insert acct;

        Account acct1 = new Account();
        acct1.Name = CSConstants.DEFAULT_ACCOUNT_NAME;
        acct1.RecordTypeId = acctRecordTypeId;
        insert acct1;
        
        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.Is_Bailment_Claims__c = true;
        c.AccountId = acct.Id;
        insert c;

        List<Case> childCases = createChildCaseRecords(System.Label.Order_Claim_Sub_Case, 'New', c.Id, 2, true);

        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];
        Case childCase = getCasesById(new Set<Id> {childCases[0].Id})[0];

        System.assertNotEquals(NULL, parentCase.EntitlementId);
        System.assertNotEquals(NULL, childCase.EntitlementId);

        caseServices.runTrigger = true;

        Test.stopTest();

        c.Status = CSConstants.DUP_NO_ACTION;
        update c;

        Case parentCaseUpdated = getCasesById(new Set<Id> {c.Id})[0];

        System.assertEquals(NULL, parentCaseUpdated.EntitlementId);

    }


    @isTest(SeeAllData = false)
    public static void updateRegionalDiplomatTest() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        insertUser();
        User u = [SELECT Id FROM User LIMIT 1];

        Test.startTest();

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingState = 'IL';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OffPremise').getRecordTypeId();
        insert testAccount;

        Case c = new Case();
        c.Status = SBP_Constants.PENDING_DOCUMENTATION;
        c.Subject = 'Test Case';
        c.Brand__c = 'Makers Mark';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        c.Purchase_Order_Uploaded__c = false;
        c.POS_Items_Selected__c = false;
        c.Bottle_Text_Entered__c = false;
        c.Barrel_selected__c = false;
        c.Retail_Account__c = testAccount.Id;
        c.Regional_Diplomat__c = null;
        caseServices.runTrigger = true;
        insert c;

        Case updatedCase = [select id, Regional_Diplomat__c from Case where Id = :c.id];

        Test.stopTest();

        //System.assertEquals(u.Id, updatedCase.Regional_Diplomat__c);
    }

    @isTest(SeeAllData = false)
    public static void moveSingleBarrelCaseStatusTest() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;

        Test.startTest();

        Case c = new Case();
        c.Status = SBP_Constants.PENDING_DOCUMENTATION;
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        c.Purchase_Order_Uploaded__c = false;
        c.POS_Items_Selected__c = false;
        c.Bottle_Text_Entered__c = false;
        c.Barrel_selected__c = false;
        insert c;

        caseServices.runTrigger = true;

        c.Purchase_Order_Uploaded__c = true;
        c.POS_Items_Selected__c = true;
        c.Bottle_Text_Entered__c = true;
        c.Barrel_selected__c = true;
        c.SAP_Number__c = '123';
        update c;

        Case updatedCase = [select id, Purchase_Order_Uploaded__c, SAP_Number__c, Status from Case where Id = :c.id];

        Test.stopTest();

        System.assertEquals(SBP_Constants.PREPARING_BARREL, updatedCase.Status);
    }


    @isTest(SeeAllData = false)
    public static void submitterMissingTest() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = true;

        Test.startTest();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;

        Case c = new Case();
        c.Status = SBP_Constants.PENDING_DOCUMENTATION;
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        c.Purchase_Order_Uploaded__c = false;
        c.POS_Items_Selected__c = true;
        c.Bottle_Text_Entered__c = true;
        c.Barrel_selected__c = true;
        insert c;

        Case updatedCase = [select id, Submitter__c, SAP_Number__c, Status from Case where Id = :c.id];

        Test.stopTest();

        System.assertNotEquals(NULL, updatedCase.Submitter__c);
    }



    

    @isTest(SeeAllData = false)
    public static void ownerChangeFromUserToQueueUpdatesStatusTest() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;

        Test.startTest();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        Group queue = [select Id, DeveloperName from Group where Type = 'Queue' AND DeveloperName = 'PTP_AP_TBO' limit 1];

        // case should be assigned to the appropriate queue
        Case c = new Case();
        c.Status = 'Logged';
        c.Subject = 'Test Case';
        c.Type = 'Payroll';
        c.GBS_Center__c = 'US/Canada';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = GBS_Constants.PAYROLL_RT_ID;
        c.setOptions(dmo);
        caseServices.runTrigger = false;
        insert c;

        Case updatedCase = [select Id, Status, Owner.Name from Case where Id = :c.Id];

        // case reassigned to a user
        updatedCase.OwnerId = UserInfo.getUserId();
        updatedCase.Status = 'In Progress';
        caseServices.runTrigger = false;
        update updatedCase;

        // case reassigned to a queue
        // should send the status back to 'Logged'
        updatedCase.OwnerId = queue.Id;
        caseServices.runTrigger = true;
        update updatedCase;

        Case updatedCase2 = [select Id, Status, Owner.Name from Case where Id = :updatedCase.Id];

        Test.stopTest();

        System.assertEquals('Logged', updatedCase2.Status, updatedCase2);
    }

    @isTest(SeeAllData = false)
    public static void ownerChangeFromQueueToUserUpdatesStatusTest() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = true;

        Test.startTest();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;

        Case c = new Case();
        c.Status = 'Logged';
        c.Subject = 'Test Case';
        c.Type = 'Payroll';
        c.GBS_Center__c = 'US/Canada';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = GBS_Constants.PAYROLL_RT_ID;
        c.setOptions(dmo);
        insert c;

        c.OwnerId = UserInfo.getUserId();
        caseServices.runTrigger = true;
        update c;

        Case updatedCase = [select Id, Status from Case where Id = :c.Id];

        Test.stopTest();

        System.assertEquals('In Progress', updatedCase.Status);
    }

    public static ContentVersion createContentVersion() {
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Attachment Name: ' + String.valueOf(System.now()),
            PathOnClient = '/Header_Picture1' + String.valueOf(System.now()) + '.pdf',
            VersionData = bodyBlob,
            origin = 'H'
        );

        insert testContentVersion;
        testContentVersion = [SELECT Id, ContentDocumentId, fileExtension FROM ContentVersion WHERE Id = : testContentVersion.Id FOR UPDATE];
        system.debug('testContentVersion.Id' + testContentVersion.Id);
        system.debug('testContentVersion.ContentDocumentId' + testContentVersion.ContentDocumentId);
        system.debug('testContentVersion.fileExtension' + testContentVersion.fileExtension);

        return testContentVersion;
    }


    public static ContentDocumentLink createContentDocumentLink(Id entityId, Id contentDocumentId) {
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = entityId;
        contentlink.ContentDocumentId = contentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;
        return contentlink;
    }

    @isTest(SeeAllData = false)
    public static void emailNonTechnicalResponseToParentCaseOwnerTest() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User u = new User();
        u.Alias = 'beamtu';
        u.Email = 'standarduser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Test';
        u.FirstName = 'Test';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Chicago';
        u.UserName = 'beamsuntorytestuser@test-user-system.com.test-only';
        insert u;

        Test.startTest();
        System.runAs(u) {
            Case c = new Case();
            c.Status = 'New';
            c.Subject = 'Test Case';
            c.Submitter__c = UserInfo.getUserId();
            c.RecordTypeId = CSConstants.QC_RT_ID;
            c.OwnerId = UserInfo.getUserId();
            insert c;

            Case updatedParentCase = [select Id, OwnerId from Case where Id = :c.Id ];
            updatedParentCase.OwnerId = u.Id;


            Case childCase = new Case();
            childCase.ParentId = c.Id;
            childCase.Status = 'New';
            childCase.Subject = 'Test Case';
            childCase.Non_Technical_Response__c = null;
            childCase.Submitter__c = UserInfo.getUserId();
            childCase.RecordTypeId = CSConstants.QC_SUBCASE_RT_ID;
            upsert new List<Case> {updatedParentCase, childCase};

            Case updatedCase = [select Id, Non_Technical_Response__c, OwnerId from Case where Id = :childCase.Id ];

            caseServices.runTrigger = true;
            updatedCase.Non_Technical_Response__c = 'Test Response';
            update updatedCase;

        }

        //Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        //System.assertNotEquals(0, invocations, 'At least one email should be sent');
    }

    @isTest(SeeAllData = false)
    public static void emailQualityRecommendationToParentCaseOwnerTest() {

        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User u = new User();
        u.Alias = 'beamtu';
        u.Email = 'standarduser@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Test';
        u.FirstName = 'Test';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Chicago';
        u.UserName = 'beamsuntorytestuser@test-user-system.com.test-only';
        insert u;

        Test.startTest();
        System.runAs(u) {
            Case c = new Case();
            c.Status = 'New';
            c.Subject = 'Test Case';
            c.Submitter__c = UserInfo.getUserId();
            c.RecordTypeId = CSConstants.QC_RT_ID;
            c.OwnerId = UserInfo.getUserId();
            insert c;

            Case updatedParentCase = [select Id, OwnerId from Case where Id = :c.Id ];
            updatedParentCase.OwnerId = u.Id;


            Case childCase = new Case();
            childCase.ParentId = c.Id;
            childCase.Status = 'New';
            childCase.Subject = 'Test Case';
            childCase.Recommendation__c = null;
            childCase.Submitter__c = UserInfo.getUserId();
            childCase.RecordTypeId = CSConstants.QC_SUBCASE_RT_ID;
            upsert new List<Case> {updatedParentCase, childCase};

            Case updatedCase = [select Id, Recommendation__c, OwnerId from Case where Id = :childCase.Id ];

            caseServices.runTrigger = true;
            updatedCase.Recommendation__c = 'Return Sample';
            update updatedCase;

        }

        //Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        //System.assertNotEquals(0, invocations, 'At least one email should be sent');
    }

    @isTest(SeeAllData = false)
    public static void createQualityClaimSubCaseTest() {

        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = true;
        List<Case> childCases;

        Test.startTest();
        Account a = new Account();
        a.RecordTypeId = accountRTId;
        a.Name = 'Test Account';
        insert a;

        Case c = new Case();
        c.Status = 'In Progress';
        c.Sub_Status__c = 'Pending with Quality';
        c.accountId = a.id;
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = CSConstants.QC_RT_ID;
        c.OwnerId = UserInfo.getUserId();
        insert c;


        childCases = [select Id, OwnerId, Status from Case where ParentId = :c.Id ];
        

        Test.stopTest();

        System.assertEquals(1, childCases.size(), 'One Child Case should have been created');
    }

    @isTest(SeeAllData = false)
    public static void updateQualityClaimSubCaseTest() {

        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        List<Case> childCases;

        Test.startTest();

        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = CSConstants.QC_RT_ID;
        c.OwnerId = UserInfo.getUserId();
        insert c;

        Case childCase = new Case();
        childCase.ParentId = c.Id;
        childCase.OwnerId = UserInfo.getUserId();
        childCase.Status = 'New';
        childCase.Subject = 'Test Case';
        childCase.Submitter__c = UserInfo.getUserId();
        childCase.RecordTypeId = CSConstants.QC_SUBCASE_RT_ID;
        insert childCase;

        Case updatedCase = [select Id, Status from Case where Id = :c.Id ];

        caseServices.runTrigger = true;
        updatedCase.Status = 'Pending Sub-Case';
        updatedCase.OwnerId = UserInfo.getUserId();
        update updatedCase;

        Case updatedChildCase = [select Id, OwnerId, Owner.Name, Status from Case where Id = :childCase.Id ];


        Test.stopTest();

        System.assertNotEquals(updatedChildCase.OwnerId, childCase.OwnerId, 'OwnerId\'s should be different');
    }

    @isTest(SeeAllData = false)
    public static void csCustomExceptionTest() {
        try {
            throw new CS_CustomException('Error Occured');
        } catch (Exception e) {

        }

    }
    
    @isTest(SeeAllData = false)
    public static void setGBSOutlookCasestoRecordTypeTest() {
        Id gbsOutlookCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GBS Outlook').getRecordTypeId();
        List<Case> casesList = new List<Case>{new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Global Master Data Management'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Human Resources'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Order to Cash / Billing'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Payroll'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Procure to Pay / Accounts Payable'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Record to Report'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Travel & Entertainment'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Claims'),
                                            new Case(RecordTypeId = gbsOutlookCaseRecordTypeId,Type = 'Tax')};
        test.startTest();
        Database.insert(casesList, false);
        test.stopTest();
    } 
    
    @isTest(SeeAllData = false)
    public static void AddingLotCodeTest() {

        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        caseServices.runTrigger = false;
        Test.startTest();
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = CSConstants.QC_RT_ID;
        c.OwnerId = UserInfo.getUserId();
        insert c;
        
        Case updatedChildCase = [select Id, OwnerId, Owner.Name, Status from Case where Id = :c.Id ];
        caseServices.runTrigger = true;
        update updatedchildCase;
        Test.stopTest();
        
     }

	public static testMethod void updateCaseForNoAllocationAailableOnDist() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
        caseServices.runTrigger = true;
        c.Flow_Completed__c = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Used_Allocations__c = 0;
        update distAlloc;
        update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('Distributor', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static Brand_Country_Region_State_Dist_Alloc__c getDistAlloc(){
        return[select Id, Allocations_Per_Interval__c,Used_Allocations__c from Brand_Country_Region_State_Dist_Alloc__c];
    }

    public static Brand_Country_Region_State_Allocation__c getStateAlloc(){
        return[select Id, Allocations_Per_Interval__c,Used_Allocations__c from Brand_Country_Region_State_Allocation__c where State__r.Name = 'IL'];
    }
    
    public static Brand_Country_Region_Allocation__c getRegionAlloc(){
        return[select Id, Allocations_Per_Interval__c,Used_Allocations__c from Brand_Country_Region_Allocation__c where Region__r.Name = 'Cental'];
    }
    
	public static Case getCaseByBrand(String brand) {
		return [select id, Barrel_Selected__c, AccountId, Retail_Account__c, Status, Remote_Selection_Date__c from Case where Brand__c = :brand limit 1];
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnState() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 10;
        update stateAlloc;
        caseServices.runTrigger = true;
        c.Flow_Completed__c = true;
		update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c, Status from Case where Id=: c.Id limit 1];
        System.assertEquals('Closed - Abandoned', newCase.Status, 'Allocation Allocated from Region');
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnRegion() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        delete stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 10;
        update regionAlloc;
		update c;

		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c, Status from Case where Id=: c.Id limit 1];
        System.assertEquals('Closed - Abandoned', newCase.Status, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForAllocationAvailableOnRegion() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        delete stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 0;
        update regionAlloc;
        Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('Region', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForAllocationAvailableOnState() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 0;
        update stateAlloc;
        Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('State', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForNationalAccount() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
        c.National_Account_Flag__c  = true;
        c.Retail_Account__c = getReatilerAccountAccount().Id;
        update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('State', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForMilitary() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
        Account distributorAccount = getTestAccount();
        distributorAccount.Military__c = 'Military';
        update distributorAccount;
		Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('Region', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForAllocationAailableOnDist() {
        
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Used_Allocations__c = 0;
        update distAlloc;
        Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('Distributor', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnDistState() {
        insertAllocHierarchy();
        Test.startTest();
		Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 10;
        update stateAlloc;
        Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c,Status from Case where Id=: c.Id limit 1];
        System.assertEquals('Closed - Abandoned', newCase.Status, 'Allocation Allocated from Region');

	}
    public static testMethod void updateCaseForAllocationAvailableOnDistState() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 0;
        update stateAlloc;
		
			Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('State', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');

	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnDistStateRegion() {
        
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 10;
        update regionAlloc;
			Update c;
		Test.stopTest();

        Case newCase = [Select Id, Allocation_Allocated_From__c,Status from Case where Id=: c.Id limit 1];
        System.assertEquals('Closed - Abandoned', newCase.Status, 'Allocation Allocated from Region');
	}
    
    public static testMethod void updateCaseForAllocationAvailableOnDistStateRegion() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 0;
        update regionAlloc;
		Update c;
		Test.stopTest();

        Case newCase = [Select Id, Allocation_Allocated_From__c from Case where Id=: c.Id limit 1];
        System.assertEquals('Region', newCase.Allocation_Allocated_From__c, 'Allocation Allocated from Region');
	}
    
    public static testMethod void updateCaseForNoAllocationAvailableOnStateRegion() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        delete distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__c regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 10;
        update regionAlloc;
        Update c;
		Test.stopTest();
        
        Case newCase = [Select Id, Allocation_Allocated_From__c, status from Case where Id=: c.Id limit 1];
        System.assertEquals('Closed - Abandoned', newCase.Status, 'Allocation Allocated from Region');
	}
    
	public static Account getReatilerAccountAccount() {
		return [select id from Account where Name = 'Retail Account'];
	}
       
    public static Brand_Allocation__c getBrandAlloc(){
        return [select id from Brand_Allocation__c where Brand__r.Name = 'Knob Creek Bourbon' limit 1];
    }
    
    public static testMethod void alreadyUpdateCaseForAllocationAailableOnDist() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Allocation_Allocated_From__c = 'Distributor';
        c.Brand_Allocation__c = getBrandAlloc().Id;
        Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Used_Allocations__c = 0;
        update distAlloc;
        
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
        update c;
        
        Test.stopTest();
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');
        
    }
    
    public static testMethod void alreadyUpdateCaseForAllocationAailableOnDistForNull() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Allocation_Allocated_From__c = 'Distributor';
        c.Brand_Allocation__c = getBrandAlloc().Id;
        Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Used_Allocations__c = null;
        update distAlloc;
        
        c.Flow_Completed__c = true;
        caseServices.runTrigger = true;
        update c;
        
        Test.stopTest();
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');
        
    }
    
    public static testMethod void AlreadyUpdateCaseForNoAllocationAvailableOnDistState() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 0;
        update stateAlloc;
        c.Flow_Completed__c = true;
        c.Brand_Allocation__c = getBrandAlloc().Id;
        c.Allocation_Allocated_From__c = 'State';
        c.Single_Barrel_State__c = 'IL';
        c.Single_Barrel_Country__c = 'US';
        caseServices.runTrigger = true;
        update c;
		Test.stopTest();
        
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');

	}
    
    public static testMethod void AlreadyUpdateCaseForNoAllocationAvailableonRegion() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__C regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        update regionAlloc;
        c.Flow_Completed__c = true;
        c.Brand_Allocation__c = getBrandAlloc().Id;
        c.Allocation_Allocated_From__c = 'Region';
        c.Single_Barrel_Region__c = 'Cental';
        c.Single_Barrel_Country__c = 'US';
        caseServices.runTrigger = true;
        update c;
		Test.stopTest();
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');

	}
    
    public static testMethod void AlreadyUpdateCaseForCancelledStatus() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        c.Brand_Allocation__c = getBrandAlloc().Id;
        c.Allocation_Allocated_From__c = 'Region';
        c.Single_Barrel_Region__c = 'Cental';
        c.Single_Barrel_Country__c = 'US';
        update c;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = false;
        update stateAlloc;
        Brand_Country_Region_Allocation__C regionAlloc = getRegionAlloc();
        regionAlloc.Is_Leaf_Node__c = true;
        regionAlloc.Allocations_Per_Interval__c = 10;
        regionAlloc.Used_Allocations__c = 8;
        update regionAlloc;
        c.status = 'Canceled';
        caseServices.runTrigger = true;
        update c;
        
		
		Test.stopTest();
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');

	}
    
    public static testMethod void AlreadyUpdateCaseForCancelledStatusonState() {
        insertAllocHierarchy();
        Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        c.Brand_Allocation__c = getBrandAlloc().Id;
        c.Allocation_Allocated_From__c = 'State';
        c.Single_Barrel_Region__c = 'Cental';
        c.Single_Barrel_State__c = 'IL';
        c.Single_Barrel_Country__c = 'US';
        update c;
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = false;
        update distAlloc;
        Brand_Country_Region_State_Allocation__c stateAlloc = getStateAlloc();
        stateAlloc.Is_Leaf_Node__c = true;
        stateAlloc.Allocations_Per_Interval__c = 10;
        stateAlloc.Used_Allocations__c = 4;
        update stateAlloc;
        Brand_Country_Region_Allocation__C regionAlloc = getRegionAlloc();
        c.status = 'Canceled';
        caseServices.runTrigger = true;
        update c;
        
		Test.stopTest();
        
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');

	}
    
    public static testMethod void AlreadyUpdateCaseForCancelledStatusonDist() {
        insertAllocHierarchy();
		Test.startTest();
        Case c = getCaseByBrand('Knob Creek');
        c.Flow_Completed__c = true;
        c.Brand_Allocation__c = getBrandAlloc().Id;
        c.Allocation_Allocated_From__c = 'Distributor';
        c.Single_Barrel_Region__c = 'Cental';
        c.Single_Barrel_State__c = 'IL';
        c.Single_Barrel_Country__c = 'US';
        update c;
        
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = getDistAlloc();
        distAlloc.Is_Leaf_Node__c = true;
        distAlloc.Allocations_Per_Interval__c =10;
        distAlloc.Used_Allocations__c = 8;
        update distAlloc;
        c.status = 'Canceled';
        caseServices.runTrigger = true;
        update c;
        Test.stopTest();
        
        System.assertEquals(true, c.Allocation_Allocated_From__c != null, 'Brand Allocation is allocated');

	}
    
    public static testMethod void AddEntitlementProcessForConsole() {
        Test.startTest();
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
        
        List<Entitlement> lstEntitlement = new List<Entitlement>();
        Entitlement newEntitlement = new Entitlement();
        newEntitlement.AccountId = newAccount.Id;
        newEntitlement.Name = 'Test';
        newEntitlement.SlaProcessId = [Select Id,Name from SlaProcess where name = 'CSG Order Claim' and isActive = true Limit 1].Id;
        newEntitlement.StartDate = Date.today();
        lstEntitlement.add(newEntitlement);
        insert lstEntitlement;
        
		Case newCase = new Case();
        newCase.recordTypeId = [SELECT Id FROM RecordType WHERE Developername = 'CSG_Order_Claim' limit 1].Id;
        newCase.Origin = 'Console';
        newCase.ContactId = newContact.Id;
        insert newCase;
        Test.stopTest();
        newCase = [select Id, EntitlementId from case where contactId =: newContact.Id limit 1];
		System.assertEquals(true, newCase.EntitlementId != null);
	}
    
    /**
    *  @description : This method is use to test email which is being sent to collaborators for cases created through console.
    **/
    public static testMethod void testSendEmailToCollaboratorsForConsole() {
        Test.startTest();
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
        Case newCase = new Case();
        newCase.recordTypeId = CSConstants.CSG_BILLING_CLAIM_RT_ID;
        newCase.Origin = 'Console';
        newCase.ContactId = newContact.Id;
        newCase.CcEmail__c = 'test@test.com;test1@test.com;';
        insert newCase;
        Test.stopTest();
    }
    
    /**
    *  @description : This method is use to test email which is being sent to collaborators for cases created through portal.
    **/
    public static testMethod void testSendEmailToCollaboratorsForPortal() {
        try{
            Test.startTest();
            Account newAccount = new Account();
            newAccount.Name = 'test';
            newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
            insert newAccount;
            
            Contact newContact = new Contact();
            newContact.LastName = 'Test';
            newContact.Email = 'test@test.com';
            newContact.AccountId = newAccount.Id;
            newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
            insert newContact;
            CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
            Case newCase = new Case();
            newCase.recordTypeId = CSConstants.CSG_ORDER_CLAIM_RT_ID;
            newCase.Origin = 'Portal';
            newCase.ContactId = newContact.Id;
            insert newCase;
            newCase.CcEmail__c = 'test@test.com;test1@test.com;';
            newCase.Flow_Completed__c = true;
            caseServices.runTrigger = true;
            update newCase;
            Test.stopTest(); 
        } catch(Exception e) {
            System.assert(e.getMessage() != null);
        }
    }

    /**
    *  @description : This method is use to test invalid email addresses.
    **/
    public static testMethod void testSendEmailToCollaboratorsInvalidEmail() {
        Test.startTest();
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
        Case newCase = new Case();
        newCase.recordTypeId = CSConstants.CSG_ORDER_CLAIM_RT_ID;
        newCase.Origin = 'Console';
        newCase.ContactId = newContact.Id;
        newCase.CcEmail__c = 'test@test.com;test1@test;';
        insert newCase;
        Test.stopTest();
    }

    /**
    *  @description : This method is use to for changing record type to CSG Quality Claim.
    **/
    public static testMethod void testUpdateRecordTypeOfCSGCasesQualityClaim() {
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;

        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
        
        Case newCase = new Case();
        newCase.recordTypeId = CSConstants.CSG_ORDER_CLAIM_RT_ID;
        newCase.Origin = 'Email';
        newCase.ContactId = newContact.Id;
        newCase.Subject = 'Testing';
        newCase.Description = 'I can see a defect in the invoice.';
        insert newCase;
        Test.startTest();
        Case updatedCase = [SELECT RecordTypeId FROM Case Where Id =: newCase.Id];
        Test.stopTest();
        System.assertEquals(CSConstants.CSG_QUALITY_CLAIM_RT_ID, updatedCase.RecordTypeId);
    }
    
    /**
    *  @description : This method is use to for changing record type to CSG Billing Claim.
    **/
    public static testMethod void testUpdateRecordTypeOfCSGCasesBillingClaim() {
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;

        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
        
        Case newCase = new Case();
        newCase.recordTypeId = CSConstants.CSG_ORDER_CLAIM_RT_ID;
        newCase.Origin = 'Email';
        newCase.ContactId = newContact.Id;
        newCase.Description = 'Please correct the invoice.';
        insert newCase;
        Test.startTest();
        Case updatedCase = [SELECT RecordTypeId FROM Case Where Id =: newCase.Id];
        Test.stopTest();
        System.assertEquals(CSConstants.CSG_BILLING_CLAIM_RT_ID, updatedCase.RecordTypeId);
    }
    /**
    *  @description : This method is use to for changing record type to CSG Order Claim.
    **/
    public static testMethod void testUpdateRecordTypeOfCSGCasesOrderClaim() {
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;

        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
        
        Case newCase = new Case();
        newCase.recordTypeId = CSConstants.CSG_ORDER_CLAIM_RT_ID;
        newCase.Origin = 'Email';
        newCase.ContactId = newContact.Id;
        newCase.Subject = 'Testing';
        newCase.Description = 'Check to default record type i.e. Order Claim';
        insert newCase;
        Test.startTest();
        Case updatedCase = [SELECT RecordTypeId FROM Case Where Id =: newCase.Id];
        Test.stopTest();
        System.assertEquals(CSConstants.CSG_ORDER_CLAIM_RT_ID, updatedCase.RecordTypeId);
    }
     /**
    *  @description : This method is use to for changing record type to CSG Quality Claim.
    **/
    public static testMethod void testUpdateCaseClosedFieldsOnStatusChanged() {
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [Select Id from RecordType where Name = 'Corporate Account' Limit 1].Id;
        insert newAccount;

        Contact newContact = new Contact();
        newContact.LastName = 'Test';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id;
        newContact.RecordTypeId = [Select Id from RecordType where Name = 'Account Contact' Limit 1].Id;
        insert newContact;
         
        Case newCase = new Case();
        newCase.recordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID;
        newCase.Origin = 'Web';
        newCase.ContactId = newContact.Id;
        newCase.Subject = 'Testing';
        newCase.Description = 'I can see a defect in the invoice.';
        newCase.status = 'New';
        newCase.Brand__c = 'Knob Creek';
        newCase.Product_Type__c = 'Bourbon';
        insert newCase;
        
        Test.startTest();
            caseServices.runTrigger = true;
            newCase.status = 'Resolved';
            update newCase;
            caseServices.runTrigger = true;
            newCase.status = 'Closed';
            update newCase;
        Test.stopTest();
        
        Case selectCase = [SELECT id , Actual_Closed_Date__c from case where Id =: newCase.Id limit 1];
        System.assertNotEquals(selectCase.Actual_Closed_Date__c, null,'Actual Closed Date should not be null');
    }
	public static testMethod void testAddEntitlementToMarketReadinessCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Market Readiness Inquiry').getRecordTypeId();
        
        Account acct = new Account();
        acct.Name = 'test Account';
        insert acct;
        
        List<Entitlement> entitlementsBefore = getEntitlementsOnAccount(acct.Id);
        
        System.assertEquals(true, entitlementsBefore.isEmpty(), 'No Entitlements should be associated with this Account');
        
        Test.starttest();
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Type = 'Licensing';
        c.AccountId = acct.Id;
        insert c;
        
        List<Entitlement> entitlementsAfter = getEntitlementsOnAccount(acct.Id);
        Case cc = getCasesById(new Set<Id> {c.Id})[0];
        Test.stopTest();
        
        System.assertEquals(1, entitlementsAfter.size(), 'The Account should have 1 Entitlement');     
    }
	
    public static testMethod void testSetDefaultAccountIfMarketReadinessCase() {
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        Id recordTypeId = CSConstants.MARKET_READINESS_RT_ID;
        Id acctRecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
        
        Test.startTest();
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.Product_Destination_Country__c = 'Sri Lanka';
        insert c;
        
        Case cse = getCasesById(new Set<Id> {c.Id})[0];
        System.assertEquals(NULL, cse.AccountId);
        
        Account a = new Account();
        a.lastname = CSConstants.DEFAULT_MARKET_READINESS;
        a.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
        insert a;
        
        c.AccountId = a.Id;
        update c;
        caseServices.setDefaultAccountForMarketReadiness(new List<Case> {c});
        Test.stopTest();
        
        Case parentCase = getCasesById(new Set<Id> {c.Id})[0];
        List<Account> accts = [select Id, RecordTypeId, Name from Account where Name = :CSConstants.DEFAULT_MARKET_READINESS AND RecordTypeId = :CSConstants.CONSUMER_ACCOUNT_RT_ID limit 1];
        System.assertEquals(accts[0].Id, parentCase.AccountId);
    }  
    
    public static testMethod void testSetOrderClaimTriggerWordChecked(){
        Id recTypeId = CSConstants.ORDER_CLAIM_RT_ID;
        
        Test.startTest();
        contact con = new contact(LastName='testCon');
        insert con;
        List<TriggerWords__c> trList = new List<TriggerWords__c>();
        TriggerWords__c tr = new TriggerWords__c();
        tr.Name = 'Dirt';
        tr.Status__c = 'Active';
        tr.Priority__c = 'Medium';
        tr.Type__c = 'Complaint';
        trList.add(tr);
        insert trList;
        
        List<Case> cList = new List<Case>();
        Case c = new Case();
        c.Status = 'New';
        c.Origin = 'Email';
        c.trigger_word__c = false;
        c.Subject = 'Test Case Dirt';
        c.Description = 'Hi this is test Dirt';
        c.RecordTypeId = recTypeId;
        c.Submitter__c = UserInfo.getUserId();
        c.ContactId = con.Id;
        
        Case c1 = new Case();
        c1.Status = 'New';
        c1.Origin = 'Web';
        c1.trigger_word__c = false;
        c1.Subject = 'Test Case 1';
        c1.Description = 'Hi this is testing for trigger word Dirt';
        c1.RecordTypeId = recTypeId;
        c.Submitter__c = UserInfo.getUserId();
        c.ContactId = con.Id;
  
        cList.add(c);
        cList.add(c1);
        insert cList;
        caseServices.setOrderClaimTriggerWordChecked(cList);
        Test.stopTest();

    }
    
    /*******************************************************************************************************************************
    Description:    This testmethod is created against a method of process builder(Update Priority based on the Type field value). This method tests priority of a case based on its Type field.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    07/04/2023         Sangeet Joshi      Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static testmethod void testUpdatePriorityBasedOnTheTypeFieldValue(){
        
        List<Case> caseList = new List<Case>();
        Case cse = new Case();
        cse.RecordTypeId = CSConstants.MARKET_READINESS_RT_ID;
        cse.Type= 'Newsletters';
        caseList.add(cse);
        
        Case cse1 = new Case();
        cse1.RecordTypeId = CSConstants.MARKET_READINESS_RT_ID;
        cse1.Type = 'Licensing';
        caseList.add(cse1);
        
        insert caseList;
        
        Test.startTest();
            caseServices.updatePriorityBasedOnTheTypeFieldValue(caseList);
        Test.stopTest();
        
        System.assertEquals('High', cse.Priority, 'Priority is not high');
        System.assertEquals('Medium', cse1.Priority, 'Priority is not high');
    }

    /*******************************************************************************************************************************
    Description:    This testmethod is created against a method of process builder(Automated Case Status Updates for Single Barrel Cases). This testmethod is testing status of case.
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    07/04/2023         Sangeet Joshi      Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static testmethod void testUpdateCaseStatus(){
        
        Account acc = new Account();
        acc.Name = 'Test account';
        insert acc;
        
        List<Case> caseList = new List<Case>();
        Case cse = new Case();
        cse.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        cse.Brand__c = SBP_Constants.BRAND_BAKERS;
        cse.Status = 'New';
        cse.Retail_Account__c = acc.Id;
        cse.AccountId = acc.Id;
        cse.Type = 'Sample Kit';
        caseList.add(cse);
        
        Case cse1 = new Case();
        cse1.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        cse1.Brand__c = SBP_Constants.BRAND_MAKERS_MARK;
        cse1.Status = 'New';
        cse1.Retail_Account__c = acc.Id;
        cse1.AccountId = acc.Id;
        cse1.Type = 'Sample Kit';
        caseList.add(cse1);
        
        Case cse2 = new Case();
        cse2.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        cse2.Brand__c = SBP_Constants.BRAND_KNOB_CREEK;
        cse2.Status = 'New';
        cse2.Retail_Account__c = acc.Id;
        cse2.Product_Type__c = 'Rye';
        cse2.AccountId = acc.Id;
        cse2.Type = 'Sample Kit';
        caseList.add(cse2);
        
        insert caseList;
        
        Test.startTest();
            caseServices.updateCaseStatus(caseList);
        Test.stopTest();
        
        System.assertEquals('Pending Documentation', cse.Status, 'Status is not pending documentation');
        System.assertEquals('New', cse1.Status, 'Status is not New');
        System.assertEquals('Pending Documentation', cse2.Status, 'Status is not pending documentation');
    }
    
    /*******************************************************************************************************************************
    Description:    This testmethod is created against a method of process builder(Update Sub Status on Case).
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    27/04/2023         Sangeet Joshi      Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static testMethod void testUpdateSubStatusOnCase(){
        
        Case cse= new Case();
        cse.RecordTypeId = CSConstants.QC_RT_ID;
        cse.Status = 'In Progress';
        cse.Sub_Status__c = 'Pending with Quality';
        insert cse;
        
        
        Case newCase = [SELECT id, Status, Sub_Status__c, AdditionalInformation__c,RecordTypeId
                            FROM Case 
                            WHERE Status = 'In Progress' AND RecordTypeId =: CSConstants.QC_RT_ID LIMIT 1];
        

        
        Case oldCase = newCase.clone(true, false, false, false);
        oldCase.Status = 'In Progress';
        oldCase.Sub_Status__c = 'Pending with Quality';
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{newCase};
        newCase.Status = 'Closed';            
        Test.startTest();
            caseServices.updateSubStatusOnCase(newList, oldMap);
        Test.stopTest();

        System.assertEquals(null, newCase.Sub_Status__c, 'sub status is not blank');
    }

    /*******************************************************************************************************************************
    Description:    This test method is created against method updateCaseType
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    29/06/2023      Deekshika Sharma      Metacube       Initial Creation
	******************************************************************************************************************************/
    public static testmethod void testUpdateCaseType() {
        Group edringtonQueue = [select Id from Group where Type = 'Queue' AND NAME = 'Edrington Queue']; 
		contact con = new contact(LastName='testCon');
        insert con;
        Case cse = new Case();
        cse.RecordTypeId = CSConstants.ORDERS_RT_ID;
        cse.OwnerId = edringtonQueue.Id;
        cse.Origin = CSConstants.EMAIL;
        cse.Submitter__c = UserInfo.getUserId();
        cse.ContactId = con.Id;
        insert cse;
        
        Test.startTest();
        	caseServices.updateCaseType(new List<Case>{cse});
        Test.stopTest();
        
        System.assertEquals(CSConstants.EDRINGTON_Type, cse.Type, 'Type should be Edrington');
    }
    
    /*******************************************************************************************************************************
    Description:    This testmethod is created against a method of process builder(Update SKU and Quantity).
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    30/01/2024        Vikash kumar      Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static testMethod void testUpdateSKUAndQuantityOnRelatedBarrels(){
        Case c = new Case();
        c.RecordTypeId = SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID;
        c.Brand__c = CSConstants.BRAND_CRUZAN;
        c.Status = 'New';
        c.Product_Type__c = CSConstants.PRODUCT_TYPE_FULL_BARREL;
        c.Type = SBP_Constants.SAMPLE_KIT;
        c.SAP_Number__c = '322344';
        insert c;
        
        Barrel__c b = new Barrel__c();
        b.RecordTypeId = SBP_Constants.CRUZAN_FULL_BARREL_RT_ID;
        b.Case__c = c.Id;
        b.Brand__c = CSConstants.BRAND_CRUZAN;
        b.Product_Type__c = CSConstants.PRODUCT_TYPE_FULL_BARREL;
        insert b;
        
        Case oldCase = c.clone(true, false, false, false);
        oldCase.Status = 'New';
        oldCase.Brand__c = CSConstants.BRAND_CRUZAN;
        oldCase.Product_Type__c = CSConstants.PRODUCT_TYPE_FULL_BARREL;
        oldCase.SAP_Number__c = '322344';
        
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(oldCase.Id,oldCase);
        List<Case> newList = new List<Case>{c};
            c.Status = SBP_Constants.PREPARING_BARREL;            
        Test.startTest();
        caseServices.updateSKUAndQuantityOnRelatedBarrels(newList, oldMap);
        Test.stopTest();
        Barrel__C barrel = [Select Id,Quantity__c,SKU__c From Barrel__c Where Id =:b.Id Limit 1];
        System.assertEquals(52, barrel.Quantity__c, 'Quantity should be 52 for full barrel');
        System.assertEquals('US114343', barrel.SKU__c, 'SKU should be US114343');
        
    }
      /*******************************************************************************************************************************
    Description:    This testmethod is created against a method pauseUnpauseMilestoneOnStatusChange().
    <Date>          <Authors Name>     <Company>     <Brief Description of Change>
    30/01/2024      Badri Vishal Soni   Metacube       Initial Creation
    ******************************************************************************************************************************/
    public static testMethod void testPauseUnpauseMilestoneOnStatusChange(){
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Order_Claim).getRecordTypeId();
        
        Test.startTest();
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case';
        c.Submitter__c = UserInfo.getUserId();
        c.RecordTypeId = recordTypeId;
        c.IsStopped = false;
        insert c;
        System.assertEquals(false, c.IsStopped , c.Status);
        
        c.Status = 'Pending Activity';
        caseServices.runTrigger = true;
        update c;
        
        Case newCase = [Select Id, IsStopped,Status from Case where Id=: c.Id limit 1];
        System.assertEquals(true, newCase.IsStopped , 'Milestone must be paused');
        
        c.Status = 'Working';
        caseServices.runTrigger = true;
        update c;
        Test.stopTest();
        System.assertEquals(false, c.IsStopped , 'Milestone must be Unpaused');
        
        
    }
}