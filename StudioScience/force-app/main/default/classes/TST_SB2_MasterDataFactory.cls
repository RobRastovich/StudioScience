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
    @description This test class is created to create master data for Brand, Country, Region, State.
*/
@isTest(seeAllData = false)
public class TST_SB2_MasterDataFactory {

    /**
    *  @description : This method is use to create record of Brand
    *  @return      : List<Brand__c>
    **/
    public static List<Brand__c> createBrand() {
        List<Brand__c> lstBrand = new List<Brand__c>();
        
        lstBrand.add(new Brand__c(Name = 'Jim Beam'));
        lstBrand.add(new Brand__c(Name = 'Knob Creek'));
        
        insert lstBrand;

        return lstBrand;
    }

    /**
    *  @description : This method is use to create record of Country
    *  @return      : Country
    **/
    public static Country__c createCountry() {
        Country__c country = new Country__c(Name = 'US', Alias__c = 'US');
        
        insert country;
        
        return country;
    }

    /**
    *  @description : This method is use to create record of Region
    *  @args        : Country__c country
    *  @return      : List<Region__c>
    **/
    public static List<Region__c> createRegion(Country__c country) {
        List<Region__c> lstRegion = new List<Region__c>();
        
        lstRegion.add(new Region__c(Name = 'East', Country__c = country.Id));
        lstRegion.add(new Region__c(Name = 'West', Country__c = country.Id));
        lstRegion.add(new Region__c(Name = 'North', Country__c = country.Id));
        
        insert lstRegion;

        return lstRegion;
    }

    /**
    *  @description : This method is use to create record of state
    *  @args        : Country__c country, List<Region__c> lstRegion
    *  @return      : List<State__c>
    **/
    public static List<State__c> createState(Country__c country, List<Region__c> lstRegion) {
        List<State__c> lstState = new List<State__c>();
        
        if(lstRegion != null) {
            if(lstRegion.size() > 0) {
                lstState.add(new State__c(Name = 'New York', Country__c = country.Id, Region__c = lstRegion[0].Id, Alias__c = 'NY', State_Manager__c = UserInfo.getUserId()));
                lstState.add(new State__c(Name = 'New Jersey', Country__c = country.Id, Region__c = lstRegion[0].Id, Alias__c = 'NJ', State_Manager__c = UserInfo.getUserId()));
            }
            if(lstRegion.size() > 1) {
                lstState.add(new State__c(Name = 'Ohio', Country__c = country.Id, Region__c = lstRegion[1].Id, Alias__c = 'OH', State_Manager__c = UserInfo.getUserId()));
                lstState.add(new State__c(Name = 'Iowa', Country__c = country.Id, Region__c = lstRegion[1].Id, Alias__c = 'IA', State_Manager__c = UserInfo.getUserId()));
            }
            if(lstRegion.size() > 2) {
                lstState.add(new State__c(Name = 'Florida', Country__c = country.Id, Region__c = lstRegion[2].Id, Alias__c = 'FL', State_Manager__c = UserInfo.getUserId()));
                lstState.add(new State__c(Name = 'Texas', Country__c = country.Id, Region__c = lstRegion[2].Id, Alias__c = 'TX', State_Manager__c = UserInfo.getUserId()));
            }
        }

        insert lstState;

        return lstState;
    }
    
    /**
    *  @description : This method is use to create distributor account record
    *  @args		: Integer numberOfRecords
    *  @return      : List<Account>
    **/
    public static List<Account> createDistributorAccount(Integer numberOfRecords) {
        List<Account> lstAccount = new List<Account>();
        for(Integer i = 1; i <= numberOfRecords; i++) {
            lstAccount.add(new Account(RecordTypeId = CSConstants.DEFAULT_ACCOUNT_RT_ID, Name = 'Account ' + i));
        }
        insert lstAccount;

        return lstAccount;
    }
    
    /**
    *  @description : This method is use to create distributor account record
    *  @args		: Integer numberOfRecords
    *  @return      : List<Brand_Allocation__c>
    **/
    public static Brand_Allocation__c createBrandAlloc(String BrandId, String programType, String YearOfAlloc,
                                                                    String timePeriod, String timeInterval) {
        Brand_Allocation__c newBrandAlloc = new Brand_Allocation__c(Brand__c = BrandId, Program_Type__c = programType,
                                                                   Year_Of_Allocation__c = YearOfAlloc, Time_Period__C = timePeriod,
                                                                   Time_Interval__c = timeInterval, Is_Active__c = true);
		return newBrandAlloc;
    }
    
    public static Brand_Country_Allocation__c createBrandCountryAlloc(String brandAlloc, String country, Boolean isLeafNode, Decimal noOfAlloc){
        Brand_Country_Allocation__c brandCountryAlloc = new Brand_Country_Allocation__c(Brand_Allocation__c = brandAlloc,
                                                                                       Country__c = country,Is_Active__c = true, Is_Leaf_Node__c = isLeafNode,
                                                                                       Allocations_per_Interval__c = noOfAlloc);
        return brandCountryAlloc;
    }
    
    public static Brand_Country_Region_Allocation__C createBrandCountryRegionAlloc(String countryAlloc, String region, 
                                                                                   Boolean isLeaf, Decimal noOfAlloc){
        Brand_Country_Region_Allocation__C regionAlloc = new Brand_Country_Region_Allocation__C(
            Brand_Country_Allocation__c = countryAlloc, Region__c = region, Is_Leaf_Node__c = isLeaf,
        	Allocations_per_Interval__c = noOfAlloc);
        return regionAlloc;
    }
    
    public static Brand_Country_Region_State_Allocation__C createBrandCountryRegionStateAlloc(String regionAlloc, String state,
                                                                                              Boolean isLeaf, Decimal noOfAlloc) {
    	Brand_Country_Region_State_Allocation__C stateAlloc = new Brand_Country_Region_State_Allocation__c(
        	Brand_Country_Region_Allocation__c = regionAlloc, State__c = state, Is_Active__c = true, Is_Leaf_Node__c = isLeaf,
        	Allocations_Per_Interval__c = noOfAlloc);
		return stateAlloc;
    }
    
    public static Brand_Country_Region_State_Dist_Alloc__c createBrandCountryRegionStateDistAlloc(String stateAlloc, String accountId,
                                                                                                  Boolean isLeaf, Decimal noOfAlloc){
		Brand_Country_Region_State_Dist_Alloc__c distAlloc = new Brand_Country_Region_State_Dist_Alloc__c(
        	Brand_Country_Region_State_Allocation__c = stateAlloc, Account__c = accountId, Is_Active__c = true, Is_Leaf_Node__c = isLeaf,
        	Allocations_Per_Interval__c = noOfAlloc);
        return distAlloc;
    }
}