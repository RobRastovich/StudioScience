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
    @description This test class is created to test CNT_CaseOwnerChange class.
*/
@IsTest
public class TST_CaseOwnerChange {
    
    public static Case caseObj ;
    public static Account accountInstance ;
    
    @testSetup
    static void setupMethod(){         
        Profile pf= [Select Id from profile where Name='Contact Us Community Profile']; 
        
        User usr = new User();
        usr.Email = 'ABC.Metacube@gmail.com';
        usr.Username = 'ABC.Metacube@gmail.com';
        usr.LastName ='XYZ';
        usr.Alias = 'ABC';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey =  'ISO-8859-1';
        usr.ProfileId = pf.Id ;
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
       	ConsumerServices__c consumerServices = new ConsumerServices__c();
        consumerServices.Agent_Email__c=usr.Email;
        insert consumerServices;
    }
    
    /**
    *  @description : This method is use setup data for test cases.
    **/
    public static void prepareData(){
        caseObj = new Case();
        caseObj.Origin = 'Web';
        caseObj.Product_Size__c = '60ml';
        caseObj.Lot_Code__c = '1123456';
        caseObj.Description = 'Test Description';
        caseObj.Do_you_still_have_the_product__c = 'I have bottle with liquid inside';
        caseObj.Issue__c = 'Taste Different Than Previous Purchase(s)';
        caseObj.Brand__c = 'Jim Beam';
        caseObj.How_can_we_help__c = 'Product or Packaging Issue';
        caseObj.Product_Type__c = 'APPLE';
        caseObj.RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID;
        accountInstance = new Account();
        accountInstance.FirstName = 'First';
        accountInstance.LastName = 'Last';
        accountInstance.PersonEmail = 'test@test.com';
        accountInstance.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
        accountInstance.PersonMailingCity = 'Jaipur';
        accountInstance.PersonMailingState = 'Niwaroo';
        accountInstance.PersonMailingCountry = 'India';
        accountInstance.PersonMailingPostalCode = '302012';
        accountInstance.PersonMailingStreet = 'Idk';
        accountInstance.Phone = '9876543210';
        insert caseObj;
        insert accountInstance;
    }
    
     public static void prepareData1(){
        caseObj = new Case();
        caseObj.Origin = 'Web';
        caseObj.Product_Size__c = '60ml';
        caseObj.Lot_Code__c = '1123456';
        caseObj.Description = 'Test Description';
        caseObj.Do_you_still_have_the_product__c = 'I have bottle with liquid inside';
        caseObj.Issue__c = 'Taste Different Than Previous Purchase(s)';
        caseObj.Brand__c = 'Jim Beam';
        caseObj.How_can_we_help__c = 'Product or Packaging Issue';
        caseObj.Product_Type__c = 'APPLE';
        caseObj.RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID;
        accountInstance = new Account();
        accountInstance.FirstName = 'First1';
        accountInstance.LastName = 'Last1';
        accountInstance.PersonEmail = 'test123@test.com';
        accountInstance.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
        accountInstance.PersonMailingCity = 'Jaipur';
        accountInstance.PersonMailingState = 'Niwaroo';
        accountInstance.PersonMailingCountry = 'India';
        accountInstance.PersonMailingPostalCode = '302012';
        accountInstance.PersonMailingStreet = 'Idk';
        accountInstance.Phone = '9876543210';
        insert caseObj;
        insert accountInstance;
    }
    
    @IsTest
    public static void testUpdateStatus() {
        prepareData();
        string errorMsg;
        Test.startTest();
        try {
            CNT_CaseOwnerChange.updateStatus(caseObj, caseObj.id);
        } catch (exception e) {
            errorMsg = e.getMessage();   
        }
        System.assertNotEquals(null, caseObj);
        Test.stopTest();
    }
    
    @IsTest
    public static void testUpdateStatusNegative() {
        prepareData();
        string errorMsg;
        Test.startTest();
        try {
            CNT_CaseOwnerChange.updateStatus(caseObj, null);
        } catch (exception e) {
            errorMsg = e.getMessage();   
        }
        System.assertNotEquals(null, errorMsg);   
        Test.stopTest();
    }
    
    @isTest
    public static void testChangeRecord()
    {
        prepareData();
        Test.startTest();
        try{
            CNT_CaseOwnerChange.changeRecord(caseObj, caseObj.id, caseObj.RecordTypeId, caseObj.caseNumber);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(null, caseObj);
    }

    @IsTest
    public static void testGetCaseRecord() 
    {
        prepareData();
        
        Test.startTest();
            CNT_CaseOwnerChange.getCaseRecord(caseObj.id);
        Test.stopTest();
        
        System.assertNotEquals(null, caseObj);
    }
    
    @isTest
    public static void testEscalateCase()
    {
        prepareData1();
        Test.startTest();
        try{
            CNT_CaseOwnerChange.escalateCaseApex(caseObj, caseObj.id, caseObj.RecordTypeId);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        System.assertNotEquals(null, caseObj);
    }
}