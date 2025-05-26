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
public class TST_CNT_SB2_ManageLeafNode {
    /**
    *  @description : This method is use to setup data for custom setting.
    **/
    @TestSetup
    public static void dataSetup(){
        List<Brand__c> lstBrand = new List<brand__c>();
        Brand__c newBrand = new Brand__c(Name = 'Test1',Is_Active__c = true);
        lstBrand.add(newBrand);
        insert lstBrand;
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
        Brand_Allocation__c newAllocation = new Brand_Allocation__c(Brand__c = newBrand.Id, Is_Active__c=true, 
                                                                    Program_Type__c='Sample Kit', Time_Interval__c ='Year',Time_Period__c='Yearly',
                                                                   Year_Of_Allocation__c = '2020');
        lstBrandAllocation.add(newAllocation);
        insert lstBrandAllocation;
        List<Country__c> lstCountry = new List<Country__c>();
        Country__c newCountry = new Country__c(Name='US',IsActive__c= true,Alias__c = 'US');
        lstCountry.add(newCountry);
        insert lstCountry;
        List<Brand_Country_Allocation__c> lstCountryAllocation = new List<Brand_Country_Allocation__c>();
        Brand_Country_Allocation__c countryAlloc = new Brand_Country_Allocation__c(Brand_Allocation__c = newAllocation.Id,
                                                                                  Country__c = newCountry.Id,Is_Active__c= true);
        lstCountryAllocation.add(countryAlloc);
        insert lstCountryAllocation;
        List<Region__c> lstRegion = new List<Region__c>();
        Region__c newRegion = new Region__c(Name = 'Cental', Country__c = newCountry.Id, IsActive__c = true);
        lstRegion.add(newRegion);
        insert lstRegion;
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
        Brand_Country_Region_Allocation__c newRegionAlloc = new Brand_Country_Region_Allocation__c(Brand_Country_Allocation__c = countryAlloc.Id, Region__c = newRegion.Id);
        lstRegionAlloc.add(newRegionAlloc);
        insert lstRegionAlloc;
        
        List<State__c> lstState = new List<State__c>();
        State__c newState1 = new State__c(Name='Chicago',Alias__c ='chi', Region__c = newRegion.Id,country__c = newCountry.Id, IsActive__c = true,State_Manager__c = UserInfo.getUserId());
        State__c newState2 = new State__c(Name='test', ALias__c = 'Tes', Region__c = newRegion.Id,country__c = newCountry.Id, IsActive__c = true,State_Manager__c = UserInfo.getUserId());
        lstState.add(newState1);
        lstState.add(newState2);
        insert lstState;
        list<Brand_Country_Region_State_Allocation__c> lstStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
        Brand_Country_Region_State_Allocation__c newStateAlloc1 = new Brand_Country_Region_State_Allocation__c(
        Allocations_Per_Interval__c = 10, Brand_Country_Region_Allocation__c = newRegionAlloc.Id, State__c = newState1.Id,
        Is_Leaf_Node__c = true, Is_Active__c = true);
        Brand_Country_Region_State_Allocation__c newStateAlloc2 = new Brand_Country_Region_State_Allocation__c(Brand_Country_Region_Allocation__c = newRegionAlloc.Id, State__c = newState1.Id,
        Is_Leaf_Node__c = false, Is_Active__c = true);
        lstStateAlloc.add(newStateAlloc1);
        lstStateAlloc.add(newStateAlloc2);
        insert lstStateAlloc;
        List<Account> lstAccount = new List<Account>();
        Id recordTypeId = [Select Id From Recordtype where SObjectType = 'Account' and DeveloperName = 'Distributor' limit 1].Id;
        Account newAccount = new Account(Name = 'test', recordtypeId = recordTypeId);
        lstAccount.add(newAccount);
        insert lstAccount;
        list<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        Brand_Country_Region_State_Dist_Alloc__c newDistAlloc = new Brand_Country_Region_State_Dist_Alloc__c(
        Account__c = newAccount.Id, Allocations_Per_Interval__c = 10, Brand_Country_Region_State_Allocation__c =newStateAlloc2.Id, 
            Is_Active__c=true,Is_Leaf_Node__c=true);
        lstDistAlloc.add(newDistAlloc);
        insert lstDistAlloc;
        
    }
    
    @isTest
    public static void testGetDistributorAllocationInfo(){
        String recordId = [Select Id from Brand_Country_Region_State_Dist_Alloc__c limit 1].Id;
        Test.startTest();
        	List<Brand_Country_Region_State_Dist_Alloc__c> result = CNT_SB2_ManageLeafNode.getDistributorAllocationInfo(recordId);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Distributor allocation is fetched');
    }
    
    @isTest
    public static void testRemoveLeafDistributorAllocation(){
        String recordId = [Select Id from Brand_Country_Region_State_Dist_Alloc__c limit 1].Id;
        Test.startTest();
        	List<Brand_Country_Region_State_Dist_Alloc__c> result = CNT_SB2_ManageLeafNode.removeLeafDistributorAllocation(recordId);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Distributor allocation is fetched');
    }
    
    @isTest
    public static void testGetStateAllocationInfoForLeafNode(){
        String recordId = [Select Id from Brand_Country_Region_State_Allocation__c where Is_Leaf_Node__c = true limit 1].Id;
        Test.startTest();
        	List<Brand_Country_Region_State_Allocation__c> result = CNT_SB2_ManageLeafNode.getStateAllocationInfoForLeafNode(recordId);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Distributor allocation is fetched');
    }
    
    @isTest
    public static void testRemoveStateAllocation(){
        String recordId = [Select Id from Brand_Country_Region_State_Allocation__c where Is_Leaf_Node__c = true limit 1].Id;
        Test.startTest();
        	List<Brand_Country_Region_State_Allocation__c> result = CNT_SB2_ManageLeafNode.removeStateAllocation(recordId);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Distributor allocation is fetched');
    }
    
    @isTest
    public static void testGetBrandAllocationInfo(){
        String recordId = [Select Id from Brand_Allocation__c limit 1].Id;
        Test.startTest();
        	List<Brand_Allocation__c> result = CNT_SB2_ManageLeafNode.getBrandAllocationInfo(recordId);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Distributor allocation is fetched');
    }
}