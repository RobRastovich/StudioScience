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
    @date 08/06/2020
    @description This controller class is used to transfer geographical hierarchy.
*/
public without sharing class CNT_SB2_TransferHierarchy {
    
    @AuraEnabled
    public static Map<String, Object> getHierarchicalData() {
        Map<String, Object> mapToReturn = new Map<String, Object>();
        
        List<State__c> lstState = [SELECT
                                   	Id, Name, Region__c, Country__c, Region__r.Name, Country__r.Name 
                                   FROM 
                                   	State__c 
                                   WHERE 
                                   	IsActive__c = TRUE 
                                   AND 
                                   	Region__r.Name != 'Military' 
                                   AND 
                                   	Region__r.Name != 'National Accounts'
                                   AND
                                   	Region__c IN (Select Region__c From Brand_Country_Region_Allocation__c) 
                                   ORDER BY 
                                   	Country__r.Name, Region__r.Name, Name];
        
        Map<String, Id> countryMap = new Map<String, Id>();
        Map<String, Id> regionMap = new Map<String, Id>();
        Map<String, Id> stateMap = new Map<String, Id>();
        Map<String, Map<String, Set<String>>> hierarchicalMap = new Map<String, Map<String, Set<String>>>();
        
        for(State__c state : lstState) {
            if(hierarchicalMap.containsKey(state.Country__r.Name)) {
                Map<String, Set<String>> regionStateMap = hierarchicalMap.get(state.Country__r.Name);
                if(regionStateMap.containsKey(state.Region__r.Name)) {
                    Set<String> states = regionStateMap.get(state.Region__r.Name);
                    states.add(state.Name);
                    regionStateMap.put(state.Region__r.Name, states);
                } else {
                    regionStateMap.put(state.Region__r.Name, new Set<String>{state.Name});
                }
                hierarchicalMap.put(state.Country__r.Name, regionStateMap);
            } else {
                hierarchicalMap.put(state.Country__r.Name, new Map<String, Set<String>>{
                    state.Region__r.Name => new Set<String>{state.Name}
                });
            }
            countryMap.put(state.Country__r.Name, state.Country__c);
            regionMap.put(state.Country__r.Name + '-' + state.Region__r.Name, state.Region__c);
            stateMap.put(state.Country__r.Name + '-' + state.Region__r.Name + '-' + state.Name, state.Id);
        }
        
        mapToReturn.put('countries', countryMap);
        mapToReturn.put('regions', regionMap);
        mapToReturn.put('states', stateMap);
        mapToReturn.put('hierarchy', hierarchicalMap);
        
        return mapToReturn;
    }
    
    @AuraEnabled
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getDistributors(String stateId) {
        Set<String> brandAllocationIds = SRV_SB2_BrandAllocation.getBrandAllocationIdsForCurrentTimePeriod();
        Map<Id, Brand_Country_Region_State_Allocation__c> stateAllocations = new Map<Id, Brand_Country_Region_State_Allocation__c>([Select Id From Brand_Country_Region_State_Allocation__c Where Is_Active__c = true AND State__c = :stateId]);
        List<Brand_Country_Region_State_Dist_Alloc__c> distributorAllocations = [Select Id, Account__r.Name, Account__c, Brand_Country_Region_State_Allocation__r.Name FROM Brand_Country_Region_State_Dist_Alloc__c Where Is_Active__c = true AND Brand_Country_Region_State_Allocation__c IN :stateAllocations.keySet() AND Brand_Allocation__c IN :brandAllocationIds];
        return distributorAllocations;
    }
    
    @AuraEnabled
    public static Map<String, String> transferState(String countryId, String oldRecordId, String oldParentId, String newParentId, String transferType) {
        Set<String> brandAllocationIds = SRV_SB2_BrandAllocation.getBrandAllocationIdsForCurrentTimePeriod();
        Map<Id, Brand_Country_Region_State_Dist_Alloc__c> distributorAllocationsToUpdate = new Map<Id, Brand_Country_Region_State_Dist_Alloc__c>();
        List<Brand_Country_Region_State_Dist_Alloc__c> distributorAllocationsToInsert = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        List<Brand_Country_Region_State_Allocation__c> stateAllocationsToInsert = new List<Brand_Country_Region_State_Allocation__c>();
        State__c stateToUpdate = SLT_SB2_State.getStateById(oldRecordId);
        State__c stateToInsert = stateToUpdate.clone(false, false, false, false);
        List<Brand_Country_Region_State_Allocation__c> stateAllocationsToUpdate = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithDistributorAllocationByBrandAllocationAndState(oldRecordId, brandAllocationIds).values();
        
        stateToUpdate.IsActive__c = false;
        update stateToUpdate;
        
        stateToInsert.Region__c = newParentId;
        stateToInsert.Country__c = countryId;
        
        insert stateToInsert;

        List<Brand_Country_Region_Allocation__c> regionAllocationsToUpdate = SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationByIdAndBrandAllocation(newParentId, brandAllocationIds);
        if(regionAllocationsToUpdate.isEmpty()) {
            throw new AuraHandledException('No allocation record found for selected region.');
        } else {
            for(Brand_Country_Region_Allocation__c regionAllocation : regionAllocationsToUpdate) {
                Boolean isRegionLeafNode = regionAllocation.Is_Leaf_Node__c;
                for(Brand_Country_Region_State_Allocation__c oldStateAllocation : stateAllocationsToUpdate) {
                    if(regionAllocation.Brand_Allocation__c == oldStateAllocation.Brand_Allocation__c) {
                        oldStateAllocation.Is_Active__c = false;
                        Brand_Country_Region_State_Allocation__c newStateAllocation = new Brand_Country_Region_State_Allocation__c();
                        newStateAllocation.State__c = stateToInsert.Id;
                        newStateAllocation.Brand_Country_Region_Allocation__c = regionAllocation.Id;
                        newStateAllocation.Is_Record_Copied__c = true;
                        newStateAllocation.External_Id__c = oldStateAllocation.Id;
                        
                        if(oldStateAllocation.Is_Leaf_Node__c) {
                            if(isRegionLeafNode) {
                                system.debug(regionAllocation);
                                regionAllocation.Allocations_Per_Interval__c += oldStateAllocation.Remaining_Allocations__c;
                            } else {
                                newStateAllocation.Allocations_Per_Interval__c = oldStateAllocation.Remaining_Allocations__c;
                                newStateAllocation.Is_Leaf_Node__c = true;
                            }
                            oldStateAllocation.Allocations_Per_Interval__c = oldStateAllocation.Used_Allocations__c;
                        }
                        
                        for(Brand_Country_Region_State_Dist_Alloc__c oldDistributorAllocation : oldStateAllocation.Brand_Country_Region_State_Dist_Allocs__r) {
                            Brand_Country_Region_State_Dist_Alloc__c newDistributorAllocation = new Brand_Country_Region_State_Dist_Alloc__c();
                            newDistributorAllocation.Account__c = oldDistributorAllocation.Account__c;
                            if(oldDistributorAllocation.Is_Leaf_Node__c) {
                                if(isRegionLeafNode) {
                                    regionAllocation.Allocations_Per_Interval__c += oldDistributorAllocation.Remaining_Allocations__c;
                                } else if(oldStateAllocation.Is_Leaf_Node__c) {
                                    newStateAllocation.Allocations_Per_Interval__c += oldDistributorAllocation.Remaining_Allocations__c;
                                    newStateAllocation.Is_Leaf_Node__c = true;
                                } else {
                                    newDistributorAllocation.Allocations_Per_Interval__c = oldDistributorAllocation.Remaining_Allocations__c;
                                    newDistributorAllocation.Is_Leaf_Node__c = true;
                                }
                                oldDistributorAllocation.Allocations_Per_Interval__c = oldDistributorAllocation.Used_Allocations__c;
                            } else {
                                newDistributorAllocation = oldDistributorAllocation.clone(false, false, false, false);
                            }
                            oldDistributorAllocation.Is_Active__c = false;
                            newDistributorAllocation.Brand_Country_Region_State_Allocation__c = oldStateAllocation.Id;
                            distributorAllocationsToUpdate.put(oldDistributorAllocation.Id, oldDistributorAllocation);
                            distributorAllocationsToInsert.add(newDistributorAllocation);
                        }
                        stateAllocationsToInsert.add(newStateAllocation);
                    }
                }
            }
            
            if(!stateAllocationsToUpdate.isEmpty()) update stateAllocationsToUpdate;
            
            if(!distributorAllocationsToUpdate.isEmpty()) update distributorAllocationsToUpdate.values();
            
            if(!stateAllocationsToInsert.isEmpty()) {
                update regionAllocationsToUpdate;
                insert stateAllocationsToInsert;
                
                for(Brand_Country_Region_State_Allocation__c stateAllocation : stateAllocationsToInsert) {
                    for(Brand_Country_Region_State_Dist_Alloc__c distributorAllocation : distributorAllocationsToInsert) {
                        if(distributorAllocation.Brand_Country_Region_State_Allocation__c == stateAllocation.External_Id__c) {
                            distributorAllocation.Brand_Country_Region_State_Allocation__c = stateAllocation.Id;
                        }
                    }
                }
                
                if(!distributorAllocationsToInsert.isEmpty()) insert distributorAllocationsToInsert;
            }
        }
        return new Map<String, String>{'result' => 'success'};
    }
    
    @AuraEnabled
    public static Map<String, String> transferDistributor(String countryId, String oldRecordId, String oldParentId, String newParentId, String transferType) {
        Set<String> brandAllocationIds = SRV_SB2_BrandAllocation.getBrandAllocationIdsForCurrentTimePeriod();
        Brand_Country_Region_State_Dist_Alloc__c distributorAllocationToUpdate = [SELECT 
                                                                                  Id, Brand_Country_Region_State_Allocation__r.Is_Leaf_Node__c, Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c,
                                                                                  Is_Leaf_Node__c, Is_Active__c, Brand_Allocation__c, Account__c,
                                                                                  Remaining_Allocations__c, Used_Allocations__c, Allocations_Per_Interval__c
                                                                                  FROM
                                                                                  Brand_Country_Region_State_Dist_Alloc__c
                                                                                  WHERE
                                                                                  Id =:oldRecordId];
        Brand_Country_Region_State_Dist_Alloc__c distributorAllocationToInsert = new Brand_Country_Region_State_Dist_Alloc__c();
        List<Brand_Country_Region_State_Allocation__c> lstStateAllocationToUpdate = [SELECT 
                                                                                     Id, Brand_Country_Region_Allocation__r.Is_Leaf_Node__c, Is_Leaf_Node__c, Allocations_Per_Interval__c
                                                                                     FROM 
                                                                                     Brand_Country_Region_State_Allocation__c
                                                                                     WHERE 
                                                                                     State__c = :newParentId
                                                                                     AND 
                                                                                     Brand_Allocation__c IN :brandAllocationIds
                                                                                     AND
                                                                                     Is_Active__c = TRUE];
        if(lstStateAllocationToUpdate.isEmpty()) {
            throw new AuraHandledException('No state allocation record found.');
        } else {
            String regionAllocationId = '';
            Boolean isStateLeafNode = false;
            for(Brand_Country_Region_State_Allocation__c stateAllocation : lstStateAllocationToUpdate) {
                if(distributorAllocationToUpdate.Is_Leaf_Node__c) {
                    if(stateAllocation.Is_Leaf_Node__c) {
                        isStateLeafNode = true;
                        stateAllocation.Allocations_Per_Interval__c += distributorAllocationToUpdate.Remaining_Allocations__c;
                        distributorAllocationToInsert.Is_Leaf_Node__c = false;
                    } else if(stateAllocation.Brand_Country_Region_Allocation__r.Is_Leaf_Node__c) {
                        regionAllocationId = stateAllocation.Brand_Country_Region_Allocation__c;
                    } else {
                        distributorAllocationToInsert.Is_Leaf_Node__c = true;
                        distributorAllocationToInsert.Allocations_Per_Interval__c = distributorAllocationToUpdate.Remaining_Allocations__c;
                    }
                    if(String.isBlank(regionAllocationId)) {
                        distributorAllocationToUpdate.Allocations_Per_Interval__c = distributorAllocationToUpdate.Used_Allocations__c;
                    }
                }
                distributorAllocationToUpdate.Is_Active__c = false;
                distributorAllocationToInsert.Account__c = distributorAllocationToUpdate.Account__c;
                distributorAllocationToInsert.Brand_Country_Region_State_Allocation__c = stateAllocation.Id;
            }
            if(String.isNotBlank(regionAllocationId)) {
                Brand_Country_Region_Allocation__c regionAllocation = [SELECT Id, Allocations_Per_Interval__c FROM Brand_Country_Region_Allocation__c WHERE Id = :regionAllocationId];
                regionAllocation.Allocations_Per_Interval__c += distributorAllocationToUpdate.Remaining_Allocations__c;
                distributorAllocationToUpdate.Allocations_Per_Interval__c = distributorAllocationToUpdate.Used_Allocations__c;
                distributorAllocationToInsert.Is_Leaf_Node__c = false;
                update regionAllocation;
            }
            
            if(isStateLeafNode) {
                update lstStateAllocationToUpdate;
            }
            
            update distributorAllocationToUpdate;
            insert distributorAllocationToInsert;
        }
        return new Map<String, String>{'result' => 'success'};
    }
    
}