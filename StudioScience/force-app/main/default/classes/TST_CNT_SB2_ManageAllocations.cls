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
    @date 15/05/2020
    @description This test class is created to test CNT_SB2_ManageAllocations.
*/
@IsTest(seeAllData = false)
public class TST_CNT_SB2_ManageAllocations {

    public static List<Brand_Allocation__c> lstBrandAllocation;
    public static Brand_Country_Allocation__c brandCountryAllocation;
    public static List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation;
    public static List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation;
    public static List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAlloc;
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
        List<String> lstYear = new List<String> {'2021','2022','2023','2024','2025'};
        for(Brand__c brand : lstBrand) {
            Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
            brandAllocation.Brand__c = brand.Id;
            brandAllocation.Is_Active__c = true;
            brandAllocation.Program_Type__c = 'Sample Kit';
            brandAllocation.Time_Period__c = 'Monthly';
            brandAllocation.Time_Interval__c = 'April';
            brandAllocation.Year_Of_Allocation__c = lstYear.get(0);
            lstBrandAllocation.add(brandAllocation);
        }
        
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

        insert lstBrandCountryRegionAllocation;

        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name='Account 1', 
                                   BillingState = lstState[2].Name, 
                                   BillingCountry=country.Name)
                      );
        lstAccount.add(new Account(RecordTypeId = rtId, 
                                   Name='Account 2', 
                                   BillingState = lstState[3].Name, 
                                   BillingCountry=country.Name)
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
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                                                    State__c = lstState[2].Id)
                                                );
        
        lstBrandCountryRegionStateAllocation.add(new Brand_Country_Region_State_Allocation__c(
                                                    Brand_Country_Region_Allocation__c = lstBrandCountryRegionAllocation[0].Id,
                                                    State__c = lstState[3].Id)
                                                );

        insert lstBrandCountryRegionStateAllocation;

        List<Brand_Country_Region_State_Dist_Alloc__c> distAllocs = [SELECT 
                                                                        Id, Is_Leaf_Node__c, Allocations_Per_Interval__c
                                                                    FROM 
                                                                        Brand_Country_Region_State_Dist_Alloc__c];

        for(Brand_Country_Region_State_Dist_Alloc__c allocation : distAllocs) {
            allocation.Is_Leaf_Node__c = true;
            allocation.Allocations_Per_Interval__c = 5;
        }

        update distAllocs;

    }

    /**
    *  @description : This method is use to test modify allocation record creation.
    **/
    @isTest
    static void testModifyAllocation() {
        Test.startTest();

        prepareData();
        List<String> lstYear = new List<String> {'2021','2022','2023','2024','2025'};
        Map<String, Object> brandAllocationData = CNT_SB2_ManageAllocations.getBrandAndCountryAllocationData(lstYear.get(0));
        List<SObject> fromAllocations = CNT_SB2_ManageAllocations.getAllocationData('Brand_Country_Region_Allocation__c', lstBrandAllocation[0].Id, brandCountryAllocation.Id);
        
        Allocation_Logger__c logger = new Allocation_Logger__c();
        logger.Change_Type__c = 'Modify';
        logger.Brand_Allocation__c = lstBrandAllocation[0].Id;
        logger.From_Region_Allocation__c = fromAllocations[0].Id;
        logger.Allocation_Changed__c = 5;
        logger.Transfer_Modification_Reason__c = 'Test reason';
        logger.From_Original_Allocation__c = Integer.valueOf(fromAllocations[0].get('Allocations_Per_Interval__c'));

        Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
        regionAllocation.Id = fromAllocations[0].Id;
        regionAllocation.Allocations_Per_Interval__c = logger.Allocation_Changed__c;

        String allocationId = CNT_SB2_ManageAllocations.createLoggerRecord(logger, regionAllocation, null);
        
        Test.stopTest();

        System.assert(allocationId != null);
        
    }

    /**
    *  @description : This method is use to test transfer allocation record creation.
    **/
    @isTest
    static void testTransferAllocation() {
        Test.startTest();

        prepareData();
        List<String> lstYear = new List<String> {'2021','2022','2023','2024','2025'};
        Map<String, Object> brandAllocationData = CNT_SB2_ManageAllocations.getBrandAndCountryAllocationData(lstYear.get(0));
        List<SObject> fromAllocations = CNT_SB2_ManageAllocations.getAllocationData('Brand_Country_Region_Allocation__c', lstBrandAllocation[0].Id, brandCountryAllocation.Id);
        List<SObject> toAllocations = CNT_SB2_ManageAllocations.getAllocationData('Brand_Country_Region_State_Allocation__c', lstBrandAllocation[0].Id, brandCountryAllocation.Id);
        
        Allocation_Logger__c logger = new Allocation_Logger__c();
        logger.Change_Type__c = 'Transfer';
        logger.Brand_Allocation__c = lstBrandAllocation[0].Id;
        logger.From_Region_Allocation__c = fromAllocations[0].Id;
        logger.To_State_Allocation__c = toAllocations[0].Id;
        logger.Allocation_Changed__c = 1;
        logger.Transfer_Modification_Reason__c = 'Test reason';
        logger.From_Original_Allocation__c = Integer.valueOf(fromAllocations[0].get('Allocations_Per_Interval__c'));

        Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
        regionAllocation.Id = fromAllocations[0].Id;
        regionAllocation.Allocations_Per_Interval__c = Integer.valueOf(fromAllocations[0].get('Allocations_Per_Interval__c')) - logger.Allocation_Changed__c;

        Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
        stateAllocation.Id = toAllocations[0].Id;
        stateAllocation.Allocations_Per_Interval__c = Integer.valueOf(toAllocations[0].get('Allocations_Per_Interval__c')) + logger.Allocation_Changed__c;

        String allocationId = CNT_SB2_ManageAllocations.createLoggerRecord(logger, regionAllocation, stateAllocation);
        
        Test.stopTest();

        System.assert(allocationId != null);
        
    }

    /**
    *  @description : This method is use to test exception case for create logger record.
    **/
    @isTest
    static void testCreateLoggerRecordException() {
        try {
            Test.startTest();
        
            Allocation_Logger__c logger = new Allocation_Logger__c();
            logger.Change_Type__c = 'Transfer';
            CNT_SB2_ManageAllocations.createLoggerRecord(logger, null, null);
            
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
        
    }

}