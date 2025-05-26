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
@date 17/04/2020
@description This test class is to test CNT_SB_ManageBrand Controller .
*/
@IsTest(seeAllData = false)
public class TST_TGR_SB2_BrandAllocation {
    
    /**
*  @description : This method is use to setup data for custom setting.
**/
    @TestSetup
    public static void dataSetup(){
        List<Brand__c> lstBrand = new List<brand__c>();
        Brand__c newBrand = new Brand__c(Name = 'Test1',Is_Active__c = true);
        lstBrand.add(newBrand);
        insert lstBrand;
        
        Country__c newCountry = TST_SB2_MasterDataFactory.createCountry();
        Country__c newCountryIndia = new Country__c(Name='India', Alias__c = 'IND');
        insert newCountryIndia;
        List<Region__c> lstRegion = TST_SB2_MasterDataFactory.createRegion(newCountry);
        List<State__c> lstState = TST_SB2_MasterDataFactory.createState(newCountry, lstRegion);
        List<Brand_Allocation__c> lstBrandAlloc = new List<Brand_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandAlloc(lstBrand[0].Id, 'Sample Kit','2019', 'Monthly', 'June')};
                lstBrandAlloc[0].Is_Carry_Forward__c = true;   
        insert lstBrandAlloc;
        List<Brand_Country_Allocation__c> lstCountryAlloc = new List<Brand_Country_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandCountryAlloc(lstBrandAlloc[0].Id, newCountry.Id, false, 0),
                TST_SB2_MasterDataFactory.createBrandCountryAlloc(lstBrandAlloc[0].Id, newCountryIndia.Id, true, 3)};
                    insert lstCountryAlloc;
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc = new List<Brand_Country_Region_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandCountryRegionAlloc(lstCountryAlloc[0].Id, lstRegion[0].Id, true, 1),
                TST_SB2_MasterDataFactory.createBrandCountryRegionAlloc(lstCountryAlloc[0].Id, lstRegion[1].Id, false, 0)};
                    insert lstRegionAlloc;
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = new List<Brand_Country_Region_State_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandCountryRegionStateAlloc(lstRegionAlloc[0].Id, lstState[0].Id, false, 0),
                TST_SB2_MasterDataFactory.createBrandCountryRegionStateAlloc(lstRegionAlloc[1].Id, lstState[1].Id, true, 5)};
                    insert lstStateAlloc;
        
        List<Brand_Allocation__c> lstNewBrandAlloc = new List<Brand_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandAlloc(lstBrand[0].Id, 'Sample Kit','2019', 'Monthly', 'July')};
                lstNewBrandAlloc[0].Is_Carry_Forward__c = true;   
        insert lstNewBrandAlloc;
        List<Brand_Country_Allocation__c> lstNewCountryAlloc = new List<Brand_Country_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandCountryAlloc(lstNewBrandAlloc[0].Id, newCountry.Id, false, 0),
                TST_SB2_MasterDataFactory.createBrandCountryAlloc(lstNewBrandAlloc[0].Id, newCountryIndia.Id, true, 3)};
                    insert lstNewCountryAlloc;
        List<Brand_Country_Region_Allocation__c> lstNewRegionAlloc = new List<Brand_Country_Region_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandCountryRegionAlloc(lstNewCountryAlloc[0].Id, lstRegion[0].Id, true, 1),
                TST_SB2_MasterDataFactory.createBrandCountryRegionAlloc(lstNewCountryAlloc[0].Id, lstRegion[1].Id, false, 0)};
                    insert lstNewRegionAlloc;
        List<Brand_Country_Region_State_Allocation__c> lstNewStateAlloc = new List<Brand_Country_Region_State_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandCountryRegionStateAlloc(lstNewRegionAlloc[0].Id, lstState[0].Id, false, 0),
                TST_SB2_MasterDataFactory.createBrandCountryRegionStateAlloc(lstNewRegionAlloc[1].Id, lstState[1].Id, true, 0)};
                    insert lstNewStateAlloc;
    }
    
    /**
*  @description : This method is use to test successfull insertion of Brand Allocation
**/
    @isTest
    public static void testBrandAllocationSuccessInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(true,result.isSuccess());
        }
    }
    
    /**
*  @description : This method is use to test If same records are inserted then a validation message is received.
**/
    @isTest
    public static void testBrandAllocationSameRecordInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        List<Brand_Allocation__c> lstBrandAllocation1 = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        insert brandAllocation;
        brandAllocation.Id = null; 
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        SYstem.debug(insertResult);
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_TimeOverlap_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
*  @description : This method is use to test when brand allocations overlap time intervals for quarter
**/
    @isTest
    public static void testBrandAllocationForTimeOverlapInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        List<Brand_Allocation__c> lstBrandAllocation1 = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        insert brandAllocation;
        brandAllocation.Id = null; 
        brandAllocation.Time_Period__c = 'Quarterly';
        brandAllocation.Time_Interval__c = 'Quarter 2';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        SYstem.debug(insertResult);
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_TimeOverlap_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
*  @description : This method is use to test when brand allocations overlap time intervals for year
**/
    @isTest
    public static void testBrandAllocationForYearlyTimeOverlapInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        List<Brand_Allocation__c> lstBrandAllocation1 = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        insert brandAllocation;
        brandAllocation.Id = null; 
        brandAllocation.Time_Period__c = 'Yearly';
        brandAllocation.Time_Interval__c = 'year';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        SYstem.debug(insertResult);
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_TimeOverlap_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
*  @description : This method is use to test successfull insertion of Brand Allocation
**/
    @isTest
    public static void testBrandAllocationInActiveInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = false;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_In_Active_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
*  @description : This method is use to test for same year allocation
**/
    @isTest
    public static void testBrandAllocationSameYearInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Yearly';
        brandAllocation.Time_Interval__c = 'year';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        insert brandAllocation;
        brandAllocation.id = null;
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_TimeOverlap_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
*  @description : This method is use to test for same year allocation
**/
    @isTest
    public static void testBrandAllocationSameQuarterInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Quarterly';
        brandAllocation.Time_Interval__c = 'Quarter 1';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        insert brandAllocation;
        brandAllocation.id = null;
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_TimeOverlap_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
*  @description : This method is use to test for same year allocation
**/
    @isTest
    public static void testBrandAllocationExpired() {
        Test.startTest();
        List<Brand_Allocation__c> lstBrandAllocation = [Select Id, Name From Brand_Allocation__c limit 1];
        lstBrandAllocation[0].Status__c = 'Expired';
        update lstBrandAllocation[0];    
        Test.stopTest();
        
    }
}