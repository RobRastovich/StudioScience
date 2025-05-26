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
    @date 24/06/2020
    @description This test class is created to test CNT_SB2_Lookup.
*/
@IsTest(seeAllData = false)
public class TST_CNT_SB2_Lookup {
    
    /**
    *  @description : This method is use to prepare test data.
    **/
    @TestSetup
    public static void prepareData(){
        Country__c country = TST_SB2_MasterDataFactory.createCountry();
        List<Region__c> lstRegion = TST_SB2_MasterDataFactory.createRegion(country);
        List<State__c> lstState = TST_SB2_MasterDataFactory.createState(country, lstRegion);
        List<Brand__c> lstBrand = TST_SB2_MasterDataFactory.createBrand();
        List<Brand_Allocation__c>lstBrandAllocation = new List<Brand_Allocation__c>();
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
                Year_Of_Allocation__c = Date.today().year()  + ''
            )
        );
        
        insert lstBrandAllocation;
        
        Brand_Country_Allocation__c brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = lstBrandAllocation[0].Id;
        
        insert brandCountryAllocation;
        
        List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation = new List<Brand_Country_Region_Allocation__c>();
        
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
        
        List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation = new List<Brand_Country_Region_State_Allocation__c>();
        
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
        
        List<Brand_Country_Region_State_Dist_Alloc__c> distAllocs = [SELECT 
                                                                     Id, Is_Leaf_Node__c, Allocations_Per_Interval__c, 
                                                                     Account__r.Name, Brand_Country_Region_State_Allocation__r.State__r.Id
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
    *  @description : This method is use to test getFieldLabel method.
    **/
    @IsTest
    public static void testGetFieldLabel() {
        String fieldLabel = CNT_SB2_Lookup.getFieldLabel('Brand_Country_Allocation__c', 'Country__c');
        System.assertEquals('Country', fieldLabel);
    }
    
    /**
    *  @description : This method is use to test getRecords method.
    **/
    @IsTest
    public static void testGetRecords() {
        String filters = '[{"field": "Is_Active__c", "operator":"=", "stringWrap": false, "value": true}, {"type": "operator", "value": "AND"},  {"field": "Program_Type__c", "operator":"!=", "value": null}]';
        List<SObject> lstRecords = CNT_SB2_Lookup.getRecords('Brand_Country_Allocation__c', 'Brand_Allocation__c', 'Name', 'Program_Type__c', null, filters, null, false);
        System.assert(lstRecords.size() > 0);
    }
    
    /**
    *  @description : This method is use to test getRecords method exception case.
    **/
    @IsTest
    public static void testGetRecordsExcepton() {
        try {
        	String filters = '[{"field": "IsActive__c", "operator":"=", "stringWrap": false, "value": true}, {"type": "operator", "value": "AND"},  {"field": "Program_Type__c", "operator":"!=", "value": null}]';
            List<SObject> lstRecords = CNT_SB2_Lookup.getRecords('Brand_Country_Allocation__c', 'Brand_Allocation__c', 'Name', 'Program_Type__c', 'U', filters, null, false);
        } catch(Exception e) {
            system.assert(e.getMessage() != null);
        }
    }
    
    /**
    *  @description : This method is use to test getRecords method with multiple search fields.
    **/
    @IsTest
    public static void testGetRecordsWithMultipleSearchFields() {
        String filters = '[{"field": "Is_Active__c", "operator":"=", "stringWrap": false, "value": true}]';
        List<SObject> lstRecords = CNT_SB2_Lookup.getRecords('Brand_Country_Allocation__c', 'Brand_Allocation__c', 'Name', 'Program_Type__c', null, filters, new List<String>{'Time_Period__c', 'Time_Interval__c'}, true);
        System.assert(lstRecords.size() > 0);
    }
    
    /**
    *  @description : This method is use to test getRecords method with record type filter.
    **/
    @IsTest
    public static void testGetRecordsWithRecordType() {
        String filters = '[{"field": "RecordType.Name", "operator":"=", "value": "Distributor"}]';
        List<SObject> lstRecords = CNT_SB2_Lookup.getRecords('Brand_Country_Region_State_Dist_Alloc__c', 'Account__c', 'Name', null, 'U', filters, null, false);
        System.assert(lstRecords.size() > 0);
    }
    
    /**
    *  @description : This method is use to test getRecordsById.
    **/
    @IsTest
    public static void testGetRecordsById() {
        String recordId = [SELECT Id FROM Brand_Allocation__c LIMIT 1].Id;
        SObject record = CNT_SB2_Lookup.getRecordById('Brand_Country_Allocation__c', 'Brand_Allocation__c', 'Name', 'Program_Type__c', new List<String>{'Time_Interval__c'}, recordId);
        System.assert(record != null);
    }
    
    /**
    *  @description : This method is use to test getRecordsById exception case.
    **/
    @IsTest
    public static void testGetRecordsByIdException() {
        try {
            String recordId = [SELECT Id FROM Brand_Allocation__c LIMIT 1].Id;
            SObject record = CNT_SB2_Lookup.getRecordById('Brand_Country_Allocation__c', ' Brand_Allocation__c', 'Name', 'Program_Type__c', new List<String>{'Time_Interval__c'}, recordId);
        } catch(Exception e) {
            system.assert(e.getMessage() != null);
        } 
    }
    
    /**
    *  @description : This method is use to test getRecordsById null check.
    **/
    @IsTest
    public static void testGetRecordsByIdNullCheck() {
        String recordId = [SELECT Id FROM Brand_Allocation__c LIMIT 1].Id;
        SObject record = CNT_SB2_Lookup.getRecordById('Brand_Allocation__c', 'Brand__c', 'Name', 'Program_Type__c', new List<String>{'Time_Interval__c'}, recordId);
        system.assert(record == null);
    }
}