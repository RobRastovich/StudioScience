/**
    @company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 17/02/2020
    @description This test class is created to test customer history controller.
*/
@isTest(SeeAllData = false)
public class TST_CustomerHistory {
    
    /**
    *  @description : This method is use setup data for test cases.
    **/
    @TestSetup
    public static void makeData(){
        caseServices.runTrigger = false;
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        List<Case> lstCase = new List<Case>();
        Account acc = new Account();
        acc.FirstName = 'First';
        acc.LastName = 'Last';
        acc.PersonEmail = 'test@test.com';
        acc.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
        acc.PersonMailingCity = 'Jaipur';
        acc.PersonMailingState = 'Niwaroo';
        acc.PersonMailingCountry = 'India';
        acc.PersonMailingPostalCode = '302012';
        acc.PersonMailingStreet = 'Idk';
        acc.Phone = '9876543210';
        insert acc; 
        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id].PersonContactId;
        
        lstCase.add(new Case(ContactId = personContactId, RecordTypeId = CSConstants.QC_RT_ID, Description = 'I got cut', Brand__c = 'Jim Beam', How_can_we_help__c = 'Where to Buy Product', Product_Type__c = 'BLACK', Subject = 'Case 1', Lot_Code__c = 'L123456'));
        lstCase.add(new Case(ContactId = personContactId, RecordTypeId = CSConstants.QC_RT_ID, Description = 'I got cut', Brand__c = 'Jim Beam', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = 'APPLE', Subject = 'Case 2', CreatedDate = Datetime.now().addDays(-1), Lot_Code__c = 'L1234567'));
        lstCase.add(new Case(ContactId = personContactId, RecordTypeId = CSConstants.QC_RT_ID, Description = 'I got cut', Brand__c = 'Laphroaig', How_can_we_help__c = 'Where to Buy Product', Product_Type__c = '10 YEAR', Subject = 'Case 3', CreatedDate = Datetime.now().addDays(-2), Lot_Code__c = 'L12345678'));
        lstCase.add(new Case(ContactId = personContactId, RecordTypeId = CSConstants.QC_RT_ID, Description = 'I got cut', Brand__c = 'Laphroaig', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = '16 YEAR', Subject = 'Case 4', CreatedDate = Datetime.now().addDays(-3), Lot_Code__c = 'L123456789'));

        insert lstCase;
    }

    /**
    *  @description : This method is use to test getCases() of customer history controller.
    **/
    @IsTest
    public static void testGetCases() {
        List<Case> lstInsertedCases = [SELECT Id, Product_Type__c, CreatedDate, RecordType.Name, Contact.Email, Contact.MailingCountry, Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity, Contact.MailingState From Case Where Contact.Email = 'test@test.com'];
        if(lstInsertedCases != null && !lstInsertedCases.isEmpty()) {
            for(Case c : lstInsertedCases) {
                List<Case> lstCases = CNT_CustomerHistory.getCases(c.Id, c.Contact.Email, c.Contact.MailingCountry, c.Contact.MailingStreet, c.Contact.MailingPostalCode, c.Contact.MailingCity, c.Contact.MailingState);
                System.assertEquals(3, lstCases.size());
            }
        }
    }

    /**
    *  @description : This method is use to test getWarningMessage() of customer histoy controller.
    **/
    @IsTest
    public static void testGetWarningMessage() {
        List<Case> lstInsertedCases = [SELECT Id, Product_Type__c, CreatedDate, RecordType.Name, Contact.Email, Contact.MailingCountry, Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity, Contact.MailingState From Case Where Contact.Email = 'test@test.com'];
        if(lstInsertedCases != null && !lstInsertedCases.isEmpty()) {
            for(Case c : lstInsertedCases) {
                String warningMessage = CNT_CustomerHistory.getWarningMessage(c.Id, c.Contact.Email, c.Contact.MailingCountry, c.Contact.MailingStreet, c.Contact.MailingPostalCode, c.Contact.MailingCity, c.Contact.MailingState, c.CreatedDate);
                if(c.Product_Type__c == 'BLACK') {
                    System.assertEquals(System.Label.WarningMessage52Weeks, warningMessage);
                } else if(c.Product_Type__c == 'APPLE') {
                    System.assertEquals(System.Label.WarningMessage52Weeks, warningMessage);
                } else if(c.Product_Type__c == '10 YEAR') {
                    System.assertEquals(System.Label.WarningMessage90Days, warningMessage);
                } else if(c.Product_Type__c == '16 YEAR') {
                    System.assertEquals('', warningMessage);
                } 
            }
        }
    }
    
    /**
    *  @description : This method is use to test getWarningMessage() of customer histoy when case id is null.
    **/
    @IsTest
    public static void testGetWarningMesssageException() {
        try{
            String warningMessage = CNT_CustomerHistory.getWarningMessage(null, 'test@test.com', 'abc', 'idk', '3020', 'ijk', 'rj', Datetime.now());
        }catch(Exception e) {
            system.assert(String.isNotBlank(e.getMessage()));
        }
    }
        
    /**
    *  @description : This method is use to test getCases() of customer histoy when case id is null.
    **/
    @IsTest
    public static void testGetCasesException() {
        try{
            List<Case> lstCases = CNT_CustomerHistory.getCases(null, 'test@test.com', 'abc', 'idk', '3020', 'ijk', 'rj');
        }catch(Exception e) {
            system.assert(String.isNotBlank(e.getMessage()));
        }
    }
    
    /**
    *  @description : This method is use to test getLotcodeCases.
    **/
    @IsTest
    public static void testGetLotcodeCases() {
        Test.startTest();
        Case caseObj = [SELECT Id, Account.PersonMailingCountry, Lot_Code__c FROM Case LIMIT 1];
        List<Case> lstCases = CNT_CustomerHistory.getLotcodeCases(caseObj.Id, caseObj.Account.PersonMailingCountry, caseObj.Lot_Code__c.substring(0, 4));
        Test.stopTest();
    }
    
    /**
    *  @description : This method is use to test exception case.
    **/
    @IsTest
    public static void testGetLotcodeCasesException() {
        try{
            List<Case> lstCases = CNT_CustomerHistory.getLotcodeCases(null, 'US', 'L123');
        }catch(Exception e) {
            system.assert(String.isNotBlank(e.getMessage()));
        }
    }
}