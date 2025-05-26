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
    @description This test class is created to test SLT_CustomSetting.
*/
@IsTest(seeAllData = false)
public class TST_SLT_CustomSetting {
    /**
    *  @description : This method is use to prepare test data.
    **/
    @TestSetup
    public static void prepareData(){
        List<CSG_Record_Type__c> lstRecordType = new List<CSG_Record_Type__c>();
        CSG_Record_Type__c newRecordType = new CSG_Record_Type__c();
        newRecordType.Access_Group__c = 'Test';
        newRecordType.Profile__c = 'Test';
        newRecordType.Label__c = 'Test';
        newRecordType.Language__c = 'Test';
        newRecordType.Name = 'Test';
        newRecordType.Sort_Order__c = 1;
        newRecordType.Value__c = 'Test';
        lstRecordType.add(newRecordType);
        insert lstRecordType;
        
        List<CSG_Type_Selection__c> lstTypeSelection = new List<CSG_Type_Selection__c>();
        CSG_Type_Selection__c typeSelection = new CSG_Type_Selection__c();
        typeSelection.Access_Group__c = 'Test';
        typeSelection.Label__c = 'Test';
        typeSelection.Language__c = 'Test';
        typeSelection.Name = 'Test';
        typeSelection.Profile__c = 'Test';
        typeSelection.Record_Type__c = 'test';
        typeSelection.Sort_Order__c = 1;
        typeSelection.Value__c = 'Test';
        lstTypeSelection.add(typeSelection);
        insert lstTypeSelection;
        
        List<CSG_Product_SIze__c> lstProductSIze = new List<CSG_Product_SIze__c>();
        CSG_Product_SIze__c productSize = new CSG_Product_SIze__c();
        productSize.Access_Group__c = 'Test';
        productSize.Label__c = 'Test';
        productSize.Language__c = 'Test';
        productSize.Name = 'Test';
        productSize.Profile__c = 'Test';
        productSize.Record_Type__c = 'Test';
        productSize.Sort_Order__c = 1;
        productSize.Value__c = 'Test';
        lstProductSIze.add(productSize);
        insert lstProductSIze;
        
        List<CSG_Quantity_Type__c> lstQunatityType = new List<CSG_Quantity_Type__c>();
        CSG_Quantity_Type__c newQuantityType = new CSG_Quantity_Type__c();
        newQuantityType.Access_Group__c = 'Test';
        newQuantityType.Label__c = 'Test';
        newQuantityType.Language__c = 'Test';
        newQuantityType.Name = 'Test';
        newQuantityType.Profile__c = 'Test';
        newQuantityType.Record_Type__c = 'Test';
        newQuantityType.Sort_Order__c = 1;
        newQuantityType.Value__c = 'Test';
        lstQunatityType.add(newQuantityType);
        insert lstQunatityType;
        
        Topic_Added_For_User__c topicAddedForUser = new Topic_Added_For_User__c(Name='Test Topics', 
                                                                                Topic_Name__c = 'Test Topics');
        insert topicAddedForUser;
    }
    
    /**
    *  @description : This method is use to test if List<CSG_Record_Type__c> is returned 
    * if accessGroup, profileName, language is passed
    **/
    @IsTest
    public static void testGetCSGRecordType() {

        Test.startTest();
        	List<CSG_Record_Type__c> result= SLT_CustomSetting.getCSGRecordType('Test', 'Test', 'Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Record Type is fetched');
    }
    
    /**
    *  @description : This method is use to test if List<CSG_Type_Selection__c> is returned
    * if accessGroup, profileName, language, record type is passed
    **/
    @IsTest
    public static void testGetTypeSelection() {

        Test.startTest();
        	List<CSG_Type_Selection__c> result= SLT_CustomSetting.getTypeSelection('Test', 'Test', 'Test', 'Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Type selection is fetched');
    }
    
    /**
    *  @description : This method is use to test if List<CSG_Quantity_Type__c> is returned
    * if accessGroup, profileName, language, record type is passed
    **/
    @IsTest
    public static void testGetQunatityType() {

        Test.startTest();
        	List<CSG_Quantity_Type__c> result= SLT_CustomSetting.getQunatityType('Test', 'Test', 'Test', 'Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Quantity type is fetched');
    }
    
    /**
    *  @description : This method is use to test if List<CSG_Quantity_Type__c> is returned
    * if accessGroup, profileName, language, record type is passed
    **/
    @IsTest
    public static void testGetProductSize() {

        Test.startTest();
        	List<CSG_Product_SIze__c> result= SLT_CustomSetting.getProductSize('Test', 'Test', 'Test', 'Test');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Product size is fetched');
    }
    
    @isTest
    private static void testGetTopicsName() {
        
        Test.startTest();
        	List<Topic_Added_For_User__c  > lstTopicsRecord = SLT_CustomSetting.getTopicsName();
        Test.stopTest();
        
        System.assertEquals(true, lstTopicsRecord.size()>0 ,'It should return Topics');
    }
}