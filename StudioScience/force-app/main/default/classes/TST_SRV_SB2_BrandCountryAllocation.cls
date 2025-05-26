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
    @description This test class is created to test service method of Brand Country Allocation.
*/
@isTest(seeAllData = false)
public class TST_SRV_SB2_BrandCountryAllocation {

    public static Brand_Allocation__c brandAllocation;
    public static Country__c country;
    
    /**
    *  @description : This method is use to prepare test data.
    **/
    public static void prepareData(){
        List<Brand__c> lstBrand = TST_SB2_MasterDataFactory.createBrand();
        
        brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Name = 'JB~Sam~2020~Apr';
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        
        insert brandAllocation;
        
        country = TST_SB2_MasterDataFactory.createCountry();
    }

    /**
    *  @description : This method is use to check duplicate record.
    **/
    @isTest
    public static void checkDuplicatedRecord() {
        prepareData();
        Test.startTest();
        Brand_Country_Allocation__c allocation = new Brand_Country_Allocation__c();
        allocation.Country__c = country.Id;
        allocation.Brand_Allocation__c = brandAllocation.Id;
        allocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        insert allocation;

        Brand_Country_Allocation__c duplicateAllocation = new Brand_Country_Allocation__c();
        duplicateAllocation.Country__c = country.Id;
        duplicateAllocation.Brand_Allocation__c = brandAllocation.Id;
        duplicateAllocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
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
        
        Brand_Country_Allocation__c allocation = new Brand_Country_Allocation__c();
        allocation.Country__c = country.Id;
        allocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        allocation.Brand_Allocation__c = brandAllocation.Id;
        allocation.Is_Leaf_Node__c = true;

        Database.SaveResult result = Database.insert(allocation, false);

        Test.stopTest();

        System.assertEquals(Label.Mandatory_Allocation_Message_for_Leaf_Node, result.errors[0].message);
    }
 	
    /**
    *  @description : This method is use to check allocation should more than 0 for leaf node.
    **/
    // @isTest
    // public static void checkAllocationProvidedForLeafNodeAllocationMoreThanZero() {
    //     prepareData();
    //     Test.startTest();
        
    //     Brand_Country_Allocation__c allocation = new Brand_Country_Allocation__c();
    //     allocation.Country__c = country.Id;
    //     allocation.Brand_Allocation__c = brandAllocation.Id;
    //     allocation.Is_Leaf_Node__c = true;
    //     allocation.Allocations_Per_Interval__c = 0;

    //     Database.SaveResult result = Database.insert(allocation, false);

    //     Test.stopTest();

    //     System.assertEquals(Label.Minimum_Allocation_Error_Message, result.errors[0].message);
    // }
    
    /**
    *  @description : This method is use to check allocation cascade up successfully.
    **/
    @isTest
    public static void cascadeUpAllocation() {
        prepareData();
        Test.startTest();
        
        Brand_Country_Allocation__c allocation = new Brand_Country_Allocation__c();
        allocation.Name = brandAllocation.Name + SB2_Constants.SEPERATOR + country.Alias__c;
        allocation.Country__c = country.Id;
        allocation.Brand_Allocation__c = brandAllocation.Id;
        allocation.Is_Leaf_Node__c = true;
        allocation.Allocations_Per_Interval__c = 2;

        Database.SaveResult result = Database.insert(allocation, false);

        Brand_Allocation__c updatedBrandAlloction = [SELECT Allocation_Per_Interval__c FROM Brand_Allocation__c WHERE Id = :brandAllocation.Id];
        
        Test.stopTest();

        System.assertEquals(2, updatedBrandAlloction.Allocation_Per_Interval__c);
    }

}