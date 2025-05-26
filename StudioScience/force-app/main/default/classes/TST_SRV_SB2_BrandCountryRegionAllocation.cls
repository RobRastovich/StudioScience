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
    @date 03/05/2020
    @description This test class is created to test service method of Brand Country Region Allocation.
*/
@isTest(seeAllData = false)
public class TST_SRV_SB2_BrandCountryRegionAllocation {
    
    public static Brand_Country_Allocation__c brandCountryAllocation;
    public static List<Region__c> lstRegion;
    
    /**
    *  @description : This method is use to prepare test data.
    **/
    public static void prepareData(){
        List<Brand__c> lstBrand = TST_SB2_MasterDataFactory.createBrand();
        
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
		brandAllocation.Name = 'JB~Sam~2020~Apr';
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        
        insert brandAllocation;
     
        Country__c country = TST_SB2_MasterDataFactory.createCountry();
        
        brandCountryAllocation = new Brand_Country_Allocation__c();
        brandCountryAllocation.Country__c = country.Id;
        brandCountryAllocation.Brand_Allocation__c = brandAllocation.Id;
        
        insert brandCountryAllocation;
        
        lstRegion = TST_SB2_MasterDataFactory.createRegion(country);
    }
    
    /**
    *  @description : This method is use to check duplicate record.
    **/
    @isTest
    public static void checkDuplicatedRecord() {
        prepareData();
        Test.startTest();
        Brand_Country_Region_Allocation__c allocation = new Brand_Country_Region_Allocation__c();
        allocation.Region__c = lstRegion[0].Id;
        allocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        insert allocation;

        Brand_Country_Region_Allocation__c duplicateAllocation = new Brand_Country_Region_Allocation__c();
        duplicateAllocation.Region__c = lstRegion[0].Id;
        duplicateAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        duplicateAllocation.Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + lstRegion[0].Name;
        
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
        
        Brand_Country_Region_Allocation__c allocation = new Brand_Country_Region_Allocation__c();
        allocation.Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + lstRegion[0].Name;      
        allocation.Region__c = lstRegion[0].Id;
        allocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        allocation.Allocations_Per_Interval__c = null;
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
        
        List<Brand_Country_Region_Allocation__c> lstAllocation = new List<Brand_Country_Region_Allocation__c>();
        
        lstAllocation.add(new Brand_Country_Region_Allocation__c(
            				Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + lstRegion[0].Name,
                            Brand_Country_Allocation__c = brandCountryAllocation.Id,
                            Region__c = lstRegion[0].Id,
                            Is_Leaf_Node__c = true,
                            Allocations_Per_Interval__c = 2)
                         );
        
        lstAllocation.add(new Brand_Country_Region_Allocation__c(
                    		Name = brandCountryAllocation.Name + SB2_Constants.SEPERATOR + lstRegion[1].Name,
                            Brand_Country_Allocation__c = brandCountryAllocation.Id,
                            Region__c = lstRegion[1].Id,
                            Is_Leaf_Node__c = true,
                            Allocations_Per_Interval__c = 2)
                         );

        insert lstAllocation;

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

        System.assertEquals(4, updatedBrandCountryAllocation.Allocations_Per_Interval__c);
        System.assertEquals(4, updatedBrandAlloction.Allocation_Per_Interval__c);
    }
    
    /**
    *  @description : This method is use to check updated records get updated for allocation report object as well.
    **/
    @isTest
    public static void testUpsertIntoAllocationRecord() {
        prepareData();
        
        Test.startTest();
        
        Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
        regionAllocation.Brand_Country_Allocation__c = brandCountryAllocation.Id;
        regionAllocation.Region__c = lstRegion[0].Id;
        regionAllocation.Is_Leaf_Node__c = true;
        regionAllocation.Allocations_Per_Interval__c = 2;
        
        insert regionAllocation;

        Allocation_Report__c afterInsertRecord = [Select Id, Barrels_Allocated__c, Barrels_Used__c, Region_Allocation__c FROM Allocation_Report__c];
        
        regionAllocation.Used_Allocations__c = 1;
        
        update regionAllocation;
        
        Allocation_Report__c afterUpdateRecord = [Select Id, Barrels_Allocated__c, Barrels_Used__c, Region_Allocation__c FROM Allocation_Report__c];
        
        Test.stopTest();
        
        System.assertEquals(2, afterInsertRecord.Barrels_Allocated__c);
        System.assertEquals(0, afterInsertRecord.Barrels_Used__c);
        System.assertEquals(2, afterUpdateRecord.Barrels_Allocated__c);
        System.assertEquals(1, afterUpdateRecord.Barrels_Used__c);

    }
}