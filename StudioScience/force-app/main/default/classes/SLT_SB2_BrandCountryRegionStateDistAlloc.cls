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
    @description This class is used to perform dml operations on Brand Country Region state Distributor Allocations
*/
public class SLT_SB2_BrandCountryRegionStateDistAlloc {
    /**
    *  @description : This method is use to get Brand Country Region State Distributor Allocation record by Id
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Distr_Alloc__c>
    **/
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getBrandCountryRegionStateDistAllocationFromState(Set<Id> setOfId){
        return[SELECT Id, Name, Account__c, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Region_State_Allocation__c,
                   Carry_Forward_Units__c, Country_Allocation__c, Is_Active__c, Is_Leaf_Node__c, Remaining_Allocations__c, Region_Allocation__c
               FROM Brand_Country_Region_State_Dist_Alloc__c
               WHERE Brand_Country_Region_State_Allocation__c IN: setOfId
               AND Is_Active__c = true];
    } 
    
    /**
    *  @description : This method is use to get Brand Country Region State Distributor Allocation record by Id
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Distr_Alloc__c>
    **/
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getBrandCountryRegionStateDistAllocation(String recordId){
        return[SELECT Id, Name, Account__c, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Region_State_Allocation__c,
                   Carry_Forward_Units__c, Country_Allocation__c, Is_Active__c, Is_Leaf_Node__c, Remaining_Allocations__c, Region_Allocation__c
               FROM Brand_Country_Region_State_Dist_Alloc__c
               WHERE Id =: recordId];
    }
    
    /**
    *  @description : This method is use to update List of Brand Country Region State Distributor Allocation
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c>
    *  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
    **/
    public static List<Brand_Country_Region_State_Dist_Alloc__c> updateLstBrandCountryRegionStateDistAllocation(List<Brand_Country_Region_State_Dist_Alloc__c> lstRecord){
        update lstRecord;
        return lstRecord;
    }
    
    /**
    *  @description : This method is use to get Brand Country Region State Distributor Allocation record by Id
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Distr_Alloc__c>
    **/
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getDistAllocFromRegion(Set<String> setOfRegionAlloc){
        return[SELECT Id, Name, Account__c, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Region_State_Allocation__c,
                   Carry_Forward_Units__c, Country_Allocation__c, Is_Active__c, Is_Leaf_Node__c, Remaining_Allocations__c, Region_Allocation__c,
               	   Brand_Country_Region_State_Allocation__r.Id
               FROM Brand_Country_Region_State_Dist_Alloc__c
               WHERE Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__c IN: setOfRegionAlloc];
    }

    /**
    *  @description : This method is use to get active leaf node of Brand Country Region State Distributor Allocation By Brand Country Region State Allocation
    *  @args        : Set<Id> brandCountryRegionStateAlloactionIds
    *  @return      : List<AggregateResult>
    **/
    public static List<AggregateResult> getDistAllocByStateAlloc(Set<Id> brandCountryRegionStateAlloactionIds) {
        return [SELECT 
                    SUM(Allocations_Per_Interval__c), SUM(Used_Allocations__c), SUM(Cancelled_Allocations__c), 
                	SUM(Carry_Forward_Units__c), Brand_Country_Region_State_Allocation__c 
                FROM
                    Brand_Country_Region_State_Dist_Alloc__c 
                WHERE
                    Is_Active__c = TRUE 
                AND
                    Is_Leaf_Node__c = TRUE 
                AND
                    Brand_Country_Region_State_Allocation__c IN :brandCountryRegionStateAlloactionIds
                GROUP BY
                    Brand_Country_Region_State_Allocation__c
                LIMIT 1000];
    }

    /**
    *  @description : This method is use to get active Brand Country Region State Distributor Allocation By Brand Country Region State Allocation and Account
    *  @args        : Set<Id> brandCountryRegionStateAllocationIds, Set<Id> accountIds
    *  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
    **/
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getDistAllocByStateAllocAndAccount(Set<Id> brandCountryRegionStateAllocationIds, Set<Id> accountIds) {
        return [SELECT 
                    Id, Brand_Country_Region_State_Allocation__c, Account__c 
                FROM 
                    Brand_Country_Region_State_Dist_Alloc__c 
                WHERE 
                    Brand_Country_Region_State_Allocation__c IN :brandCountryRegionStateAllocationIds 
                AND 
                    Account__c IN :accountIds 
                AND 
                    Is_Active__c = TRUE
                LIMIT 1000];
    }
    
    /**
    *  @description : This method is use to get active Brand Country Region State Distributor Allocation By Brand Country Region State Allocation and Account
    *  @args        : Set<Id> brandCountryRegionStateAllocationIds, Set<Id> accountIds
    *  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
    **/
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getDistAllocByAccountAndBrandAlloc(String selectedBrandAllocation, String accountId) {
        return [SELECT Id, Account__c, Allocations_Per_Interval__c, Brand_Allocation__c, Is_Active__c,
                    Is_Leaf_Node__c, Used_Allocations__c, Brand_Country_Region_State_Allocation__r.Id,
                    Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c, Cancelled_Allocations__c,
                    Brand_Country_Region_State_Allocation__r.Is_Active__c, Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c, 
                    Brand_Country_Region_State_Allocation__r.Used_Allocations__c,Brand_Country_Region_State_Allocation__r.State__r.Name,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Id,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name
                FROM Brand_Country_Region_State_Dist_Alloc__c 
                WHERE Brand_Allocation__c =: selectedBrandAllocation
                AND Account__c =: accountId
                AND Is_Active__c = true
                LIMIT 1000];
    } 
    
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getDistAllocByBrandAlloc(List<String> selectedBrandAllocation) {
        return [SELECT Id, Account__c, Allocations_Per_Interval__c, Brand_Allocation__c, Is_Active__c,
                    Is_Leaf_Node__c, Used_Allocations__c, Brand_Country_Region_State_Allocation__r.Id,
                    Brand_Country_Region_State_Allocation__r.Allocations_Per_Interval__c, 
                    Brand_Country_Region_State_Allocation__r.Is_Active__c, Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c, 
                    Brand_Country_Region_State_Allocation__r.Used_Allocations__c,Brand_Country_Region_State_Allocation__r.State__r.Name,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Id,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Allocations_Per_Interval__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Used_Allocations__c,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name,
                    Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name
                FROM Brand_Country_Region_State_Dist_Alloc__c 
                WHERE Brand_Allocation__c IN: selectedBrandAllocation
                AND IS_Active__C = true
                LIMIT 1000];
    } 
}