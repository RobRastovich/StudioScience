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
    @date 04/05/2020
    @description This test class is created to test CNT_SB2_CreateAllocationRecord.
*/
@isTest(seeAllData = false)
public class TST_CNT_SB2_CreateAllocationRecord {
    
    public static State__c state;
    public static Region__c region;
    public static Country__c country;
    public static Account distributorAccount;
    public static Brand_Allocation__c brandAllocation;
    
    /**
    *  @description : This method is use to prepare test data.
    **/
    public static void prepareData(){
        List<Brand__c> lstBrand = TST_SB2_MasterDataFactory.createBrand();
        country = TST_SB2_MasterDataFactory.createCountry();
        region = TST_SB2_MasterDataFactory.createRegion(country)[0];
        state = TST_SB2_MasterDataFactory.createState(country, new List<Region__c>{region})[0];
        distributorAccount = TST_SB2_MasterDataFactory.createDistributorAccount(1)[0];
        
        brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Name = 'JB||Sam||2020||Apr';
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        
        insert brandAllocation;
    }
    
    /**
    *  @description : This method is use to create brand country allocation.
    **/
    @isTest
    public static void createBrandCountryAllocation() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
        
        Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryAllocation(brandCountryAllocation, brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c);

        Test.stopTest();

        System.assert(returnValue.containsKey('Id') && returnValue.get('Id') != null);
    }
    
    /**
    *  @description : This method is use to create brand country allocation exception.
    **/
    @isTest
    public static void createBrandCountryAllocationException() {
        prepareData();
        try {
            Test.startTest();
        
            Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
            brandCountryAllocation.Country__c = country.Id;
            brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
            brandCountryAllocation.Is_Leaf_Node__c = true;
            
            Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryAllocation(brandCountryAllocation, brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c);
    
            Test.stopTest();
        } catch(Exception e) {
         	System.assert(String.isNotBlank(e.getMessage()));   
        }
    }
    
    /**
    *  @description : This method is use to create brand country region allocation.
    **/
    @isTest
    public static void createBrandCountryRegionAllocation() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
        brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        insert brandCountryAllocation;
        
        Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
        regionAllocation.Region__c = region.Id;
        regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryRegionAllocation(regionAllocation, brandCountryAllocation.Name + SB2_Constants.SEPERATOR + region.Name);

        Test.stopTest();

        System.assert(returnValue.containsKey('Id') && returnValue.get('Id') != null);
    }
    
    /**
    *  @description : This method is use to create brand country region allocation exception.
    **/
    @isTest
    public static void createBrandCountryRegionAllocationException() {
        prepareData();
        try {
            Test.startTest();
        
            Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
            brandCountryAllocation.Country__c = country.Id;
            brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
            brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
            insert brandCountryAllocation;
            
            Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
            regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
            regionAllocation.Is_Leaf_Node__c = true;
            Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryRegionAllocation(regionAllocation, brandCountryAllocation.Name + SB2_Constants.SEPERATOR + region.Name);
    
            Test.stopTest();
        } catch(Exception e) {
         	System.assert(String.isNotBlank(e.getMessage()));   
        }
    }
    
    /**
    *  @description : This method is use to create brand country region state allocation.
    **/
    @isTest
    public static void createBrandCountryRegionStateAllocation() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
        brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        insert brandCountryAllocation;
        
        Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
        regionAllocation.Region__c = region.Id;
        regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        regionAllocation.Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + region.Name;
        insert regionAllocation;
        
        Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
        stateAllocation.State__c = state.Id;
        stateAllocation.Brand_Country_Region_Allocation__c = regionAllocation.Id;
        Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryRegionStateAllocation(stateAllocation, regionAllocation.Name + SB2_Constants.SEPERATOR + state.Alias__c);

        Test.stopTest();

        System.assert(returnValue.containsKey('Id') && returnValue.get('Id') != null);
    }
    
    /**
    *  @description : This method is use to create brand country region state allocation exception.
    **/
    @isTest
    public static void createBrandCountryRegionStateAllocationException() {
        prepareData();
        try {
            Test.startTest();
        
            Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
            brandCountryAllocation.Country__c = country.Id;
            brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
            brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
            insert brandCountryAllocation;
            
            Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
            regionAllocation.Region__c = region.Id;
            regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
            regionAllocation.Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + region.Name;
            insert regionAllocation;
            
            Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
            stateAllocation.Brand_Country_Region_Allocation__c = regionAllocation.Id;
            stateAllocation.Is_Leaf_Node__c = true;
            Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryRegionStateAllocation(stateAllocation, regionAllocation.Name + SB2_Constants.SEPERATOR + state.Alias__c);
            
            Test.stopTest();
        } catch(Exception e) {
         	System.assert(String.isNotBlank(e.getMessage()));   
        }
    }
    
    /**
    *  @description : This method is use to create brand country region state dist alloc.
    **/
    @isTest
    public static void createBrandCountryRegionStateDistAlloc() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
        brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        insert brandCountryAllocation;
        
        Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
        regionAllocation.Region__c = region.Id;
        regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        regionAllocation.Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + region.Name;
        insert regionAllocation;
        
        Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
        stateAllocation.State__c = state.Id;
        stateAllocation.Brand_Country_Region_Allocation__c = regionAllocation.Id;
        stateAllocation.Name = regionAllocation.Name + SB2_Constants.SEPERATOR + state.Alias__c;
        insert stateAllocation;
        
        Brand_Country_Region_State_Dist_Alloc__c distributorAllocation = new Brand_Country_Region_State_Dist_Alloc__c();
        distributorAllocation.Account__c = distributorAccount.Id;
        distributorAllocation.Brand_Country_Region_State_Allocation__c = stateAllocation.Id;
        Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryRegionStateDistAlloc(distributorAllocation);

        Test.stopTest();

        System.assert(returnValue.containsKey('Id') && returnValue.get('Id') != null);
    }
    
    /**
    *  @description : This method is use to create brand country region state dist alloc.
    **/
    @isTest
    public static void createBrandCountryRegionStateDistAllocException() {
        prepareData();
        try {
            Test.startTest();

            Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
            brandCountryAllocation.Country__c = country.Id;
            brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
            brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
            insert brandCountryAllocation;
            
            Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
            regionAllocation.Region__c = region.Id;
            regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
            regionAllocation.Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + region.Name;
            insert regionAllocation;
            
            Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
            stateAllocation.State__c = state.Id;
            stateAllocation.Brand_Country_Region_Allocation__c = regionAllocation.Id;
            stateAllocation.Name = regionAllocation.Name + SB2_Constants.SEPERATOR + state.Alias__c;
            insert stateAllocation;
            
            Brand_Country_Region_State_Dist_Alloc__c distributorAllocation = new Brand_Country_Region_State_Dist_Alloc__c();
            distributorAllocation.Brand_Country_Region_State_Allocation__c = stateAllocation.Id;
            distributorAllocation.Is_Leaf_Node__c = true;
            Map<String, Object> returnValue = CNT_SB2_CreateAllocationRecord.createBrandCountryRegionStateDistAlloc(distributorAllocation);
            
            Test.stopTest();
        } catch(Exception e) {
         	System.assert(String.isNotBlank(e.getMessage()));   
        }
    }
}