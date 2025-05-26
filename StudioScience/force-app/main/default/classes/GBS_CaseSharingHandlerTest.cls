/**************************************************************************************************************
    Description:	Test Class for GBS_CaseSharingHandler class.

    History
    <Date>      <Authors Name>     <Brief Description of Change>
    8/2019     	Connor Gallaher    Initial Creation

***************************************************************************************************************/

@isTest
public class GBS_CaseSharingHandlerTest {

    public static List<Case> getCases() {
        return [SELECT Id, RecordTypeId, GBS_Center__c, Origin, Type, Category_1__c, Category_2__c, Submitter__c FROM Case];
    }

    public static List<Case> getCasesForGBSCenter(String gbsCenter) {
        List<Case> cases = getCases();
        List<Case> casesForGBSCenter = new List<Case>();
        for (Case c : cases) {
            if (c.GBS_Center__c.equals(gbsCenter)) {
                casesForGBSCenter.add(c);
            }
        }
        return casesForGBSCenter;
    }

    public static List<CaseShare> getCaseSharesForCaseId(Id caseId) {
        return [SELECT Id, CaseId, UserOrGroupId, CaseAccessLevel FROM CaseShare WHERE CaseId = :caseId];
    }

    public static List<Group> getGroupsForGBSCenter(String gbsCenter) {
        String groupName = 'GBS: ' + gbsCenter + '%';
        return [SELECT Id, Name FROM Group WHERE Name LIKE :groupName];
    }


    @testSetup
    static void setupData() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        Profile p = [SELECT Id FROM Profile WHERE Name='GBS Analyst']; 
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='TestingUser', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com', Country='Australia');
        
        Blob b2 = Crypto.GenerateAESKey(128);
        String h2 = EncodingUtil.ConvertTohex(b2);
        String uid2 = h2.SubString(0,8);
        User u2 = new User(Alias = uid2, Email= uid2 + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='OtherUser', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid2 + '@myorg.com', Country='Japan'); 
        
                  
        // 11-11-2020 ref: Jira story #SAL-420 -- added by #Arun Sharma
        Blob b3 = Crypto.GenerateAESKey(128);
        String h3 = EncodingUtil.ConvertTohex(b3);
        String uid3 = h3.SubString(0,8);
        User u3 = new User(Alias = uid3, Email= uid3 + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='NoCountryUser', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid3 + '@myorg.com', Country=''); 
        
        List<User> users = new List<User>();
        users.add(u);
        users.add(u2);
        users.add(u3);
        insert users;

        List<Case> cases = new List<Case>();
        Case caseAPACException1 = new Case();
        caseAPACException1.GBS_Center__c    = 'Singapore';
        caseAPACException1.RecordTypeId     = GBS_Constants.PTP_RT_ID;
        caseAPACException1.Origin           = 'Company Community';
        caseAPACException1.Type             = 'Procure to Pay / Accounts Payable';
        caseAPACException1.Category_1__c    = 'Other procure to pay request';
        cases.add(caseAPACException1);
        
        Case caseAPACException2 = new Case();
        caseAPACException2.GBS_Center__c    = 'Singapore';
        caseAPACException2.RecordTypeId     = GBS_Constants.PTP_RT_ID;
        caseAPACException2.Origin           = 'Company Community';
        caseAPACException2.Type             = 'Procure to Pay / Accounts Payable';
        caseAPACException2.Category_1__c    = 'Remittance detail request';
        cases.add(caseAPACException2);
        
        Case caseAPACException3 = new Case();
        caseAPACException3.GBS_Center__c    = 'Singapore';
        caseAPACException3.RecordTypeId     = GBS_Constants.PTP_RT_ID;
        caseAPACException3.Origin           = 'Company Community';
        caseAPACException3.Type             = 'Procure to Pay / Accounts Payable';
        caseAPACException3.Category_1__c    = 'Purchase requisition inquiries';
        cases.add(caseAPACException3);
        
        Case caseAPACException4 = new Case();
        caseAPACException4.GBS_Center__c    = 'Singapore';
        caseAPACException4.RecordTypeId     = GBS_Constants.PTP_RT_ID;
        caseAPACException4.Origin           = 'Company Community';
        caseAPACException4.Type             = 'Record to Report';
        caseAPACException4.Category_1__c    = 'Other record to report request';
        cases.add(caseAPACException4);
        
        Case caseSGNonPayroll = new Case();
        caseSGNonPayroll.GBS_Center__c      = 'Singapore';
        caseSGNonPayroll.RecordTypeId       = GBS_Constants.RTR_RT_ID;
        caseSGNonPayroll.Origin             = 'Company Community';
        caseSGNonPayroll.Type               = 'Record to Report';
        caseSGNonPayroll.Category_1__c      = 'Fixed asset request';
        caseSGNonPayroll.Category_2__c      = 'Other fixed asset request';
        cases.add(caseSGNonPayroll);

        Case caseSGPayroll = new Case();
        caseSGPayroll.GBS_Center__c         = 'Singapore';
        caseSGPayroll.RecordTypeId          = GBS_Constants.PAYROLL_RT_ID;
        caseSGPayroll.Origin                = 'Company Community';
        caseSGPayroll.Type                  = 'Payroll';
        caseSGPayroll.Category_1__c         = 'Partner';
        caseSGPayroll.Category_2__c         = 'Report Requests';
        cases.add(caseSGPayroll);

        Case caseINNonPayroll = new Case();
        caseINNonPayroll.GBS_Center__c      = 'India';
        caseINNonPayroll.RecordTypeId       = GBS_Constants.OTC_BILLING_RT_ID;
        caseINNonPayroll.Origin             = 'Company Community';
        caseINNonPayroll.Type               = 'Order to Cash / Billing';
        caseINNonPayroll.Category_1__c      = 'Audit request';
        cases.add(caseINNonPayroll);

        Case caseINNonPayroll2 = new Case();
        caseINNonPayroll2.GBS_Center__c     = 'India';
        caseINNonPayroll2.RecordTypeId      = GBS_Constants.RTR_RT_ID;
        caseINNonPayroll2.Origin            = 'Company Community';
        caseINNonPayroll2.Type              = 'Record to Report';
        caseINNonPayroll2.Category_1__c     = 'Audit request';
        cases.add(caseINNonPayroll2);

        Case caseINPayroll = new Case();
        caseINPayroll.GBS_Center__c         = 'India';
        caseINPayroll.RecordTypeId          = GBS_Constants.PAYROLL_RT_ID;
        caseINPayroll.Origin                = 'Company Community';
        caseINPayroll.Type                  = 'Payroll';
        caseINPayroll.Category_1__c         = 'Partner';
        caseINPayroll.Category_2__c         = 'Report Requests';
        cases.add(caseINPayroll);

        Case caseESNonPayroll = new Case();
        caseESNonPayroll.GBS_Center__c      = 'Madrid';
        caseESNonPayroll.RecordTypeId       = GBS_Constants.OTC_BILLING_RT_ID;
        caseESNonPayroll.Origin             = 'Company Community';
        caseESNonPayroll.Type               = 'Order to Cash / Billing';
        caseESNonPayroll.Category_1__c      = 'Order release status';
        cases.add(caseESNonPayroll);

        Case caseESPayroll = new Case();
        caseESPayroll.GBS_Center__c         = 'Madrid';
        caseESPayroll.RecordTypeId          = GBS_Constants.PAYROLL_RT_ID;
        caseESPayroll.Origin                = 'Company Community';
        caseESPayroll.Type                  = 'Payroll';
        caseESPayroll.Category_1__c         = 'Partner';
        caseESPayroll.Category_2__c         = 'Report Requests';
        cases.add(caseESPayroll);

        //SBFE Only has Non-Payroll for now
        Case caseSBFENonPayroll = new Case();
        caseSBFENonPayroll.GBS_Center__c    = 'SBFE';
        caseSBFENonPayroll.RecordTypeId     = GBS_Constants.PTP_RT_ID;
        caseSBFENonPayroll.Origin           = 'Company Community';
        caseSBFENonPayroll.Type             = 'Procure to Pay / Accounts Payable';
        caseSBFENonPayroll.Category_1__c    = 'Invoice/Payment status';
        cases.add(caseSBFENonPayroll);

        Case caseUSNonPayroll = new Case();
        caseUSNonPayroll.GBS_Center__c      = 'US/Canada';
        caseUSNonPayroll.RecordTypeId       = GBS_Constants.RTR_RT_ID;
        caseUSNonPayroll.Origin             = 'Company Community';
        caseUSNonPayroll.Type               = 'Record to Report';
        caseUSNonPayroll.Category_1__c      = 'Fixed asset request';
        caseUSNonPayroll.Category_2__c      = 'Other fixed asset request';
        cases.add(caseUSNonPayroll);

        Case caseUSPayroll = new Case();
        caseUSPayroll.GBS_Center__c         = 'US/Canada';
        caseUSPayroll.RecordTypeId          = GBS_Constants.PAYROLL_RT_ID;
        caseUSPayroll.Origin                = 'Company Community';
        caseUSPayroll.Type                  = 'Payroll';
        caseUSPayroll.Category_1__c         = 'Partner';
        caseUSPayroll.Category_2__c         = 'Report Requests';
        cases.add(caseUSPayroll);

        Case caseMXNonPayroll = new Case();
        caseMXNonPayroll.GBS_Center__c      = 'Mexico';
        caseMXNonPayroll.RecordTypeId       = GBS_Constants.RTR_RT_ID;
        caseMXNonPayroll.Origin             = 'Company Community';
        caseMXNonPayroll.Type               = 'Record to Report';
        caseMXNonPayroll.Category_1__c      = 'Fixed asset request';
        caseMXNonPayroll.Category_2__c      = 'Other fixed asset request';
        cases.add(caseMXNonPayroll);

        Case caseMXPayroll = new Case();
        caseMXPayroll.GBS_Center__c         = 'Mexico';
        caseMXPayroll.RecordTypeId          = GBS_Constants.PAYROLL_RT_ID;
        caseMXPayroll.Origin                = 'Company Community';
        caseMXPayroll.Type                  = 'Payroll';
        caseMXPayroll.Category_1__c         = 'Partner';
        caseMXPayroll.Category_2__c         = 'Report Requests';
        cases.add(caseMXPayroll);

        try {
            insert cases;
        }
        catch (DmlException ex) {
            System.debug('An error occurred : ' + ex.getMessage());
        }
    }

    @isTest
    static void getCaseSharesForAPACExceptionSGAndINTest() {
		Test.startTest();
        List<Case> singaporeCases = getCasesForGBSCenter('Singapore');
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'TestingUser'];
        
        Case testCase;
        for (Case c : singaporeCases) {
            if (c.Category_1__c.equals('Other procure to pay request')) {
                testCase = c;
            }
        }
        testCase.Submitter__c = u.Id;
        
        update testCase;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('India/Singapore');

        System.assertNotEquals('Payroll', testCase.Type);
        System.assertEquals('Singapore', testCase.GBS_Center__c);
        List<CaseShare> caseShares = getCaseSharesForCaseId(testCase.Id);
        //System.assertEquals(3, caseShares.size());
        System.assert(caseShares.size()> 0);
        for (CaseShare cs : caseShares) {
            if (cs.UserOrGroupId == groupsForGBSCenter[0].Id) {
                System.assertEquals(groupsForGBSCenter[0].Id, cs.UserOrGroupId);
                System.assertEquals('Edit', cs.CaseAccessLevel);
            }
        }
    }

    @isTest
    static void getCaseSharesForAPACExceptionSGTest() {
		Test.startTest();
        List<Case> singaporeCases = getCasesForGBSCenter('Singapore');
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'TestingUser'];
        
        Case testCase;
        for (Case c : singaporeCases) {
            if (c.Category_1__c.equals('Remittance detail request')) {
                testCase = c;
            }
        }
        testCase.Submitter__c = u.Id;
        
        update testCase;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('Singapore');
        Group singaporeNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if (g.Name.contains('Non')) {
                singaporeNonPayroll = g;
            }
        }
        System.assertNotEquals('Payroll', testCase.Type);
        System.assertEquals('Singapore', testCase.GBS_Center__c);
        List<CaseShare> caseShares = getCaseSharesForCaseId(testCase.Id);
        //System.assertEquals(3, caseShares.size());
        System.assert(caseShares.size()> 0);
        for (CaseShare cs : caseShares) {
            if (cs.UserOrGroupId == singaporeNonPayroll.Id) {
                System.assertEquals(singaporeNonPayroll.Id, cs.UserOrGroupId);
                System.assertEquals('Edit', cs.CaseAccessLevel);
            }
        }
    }

    @isTest
    static void getCaseSharesForAPACExceptionINTest() {
		Test.startTest();
        List<Case> singaporeCases = getCasesForGBSCenter('Singapore');
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'TestingUser'];
        
        Case testCase;
        for (Case c : singaporeCases) {
            if (c.Category_1__c.equals('Purchase requisition inquiries')) {
                testCase = c;
            }
        }
        testCase.Submitter__c = u.Id;
        
        update testCase;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('India');

        System.assertNotEquals('Payroll', testCase.Type);
        System.assertEquals('Singapore', testCase.GBS_Center__c);
        List<CaseShare> caseShares = getCaseSharesForCaseId(testCase.Id);
        //System.assertEquals(3, caseShares.size());
        System.assert(caseShares.size()> 0);
        for (CaseShare cs : caseShares) {
            if (cs.UserOrGroupId == groupsForGBSCenter[0].Id) {
                System.assertEquals(groupsForGBSCenter[0].Id, cs.UserOrGroupId);
                System.assertEquals('Edit', cs.CaseAccessLevel);
            }
        }
    }
    
    @isTest
    static void getCaseSharesForAPACExceptionRTRTest() {
		Test.startTest();
        List<Case> singaporeCases = getCasesForGBSCenter('Singapore');
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'TestingUser'];
        
        Case testCase;
        for (Case c : singaporeCases) {
            if (c.type.equals('Record to Report')) {
                testCase = c;
            }
        }
        testCase.Submitter__c = u.Id;
        
        update testCase;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('India');

        System.assertNotEquals('Payroll', testCase.Type);
        System.assertEquals('Singapore', testCase.GBS_Center__c);
        List<CaseShare> caseShares = getCaseSharesForCaseId(testCase.Id);
        //System.assertEquals(3, caseShares.size());
        System.assert(caseShares.size()> 0);
        for (CaseShare cs : caseShares) {
            if (cs.UserOrGroupId == groupsForGBSCenter[0].Id) {
                System.assertEquals(groupsForGBSCenter[0].Id, cs.UserOrGroupId);
                System.assertEquals('Edit', cs.CaseAccessLevel);
            }
        }
    }

    @isTest
    static void getCaseSharesForSingaporeTest() {
		Test.startTest();
        List<Case> singaporeCases = getCasesForGBSCenter('Singapore');
        
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        for (Case sc : singaporeCases) {
            sc.Submitter__c = u.Id;
        }
        
        update singaporeCases;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();        

        Set<Id> singaporeCasesIds = new Set<Id>();
        for (Case sgCase : singaporeCases) {
            singaporeCasesIds.add(sgCase.Id);
        }

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('Singapore');
        Group singaporePayroll, singaporeNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if (g.Name.contains('Non')) {
                singaporeNonPayroll = g;
            }
            else {
                singaporePayroll = g;
            }
        }
        
        for (Case c : singaporeCases) {
            if (c.Type.equals('Payroll')) {
                //Payroll
                System.assertEquals('Payroll', c.Type);
                System.assertEquals('Singapore', c.GBS_Center__c);
                List<CaseShare> caseSharesSingaporePayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesSingaporePayroll.size());
                System.assert(caseSharesSingaporePayroll.size()> 0);
                for (CaseShare cs : caseSharesSingaporePayroll) {
                    if (cs.UserOrGroupId == singaporePayroll.Id) {
                        System.assertEquals(singaporePayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
            else {
                //Non-Payroll
                System.assertNotEquals('Payroll', c.Type);
                System.assertEquals('Singapore', c.GBS_Center__c);
                List<CaseShare> caseSharesSingaporeNonPayroll = getCaseSharesForCaseId(c.Id);
               // System.assertEquals(3, caseSharesSingaporeNonPayroll.size());
                System.assert(caseSharesSingaporeNonPayroll.size()> 0);
                for (CaseShare cs : caseSharesSingaporeNonPayroll) {
                    if (cs.UserOrGroupId == singaporeNonPayroll.Id) {
                        System.assertEquals(singaporeNonPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
        }
    }

    @isTest
    static void getCaseSharesForMadridTest() {
		Test.startTest();
        List<Case> madridCases = getCasesForGBSCenter('Madrid');
        
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        for (Case mc : madridCases) {
            mc.Submitter__c = u.Id;
        }
        
        update madridCases;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();        

        Set<Id> madridCasesIds = new Set<Id>();
        for (Case esCase : madridCases) {
            madridCasesIds.add(esCase.Id);
        }

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('Madrid');
        Group madridPayroll, madridNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if (g.Name.contains('Non')) {
                madridNonPayroll = g;
            }
            else {
                madridPayroll = g;
            }
        }
        
        for (Case c : madridCases) {
            if (c.Type.equals('Payroll')) {
                //Payroll
                System.assertEquals('Payroll', c.Type);
                System.assertEquals('Madrid', c.GBS_Center__c);
                List<CaseShare> caseSharesMadridPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesMadridPayroll.size());
                System.assert(caseSharesMadridPayroll.size()> 0);
                for (CaseShare cs : caseSharesMadridPayroll) {
                    if (cs.UserOrGroupId == madridPayroll.Id) {
                        System.assertEquals(madridPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
            else {
                //Non-Payroll
                System.assertNotEquals('Payroll', c.Type);
                System.assertEquals('Madrid', c.GBS_Center__c);
                List<CaseShare> caseSharesMadridNonPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesMadridNonPayroll.size());
                System.assert(caseSharesMadridNonPayroll.size()> 0);
                for (CaseShare cs : caseSharesMadridNonPayroll) {
                    if (cs.UserOrGroupId == madridNonPayroll.Id) {
                        System.assertEquals(madridNonPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
        }
    }

    @isTest
    static void getCaseSharesForSBFETest() {
		Test.startTest();
        List<Case> sbfeCases = getCasesForGBSCenter('SBFE');
        
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        for (Case sbfec : sbfeCases) {
            sbfec.Submitter__c = u.Id;
        }
        
        update sbfeCases;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();        

        Set<Id> sbfeCasesIds = new Set<Id>();
        for (Case sbfeCase : sbfeCases) {
            sbfeCasesIds.add(sbfeCase.Id);
        }

        //SBFE Cases are managed by Madrid, so get Madrid Groups
        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('Madrid');
        Group madridNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if (g.Name.contains('Non')) {
                madridNonPayroll = g;
            }
        }
        
        for (Case c : sbfeCases) {
            //Non-Payroll ONLY for SBFE
            System.assertNotEquals('Payroll', c.Type);
            System.assertEquals('SBFE', c.GBS_Center__c);
            List<CaseShare> caseSharesSBFENonPayroll = getCaseSharesForCaseId(c.Id);
            //System.assertEquals(3, caseSharesSBFENonPayroll.size());
            System.assert(caseSharesSBFENonPayroll.size()> 0);
            for (CaseShare cs : caseSharesSBFENonPayroll) {
                if (cs.UserOrGroupId == madridNonPayroll.Id) {
                    System.assertEquals(madridNonPayroll.Id, cs.UserOrGroupId);
                    System.assertEquals('Edit', cs.CaseAccessLevel);
                }
            }
        }
    }

    @isTest
    static void getCaseSharesForIndiaTest() {
		Test.startTest();
        List<Case> inCases = getCasesForGBSCenter('India');
        
         User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        for (Case ic : inCases) {
            ic.Submitter__c = u.Id;
        }
        
        update inCases;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();

        Set<Id> inCaseIds = new Set<Id>();
        for (Case inCase : inCases) {
            inCaseIds.add(inCase.Id);
        }

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('India');
        //Need to also get Singapore Groups (specifically Payroll) as SG Payroll handles
        //India Payroll Cases
        groupsForGBSCenter.addAll(getGroupsForGBSCenter('Singapore'));
        Group sgPayroll, sgNonPayroll, inNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if ((g.Name.contains('Non')) && (g.Name.contains('India'))) {
                inNonPayroll = g;
            }
            else if ((g.Name.contains('Non')) && (g.Name.contains('Singapore'))) {
                sgNonPayroll = g;
            }
            else if (!g.Name.contains('Non')) {
                sgPayroll = g;
            }
            else {
                continue;
            }
        }
        
        for (Case c : inCases) {
            if (c.Type.equals('Payroll')) {
                //Payroll
                System.assertEquals('Payroll', c.Type);
                System.assertEquals('India', c.GBS_Center__c);
                List<CaseShare> caseSharesINPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesINPayroll.size());
                System.assert(caseSharesINPayroll.size()> 0);
                for (CaseShare cs : caseSharesINPayroll) {
                    //SG Payroll handles IN Payroll Cases
                    if (cs.UserOrGroupId == sgPayroll.Id) {
                        System.assertEquals(sgPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
            else {
                //Non-Payroll - OTC / Billing
                if (c.Type == 'Order to Cash / Billing') {
                    System.assertNotEquals('Payroll', c.Type);
                    System.assertEquals('Order to Cash / Billing', c.Type);
                    System.assertEquals('India', c.GBS_Center__c);
                    List<CaseShare> caseSharesINNonPayroll = getCaseSharesForCaseId(c.Id);
                    //System.assertEquals(3, caseSharesINNonPayroll.size());
                    System.assert(caseSharesINNonPayroll.size()> 0);
                    for (CaseShare cs : caseSharesINNonPayroll) {
                        if (cs.UserOrGroupId == sgNonPayroll.Id) {
                            System.assertEquals(sgNonPayroll.Id, cs.UserOrGroupId);
                            System.assertEquals('Edit', cs.CaseAccessLevel);
                        }
                    }     
                }
                else {
                    //Non-Payroll - RTR
                    System.assertNotEquals('Payroll', c.Type);
                    System.assertEquals('Record to Report', c.Type);
                    System.assertEquals('India', c.GBS_Center__c);
                    List<CaseShare> caseSharesINNonPayroll = getCaseSharesForCaseId(c.Id);
                    //System.assertEquals(3, caseSharesINNonPayroll.size());
                    System.assert(caseSharesINNonPayroll.size()> 0);
                    for (CaseShare cs : caseSharesINNonPayroll) {
                        if (cs.UserOrGroupId == inNonPayroll.Id) {
                            System.assertEquals(inNonPayroll.Id, cs.UserOrGroupId);
                            System.assertEquals('Edit', cs.CaseAccessLevel);
                        }
                    }     
                }       
            }
        }
    }

    @isTest
    static void getCaseSharesForUSTest() {
		Test.startTest();
        List<Case> usCases = getCasesForGBSCenter('US/Canada');
        
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        for (Case uc : usCases) {
            uc.Submitter__c = u.Id;
        }
        
        update usCases;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();        

        Set<Id> usCasesIds = new Set<Id>();
        for (Case usCase : usCases) {
            usCasesIds.add(usCase.Id);
        }

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('US/Canada');
        Group usPayroll, usNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if (g.Name.contains('Non')) {
                usNonPayroll = g;
            }
            else {
                usPayroll = g;
            }
        }
        
        for (Case c : usCases) {
            if (c.Type.equals('Payroll')) {
                //Payroll
                System.assertEquals('Payroll', c.Type);
                System.assertEquals('US/Canada', c.GBS_Center__c);
                List<CaseShare> caseSharesUSPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesUSPayroll.size());
                System.assert(caseSharesUSPayroll.size()> 0);
                for (CaseShare cs : caseSharesUSPayroll) {
                    if (cs.UserOrGroupId == usPayroll.Id) {
                        System.assertEquals(usPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
            else {
                //Non-Payroll
                System.assertNotEquals('Payroll', c.Type);
                System.assertEquals('US/Canada', c.GBS_Center__c);
                List<CaseShare> caseSharesUSNonPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesUSNonPayroll.size());
                System.assert(caseSharesUSNonPayroll.size()> 0);
                for (CaseShare cs : caseSharesUSNonPayroll) {
                    if (cs.UserOrGroupId == usNonPayroll.Id) {
                        System.assertEquals(usNonPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
        }
    }

    @isTest
    static void getCaseSharesForMXTest() {
		Test.startTest();
        List<Case> mxCases = getCasesForGBSCenter('Mexico');
        
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        for (Case mc : mxCases) {
            mc.Submitter__c = u.Id;
        }
        
        update mxCases;

        //Test.startTest();

        GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Test scheduler', sch, gbsCaseSharingSch);

        Test.stopTest();        

        Set<Id> mxCasesIds = new Set<Id>();
        for (Case mxCase : mxCases) {
            mxCasesIds.add(mxCase.Id);
        }

        List<Group> groupsForGBSCenter = getGroupsForGBSCenter('Mexico');
        Group mxPayroll, mxNonPayroll;
        for (Group g : groupsForGBSCenter) {
            if (g.Name.contains('Non')) {
                mxNonPayroll = g;
            }
            else {
                mxPayroll = g;
            }
        }
        
        for (Case c : mxCases) {
            if (c.Type.equals('Payroll')) {
                //Payroll
                System.assertEquals('Payroll', c.Type);
                System.assertEquals('Mexico', c.GBS_Center__c);
                List<CaseShare> caseSharesMXPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesMXPayroll.size());
                System.assert(caseSharesMXPayroll.size()> 0);
                for (CaseShare cs : caseSharesMXPayroll) {
                    if (cs.UserOrGroupId == mxPayroll.Id) {
                        System.assertEquals(mxPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
            else {
                //Non-Payroll
                System.assertNotEquals('Payroll', c.Type);
                System.assertEquals('Mexico', c.GBS_Center__c);
                List<CaseShare> caseSharesMXNonPayroll = getCaseSharesForCaseId(c.Id);
                //System.assertEquals(3, caseSharesMXNonPayroll.size());
                System.assert(caseSharesMXNonPayroll.size()> 0);
                for (CaseShare cs : caseSharesMXNonPayroll) {
                    if (cs.UserOrGroupId == mxNonPayroll.Id) {
                        System.assertEquals(mxNonPayroll.Id, cs.UserOrGroupId);
                        System.assertEquals('Edit', cs.CaseAccessLevel);
                    }
                }
            }
        }
    }

     // 11-11-2020 ref: Jira story #SAL-420 -- added by #Arun Sharma
     @isTest
     static void getCaseSharesForAPACExceptionUserWithoutCountryTest() {
         Test.startTest();
         List<Case> singaporeCases = getCasesForGBSCenter('Singapore');
         User u = [SELECT Id, LastName FROM User WHERE LastName = 'NoCountryUser'];
         
         Case testCase;
         for (Case c : singaporeCases) {
             if (c.Category_1__c.equals('Other procure to pay request')) {
                 testCase = c;
             }
         }
         testCase.Submitter__c = u.Id;
         
         update testCase;
 
         //Test.startTest();
 
         GBS_CaseSharingScheduler gbsCaseSharingSch = new GBS_CaseSharingScheduler();
         String sch = '0 0 23 * * ?';
         System.schedule('Test scheduler', sch, gbsCaseSharingSch);
 
         Test.stopTest();
 
         List<Group> groupsForGBSCenter = getGroupsForGBSCenter('India/Singapore');
 
         System.assertNotEquals('Payroll', testCase.Type);
         System.assertEquals('Singapore', testCase.GBS_Center__c);
         List<CaseShare> caseShares = getCaseSharesForCaseId(testCase.Id);
         //System.assertEquals(3, caseShares.size());
         System.assert(caseShares.size()> 0);
         for (CaseShare cs : caseShares) {
             if (cs.UserOrGroupId == groupsForGBSCenter[0].Id) {
                 System.assertEquals(groupsForGBSCenter[0].Id, cs.UserOrGroupId);
                 System.assertEquals('Edit', cs.CaseAccessLevel);
             }
         }
     }
}