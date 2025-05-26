/**
    @company : Copyright © 2019, BeamSuntory
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
    @date 16/04/2020
    @description This Class is DAO class Brand Allocation
*/
public class SLT_SB2_BrandAllocation {
    /**
    *  @description : This method is get brand Allocation for a particular list of brand
    *  @args        : Set<Id>
    *  @return      : List<Brand_Allocation__c>
    **/
    public static List<Brand_Allocation__c> getExistingBrandAllocation(Set<Id> listOfBrand) {
            return[SELECT Id, Time_Period__c, Time_Interval__c, Year_Of_Allocation__c,
                          Brand__c, is_Active__c, Program_Type__C
                   FROM Brand_Allocation__c 
				   WHERE Brand__c IN: listOfBrand 
                   AND is_Active__c = true];
    }
    
    /**
    *  @description : This method is get brand Allocation form Brand ALlocation Id
    *  @args        : String
    *  @return      : List<Brand_Allocation__c>
    **/
    public static List<Brand_Allocation__c> getBrandAllocation(String recordId){
        return [SELECT Id, Name, Is_Active__c,Brand__c,Brand__r.Name, Carry_Forward_Units__c, Status__c,Allocation_End_Date__c ,
                    Is_Carry_Forward__c,Program_Type__c,Time_Interval__c,Time_Period__c,Year_Of_Allocation__c 
                FROM Brand_Allocation__c
                WHERE ID =: recordId];
    }
    
    /**
    *  @description : This method is get brand Allocation form Brand ALlocation by program type brand and year of allocation
    *  @args        : String
    *  @return      : List<Brand_Allocation__c>
    **/
    public static List<Brand_Allocation__c> getBrandAllocation(String brandName, String programType, String yearOfAllocation){
        return [select Allocation_Per_Interval__c, Brand__c, Is_Active__c, Program_Type__c, 
                              	Time_Interval__c,Time_Period__c,Year_Of_Allocation__c
                FROM Brand_Allocation__c 
                WHERE Brand__r.Name =: brandName
                AND Program_Type__c Like: '%'+programType+'%'
                AND Year_Of_Allocation__c =: yearOfAllocation];
    }

    /**
    *  @description : This method is used to get brand Allocation with country allocation by year of allocation
    *  @args        : String yearOfAllocation
    *  @return      : List<Brand_Allocation__c>
    **/
    public static List<Brand_Allocation__c> getBrandAllocationWithCountryAllocationByYear(String yearOfAllocation) {
        return [SELECT 
                    Id, Brand__r.Name, Program_Type__c, Year_Of_Allocation__c, Time_Interval__c, (Select Id, Country__r.Name From Brand_Country_Allocations__r WHERE Is_Active__c = TRUE)
                FROM 
                    Brand_Allocation__c
                WHERE
                    Is_Active__c = TRUE
                AND 
                    Year_of_Allocation__c = :yearOfAllocation
                ORDER BY 
                    Program_Type__c];
    }

    /**
    *  @description : This method is use to fetch brand allocation records.
    *  @args        : Set<Id> brandAllocationIds
    *  @return      : Map<Id, Brand_Allocation__c>
    **/
    public static Map<Id, Brand_Allocation__c> getBrandAllocationMap(Set<Id> brandAllocationIds) {
        return new Map<Id, Brand_Allocation__c>([
            SELECT
                Id, Name
            FROM
                Brand_Allocation__c
            WHERE
                Id IN: brandAllocationIds
        ]);
    }
    
    public static List<Brand_Allocation__c> getSelectedBrandAllocation(String brandId, Boolean isActive, String yearOfAlloc,
                                                                       List<String> lstOfTimePeriod, List<String> lstOfTimeInterval, String programType){
    	return [SELECT
               		Id, Name,Time_Interval__c
                FROM
               		Brand_Allocation__c
                WHERE 
               		Brand__c =: brandId
                AND
               		Is_Active__c =: isActive
                AND
               		Year_Of_Allocation__c =: yearOfAlloc
                AND
               		Time_Period__c IN: lstOfTimePeriod
                AND
               		Time_Interval__c IN: lstOfTimeInterval
               AND 
               		Program_Type__c =: programType];
	}
    
    public static List<Brand_Allocation__c> getBrandAllocationByName(List<String> lstName){
        return [SELECT
               		Id, Name,Time_Interval__c
                FROM
               		Brand_Allocation__c
                WHERE 
               		Name IN: lstName
                AND
               		Is_Active__c = true];
    }
    
    
    public static List<Brand_Allocation__c> getBrandAllocationByBrandYearTimeInterval(Set<Id> setBrand, Set<String> setYearOfAlloc,
                                                                                     Set<String> setTimeInterval, Set<String> setProgramType, 
                                                                                     Boolean isActive, String status){
        return [SELECT
               		Id, Name, Time_Interval__c, Brand__c, Program_Type__c, Year_Of_Allocation__c
                FROM
               		Brand_Allocation__c
                WHERE 
               		Brand__C IN: setBrand
                AND
               		Is_Active__c =: isActive
                AND 
               		Status__C =: status
                AND 
               		Program_Type__c IN: setProgramType
                AND
               		Time_Interval__c IN: setTimeInterval
                AND 
               		Year_Of_Allocation__c IN: setYearOfAlloc];
    }

    public static List<Brand_Allocation__c> getBrandAllocationForCurrentYear(){
        String currentYear = Date.today().year() + '';
        return [SELECT
               		Id, Name, Time_Interval__c, Time_Period__c
                FROM
               		Brand_Allocation__c
                WHERE 
                    Is_Active__c = TRUE
                AND
                	Status__c = 'Active'
                AND 
                    Year_Of_Allocation__c = :currentYear];
    }
    
}