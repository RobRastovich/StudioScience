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
    @description This Class is handler class for Brand Country Region state Allocation Trigger
*/
public class SRV_SB2_BrandCountryRegionStateAlloc {

    /**
    *  @description : This method is use to set allocation name.
    *  @args        : List<Brand_Country_Region_State_Allocation__c> lstStateAllocation
    **/
    public static void setAllocationName(List<Brand_Country_Region_State_Allocation__c> lstStateAllocation) {
        Set<Id> stateIds = new Set<Id>();
        Set<Id> regionAllocationIds = new Set<Id>();
        
        for(Brand_Country_Region_State_Allocation__c allocation : lstStateAllocation) {
            if(String.isBlank(allocation.Name)) {
                stateIds.add(allocation.State__c);
                regionAllocationIds.add(allocation.Brand_Country_Region_Allocation__c);
            }
        }

        if(!stateIds.isEmpty() && !regionAllocationIds.isEmpty()) {
            Map<Id, State__c> stateMap = SLT_SB2_State.getStateMap(stateIds);
            Map<Id, Brand_Country_Region_Allocation__c> regionAllocationMap = SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationMap(regionAllocationIds);
            
            for(Brand_Country_Region_State_Allocation__c allocation : lstStateAllocation) {
                if(String.isBlank(allocation.Name)) {
                    String regionAllocationName = regionAllocationMap.get(allocation.Brand_Country_Region_Allocation__c).Name;
                    if(stateMap.containskey(allocation.State__c)) {
                        String stateAlias = stateMap.get(allocation.State__c).Alias__c;
                        allocation.Name = regionAllocationName + SB2_Constants.SEPERATOR + stateAlias;  
                    }
                }
            }
        }
    }
    
    /**
    *  @description : This method is use to update Brand Country Region State Distributor Allocation
    *  @args        : List Brand_Country_Region_State_Allocation__c
    *  @return      : void
    **/
    public static void updateRespectiveDistributorAllocation(List<Brand_Country_Region_State_Allocation__c> lstRecord) {
        Set<Id> setBrandCountryRegionStateAllocation = new Set<Id>();
        for(Brand_Country_Region_State_Allocation__c brandCountryRegionStateAllocaton : lstRecord) {
            if(!brandCountryRegionStateAllocaton.Is_Active__c) {
                setBrandCountryRegionStateAllocation.add(brandCountryRegionStateAllocaton.Id);
            }
        }
        
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAllocation = 
            SLT_SB2_BrandCountryRegionStateDistAlloc.getBrandCountryRegionStateDistAllocationFromState(setBrandCountryRegionStateAllocation);
        for(Brand_Country_Region_State_Dist_Alloc__c distributorAllocation : lstDistributorAllocation){
            distributorAllocation.Is_Active__c = false;
        }
        SLT_SB2_BrandCountryRegionStateDistAlloc.updateLstBrandCountryRegionStateDistAllocation(lstDistributorAllocation);
    }

    /**
    *  @description : This method is use to check duplicate entry on insert.
    *  @args        : List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation
    **/
    public static void checkDuplicateRecord(List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation) {
        List<Brand_Country_Region_State_Allocation__c> existingAllocationList = getExistingRecords(lstBrandCountryRegionStateAllocation);
        if(!existingAllocationList.isEmpty()) {
            Set<String> existingAllocationSet = new Set<String>();
            for(Brand_Country_Region_State_Allocation__c exisitingAllocation : existingAllocationList) {
                existingAllocationSet.add(exisitingAllocation.Brand_Country_Region_Allocation__c + ' - ' + exisitingAllocation.State__c);
            }

            for(Brand_Country_Region_State_Allocation__c newAllocation : lstBrandCountryRegionStateAllocation) {
                String relatedRecordKey = newAllocation.Brand_Country_Region_Allocation__c + ' - ' + newAllocation.State__c;
                if(existingAllocationSet.contains(relatedRecordKey)) {
                    newAllocation.addError(Label.Allocation_Duplicate_Message);
                }
            }
        }
    }

    /**
    *  @description : This method is use to cascade up the allocation per interval.
    *  @args        : List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation
    **/
    public static void cascadeUpAllocation(List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation) {
        Set<Id> brandCountryRegionAlloactionIds = new Set<Id>();
        Boolean isAfterUpdate = Trigger.isAfter && Trigger.isUpdate;
        for(Brand_Country_Region_State_Allocation__c newAllocation : lstBrandCountryRegionStateAllocation ) {
            if(newAllocation.Is_Leaf_Node__c || isAfterUpdate) {
                brandCountryRegionAlloactionIds.add(newAllocation.Brand_Country_Region_Allocation__c);
            }
        }
        if(!brandCountryRegionAlloactionIds.isEmpty()) {
            List<AggregateResult> lstResult = SLT_SB2_BrandCountryRegionStateAlloc.getBrandCountryRegionStateAllocationByBrandCountryRegionAllocation(brandCountryRegionAlloactionIds);
            
            List<Brand_Country_Region_Allocation__c> recordsToUpdate = new List<Brand_Country_Region_Allocation__c>();
            
            if(!lstResult.isEmpty()) {
                for(AggregateResult result : lstResult) {
                    recordsToUpdate.add(
                        new Brand_Country_Region_Allocation__c(
                            Id = (Id) result.get('Brand_Country_Region_Allocation__c'), 
                            Allocations_Per_Interval__c = (Decimal) result.get('expr0')
                        )
                    );
                }
            }

            if(!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
    }

    /**
    *  @description : This method is use to check if record is leaf node than allocation should be there.
    *  @args        : List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation
    **/
    public static void checkAllocationProvidedForLeafNode(List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation) {
        for(Brand_Country_Region_State_Allocation__c newAllocation : lstBrandCountryRegionStateAllocation) {
            if(newAllocation.Is_Leaf_Node__c){
                if(newAllocation.Allocations_Per_Interval__c == null) {
                    newAllocation.addError(Label.Mandatory_Allocation_Message_for_Leaf_Node);
                }
                // else if(newAllocation.Allocations_Per_Interval__c < 1) {
                //     newAllocation.addError(Label.Minimum_Allocation_Error_Message);
                // }
            }
        }
    }

    /**
    *  @description : This method is use to create distributor allocation records.
    *  @args        : Map<Id, Brand_Country_Region_State_Allocation__c> newStateAllocationMap
    **/
    public static void createDistributorAllocationRecords(Map<Id, Brand_Country_Region_State_Allocation__c> newStateAllocationMap) {
        List<Brand_Country_Region_State_Allocation__c> lstObj = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithStateAndCountry(newStateAllocationMap.keySet());
        
        Map<String, Id> associationMap = new Map<String, Id>();
        Set<String> states = new Set<String>();
        Set<String> countries = new Set<String>();

        for(Brand_Country_Region_State_Allocation__c all : lstObj) {
            System.debug('Is_Record_Copied__c--'+all.Is_Record_Copied__c);
            if(!all.Is_Record_Copied__c) {
                String key = all.Name + (all.State__r.Name + ' - ' + all.State__r.Country__r.Name).toUpperCase();
                states.add(all.State__r.Name);
                countries.add(all.State__r.Country__r.Name);
                associationMap.put(key, all.Id);   
            }
        }
		System.debug('associationMap--'+associationMap);
        if(!associationMap.isEmpty()) {
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
            
            List<Account> lstAccount = SLT_Account.getAccountsByStateCountryRecordType(recordTypeId, states, countries);
            List<Brand_Country_Region_State_Dist_Alloc__c> distributorAllocation = new List<Brand_Country_Region_State_Dist_Alloc__c>();
            for(Brand_Country_Region_State_Allocation__c stateAllocation : newStateAllocationMap.values()) {
                for(Account acc : lstAccount) {
                    String key = stateAllocation.Name + (acc.BillingState + ' - ' + acc.BillingCountry).toUpperCase();
                    if(associationMap.containsKey(key)) {
                        distributorAllocation.add(new Brand_Country_Region_State_Dist_Alloc__c(
                                Account__c = acc.Id, 
                                Brand_Country_Region_State_Allocation__c = associationMap.get(key)
                            )
                        );
                    }
            	}
            }
            
            System.debug('distributorAllocation'+distributorAllocation);
            if(!distributorAllocation.isEmpty()) {
                insert distributorAllocation;
            }
        }
    }

    public static void upsertIntoAllocationReport(Map<Id, Brand_Country_Region_State_Allocation__c> newMapOfStateAllocation, Map<Id, Brand_Country_Region_State_Allocation__c> oldMapOfStateAllocation) {
        Boolean isAfterInsert = Trigger.isInsert && Trigger.isAfter;
        Boolean isAfterUpdate = Trigger.isUpdate && Trigger.isAfter;
        List<Allocation_Report__c> lstAllocationReportToInsert = new List<Allocation_Report__c>();
        Set<Id> stateAllocationIds = new Set<Id>();
        for(Brand_Country_Region_State_Allocation__c stateAllocation : newMapOfStateAllocation.values()){
            if(isAfterInsert && stateAllocation.Is_Leaf_Node__c) {
                Allocation_Report__c allocationReport = new Allocation_Report__c();
                allocationReport.Brand_Allocation__c = stateAllocation.Brand_Allocation__c;
                allocationReport.State_Allocation__c = stateAllocation.Id;
                allocationReport.Region_Allocation__c = stateAllocation.Brand_Country_Region_Allocation__c;
                allocationReport.Country_Allocation__c = stateAllocation.Country_Allocation__c;
                allocationReport.Barrels_Allocated__c = stateAllocation.Allocations_Per_Interval__c;
                allocationReport.Barrels_Used__c = stateAllocation.Used_Allocations__c;
                allocationReport.Leaf_Node_Status__c = 'Active';
                lstAllocationReportToInsert.add(allocationReport);
            } else if(isAfterUpdate 
                      && stateAllocation.Is_Leaf_Node__c 
                      && (stateAllocation.Allocations_Per_Interval__c != oldMapOfStateAllocation.get(stateAllocation.Id).Allocations_Per_Interval__c
                          || stateAllocation.Used_Allocations__c != oldMapOfStateAllocation.get(stateAllocation.Id).Used_Allocations__c
                         || !stateAllocation.Is_Active__c)
                     ) {
                         stateAllocationIds.add(stateAllocation.Id);
                     }
            
        }
        
        if(!lstAllocationReportToInsert.isEmpty() && stateAllocationIds.isEmpty()) {
            insert lstAllocationReportToInsert;
        }
        
        if(!stateAllocationIds.isEmpty()) {
            List<Allocation_Report__c> lstAllocationReportToUpdate = [Select Id, Barrels_Allocated__c, Barrels_Used__c, Leaf_Node_Status__c, State_Allocation__c FROM Allocation_Report__c WHERE State_Allocation__c IN :stateAllocationIds];
            for(Allocation_Report__c allocationReport : lstAllocationReportToUpdate) {
                if(newMapOfStateAllocation.containsKey(allocationReport.State_Allocation__c)) {
                    allocationReport.Barrels_Allocated__c = newMapOfStateAllocation.get(allocationReport.State_Allocation__c).Allocations_Per_Interval__c;
                    allocationReport.Barrels_Used__c = newMapOfStateAllocation.get(allocationReport.State_Allocation__c).Used_Allocations__c;
                    allocationReport.Leaf_Node_Status__c = newMapOfStateAllocation.get(allocationReport.State_Allocation__c).Is_Active__c ? 'Active' : 'Inactive';
                }
            }
            if(!lstAllocationReportToUpdate.isEmpty()) {
                update lstAllocationReportToUpdate;
            }
        }
        
    }
    
    /**
    *  @description : This helper method is use to fetch existing records.
    *  @args        : List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionAllocation
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    private static List<Brand_Country_Region_State_Allocation__c> getExistingRecords(List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation) {
        Set<Id> brandCountryRegionAllocationIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        for(Brand_Country_Region_State_Allocation__c allocation : lstBrandCountryRegionStateAllocation) {
            brandCountryRegionAllocationIds.add(allocation.Brand_Country_Region_Allocation__c);
            stateIds.add(allocation.State__c);
        }
        return SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationByRegionAllocationAndState(brandCountryRegionAllocationIds, stateIds);
    }
    /**
    *  @description : This method is use to cascade up the allocation per interval if state is marked as inactive.
    *  @args        : List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation
    **/
    public static void cascadeUpAllocationForIsActive(List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation) {
        Set<Id> brandCountryRegionAlloactionIds = new Set<Id>();
        Boolean isAfterUpdate = Trigger.isAfter && Trigger.isUpdate;
        for(Brand_Country_Region_State_Allocation__c newAllocation : lstBrandCountryRegionStateAllocation ) {
            if(isAfterUpdate) {
                brandCountryRegionAlloactionIds.add(newAllocation.Brand_Country_Region_Allocation__c);
            }
        }
        if(!brandCountryRegionAlloactionIds.isEmpty()) {
            List<AggregateResult> lstResult = SLT_SB2_BrandCountryRegionStateAlloc.getBrandCountryRegionStateAllocationByBrandCountryRegionAllocation(brandCountryRegionAlloactionIds);
            
            List<Brand_Country_Region_Allocation__c> recordsToUpdate = new List<Brand_Country_Region_Allocation__c>();
            
            if(!lstResult.isEmpty()) {
                for(AggregateResult result : lstResult) {
                    recordsToUpdate.add(
                        new Brand_Country_Region_Allocation__c(
                            Id = (Id) result.get('Brand_Country_Region_Allocation__c'), 
                            Allocations_Per_Interval__c = (Decimal) result.get('expr0'),
                            Used_Allocations__c = (Decimal) result.get('expr1'),
                            Cancelled_Allocations__c = (Decimal) result.get('expr2'),
                            Carry_Forward_Units__c = (Decimal) result.get('expr3')
                        )
                    );
                }
            } else {
                List<Brand_Country_Region_Allocation__c> regionAllocationsToUpdate = SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationMap(brandCountryRegionAlloactionIds).values();
                for(Brand_Country_Region_Allocation__c regionAllocation : regionAllocationsToUpdate) {
                    recordsToUpdate.add(
                        new Brand_Country_Region_Allocation__c(
                            Id = regionAllocation.Id,
                            Allocations_Per_Interval__c = 0,
                            Used_Allocations__c = 0
                        )
                    );
                }
            }

            if(!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
    }
}