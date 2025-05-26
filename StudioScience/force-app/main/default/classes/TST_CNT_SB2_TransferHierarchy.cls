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
    @date 23/06/2020
    @description This test class is created to test CNT_SB2_TransferHierarchy.
*/
@IsTest(seeAllData = false)
public class TST_CNT_SB2_TransferHierarchy {
    
    public static List<Brand_Allocation__c> lstBrandAllocation;
    public static Brand_Country_Allocation__c brandCountryAllocation;
    public static List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation;
    public static List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation;
    public static List<Brand_Country_Region_State_Dist_Alloc__c> distAllocs;
    public static List<Region__c> lstRegion;
    public static List<State__c> lstState;
    public static Country__c country;
    
    /**
    *  @description : This method is use to prepare test data.
    **/
    public static void prepareData(){
        List<Brand__c> lstBrand = TST_SB2_MasterDataFactory.createBrand();
        country = TST_SB2_MasterDataFactory.createCountry();
        lstRegion = TST_SB2_MasterDataFactory.createRegion(country);
        lstState = TST_SB2_MasterDataFactory.createState(country, lstRegion);
        lstBrandAllocation = new List<Brand_Allocation__c>();
        for(Brand__c brand : lstBrand) {
            Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
            brandAllocation.Brand__c = brand.Id;
            brandAllocation.Is_Active__c = true;
            brandAllocation.Program_Type__c = 'Sample Kit';
            brandAllocation.Time_Period__c = 'Monthly';
            brandAllocation.Time_Interval__c = SB2_Constants.mapOfIntegerMonth.get(Date.today().month());
            brandAllocation.Year_Of_Allocation__c = Date.today().year() + '';
            lstBrandAllocation.add(brandAllocation);
        }
        
        lstBrandAllocation.add(
        	new Brand_Allocation__c(
                Brand__c = lstBrand[1].Id,
                Is_Active__c = true,
                Program_Type__c = 'Sample Kit',
                Time_Period__c = 'Monthly',
                Time_Interval__c = SB2_Constants.mapOfIntegerMonth.get(Date.today().month()),
                Year_Of_Allocation__c = Date.today().year() + ''
            )
        );
        
        insert lstBrandAllocation;
        
        brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = lstBrandAllocation[0].Id;
        
        insert brandCountryAllocation;
        
        lstBrandCountryRegionAllocation = new List<Brand_Country_Region_Allocation__c>();
        
        lstBrandCountryRegionAllocation.add(new Brand_Country_Region_Allocation__c(
                                                Brand_Country_Allocation__c = brandCountryAllocation.Id,
                                                Region__c = lstRegion[0].Id)
                                           );
        
        lstBrandCountryRegionAllocation.add(new Brand_Country_Region_Allocation__c(
                                                Brand_Country_Allocation__c = brandCountryAllocation.Id,
                                                Region__c = lstRegion[1].Id,
                                                Is_Leaf_Node__c = true,
                                                Allocations_Per_Interval__c = 2)
                                           );
        lstBrandCountryRegionAllocation.add(new Brand_Country_Region_Allocation__c(
                                                Brand_Country_Allocation__c = brandCountryAllocation.Id,
                                                Region__c = lstRegion[2].Id)
                                           );
        
        insert lstBrandCountryRegionAllocation;
        
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name='Account 1', 
                                   BillingState = lstState[2].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name='Account 2', 
                                   BillingState = lstState[3].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name='Account 3', 
                                   BillingState = lstState[4].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name='Account 4', 
                                   BillingState = lstState[5].Name, 
                                   BillingCountry = country.Name)
                      );
        
        insert lstAccount;
        
        lstBrandCountryRegionStateAllocation = new List<Brand_Country_Region_State_Allocation__c>();
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                                                    State__c = lstState[0].Id,
                                                    Is_Leaf_Node__c = true,
                                                    Allocations_Per_Interval__c = 3)
                                                );
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                                                    State__c = lstState[1].Id,
                                                    Is_Leaf_Node__c = true,
                                                    Allocations_Per_Interval__c = 4)
                                                );
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[1].Id,
                                                    State__c = lstState[2].Id)
                                                );
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[1].Id,
                                                    State__c = lstState[3].Id)
                                                );
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[2].Id,
                                                    State__c = lstState[4].Id)
                                                );
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[2].Id,
                                                    State__c = lstState[5].Id)
                                                );
        
        insert lstBrandCountryRegionStateAllocation;
        
        distAllocs = [SELECT 
	                      Id, Is_Leaf_Node__c, Allocations_Per_Interval__c, Account__r.Name, Brand_Country_Region_State_Allocation__r.State__r.Id
                      FROM 
    	                  Brand_Country_Region_State_Dist_Alloc__c];
        
        for(Brand_Country_Region_State_Dist_Alloc__c allocation : distAllocs) {
            if(allocation.Account__r.Name == 'Account 3' || allocation.Account__r.Name == 'Account 4') {
            	allocation.Is_Leaf_Node__c = true;
	            allocation.Allocations_Per_Interval__c = 5;    
            }        
        }
        update distAllocs;
    }
    
    /**
    *  @description : This method is use to test transfer state with state allocation being leaf node.
    **/
    @IsTest
    public static void testTransferStateWithLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferState(lstState[0].Country__c, lstState[0].Id, lstState[0].Region__c, lstRegion[2].Id, null);
        List<Brand_Country_Region_Allocation__c> lstRegionAllocation = [SELECT 
                                                                        	Id, 
                                                                        	(SELECT 
                                                                             	Id 
                                                                             FROM 
                                                                             	Brand_Country_Region_State_Allocations__r
                                                                            ) 
                                                                        FROM 
                                                                        	Brand_Country_Region_Allocation__c 
                                                                        WHERE 
                                                                        	Region__c = :lstRegion[2].Id];
        State__c transferredState = [SELECT Id, Region__c FROM State__c WHERE IsActive__c = TRUE AND Name = :lstState[0].Name];
        Test.stopTest();
        System.assertEquals(transferredState.Region__c, lstRegion[2].Id);
        System.assert(lstRegionAllocation[0].Brand_Country_Region_State_Allocations__r.size() == 3);
    }
    
    /**
    *  @description : This method is use to test transfer state where new parent allocation is leaf node.
    **/
    @IsTest
    public static void testTransferStateWithRegionLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferState(lstState[0].Country__c, lstState[0].Id, lstState[0].Region__c, lstRegion[1].Id, null);
        List<Brand_Country_Region_Allocation__c> lstRegionAllocation = [SELECT Id, Allocations_Per_Interval__c FROM Brand_Country_Region_Allocation__c WHERE Region__c = :lstRegion[1].Id];
        State__c transferredState = [SELECT Id, Region__c FROM State__c WHERE IsActive__c = TRUE AND Name = :lstState[0].Name];
        Test.stopTest();
        System.assertEquals(transferredState.Region__c, lstRegion[1].Id);
        System.assert(lstRegionAllocation[0].Allocations_Per_Interval__c == 5);
    }
    
    /**
    *  @description : This method is use to test transfer state where 
    * 				  distributor allocation is leaf node & new parent region is leaf node.
    **/
    @IsTest
    public static void testTransferStateWithRegionAndDistributorLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferState(lstState[4].Country__c, lstState[4].Id, lstState[4].Region__c, lstRegion[1].Id, null);
        List<Brand_Country_Region_Allocation__c> lstRegionAllocation = [SELECT Id, Allocations_Per_Interval__c FROM Brand_Country_Region_Allocation__c WHERE Region__c = :lstRegion[1].Id];
        State__c transferredState = [SELECT Id, Region__c FROM State__c WHERE IsActive__c = TRUE AND Name = :lstState[4].Name];
        Test.stopTest();
        System.assertEquals(transferredState.Region__c, lstRegion[1].Id);
        System.assert(lstRegionAllocation[0].Allocations_Per_Interval__c == 7);
    }
    
    /**
    *  @description : This method is use to test transfer state where 
    * 				  distributor allocation is leaf node.
    **/
    @IsTest
    public static void testTransferStateWithDistributorLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferState(lstState[4].Country__c, lstState[4].Id, lstState[4].Region__c, lstRegion[0].Id, null);
        State__c transferredState = [SELECT Id, Region__c FROM State__c WHERE IsActive__c = TRUE AND Name = :lstState[4].Name];
        Test.stopTest();
        System.assertEquals(transferredState.Region__c, lstRegion[0].Id);
    }
    
    /**
    *  @description : This method is use to test transfer state where state allocation is not leaf node.
    **/
    @IsTest
    public static void testTransferStateWithoutLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferState(lstState[2].Country__c, lstState[2].Id, 
                                                                                     lstState[2].Region__c, lstRegion[1].Id, 
                                                                                     null);
        State__c transferredState = [SELECT 
                                     	Id, Region__c 
                                     FROM 
                                     	State__c 
                                     WHERE 
                                     	IsActive__c = TRUE 
                                     AND 
                                     	Name = :lstState[2].Name];
        Test.stopTest();
        System.assertEquals(transferredState.Region__c, lstRegion[1].Id);
    }
    
    /**
    *  @description : This method is use to test distributor transfer.
    **/
    @IsTest
    public static void testTransferDistributor() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributor = CNT_SB2_TransferHierarchy.getDistributors(lstState[3].Id);
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferDistributor(country.Id, distAllocs[0].Id, 
                                                                                           distAllocs[0].Brand_Country_Region_State_Allocation__r.State__r.Id, 
                                                                                           lstState[3].Id, null);
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocation = [SELECT 
                                                                             	Id, Allocations_Per_Interval__c,
                                                                             	(SELECT 
                                                                                 	Id 
                                                                                 FROM 
                                                                                 	Brand_Country_Region_State_Dist_Allocs__r
                                                                                ) 
                                                                             FROM 
                                                                             	Brand_Country_Region_State_Allocation__c 
                                                                             WHERE 
                                                                             	State__c = :lstState[3].Id];
        Test.stopTest();
        system.assert(lstStateAllocation[0].Brand_Country_Region_State_Dist_Allocs__r.size() == 2);
    }
    
    /**
    *  @description : This method is use to test distributor transfer where state's region is leaf node.
    **/
    @IsTest
    public static void testTransferDistributorWithRegionLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributor = CNT_SB2_TransferHierarchy.getDistributors(lstState[2].Id);
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferDistributor(country.Id, distAllocs[2].Id, distAllocs[2].Brand_Country_Region_State_Allocation__r.State__r.Id, lstState[2].Id, null);
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocation = [SELECT 
                                                                             	Id, Allocations_Per_Interval__c,
                                                                             	(SELECT 
                                                                                 	Id 
                                                                                 FROM 
                                                                                 	Brand_Country_Region_State_Dist_Allocs__r
                                                                                ) 
                                                                             FROM 
                                                                             	Brand_Country_Region_State_Allocation__c 
                                                                             WHERE 
                                                                             	State__c = :lstState[2].Id];
        Test.stopTest();
        system.assert(lstStateAllocation[0].Brand_Country_Region_State_Dist_Allocs__r.size() == 2);
    }
    
    /**
    *  @description : This method is use to test distributor transfer where state is leaf node.
    **/
    @IsTest
    public static void testTransferDistributorWithStateLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributor = CNT_SB2_TransferHierarchy.getDistributors(lstState[1].Id);
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferDistributor(country.Id, distAllocs[2].Id, distAllocs[2].Brand_Country_Region_State_Allocation__r.State__r.Id, lstState[1].Id, null);
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocation = [SELECT 
                                                                             	Id, Allocations_Per_Interval__c,
                                                                             	(SELECT 
                                                                                 	Id 
                                                                                 FROM 
                                                                                 	Brand_Country_Region_State_Dist_Allocs__r
                                                                                ) 
                                                                             FROM 
                                                                             	Brand_Country_Region_State_Allocation__c 
                                                                             WHERE 
                                                                             	State__c = :lstState[1].Id];
        Test.stopTest();
        system.assert(lstStateAllocation[0].Allocations_Per_Interval__c == 9);
        system.assert(lstStateAllocation[0].Brand_Country_Region_State_Dist_Allocs__r.size() == 1);
    }
    
    /**
    *  @description : This method is use to test distributor transfer where distributor is leaf node.
    **/
    @IsTest
    public static void testTransferDistributorWithLeafNode() {
        prepareData();
        Test.startTest();
        Map<String, Object> hierarchicalData = CNT_SB2_TransferHierarchy.getHierarchicalData();
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributor = CNT_SB2_TransferHierarchy.getDistributors(lstState[4].Id);
        Map<String, String> transferResult = CNT_SB2_TransferHierarchy.transferDistributor(country.Id, distAllocs[3].Id, distAllocs[3].Brand_Country_Region_State_Allocation__r.State__r.Id, lstState[4].Id, null);
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocation = [SELECT 
                                                                             	Id, Allocations_Per_Interval__c,
                                                                             	(SELECT 
                                                                                 	Id 
                                                                                 FROM 
                                                                                 	Brand_Country_Region_State_Dist_Allocs__r
                                                                                ) 
                                                                             FROM 
                                                                             	Brand_Country_Region_State_Allocation__c 
                                                                             WHERE 
                                                                             	State__c = :lstState[4].Id];
        Test.stopTest();
        system.assert(lstStateAllocation[0].Brand_Country_Region_State_Dist_Allocs__r.size() == 2);
    }
}