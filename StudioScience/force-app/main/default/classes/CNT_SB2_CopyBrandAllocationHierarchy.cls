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
@description This class is used to get brand allocation info and to perform different operations on it
*/
public class CNT_SB2_CopyBrandAllocationHierarchy {
    /**
*  @description : This method is use to fetch Brand allocation info
*  @args        : String record Id
*  @return      : List<Brand_Allocation__c>
**/
    @AuraEnabled
    public static List<Brand_Allocation__c> getBrandAllocation(String recordId){
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(recordId);
        if(!lstBrandAllocation.isEmpty()){
            return lstBrandAllocation;
        }
        return null;
    }	
    
    @AuraEnabled
    public static Map<String, Object> copyGeographicalHierarchy(String brandAllocationId, String currentBrandAllocationId) {
        try {
            List<Brand_Country_Allocation__c> lstBrandCountryAlloc = [Select Id,Brand_Allocation__c, Country__c, Is_Active__c, 
                                                                      Is_leaf_node__c 
                                                                      From Brand_Country_Allocation__c
                                                                      where Brand_Allocation__c =: brandAllocationId];
            List<Brand_Country_Allocation__c> lstNewBrandCountryAlloc = new List<Brand_Country_Allocation__c>();
            for(Brand_Country_Allocation__c countryAlloc : lstBrandCountryAlloc) {
                Brand_Country_Allocation__c newCountryAlloc = new Brand_Country_Allocation__c();
                newCountryAlloc = countryAlloc.clone();
                newCountryAlloc.Brand_Allocation__c = currentBrandAllocationId;
                newCountryAlloc.Allocations_Per_Interval__c = 0;
                newCountryAlloc.Used_Allocations__c = 0;
                newCountryAlloc.Cancelled_Allocations__c = 0;
                newCountryAlloc.Carry_Forward_Units__c = 0;
                newCountryAlloc.Is_Record_Copied__c = true;
                newCountryAlloc.name = '';
                lstNewBrandCountryAlloc.add(newCountryAlloc);
            }
            if(!lstNewBrandCountryAlloc.isEmpty()){
				insert lstNewBrandCountryAlloc;             
            }
            map<String, String> mapOfOldNewCountryAlloc = new map<String, String>();
            for(Integer i=0; i< lstBrandCountryAlloc.size(); i++) {
                for(Integer j=0;j<lstNewBrandCountryAlloc.size(); j++)
                if(lstBrandCountryAlloc[i].Country__c == lstNewBrandCountryAlloc[j].Country__c){
                    mapOfOldNewCountryAlloc.put(lstBrandCountryAlloc[i].Id, lstNewBrandCountryAlloc[j].Id);
                }
            }
            List<Brand_Country_Region_Allocation__c> lstNewRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
            List<Brand_Country_Region_Allocation__c> lstRegionAlloc = [Select Id, Name, Brand_Country_Allocation__c , 
                                                                      Is_Leaf_Node__c, Region__c 
                                                                      From Brand_Country_Region_Allocation__c
                                                                      where Brand_Country_Allocation__c In : mapOfOldNewCountryAlloc.keySet()];
            for(Brand_Country_Region_Allocation__c regionAlloc : lstRegionAlloc){
                Brand_Country_Region_Allocation__c newRegionAlloc = new Brand_Country_Region_Allocation__c();
                newRegionAlloc = regionAlloc.clone();
                newRegionAlloc.Brand_Country_Allocation__c = mapOfOldNewCountryAlloc.get(regionAlloc.Brand_Country_Allocation__c);
                newRegionAlloc.Used_Allocations__c = 0;
                newRegionAlloc.Allocations_Per_Interval__c = 0;
                newRegionAlloc.Cancelled_Allocations__c = 0;
                newRegionAlloc.Carry_Forward_Units__c =0;
                newRegionAlloc.Is_Record_Copied__c = true;
                newRegionAlloc.name = '';
                lstNewRegionAlloc.add(newRegionAlloc);
            }
            System.debug('lstBrandCountryAlloc--'+lstBrandCountryAlloc);
            if(!lstNewRegionAlloc.isEmpty()){
            	insert lstNewRegionAlloc;
            }
            map<String, String> mapOfOldNewRegion = new map<String, String>();
            for(Integer i=0; i<lstRegionAlloc.size(); i++) {
                for(Integer j=0; j<lstNewRegionAlloc.size(); j++) {
                    if(lstRegionAlloc[i].Region__c == lstNewRegionAlloc[j].Region__c){
                        mapOfOldNewRegion.put(lstRegionAlloc[i].Id, lstNewRegionAlloc[j].Id);
                    }
                }
            }
            List<Brand_Country_Region_State_Allocation__c> lstNewStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
            List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = [select Is_Active__c, Is_Leaf_Node__c, Brand_Country_Region_Allocation__c , State__c 
                                                                           from Brand_Country_Region_State_Allocation__c 
                                                                           where Brand_Country_Region_Allocation__c IN: mapOfOldNewRegion.keySet()];
            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
                Brand_Country_Region_State_Allocation__c newStateAlloc = new Brand_Country_Region_State_Allocation__c();
                newStateAlloc = stateAlloc.clone();
                newStateAlloc.Allocations_Per_Interval__c = 0;
                newStateAlloc.Brand_Country_Region_Allocation__c = mapOfOldNewRegion.get(stateAlloc.Brand_Country_Region_Allocation__c);
                newStateAlloc.Used_Allocations__c = 0;
                newStateAlloc.Carry_Forward_Units__c = 0;
                newStateAlloc.Cancelled_Allocations__c = 0;
                newStateAlloc.Is_Record_Copied__c = true;
                newStateAlloc.name = '';
                lstNewStateAlloc.add(newStateAlloc);
            }
            if(!lstNewStateAlloc.isEmpty()){
                insert lstNewStateAlloc;
            }
            map<String, String> mapOfOldNewState = new Map<String, String>();
            for(Integer i=0; i<lstStateAlloc.size(); i++){
                for(Integer j=0; j< lstNewStateAlloc.size(); j++) {
                    if(lstStateAlloc[i].state__c == lstNewStateAlloc[j].state__c){
                        mapOfOldNewState.put(lstStateAlloc[i].Id, lstNewStateAlloc[j].Id);
                    }
                }
            }
            List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = [Select Id, Account__c, Is_Active__c, Is_Leaf_Node__c, Brand_Country_Region_State_Allocation__c
                                                                          From Brand_COuntry_Region_State_Dist_Alloc__c
                                                                          where Brand_Country_Region_State_Allocation__C IN : mapOfOldNewState.keySet()];
            List<Brand_Country_Region_State_Dist_Alloc__c> lstNewDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
            for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : lstDistAlloc){
                Brand_Country_Region_State_Dist_Alloc__c newDistAlloc = new Brand_Country_Region_State_Dist_Alloc__c();
                newDistAlloc = distAlloc.clone();
                newDistAlloc.Brand_Country_Region_State_Allocation__c = mapOfOldNewState.get(distAlloc.Brand_Country_Region_State_Allocation__c);
                newDistAlloc.Allocations_Per_Interval__c = 0;
                newDistAlloc.Cancelled_Allocations__c = 0;
                newDistAlloc.Carry_Forward_Units__c = 0;
                newDistAlloc.Used_Allocations__c = 0;
                newDistAlloc.Is_Record_Copied__c = true;
                lstNewDistAlloc.add(newDistAlloc);
            }
            if(!lstNewDistAlloc.isEmpty()) {
                insert lstNewDistAlloc;
            }
            return new Map<String, Object>{'Id' => lstNewBrandCountryAlloc[0].Id};
                } catch (Exception e) {
                    throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
                }
    }
    
    @AuraEnabled
    public static List<Brand_Country_Allocation__c> fetchHierarchyBrandAllocation(String recordId) {
        List<Brand_Country_Allocation__c> lstCountryAlloc = SLT_SB2_BrandCountryAlloc.getBrandCountryAllocation(new Set<String> {recordId});
        return lstCountryAlloc;
    }
}