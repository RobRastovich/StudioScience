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
    @date 18/11/2020
    @description This test class is created to test SLT_User.
*/
@IsTest(seeAllData = false)
public class TST_CNT_CSG_Claim {
    /**
    *  @description : This method is use to prepare test data.
    **/
    @TestSetup
    public static void prepareData(){
        
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

        List<CSG_Record_Type__c> lstRecordType = new List<CSG_Record_Type__c>();
        CSG_Record_Type__c newRecordType = new CSG_Record_Type__c();
        newRecordType.Access_Group__c = 'ADMIN';
        newRecordType.Profile__c = 'System Administrator';
        newRecordType.Label__c = 'Test'; 
        newRecordType.Language__c = 'en_US';
        newRecordType.Name = 'Test';
        newRecordType.Sort_Order__c = 1;
        newRecordType.Value__c = 'Test';
        lstRecordType.add(newRecordType);
        insert lstRecordType;
        
        List<CSG_Type_Selection__c> lstTypeSelection = new List<CSG_Type_Selection__c>();
        CSG_Type_Selection__c typeSelection = new CSG_Type_Selection__c();
        typeSelection.Access_Group__c = 'ADMIN';
        typeSelection.Label__c = 'Test';
        typeSelection.Language__c = 'en_US';
        typeSelection.Name = 'Test';
        typeSelection.Profile__c = 'System Administrator';
        typeSelection.Record_Type__c = 'test';
        typeSelection.Sort_Order__c = 1;
        typeSelection.Value__c = 'Test';
        lstTypeSelection.add(typeSelection);
        insert lstTypeSelection;
        
        List<CSG_Product_SIze__c> lstProductSIze = new List<CSG_Product_SIze__c>();
        CSG_Product_SIze__c productSize = new CSG_Product_SIze__c();
        productSize.Access_Group__c = 'ADMIN';
        productSize.Label__c = 'Test';
        productSize.Language__c = 'en_US';
        productSize.Name = 'Test';
        productSize.Profile__c = 'System Administrator';
        productSize.Record_Type__c = 'Test';
        productSize.Sort_Order__c = 1;
        productSize.Value__c = 'Test';
        lstProductSIze.add(productSize);
        insert lstProductSIze;
        
        List<CSG_Quantity_Type__c> lstQunatityType = new List<CSG_Quantity_Type__c>();
        CSG_Quantity_Type__c newQuantityType = new CSG_Quantity_Type__c();
        newQuantityType.Access_Group__c = 'ADMIN';
        newQuantityType.Label__c = 'Test';
        newQuantityType.Language__c = 'en_US';
        newQuantityType.Name = 'Test';
        newQuantityType.Profile__c = 'System Administrator';
        newQuantityType.Record_Type__c = 'Test';
        newQuantityType.Sort_Order__c = 1;
        newQuantityType.Value__c = 'Test';
        lstQunatityType.add(newQuantityType);
        insert lstQunatityType;
        
        List<Entitlement> lstEntitlement = new List<Entitlement>();
        Entitlement newEntitlement = new Entitlement();
        newEntitlement.AccountId = newAccount.Id;
        newEntitlement.Name = 'Test';
        newEntitlement.SlaProcessId = [Select Id,Name from SlaProcess where name = 'CSG Order Claim' and isActive = true Limit 1].Id;
        newEntitlement.StartDate = Date.today();
        lstEntitlement.add(newEntitlement);
        insert lstEntitlement;
    }
    
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testGetRecordTypeForCase() {
        
        Test.startTest();
        	Map<String, String> result= CNT_CSG_Claim.getRecordTypeForCase();
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
    }
    
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testGetTypeSelectionForCase() {
        
        Test.startTest();
        	Map<String, String> result= CNT_CSG_Claim.getTypeSelectionForCase('Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
    }
    
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testGetProductSizeForCase() {
        
        Test.startTest();
        	Map<String, String> result= CNT_CSG_Claim.getProductSizeForCase('Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
    }
    
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testGetQuantityTypeForCase() {
        
        Test.startTest();
        	Map<String, String> result= CNT_CSG_Claim.getQuantityTypeForCase('Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
    }
    
    @IsTest
    public static void testGetCategoryForCase() {
        
        Test.startTest();
        	Map<String, String> result= CNT_CSG_Claim.getCategoryForCase('Test','Test');
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(), 'User is fetched is fetched');
    }
    
    @IsTest
    public static void testGetSubCategoryForCase() {
        
        Test.startTest();
        	Map<String, String> result= CNT_CSG_Claim.getSubCategoryForCase('Test','Test');
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(), 'User is fetched is fetched');
    }
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testCreateCase() {
        
        User newUser = new user();
        newUser.Username = 'test@test.com'+String.valueOf(Date.today());
		newUser.Email =  'test@test.com';
        newUser.ProfileId = [Select Id from Profile where name = 'CSG Customer Community Plus' limit 1].Id;
		newUser.ContactId = [select Id from contact where name = 'Test' limit 1].Id;
        newUser.LastName = 'Test1212';
        newUser.Alias = 'test123';
        newUser.LocaleSidKey = 'America/Chicago';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/Chicago';
        insert newUser;
        
        Case newCase = new Case();
        newCase.Change_Reason__c = 'CSG Order Claim';
        
        System.runAs(newUser) {
        Test.startTest();
        	Map<String, String> result = CNT_CSG_Claim.createCase(newCase);
        Test.stopTest();
            System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
        }        
        
    }
    
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testCreateCaseForUpdate() {
        
        User newUser = new user();
        newUser.Username = 'test@test.com'+String.valueOf(Date.today());
		newUser.Email =  'test@test.com';
        newUser.ProfileId = [Select Id from Profile where name = 'CSG Customer Community Plus' limit 1].Id;
		newUser.ContactId = [select Id from contact where name = 'Test' limit 1].Id;
        newUser.LastName = 'Test1212';
        newUser.Alias = 'test123';
        newUser.LocaleSidKey = 'America/Chicago';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/Chicago';
        insert newUser;
        
        Case newCase = new Case();
        newCase.Change_Reason__c = 'CSG Order Claim';
        
        
        System.runAs(newUser) {
			Map<String, String> result = CNT_CSG_Claim.createCase(newCase);
        Test.startTest();
        	result = CNT_CSG_Claim.createCase(newCase);
        Test.stopTest();
            System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
        }     
    }
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testUpdateCase() {
        
        User newUser = new user();
        newUser.Username = 'test@test.com'+String.valueOf(Date.today());
		newUser.Email =  'test@test.com';
        newUser.ProfileId = [Select Id from Profile where name = 'CSG Customer Community Plus' limit 1].Id;
		newUser.ContactId = [select Id from contact where name = 'Test' limit 1].Id;
        newUser.LastName = 'Test1212';
        newUser.Alias = 'test123';
        newUser.LocaleSidKey = 'America/Chicago';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/Chicago';
        insert newUser;
        
        Case newCase = new Case();
        newCase.Change_Reason__c = 'CSG Order Claim';
        
        
        System.runAs(newUser) {
			Map<String, String> result = CNT_CSG_Claim.createCase(newCase);
        Test.startTest();
        	result = CNT_CSG_Claim.updateCase(newCase);
        Test.stopTest();
            System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
        }
        
    }
    
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testGetCaseRecordValue() {
        
        User newUser = new user();
        newUser.Username = 'test@test.com'+String.valueOf(Date.today());
		newUser.Email =  'test@test.com';
        newUser.ProfileId = [Select Id from Profile where name = 'CSG Customer Community Plus' limit 1].Id;
		newUser.ContactId = [select Id from contact where name = 'Test' limit 1].Id;
        newUser.LastName = 'Test1212';
        newUser.Alias = 'test123';
        newUser.LocaleSidKey = 'America/Chicago';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/Chicago';
        insert newUser;
        
        Case newCase = new Case();
        newCase.Change_Reason__c = 'CSG Order Claim';
        
        
        System.runAs(newUser) {
			CNT_CSG_Claim.createCase(newCase);
        Test.startTest();
            
        	case result = CNT_CSG_Claim.getCaseRecordValue([Select Id from Case Limit 1].Id);
        Test.stopTest();
            System.assertEquals(true, result != null, 'User is fetched is fetched');
        }
        
    }
}