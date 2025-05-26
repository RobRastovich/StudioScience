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
    @date 27/04/2020
    @description This service class is created for Brand Country Region State Dist Alloc object.
*/
public class SRV_SB2_BrandCountryRegionStateDistAlloc {
    
    /**
	*  @description : This method is use to move is leaf node from Distributor to State Allocation
	*  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAlloc   
	**/
    public static void changeLeafNodeToState(
        List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAlloc,
        Map<Id, Brand_Country_Region_State_Dist_Alloc__c> mapBrandCountryRegionStateDistAlloc) {

    }

    /**
    *  @description : This method is use to check duplicate entry on insert.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation
    **/
    public static void checkDuplicateRecord(List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation) {
        List<Brand_Country_Region_State_Dist_Alloc__c> existingAllocationList = getExistingRecords(lstBrandCountryRegionStateDistAllocation);
        if(!existingAllocationList.isEmpty()) {
            Set<String> existingAllocationSet = new Set<String>();
            for(Brand_Country_Region_State_Dist_Alloc__c exisitingAllocation : existingAllocationList) {
                existingAllocationSet.add(exisitingAllocation.Brand_Country_Region_State_Allocation__c + ' - ' + exisitingAllocation.Account__c);
            }

            for(Brand_Country_Region_State_Dist_Alloc__c newAllocation : lstBrandCountryRegionStateDistAllocation) {
                String relatedRecordKey = newAllocation.Brand_Country_Region_State_Allocation__c + ' - ' + newAllocation.Account__c;
                if(existingAllocationSet.contains(relatedRecordKey)) {
                    newAllocation.addError(Label.Allocation_Duplicate_Message);
                }
            }
        }
    }

    /**
    *  @description : This method is use to check if record is leaf node than allocation should be there.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation
    **/
    public static void checkAllocationProvidedForLeafNode(List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation) {
        for(Brand_Country_Region_State_Dist_Alloc__c newAllocation : lstBrandCountryRegionStateDistAllocation) {
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
    
    public static void upsertIntoAllocationReport(Map<Id, Brand_Country_Region_State_Dist_Alloc__c> newMapOfDistributorAllocation, Map<Id, Brand_Country_Region_State_Dist_Alloc__c> oldMapOfDistributorAllocation) {
        Boolean isAfterInsert = Trigger.isInsert && Trigger.isAfter;
        Boolean isAfterUpdate = Trigger.isUpdate && Trigger.isAfter;
        List<Allocation_Report__c> lstAllocationReportToInsert = new List<Allocation_Report__c>();
        Set<Id> distributorAllocationIds = new Set<Id>();
        for(Brand_Country_Region_State_Dist_Alloc__c distributorAllocation : newMapOfDistributorAllocation.values()) {
            if(isAfterInsert && distributorAllocation.Is_Leaf_Node__c) {
                Allocation_Report__c allocationReport = new Allocation_Report__c();
                allocationReport.Brand_Allocation__c = distributorAllocation.Brand_Allocation__c;
                allocationReport.Distributor_Allocation__c = distributorAllocation.Id;
                allocationReport.State_Allocation__c = distributorAllocation.Brand_Country_Region_State_Allocation__c;
                allocationReport.Region_Allocation__c = distributorAllocation.Region_Allocation__c;
                allocationReport.Country_Allocation__c = distributorAllocation.Country_Allocation__c;
                allocationReport.Barrels_Allocated__c = distributorAllocation.Allocations_Per_Interval__c;
                allocationReport.Barrels_Used__c = distributorAllocation.Used_Allocations__c;
                allocationReport.Leaf_Node_Status__c = 'Active';
                lstAllocationReportToInsert.add(allocationReport);                
            } else if(isAfterUpdate 
                      && distributorAllocation.Is_Leaf_Node__c 
                      && (distributorAllocation.Allocations_Per_Interval__c != oldMapOfDistributorAllocation.get(distributorAllocation.Id).Allocations_Per_Interval__c
                          || distributorAllocation.Used_Allocations__c != oldMapOfDistributorAllocation.get(distributorAllocation.Id).Used_Allocations__c 
                          || !distributorAllocation.Is_Active__c)
                     ) {
                         distributorAllocationIds.add(distributorAllocation.Id);
                     }
            
        }
        if(!lstAllocationReportToInsert.isEmpty() && distributorAllocationIds.isEmpty()) {
            insert lstAllocationReportToInsert;
        }
        
        if(!distributorAllocationIds.isEmpty()) {
            List<Allocation_Report__c> lstAllocationReportToUpdate = [Select Id, Barrels_Allocated__c, Barrels_Used__c, Leaf_Node_Status__c, Distributor_Allocation__c FROM Allocation_Report__c WHERE Distributor_Allocation__c IN :distributorAllocationIds];
            for(Allocation_Report__c allocationReport : lstAllocationReportToUpdate) {
                if(newMapOfDistributorAllocation.containsKey(allocationReport.Distributor_Allocation__c)) {
                    allocationReport.Barrels_Allocated__c = newMapOfDistributorAllocation.get(allocationReport.Distributor_Allocation__c).Allocations_Per_Interval__c;
                    allocationReport.Barrels_Used__c = newMapOfDistributorAllocation.get(allocationReport.Distributor_Allocation__c).Used_Allocations__c;
                    allocationReport.Leaf_Node_Status__c = newMapOfDistributorAllocation.get(allocationReport.Distributor_Allocation__c).Is_Active__c ? 'Active' : 'Inactive';
                }
            }
            if(!lstAllocationReportToUpdate.isEmpty()) {
                update lstAllocationReportToUpdate;
            }
        }
    }

    /**
    *  @description : This method is use to cascade up the allocation per interval.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation
    **/
    public static void cascadeUpAllocation(List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation) {
        Set<Id> brandCountryRegionStateAlloactionIds = new Set<Id>();
        Boolean isAfterUpdate = Trigger.isAfter && Trigger.isUpdate;
        for(Brand_Country_Region_State_Dist_Alloc__c newAllocation : lstBrandCountryRegionStateDistAllocation ) {
            if(newAllocation.Is_Leaf_Node__c || isAfterUpdate) {
                brandCountryRegionStateAlloactionIds.add(newAllocation.Brand_Country_Region_State_Allocation__c);
            }
        }
        if(!brandCountryRegionStateAlloactionIds.isEmpty()) {
            List<AggregateResult> lstResult = SLT_SB2_BrandCountryRegionStateDistAlloc.getDistAllocByStateAlloc(brandCountryRegionStateAlloactionIds);
            System.debug('---'+lstResult);
            List<Brand_Country_Region_State_Allocation__c> recordsToUpdate = new List<Brand_Country_Region_State_Allocation__c>();
            
            if(!lstResult.isEmpty()) {
                for(AggregateResult result : lstResult) {
                    recordsToUpdate.add(
                        new Brand_Country_Region_State_Allocation__c(
                            Id = (Id) result.get('Brand_Country_Region_State_Allocation__c'), 
                            Allocations_Per_Interval__c = (Decimal) result.get('expr0'),
                            Used_Allocations__c = (Decimal) result.get('expr1'),
                            Cancelled_Allocations__c = (Decimal) result.get('expr2'),
                            Carry_Forward_Units__c  = (Decimal) result.get('expr3')
                        )
                    );
                }
            } else {
                List<Brand_Country_Region_State_Allocation__c> stateAllocationsToUpdate = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationsByIds(brandCountryRegionStateAlloactionIds);
                for(Brand_Country_Region_State_Allocation__c stateAllocation : stateAllocationsToUpdate) {
                    recordsToUpdate.add(
                        new Brand_Country_Region_State_Allocation__c(
                            Id = stateAllocation.Id,
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

    /**
    *  @description : This helper method is use to fetch existing records.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation
    *  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
    **/
    private static List<Brand_Country_Region_State_Dist_Alloc__c> getExistingRecords(List<Brand_Country_Region_State_Dist_Alloc__c> lstBrandCountryRegionStateDistAllocation) {
        Set<Id> brandCountryRegionStateAllocationIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Brand_Country_Region_State_Dist_Alloc__c allocation : lstBrandCountryRegionStateDistAllocation) {
            brandCountryRegionStateAllocationIds.add(allocation.Brand_Country_Region_State_Allocation__c);
            accountIds.add(allocation.Account__c);
        }
        return SLT_SB2_BrandCountryRegionStateDistAlloc.getDistAllocByStateAllocAndAccount(brandCountryRegionStateAllocationIds, accountIds);
    }
}