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
    @date 23/04/2020
    @description This class is used to perform dml operations on Brand Country Region state Allocations
*/ 
public class SLT_SB2_BrandCountryRegionStateAlloc {
    /**
    *  @description : This method is use to get Brand Country Region State Allocation record by Id
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getBrandCountryRegionStateAllocation(String Id){
        return [SELECT Id, Name, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Region_Allocation__c,
                   Carry_Forward_Units__c, Country_Allocation__c, Is_Active__c, Is_Leaf_Node__c,
                   State__c, Brand_Country_Region_Allocation__r.Is_Leaf_Node__c, Remaining_Allocations__c,
                  (SELECT Id, Name, Is_Leaf_Node__c,Allocations_Per_Interval__c   From Brand_Country_Region_State_Dist_Allocs__r)
               FROM Brand_Country_Region_State_Allocation__c
               WHERE Id =: Id];
    }
    
    /**
    *  @description : This method is use to update List of Brand Country Region State Allocation
    *  @args        : List<Brand_Country_Region_State_Allocation__c>
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> updateLstBrandCountryRegionStateAllocation(List<Brand_Country_Region_State_Allocation__c> lstRecord){
        update lstRecord;
        return lstRecord;
    }
    
    /**
    *  @description : This method is use to get List of Brand Country Region State Allocation from Id
    *  @args        : Set<Id>
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getListBrandCountryRegionStateAllocation(Set<Id> setOfId){
        return [SELECT Id, Name, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Region_Allocation__c,
                   Carry_Forward_Units__c, Country_Allocation__c, Is_Active__c, Is_Leaf_Node__c, Remaining_Allocations__c, 
                   State__c, (SELECT Id, Name, Allocations_Per_Interval__c, Is_Active__c, Is_Leaf_Node__c 
                              FROM Brand_Country_Region_State_Dist_Allocs__r )
               FROM Brand_Country_Region_State_Allocation__c
               WHERE Id IN: setOfId];
    }
    
    /**
    *  @description : This method is use to get List of Brand Country Region State Allocation from Id
    *  @args        : Set<Id>
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getListBrandCountryRegionStateAllocationFromRegion(Set<Id> setOfId){
        return [SELECT Id, Name, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Region_Allocation__c,
                   Carry_Forward_Units__c, Country_Allocation__c, Is_Active__c, Is_Leaf_Node__c, Remaining_Allocations__c,
                   Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name,
                   Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c,
                   Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Name,
                   Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c,
                   Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c,
                   Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name,State__r.State_Manager__r.Name,
                   Brand_Country_Region_Allocation__r.Region__r.Name,State__r.Name, State__c, Used_Allocations__c,
                   (SELECT Id, Name, Allocations_Per_Interval__c, Is_Active__c, Is_Leaf_Node__c ,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c,
                   Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Name,
                   Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c,
                   Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c,
                   Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name,
                   Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name,
                    Brand_Country_Region_State_Allocation__r.State__r.Name, Brand_Country_Region_State_Allocation__r.State__r.State_Manager__r.Name,
                              Brand_Country_Region_State_Allocation__c, Account__c, Remaining_Allocations__c,Account__r.Name, Used_Allocations__c  
                              FROM Brand_Country_Region_State_Dist_Allocs__r )
               FROM Brand_Country_Region_State_Allocation__c
               WHERE Brand_Country_Region_Allocation__c IN: setOfId
               AND Is_Active__c = true];
    }

    /**
    *  @description : This method is use to get Brand Country Region State Allocation by Brand Country Region Allocaiton
    *  @args        : Set<Id> brandCountryRegionAlloactionIds
    *  @return      : List<AggregateResult>
    **/   
    public static List<AggregateResult> getBrandCountryRegionStateAllocationByBrandCountryRegionAllocation(Set<Id> brandCountryRegionAlloactionIds) {
        return [SELECT 
                    SUM(Allocations_Per_Interval__c),SUM(Used_Allocations__c), SUM(Cancelled_Allocations__c), 
                	SUM(Carry_Forward_Units__c), Brand_Country_Region_Allocation__c
                FROM
                    Brand_Country_Region_State_Allocation__c 
                WHERE 
                    Is_Active__c = TRUE 
                AND 
                    Brand_Country_Region_Allocation__c IN :brandCountryRegionAlloactionIds
                GROUP BY
                    Brand_Country_Region_Allocation__c
                LIMIT 1000];
    }

    /**
    *  @description : This method is use to get active Brand Country Region State Allocation by Brand Country Region Allocaiton and State
    *  @args        : Set<Id> brandCountryRegionAllocationIds, Set<Id> stateIds
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationByRegionAllocationAndState(Set<Id> brandCountryRegionAllocationIds, Set<Id> stateIds) {
        return [SELECT 
                    Id, Brand_Country_Region_Allocation__c, State__c 
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE
                    Brand_Country_Region_Allocation__c IN :brandCountryRegionAllocationIds 
                AND 
                    State__c IN :stateIds 
                AND 
                    Is_Active__c = TRUE
                LIMIT 1000];
    }

    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with state & country
    *  @args        : Set<Id> brandCountryRegionAllocationIds
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationWithStateAndCountry(Set<Id> brandCountryRegionAllocationIds) {
        return [SELECT 
                    Id, Name, State__r.Name, State__r.Country__r.Name, Is_Record_Copied__c
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE
                    Id IN :brandCountryRegionAllocationIds
                LIMIT 1000];
    }
    
    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with state
    *  @args        : Set<Id> State
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationWithState(Set<Id> setStateId) {
        return [SELECT 
                    Id, State__r.Name, State__r.Country__r.Name,Is_Active__c,
                    (SELECT 
                        Id, Name, Allocations_Per_Interval__c, Is_Active__c, Is_Leaf_Node__c 
                     FROM Brand_Country_Region_State_Dist_Allocs__r )
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE
                    State__c IN :setStateId
                LIMIT 1000];
    }
    
    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with state
    *  @args        : Set<Id> State
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationWithCountryAndRegion(String stateName, String regionName, String brandAllocation, String countryName) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c,Brand_Allocation__c,Brand_Country_Region_Allocation__c,Is_Active__c,
                    Is_Leaf_Node__c, Used_Allocations__c,Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c,
                    Brand_Country_Region_Allocation__r.Brand_Country_Allocation__c,Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                    Brand_Country_Region_Allocation__r.Region__c, Brand_Country_Region_Allocation__r.Used_Allocations__c, Remaining_Allocations__c,
                    Brand_Country_Region_Allocation__r.Region__r.Name,Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name,
                    State__r.Name
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE
                    State__r.Name =: stateName
                AND
                    Brand_Country_Region_Allocation__r.Region__r.Name =: regionName
                AND 
                    State__r.Country__r.Name =: countryName
                AND
                    Brand_Allocation__c =: brandAllocation];
    }
    
    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with state
    *  @args        : Set<Id> State
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationByBrandAllocationAndState(String stateName, String brandAllocation, String countryName) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c,Brand_Allocation__c,Brand_Country_Region_Allocation__c,Is_Active__c, State__r.Name, 
                    Is_Leaf_Node__c, Used_Allocations__c,Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c, Cancelled_Allocations__c,
                    Brand_Country_Region_Allocation__r.Brand_Country_Allocation__c,Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                    Brand_Country_Region_Allocation__r.Region__c, Brand_Country_Region_Allocation__r.Used_Allocations__c, Remaining_Allocations__c,
                    Brand_Country_Region_Allocation__r.Region__r.Name,Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name,
                	Brand_Country_Region_State_Allocation__c.Allocation_Used__c
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE
                    State__r.Name =: stateName
                AND 
                    State__r.Country__r.Name =: countryName
                AND
                    Brand_Allocation__c =: brandAllocation
                AND
               		Is_Active__c = true];
    }
    
    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with state
    *  @args        : Set<Id> State
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationByBrandAllocation(List<String> brandAllocation) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c,Brand_Allocation__c,Brand_Country_Region_Allocation__c,Is_Active__c, State__r.Name, 
                    Is_Leaf_Node__c, Used_Allocations__c,Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c,
                    Brand_Country_Region_Allocation__r.Brand_Country_Allocation__c,Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                    Brand_Country_Region_Allocation__r.Region__c, Brand_Country_Region_Allocation__r.Used_Allocations__c, Remaining_Allocations__c,
                    Brand_Country_Region_Allocation__r.Region__r.Name,Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE 
                	Is_Active__c = true
                AND
                    Brand_Allocation__c =: brandAllocation
                    ];
    }

    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with Distributor Level Allocation by Brand Allocation and State 
    *  @args        : Id stateId, Set<String> brandAllocationIds
    *  @return      : Map<Id, Brand_Country_Region_State_Allocation__c>
    **/
    public static Map<Id, Brand_Country_Region_State_Allocation__c> getStateAllocationWithDistributorAllocationByBrandAllocationAndState(Id stateId, Set<String> brandAllocationIds) {
        return new Map<Id, Brand_Country_Region_State_Allocation__c>(
            [SELECT
                Id, Remaining_Allocations__c, Used_Allocations__c, Brand_Allocation__c, 
                Allocations_Per_Interval__c, Is_Leaf_Node__c, Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                (SELECT 
                    Id, Is_Leaf_Node__c, Account__c, Brand_Country_Region_State_Allocation__c, 
                    Remaining_Allocations__c, Used_Allocations__c, Allocations_Per_Interval__c
                FROM 
                    Brand_Country_Region_State_Dist_Allocs__r
                WHERE 
                    Is_Active__c = TRUE) 
            FROM 
                Brand_Country_Region_State_Allocation__c 
            WHERE 
                Is_Active__c = TRUE 
            AND 
                State__c = :stateId
            AND
                Brand_Allocation__c IN :brandAllocationIds]
        );
    }
    
    /**
    *  @description : This method is use to get active Brand Country Region State Allocation with state
    *  @args        : Set<Id> State
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationWithRegion(String stateName, String regionName, String brandAllocation) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c,Brand_Allocation__c,Brand_Country_Region_Allocation__c,Is_Active__c,
                    Is_Leaf_Node__c, Used_Allocations__c,Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c,
                    Brand_Country_Region_Allocation__r.Brand_Country_Allocation__c,Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                    Brand_Country_Region_Allocation__r.Region__c, Brand_Country_Region_Allocation__r.Used_Allocations__c, Remaining_Allocations__c,
                    Brand_Country_Region_Allocation__r.Region__r.Name,Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name,
                    State__r.Name, Cancelled_Allocations__c
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE
                    State__r.Name =: stateName
                AND
                    Brand_Country_Region_Allocation__r.Region__r.Name =: regionName
                AND
                    Brand_Allocation__c =: brandAllocation
               AND Is_Active__c = true];
    }

    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationsByIds(Set<Id> stateAllocationIds) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c, Used_Allocations__c 
                FROM 
                    Brand_Country_Region_State_Allocation__c 
                WHERE 
                    Id IN :stateAllocationIds];
    }
    
}