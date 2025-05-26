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
    @description This test class is to test Contact Us Controller .
*/
@isTest(SeeAllData = false)
public class TST_ContactUs {
    public static Case caseObj ;
    public static Account accountInstance ;
    
    /**
    *  @description : This method is use to setup data for custom setting.
    **/
    @TestSetup
    public static void makeData(){
        ContactUs_Setting__c contactUsSettingObj = new ContactUs_Setting__c();
        contactUsSettingObj.Name = 'Default';
        contactUsSettingObj.ReCaptchaEndPoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        contactUsSettingObj.ReCaptchaSecretKey__c = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe';
        contactUsSettingObj.ReCaptchaSiteKey__c = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI';
        insert contactUsSettingObj;
    }
    
    /**
    *  @description : This method is use to prepare data for case and account not inserting.
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
    }
    
    public static void prepareDataDTC(){
        caseObj = new Case();
        caseObj.Origin = 'Web';
        caseObj.Product_Size__c = '60ml';
        caseObj.Lot_Code__c = '1123456';
        caseObj.Description = 'Test Description';
        caseObj.Do_you_still_have_the_product__c = 'I have bottle with liquid inside';
        caseObj.Issue__c = 'Taste Different Than Previous Purchase(s)';
        caseObj.Brand__c = 'Jim Beam';
        caseObj.How_can_we_help__c = 'Product or Packaging Issue';
        caseObj.UPS_Tracking_Number__c = 'UPS123';
        caseObj.Damage_Issue__c = 'Lost';
        caseObj.OrderID__c = 'test9999';
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
    }
    
    /**
    *  @description : This method is use to test picklist values for brand Jim Beam.
    **/
    @IsTest
    public static void testGetPickListValues() {
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.getPickListValues('Jim Beam');
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetPickListValuesForLwc() {
        Test.startTest();
        	Map<String, Object> responseMap = CNT_ContactUs.getPickListValuesForLwc('Jim Beam');
        Test.stopTest();
    }
    
    /**
    *  @description : This method is use to test creation of case for inquiry.
    **/
    @IsTest
    public static void testCreateCaseForInquiry() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,false,'dkhjkkaskcbkj',accountInstance,null, new List<String>());
        Test.stopTest();
        System.assertNotEquals(null,responseMap.get('caseId'));
        System.assertNotEquals(null,responseMap.get('accountId'));
        
    }
    
    /**
    *  @description : This method is use to test creation of case for DTC.
    *                 Changes Made by Nishant Khandal DTCS 22
    **/
    @IsTest
    public static void testCreateCaseForDTC() {
        prepareData();
        caseObj.How_can_we_help__c = 'Barreled & Boxed – Membership Program';
        caseObj.AdditionalInformation__c = 'Membership Cancellation';
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,false,'dkhjkkaskcbkj',accountInstance,null, new List<String>());
        Test.stopTest();
        System.assertNotEquals(null,responseMap.get('caseId'));
        System.assertNotEquals(null,responseMap.get('accountId')); 
    }
    
    @IsTest
    public static void testCreateCaseForDTCMakersMark() {
        prepareDataDTC();
        caseObj.How_can_we_help__c = DTC_Constants.WHISKY_DROP;
        caseObj.AdditionalInformation__c = DTC_Constants.SHIPPING_AND_DELIVERY_QUESTIONS;
 		caseObj.Brand__c= System.label.Makers_Mark_Brand;
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,false,'dkhjkkaskcbkj',accountInstance,null, new List<String>());
        Test.stopTest();
        System.assertNotEquals(null,responseMap.get('caseId'));
        System.assertNotEquals(null,responseMap.get('accountId')); 
    }
    
    /**
    *  @description : This method is use to test update of case for complain.
    **/
    @IsTest
    public static void testUpdateCaseForComplaint() {
        prepareData();
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,true,'dkhjkkaskcbkj',accountInstance,null, new List<String>());
        System.assertNotEquals(null,responseMap.get('caseId'));
        System.assertNotEquals(null,responseMap.get('accountId'));
        String caseID = (String)responseMap.get('caseId');
        String accountId = (String)responseMap.get('accountId');
        responseMap = CNT_ContactUs.updateCase(caseObj,caseID,accountInstance,accountId,'Address2');
        Test.stopTest();
        System.assertNotEquals(null,responseMap.get('caseId'));
        System.assertEquals(true,responseMap.get('success'));
    }
    
    /**
    *  @description : This method is use to test creation of case for complaint.
    **/
   	@IsTest
    public static void testCreateCaseForComplaint(){
        prepareData();
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        caseObj.RecordTypeId = CSConstants.DUMMY_CASE_RT_ID;
        insert caseObj;
        insert accountInstance;
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,caseObj.id,true,'dkhjkkaskcbkj',accountInstance,accountInstance.id, new List<String>());
        Test.stopTest();
        System.assertNotEquals(null,responseMap.get('caseId'));
        System.assertNotEquals(null,responseMap.get('accountId'));
    } 
    
    /**
    *  @description : This method is use to test creation of case for inquiry when reCaptcha response is null.
    **/
    @IsTest
    public static void testCreateCaseForInquiryWhenRecaptchaResponseisNull(){
        prepareData();
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,true,'',accountInstance,null, new List<String>());
        Test.stopTest();
        System.assertEquals(null,responseMap);
    } 
    
    /**
    *  @description : This method is use to test creation of case for inquiry when reCaptcha response is false.
    **/
    @IsTest
    public static void testCreateCaseForNegativeResponse(){
        prepareData();
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilNegativeResponseGenerator());
        Test.startTest();
        Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,true,'vsdhjdhfkghk',accountInstance,null, new List<String>());
        Test.stopTest();
        System.assertEquals(false,responseMap.get('success'));
    }
    
    /**
    *  @description : This method is use to test getPicklistValues brand name is empty.
    **/
    @IsTest
    public static void testGetPickListValuesException() {
        try{
           Test.startTest();
            Map<String, Object> responseMap = CNT_ContactUs.getPickListValues('');
            Test.stopTest(); 
        } catch(Exception e) {
            System.assert(e.getMessage() != null);
        }
        
    }
    
    /**
    *  @description : This method is use to test creation of case when brand name is invalid.
    **/
    @IsTest
    public static void testCreateCaseForInvalidBrand(){
        try{
            prepareData();
            caseObj.Brand__c = 'Test';
            Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
            Test.startTest();
            Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,false,'vsdhjdhfkghk',accountInstance,null, new List<String>());
            Test.stopTest();
        } catch(Exception e) {
            System.assert(e.getMessage() != null);
        }
    }
    
    /**
    *  @description : This method is use to test update of case when brand name is invalid.
    **/
    @IsTest
    public static void testUpdateCaseForInvalidBrand(){
        try{
            prepareData();
            caseObj.Brand__c = 'Test';
            Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
            Test.startTest();
            Map<String, Object> responseMap = CNT_ContactUs.updateCase(caseObj,null,accountInstance,null,'Address2');
            Test.stopTest();
        } catch(Exception e) {
            System.assert(e.getMessage() != null);
        }
    }
    
    @IsTest
    public static void testDocumentIds() {
        prepareData();
        ContentVersion cv = new ContentVersion();
		cv.Title = 'Test Document';
		cv.PathOnClient = 'TestDocument.pdf';
		cv.VersionData = Blob.valueOf('Test Content');
		cv.IsMajorVersion = true;
		Insert cv;
		Id conDocId = [SELECT ContentDocumentId 
                          FROM ContentVersion 
                          WHERE Id =:cv.Id].ContentDocumentId;
        List<String> documentIds = new List<String>();
        documentIds.add(conDocId);
        Test.setMock(HttpCalloutMock.class, new MockHttpUtilResponseGenerator());
        
        Test.startTest();
        	Map<String, Object> responseMap = CNT_ContactUs.createCase(caseObj,null,false,
                                                  'dkhjkkaskcbkj',accountInstance,null, documentIds);
        Test.stopTest();
        
        System.assertNotEquals(null,responseMap.get('caseId'), 'responseMap should be contain caseId');
        System.assertNotEquals(null,responseMap.get('accountId'), 'responseMap should be contain accountId');
    }
}