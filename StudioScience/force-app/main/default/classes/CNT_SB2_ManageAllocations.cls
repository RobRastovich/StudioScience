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
@date 08/05/2020
@description This controller class is used to manage allocations.
*/
public without sharing class CNT_SB2_ManageAllocations {
    
    /**
*  @description : This method is used to get brand & country allocation.
*  @return      : Map<String, Object>
**/
    @AuraEnabled
    public static Map<String, Object> getBrandAndCountryAllocationData(String year) {
        // String currentYear = Date.today().year() + '';
        Map<String, Object> mapToReturn = new Map<String, Object>();
        
        // List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocationWithCountryAllocationByYear(currentYear);
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocationWithCountryAllocationByYear(year);
        
        Map<String, Object> brandAllocationMap = new Map<String, Object>();
        Map<String, Map<String, String>> countryByProgramType = new Map<String, Map<String, String>>();
        Map<String, Set<String>> brands = new Map<String, Set<String>>();
        Set<String> programTypesAndTimeIntervals = new Set<String>();
        
        for(Brand_Allocation__c allocation : lstBrandAllocation) {
            String key = allocation.Brand__r.Name + ' | ' + allocation.Program_Type__c + ' | ' + allocation.Time_Interval__c;
            
            brandAllocationMap.put(key, allocation.Id);
            
            if(brands.containsKey(allocation.Brand__r.Name)) {
                Set<String> programTypesInterval = brands.get(allocation.Brand__r.Name);
                programTypesInterval.add(allocation.Program_Type__c + ' | ' + allocation.Time_Interval__c);
                brands.put(allocation.Brand__r.Name, programTypesInterval);
            } else {
                brands.put(allocation.Brand__r.Name, new Set<String>{allocation.Program_Type__c + ' | ' + allocation.Time_Interval__c});
            }
            
            String programTypeIntervalKey = allocation.Brand__r.Name + ' | ' +allocation.Program_Type__c + ' | ' + allocation.Time_Interval__c;
            
            for(Brand_Country_Allocation__c countryAllocation : allocation.Brand_Country_Allocations__r) {
                if(countryByProgramType.containsKey(programTypeIntervalKey)) {
                    Map<String, String> countryMap = countryByProgramType.get(programTypeIntervalKey);
                    countryMap.put(countryAllocation.Country__r.Name, countryAllocation.Id);
                    countryByProgramType.put(programTypeIntervalKey, countryMap);
                } else {
                    countryByProgramType.put(programTypeIntervalKey, new Map<String, String>{countryAllocation.Country__r.Name => countryAllocation.Id});
                }
            }
        }
        brandAllocationMap.put('brands', brands);
        brandAllocationMap.put('countries',countryByProgramType);
        
        mapToReturn.put('brandAllocation', brandAllocationMap);
        
        return mapToReturn;
    }
    
    
    /**
*  @description : This method is used to get allocation data by brand & country allocation.
*  @args        : String objectName, String brandAllocation, String countryAllocation
*  @return      : List<SObject>
**/
    @AuraEnabled
    public static List<SObject> getAllocationData(String objectName, String brandAllocation, String countryAllocation) {
        String countryAllocationApi = objectName == 'Brand_Country_Region_Allocation__c' ? 'Brand_Country_Allocation__c' : 'Country_Allocation__c';
        String countryAllocationId = objectName == 'Brand_Country_Region_Allocation__c' ? countryAllocation : countryAllocation.substring(0, 15);
        String brandAllocationId = brandAllocation.substring(0, 15);
        String distributorFields = objectName == 'Brand_Country_Region_State_Dist_Alloc__c' ? ', Brand_Country_Region_State_Allocation__r.Name, Account__r.Name ' : '';
        return Database.query('Select Id, Name, Allocations_Per_Interval__c, Used_Allocations__c, Remaining_Allocations__c' + distributorFields + ' From ' + objectName + ' Where Is_Leaf_Node__c = TRUE AND Brand_Allocation__c = :brandAllocationId AND ' + countryAllocationApi + ' = :countryAllocationId');
    }
    
    /**
*  @description : This method is get allocation data by brand & country allocation.
*  @args        : String objectName, String brandAllocation, String countryAllocation
*  @return      : List<SObject>
**/
    @AuraEnabled
    public static String createLoggerRecord(Allocation_Logger__c logger, SObject fromAllocation, SObject toAllocation) {
        try {
            insert logger;
            update fromAllocation;
            if(logger.Change_Type__c == 'Transfer') {
                update toAllocation;
            }
            return logger.Id;
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
    
}