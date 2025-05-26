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
@date 23/04/2020
@description This class is used to manage and deactivate Brand region state allocation
*/
public without sharing class  CNT_SB2_ManageLeafNode {
    /**
*  @description : This method is use to fetch Brand Country Region state Dist allocation info
*  @args        : String record Id
*  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
**/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getDistributorAllocationInfo(String recordId){
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAllocation = SLT_SB2_BrandCountryRegionStateDistAlloc.getBrandCountryRegionStateDistAllocation(recordId);
        List<Brand_Country_Region_State_Dist_Alloc__c> lstAllDistributorForState = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        String stateAllocationId;
        if(!lstDistributorAllocation.isEmpty()){
            for(Brand_Country_Region_State_Dist_Alloc__c DistAlloc : lstDistributorAllocation){
                if(DistAlloc.Is_Active__c){ 
                    stateAllocationId = DistAlloc.Brand_Country_Region_State_Allocation__c;
                }
            }
            if(!String.isEmpty(stateAllocationId)){
                lstAllDistributorForState = 
                    SLT_SB2_BrandCountryRegionStateDistAlloc.getBrandCountryRegionStateDistAllocationFromState(new Set<Id>{stateAllocationId});            
                return lstAllDistributorForState;
            }
            return lstDistributorAllocation;     
        }
        return null;
    }
    
    /**
*  @description : This method is use to fetch Brand Country Region state Dist allocation info
*  @args        : String record Id
*  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
**/
    @AuraEnabled
    public static List<Brand_Allocation__C> getBrandAllocationInfo(String recordId){
        List<Brand_Allocation__c> lstBrandAlloc = SLT_SB2_BrandAllocation.getBrandAllocation(recordId);
        return lstBrandAlloc;
    }
    /**
*  @description : This method is use to deactivate Brand Country Region State Distributor Allocation
*  @args        : String record Id
*  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
**/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Dist_Alloc__c> removeLeafDistributorAllocation(String recordId){
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAllocation = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocation = new List<Brand_Country_Region_State_Allocation__c>();
        lstDistributorAllocation = SLT_SB2_BrandCountryRegionStateDistAlloc.getBrandCountryRegionStateDistAllocation(recordId);
        Set<Id> setOfStateAlloc = new Set<Id>();
        for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : lstDistributorAllocation){
            setOfStateAlloc.add(distAlloc.Brand_Country_Region_State_Allocation__c);
        }
        if(!setOfStateAlloc.isEmpty()){
            lstStateAllocation = SLT_SB2_BrandCountryRegionStateAlloc.getListBrandCountryRegionStateAllocation(setOfStateAlloc);
        }
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        if(!lstStateAllocation.isEmpty()) {
            for(Brand_Country_Region_State_Allocation__c stateAllocation : lstStateAllocation){
                stateAllocation.Is_Leaf_Node__c = true;
                for(Brand_Country_Region_State_Dist_Alloc__c distributorAlloc : stateAllocation.Brand_Country_Region_State_Dist_Allocs__r){
                    if(distributorAlloc.Is_Active__c && distributorAlloc.Is_Leaf_Node__c){
                        distributorAlloc.Is_Leaf_Node__c = false;
                        lstDistAlloc.add(distributorAlloc);
                    }
                }
            }
        }
        lstStateAllocation = SLT_SB2_BrandCountryRegionStateAlloc.updateLstBrandCountryRegionStateAllocation(lstStateAllocation);
        lstDistAlloc = SLT_SB2_BrandCountryRegionStateDistAlloc.updateLstBrandCountryRegionStateDistAllocation(lstDistAlloc);
        return lstDistAlloc;
    }
    
    /**
*  @description : This method is use to fetch Brand Country Region state allocation info
*  @args        : String record Id
*  @return      : List<Brand_Country_Region_State_Allocation__c>
**/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Allocation__c> getStateAllocationInfoForLeafNode(String recordId){
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocation = SLT_SB2_BrandCountryRegionStateAlloc.getBrandCountryRegionStateAllocation(recordId);
        List<Brand_Country_Region_State_Allocation__c> lstAllStateForRegion = new List<Brand_Country_Region_State_Allocation__c>();
        String regionAllocationId;
        if(!lstStateAllocation.isEmpty()){
            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAllocation){
                if(stateAlloc.Is_Active__c){ 
                    regionAllocationId = stateAlloc.Brand_Country_Region_Allocation__c;
                }
            }
            if(!String.isEmpty(regionAllocationId)){
                lstAllStateForRegion = 
                    SLT_SB2_BrandCountryRegionStateAlloc.getListBrandCountryRegionStateAllocationFromRegion(new Set<Id>{regionAllocationId});            
                return lstAllStateForRegion;
            }
            return lstStateAllocation;     
        }
        return null;
    } 
    
    /**
*  @description : This method is use to deactivate Brand Country Region State Distributor Allocation
*  @args        : String record Id
*  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
**/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Allocation__c> removeStateAllocation(String recordId){
        List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
        List<Brand_Country_Region_Allocation__c> lstRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
        lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getBrandCountryRegionStateAllocation(recordId);
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        Set<String> setOfRegionAlloc = new Set<String>();
        
        for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
            setOfRegionAlloc.add(stateAlloc.Brand_Country_Region_Allocation__c);
        }
        if(!setOfRegionAlloc.isEmpty()){
            lstRegionAlloc = SLT_SB2_BrandCountryRegionAlloc.getListBrandCountryRegionAllocation(setOfRegionAlloc);
            lstDistAlloc = SLT_SB2_BrandCountryRegionStateDistAlloc.getDistAllocFromRegion(setOfRegionAlloc);
        }
        map<Id, List<Brand_Country_Region_State_Dist_Alloc__c>> mapOfStateAndDistAlloc = new Map<Id, List<Brand_Country_Region_State_Dist_Alloc__c>>();
        if(!lstDistAlloc.isEmpty()){
            for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : lstDistAlloc){
                if(mapOfStateAndDistAlloc.containsKey(distAlloc.Brand_Country_Region_State_Allocation__r.Id)){
                    mapOfStateAndDistAlloc.get(distAlloc.Brand_Country_Region_State_Allocation__r.Id).add(distAlloc);
                } else {
                    mapOfStateAndDistAlloc.put(distAlloc.Brand_Country_Region_State_Allocation__r.Id, 
                                               new List<Brand_Country_Region_State_Dist_Alloc__c>{distAlloc});
                }
            }
        }
        List<Brand_Country_Region_State_Allocation__c> lstAllStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
        List<Brand_Country_Region_State_Dist_Alloc__c> lstAllDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        if(!lstRegionAlloc.isEmpty()) {
            for(Brand_Country_Region_Allocation__c regionAlloc : lstRegionAlloc){
                regionAlloc.Is_Leaf_Node__c = true;
                for(Brand_Country_Region_State_Allocation__c stateAlloc : regionAlloc.Brand_Country_Region_State_Allocations__r){
                    if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c){
                        stateAlloc.Is_Leaf_Node__c = false;
                        lstAllStateAlloc.add(stateAlloc);
                    }
                    if(!stateAlloc.Is_Leaf_Node__c && mapOfStateAndDistAlloc.containskey(stateAlloc.Id)){
                        for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : mapOfStateAndDistAlloc.get(stateAlloc.Id)){
                            if(distAlloc.Is_Active__c && distAlloc.Is_Leaf_Node__c){
                                distAlloc.Is_Leaf_Node__c = false;
                                lstAllDistAlloc.add(distAlloc);
                            }
                        }
                    }
                }
            }
        }
        lstRegionAlloc = SLT_SB2_BrandCountryRegionAlloc.updateBrandCountryRegionAllocation(lstRegionAlloc);
        lstAllStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.updateLstBrandCountryRegionStateAllocation(lstAllStateAlloc);
        lstAllDistAlloc = SLT_SB2_BrandCountryRegionStateDistAlloc.updateLstBrandCountryRegionStateDistAllocation(lstAllDistAlloc);
        return lstAllStateAlloc;
    }
}