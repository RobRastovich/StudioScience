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
    @date 02/05/2020
    @description This class is used to fetch data on Brand Country Allocation
*/
public class SLT_SB2_BrandCountryAlloc {

    /**
    *  @description : This method is use to get List of Brand Country Region State Allocation from Id
    *  @args        : Set<Id>
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<AggregateResult> getBrandCountryAllocationByBrandAllocation(Set<Id> brandAlloactionIds) {
        return [SELECT 
                    SUM(Allocations_Per_Interval__c), SUM(Used_Allocations__c), SUM(Cancelled_Allocations__c ), 
                	SUM(Carry_Forward_Units__c), Brand_Allocation__c 
                FROM
                    Brand_Country_Allocation__c
                WHERE 
                    Is_Active__c = TRUE 
                AND 
                    Brand_Allocation__c IN :brandAlloactionIds
                GROUP BY
                    Brand_Allocation__c
                LIMIT 1000];
    }
    
    /**
    *  @description : This method is use to get List of Brand Country Region State Allocation from Id
    *  @args        : Set<Id>
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    public static List<Brand_Country_Allocation__c> getBrandCountrAllocationByBrandAllocationAndCountry(Set<Id> brandAllocationIds, Set<Id> countryIds) {
        return [SELECT
                    Id, Brand_Allocation__c, Country__c
                FROM
                    Brand_Country_Allocation__c
                WHERE
                    Brand_Allocation__c IN :brandAllocationIds 
                AND 
                    Country__c IN :countryIds 
                AND 
                    Is_Active__c = TRUE
                LIMIT 1000];
    }

    /**
    *  @description : This method is use to fetch country allocation records.
    *  @args        : Set<Id> countryAllocationIds
    *  @return      : Map<Id, Brand_Country_Allocation__c>
    **/
    public static Map<Id, Brand_Country_Allocation__c> getCountryAllocationMap(Set<Id> countryAllocationIds) {
        return new Map<Id, Brand_Country_Allocation__c>([
            SELECT
                Id, Name
            FROM
                Brand_Country_Allocation__c
            WHERE
                Id IN: countryAllocationIds
        ]);
    }
    
    public static List<Brand_Country_Allocation__c> getBrandCountryAllocation(Set<String> setOfBrandAllocation){
        return [SELECT Id, Name, Is_Leaf_Node__c , Is_Active__c, Used_Allocations__c, Remaining_Allocations__c, 
                Brand_Allocation__C, Country__c, Allocations_Per_Interval__c, Brand_Allocation__r.Brand__r.Name,
                Brand_Allocation__r.Program_Type__c, Brand_Allocation__r.Name, Brand_Allocation__r.Year_Of_Allocation__c,
                Brand_Allocation__r.Time_Interval__c, Country__r.Name, 
               		(SELECT Id, Name, Is_Leaf_Node__c, Allocations_Per_Interval__c, Carry_Forward_Units__c, Brand_Country_Allocation__c,
                     Remaining_Allocations__c, Region__c, Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name,
                     Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c, Brand_Country_Allocation__r.Brand_Allocation__r.Name,
                     Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c, Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c,
                     Brand_Country_Allocation__r.Country__r.Name, Region__r.Name, Used_Allocations__c
                     FROM Brand_Country_Region_Allocations__r)
               FROM Brand_Country_Allocation__c
               WHERE Brand_Allocation__c IN: setOfBrandAllocation];
    }
}