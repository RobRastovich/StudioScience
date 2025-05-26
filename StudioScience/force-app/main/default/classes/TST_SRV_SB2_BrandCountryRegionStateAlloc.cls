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
    @description This test class is created to test service method of Brand Country Region State Allocation.
*/
@isTest(seeAllData = false)
public class TST_SRV_SB2_BrandCountryRegionStateAlloc {
    
    public static Brand_Allocation__c brandAllocation;
    public static Brand_Country_Allocation__c brandCountryAllocation;
    public static List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation;
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
        
        brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Name = 'JB~Sam~2020~Apr';
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        
        insert brandAllocation;
        
        brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
        brandCountryAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        
        insert brandCountryAllocation;
        
        lstBrandCountryRegionAllocation = new List<Brand_Country_Region_Allocation__c>();
        
        lstBrandCountryRegionAllocation.add(new Brand_Country_Region_Allocation__c(
									            Name = 'Region Allocation 1',
                                                Brand_Country_Allocation__c = brandCountryAllocation.Id,
                                                Region__c = lstRegion[0].Id)
                                           );
        
        lstBrandCountryRegionAllocation.add(new Brand_Country_Region_Allocation__c(
									            Name = 'Region Allocation 2',
                                                Brand_Country_Allocation__c = brandCountryAllocation.Id,
                                                Region__c = lstRegion[1].Id,
                                                Is_Leaf_Node__c = true,
                                                Allocations_Per_Interval__c = 2)
                                           );

        insert lstBrandCountryRegionAllocation;
        
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name = 'Account 1', 
                                   BillingState = lstState[0].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name = 'Account 2', 
                                   BillingState = lstState[0].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name = 'Account 3', 
                                   BillingState = lstState[1].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name = 'Account 4', 
                                   BillingState = lstState[1].Name, 
                                   BillingCountry = country.Name)
                      );
                      
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name = 'Account 5', 
                                   BillingState = lstState[2].Name, 
                                   BillingCountry = country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name = 'Account 6', 
                                   BillingState = lstState[3].Name, 
                                   BillingCountry = country.Name)
                      );

        insert lstAccount;
    }
    
	/**
    *  @description : This method is use to check duplicate record.
    **/
    @isTest
    public static void checkDuplicatedRecord() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Region_State_Allocation__c allocation = new Brand_Country_Region_State_Allocation__c();
        allocation.State__c = lstState[0].Id;
        allocation.Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id;
        allocation.Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[0].Alias__c;
        
        insert allocation;

        Brand_Country_Region_State_Allocation__c duplicateAllocation = new Brand_Country_Region_State_Allocation__c();
        duplicateAllocation.State__c = lstState[0].Id;
        duplicateAllocation.Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id;
        duplicateAllocation.Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[0].Alias__c;
        
        Database.SaveResult result = Database.insert(duplicateAllocation, false);
        
        Test.stopTest();

        System.assertEquals(Label.Allocation_Duplicate_Message, result.errors[0].message);
    }
    
    /**
    *  @description : This method is use to check allocation should be provided for leaf node.
    **/
    @isTest
    public static void checkAllocationProvidedForLeafNodeMandatory() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Region_State_Allocation__c allocation = new Brand_Country_Region_State_Allocation__c();
        allocation.State__c = lstState[0].Id;
        allocation.Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id;
        allocation.Allocations_Per_Interval__c = null;
        allocation.Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[0].Alias__c;
        allocation.Is_Leaf_Node__c = true;

        Database.SaveResult result = Database.insert(allocation, false);

        Test.stopTest();

        System.assertEquals(Label.Mandatory_Allocation_Message_for_Leaf_Node, result.errors[0].message);
    }
    
    /**
    *  @description : This method is use to check allocation cascade up successfully.
    **/
    @isTest
    public static void cascadeUpAllocation() {
        prepareData();
        Test.startTest();
        
        List<Brand_Country_Region_State_Allocation__c> lstAllocation = new List<Brand_Country_Region_State_Allocation__c>();
        
        lstAllocation.add(new Brand_Country_Region_State_Allocation__c(
            				Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[0].Alias__c,
                            Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                            State__c = lstState[0].Id,
                            Is_Leaf_Node__c = true,
                            Allocations_Per_Interval__c = 3)
                         );
        
        lstAllocation.add(new Brand_Country_Region_State_Allocation__c(
            				Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[1].Alias__c,
				            Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,	
                            State__c = lstState[1].Id,
                            Is_Leaf_Node__c = true,
                            Allocations_Per_Interval__c = 4)
                         );
        
        lstAllocation.add(new Brand_Country_Region_State_Allocation__c(
                        	Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[2].Alias__c,
                            Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                            State__c = lstState[2].Id,
                            Is_Leaf_Node__c = true,
                            Allocations_Per_Interval__c = 5)
                         );
        
        lstAllocation.add(new Brand_Country_Region_State_Allocation__c(
							Name = lstBrandCountryRegionAllocation[0].Name + SB2_Constants.SEPERATOR + lstState[3].Alias__c,
                            Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                            State__c = lstState[3].Id,
                            Is_Leaf_Node__c = true,
                            Allocations_Per_Interval__c = 6)
                         );

        insert lstAllocation;
        
        Brand_Country_Region_Allocation__c updatedBrandCountryRegionAllocation = [SELECT
                                                                                  	Allocations_Per_Interval__c
                                                                                  FROM
                                                                                  	Brand_Country_Region_Allocation__c
                                                                                  WHERE
                                                                                  	Id = :lstBrandCountryRegionAllocation[0].Id];

        Brand_Country_Allocation__c updatedBrandCountryAllocation = [SELECT 
                                                                     	Allocations_Per_Interval__c 
                                                                     FROM 
                                                                        Brand_Country_Allocation__c 
                                                                     WHERE 
                                                                        Id = :brandCountryAllocation.Id];
        Brand_Allocation__c updatedBrandAlloction = [SELECT 
                                                     	Allocation_Per_Interval__c 
                                                     FROM 
                                                     	Brand_Allocation__c 
                                                     WHERE 
                                                     	Id = :brandCountryAllocation.Brand_Allocation__c];
        
        Test.stopTest();

        System.assertEquals(18, updatedBrandCountryRegionAllocation.Allocations_Per_Interval__c);
        System.assertEquals(20, updatedBrandCountryAllocation.Allocations_Per_Interval__c);
        System.assertEquals(20, updatedBrandAlloction.Allocation_Per_Interval__c);
    }
    
    /**
    *  @description : This method is use to check distributor allocation records created successfully.
    **/
    @isTest
    public static void createDistributorAllocationRecords(){
        prepareData();
        Test.startTest();
        List<Brand_Country_Region_State_Allocation__c> allocation = new List<Brand_Country_Region_State_Allocation__c>();
        allocation.add(new Brand_Country_Region_State_Allocation__c(
                            State__c = lstState[0].Id, 
                            Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id)
                      );

		allocation.add(new Brand_Country_Region_State_Allocation__c(
                            State__c = lstState[1].Id, 
                            Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id)
                      );
        
        insert allocation;
        
        List<Brand_Country_Region_State_Dist_Alloc__c> distAllocs = [Select Id From Brand_Country_Region_State_Dist_Alloc__c];
        Test.stopTest();
        
        System.assertEquals(4, distAllocs.size());
    }
    
    /**
    *  @description : This method is use to check updated records get updated for allocation report object as well.
    **/
    @isTest
    public static void testUpsertIntoAllocationRecord(){
        prepareData();
        
        Test.startTest();
        
        Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
        stateAllocation.State__c = lstState[0].Id;
        stateAllocation.Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id;
        stateAllocation.Is_Leaf_Node__c = TRUE;
        stateAllocation.Allocations_Per_Interval__c = 5;        
        insert stateAllocation;
        
        Allocation_Report__c afterInsertRecord = [Select Id, Barrels_Allocated__c, Barrels_Used__c FROM Allocation_Report__c Where State_Allocation__c != null];
        
        stateAllocation.Used_Allocations__c = 1;
        
        update stateAllocation;
        
        Allocation_Report__c afterUpdateRecord = [Select Id, Barrels_Allocated__c, Barrels_Used__c FROM Allocation_Report__c Where State_Allocation__c != null];
        
        Test.stopTest();
        
        System.assertEquals(5, afterInsertRecord.Barrels_Allocated__c);
        System.assertEquals(0, afterInsertRecord.Barrels_Used__c);
        System.assertEquals(5, afterUpdateRecord.Barrels_Allocated__c);
        System.assertEquals(1, afterUpdateRecord.Barrels_Used__c);
    }
    
    /**
    *  @description : This method is use to check the distributor allocation recrod will marked as inactive by marking the state allocation record inactive.
    **/
    @isTest
    public static void testUpdateRespectiveDistributorAllocation(){
        prepareData();
        
        Test.startTest();
        
        Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
        stateAllocation.State__c = lstState[0].Id;
        stateAllocation.Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id;
        stateAllocation.Is_Leaf_Node__c = TRUE;
        stateAllocation.Allocations_Per_Interval__c = 5;        
        insert stateAllocation;
        
        stateAllocation.Is_Active__c = false;
        update stateAllocation;
        
        Test.stopTest();
        
        for(Brand_Country_Region_State_Dist_Alloc__c distributorAllocation : [Select Id, Is_Active__c From Brand_Country_Region_State_Dist_Alloc__c]) {
            system.assert(!distributorAllocation.Is_Active__c);
        }
    }
}