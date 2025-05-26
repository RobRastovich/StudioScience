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
public class SLT_SB2_BrandCountryRegionAlloc {
    /**
    *  @description : This method is use to get List of Brand Country Region State Allocation from Id
    *  @args        : Set<Id>
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<Brand_Country_Region_Allocation__c> getListBrandCountryRegionAllocation(Set<String> setOfId){
        return [SELECT Id, Name, Allocations_Per_Interval__c, Brand_Allocation__c, Brand_Country_Allocation__c,
                   Carry_Forward_Units__c, Is_Leaf_Node__c,
                   (SELECT Id, Name, Allocations_Per_Interval__c, Is_Active__c, Is_Leaf_Node__c 
                    FROM Brand_Country_Region_State_Allocations__r )
               FROM Brand_Country_Region_Allocation__c
               WHERE Id IN: setOfId];
    }
    
    /**
    *  @description : This method is use to update List of Brand Country Region State Allocation
    *  @args        : List<Brand_Country_Region_Allocation__c>
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<Brand_Country_Region_Allocation__c> updateBrandCountryRegionAllocation(List<Brand_Country_Region_Allocation__c> lstRecord){
        update lstRecord;
        return lstRecord;
    }

    /**
    *  @description : This method is use to get Brand Country Region Allocation by Brand Country Allocation
    *  @args        : Set<Id> brandCountryAlloactionIds
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<AggregateResult> getBrandCountryRegionAllocationByBrandCountryAllocation(Set<Id> brandCountryAlloactionIds) {
        return [SELECT 
                    SUM(Allocations_Per_Interval__c), SUM(Used_Allocations__c), SUM(Cancelled_Allocations__c ), 
                	SUM(Carry_Forward_Units__c), Brand_Country_Allocation__c
                FROM 
                    Brand_Country_Region_Allocation__c 
                WHERE 
                    Brand_Country_Allocation__c IN :brandCountryAlloactionIds
                GROUP BY
                    Brand_Country_Allocation__c
                LIMIT 1000];
    }

    /**
    *  @description : This method is use to get Brand Country Region Allocation by Brand Country Allocation and Region 
    *  @args        : Set<Id> brandCountryAllocationIds, Set<Id> regionIds
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<Brand_Country_Region_Allocation__c> getRegionAllocationByCountryAllocationAndRegion(Set<Id> brandCountryAllocationIds, Set<Id> regionIds) {
        return [SELECT 
                    Id, Brand_Country_Allocation__c, Region__c
                FROM
                    Brand_Country_Region_Allocation__c 
                WHERE
                    Brand_Country_Allocation__c IN :brandCountryAllocationIds 
                AND 
                    Region__c IN :regionIds
                LIMIT 1000];
    }
    
    /**
    *  @description : This method is use to get Brand Country Region Allocation by Brand Country Allocation and Region 
    *  @args        : Set<Id> brandCountryAllocationIds, Set<Id> regionIds
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<Brand_Country_Region_Allocation__c> getRegionAllocationByCountryAndRegionAndBrand(
        String regionName, String countryName, String brandAllocation) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c, Is_Leaf_Node__c, Used_Allocations__c,Region__r.Name,
                    Brand_Country_Allocation__r.Country__r.Name, Cancelled_Allocations__c
                FROM
                    Brand_Country_Region_Allocation__c 
                WHERE 
                    Region__r.Name =: regionName
                AND 
                    Region__r.Country__r.Name =: countryName
                AND
                    Brand_Allocation__c =: brandAllocation];
    }

    /**
    *  @description : This method is use to fetch country allocation records.
    *  @args        : Set<Id> regionAllocationIds
    *  @return      : Map<Id, Brand_Country_Region_Allocation__c>
    **/
    public static Map<Id, Brand_Country_Region_Allocation__c> getRegionAllocationMap(Set<Id> regionAllocationIds) {
        return new Map<Id, Brand_Country_Region_Allocation__c>([
            SELECT
                Id, Name, Allocations_Per_Interval__c, Used_Allocations__c
            FROM
                Brand_Country_Region_Allocation__c
            WHERE
                Id IN: regionAllocationIds
        ]);
    }

    public static List<Brand_Country_Region_Allocation__c> getRegionAllocationByIdAndBrandAllocation(String id, Set<String> brandAllocationIds) {
        return [SELECT 
                    Id, Allocations_Per_Interval__c, Is_Leaf_Node__c, Brand_Allocation__c 
                FROM 
                    Brand_Country_Region_Allocation__c 
                WHERE 
                    Region__c = :id 
                AND 
                    Brand_Allocation__c IN :brandAllocationIds];
    }
}