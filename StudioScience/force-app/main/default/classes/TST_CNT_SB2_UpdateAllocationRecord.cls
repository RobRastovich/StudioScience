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
public class TST_CNT_SB2_UpdateAllocationRecord {
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
        List<Account> lstAccount = new List<Account>();
        Account newAccount = new Account();
        newAccount.Name = 'test';
        newAccount.RecordTypeId = [SELECT Id from RecordType where DeveloperName = 'Distributor' and SobjectType = 'Account' limit 1].Id;
        lstAccount.add(newAccount);
        insert lstAccount;
        
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>{
            TST_SB2_MasterDataFactory.createBrandCountryRegionStateDistAlloc(lstStateAlloc[0].Id, lstAccount[0].Id, 
                                                                             true, 2)
                };
                    insert lstDistAlloc;
        
    }
    
    /**
    *  @description : This method is use to test GetBrandAllocation() to get result.
    **/
    @isTest
    public static void testUpdateDistributorAllocation(){
		String recordId = [SELECT Id FROM Brand_Country_Region_State_Dist_Alloc__c limit 1].Id;
        
        Test.startTest();
        	Map<String, Object> result = CNT_SB2_UpdateAllocationRecord.updateDistributorAllocation(recordId, 5);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Distrubtor is update with new allocation');
    }
    
    /**
    *  @description : This method is use to test GetBrandAllocation() to get result.
    **/
    @isTest
    public static void testUpdateStateAllocation(){
		String recordId = [SELECT Id FROM Brand_Country_Region_State_Allocation__c limit 1].Id;
        
        Test.startTest();
        	Map<String, Object> result = CNT_SB2_UpdateAllocationRecord.updateStateAllocation(recordId, 5);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'State is update with new allocation');
    }
    
    /**
    *  @description : This method is use to test GetBrandAllocation() to get result.
    **/
    @isTest
    public static void testUpdateRegionAllocation(){
		String recordId = [SELECT Id FROM Brand_Country_Region_Allocation__c limit 1].Id;
        
        Test.startTest();
        	Map<String, Object> result = CNT_SB2_UpdateAllocationRecord.updateRegionAllocation(recordId, 5);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Region is update with new allocation');
    }
    
    /**
    *  @description : This method is use to test GetBrandAllocation() to get result.
    **/
    @isTest
    public static void testUpdateCountryAllocation(){
		String recordId = [SELECT Id FROM Brand_Country_Allocation__c limit 1].Id;
        
        Test.startTest();
        	Map<String, Object> result = CNT_SB2_UpdateAllocationRecord.updateCountryAllocation(recordId, 5);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Country is update with new allocation');
    }
}