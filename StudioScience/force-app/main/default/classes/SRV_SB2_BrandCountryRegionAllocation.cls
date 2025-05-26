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
    @date 30/04/2020
    @description This service class is for Brand Country Region Allocation
*/
public class SRV_SB2_BrandCountryRegionAllocation {


    /**
    *  @description : This method is use to set allocation name.
    *  @args        : List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation
    **/
    public static void setAllocationName(List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation) {
        Set<Id> regionIds = new Set<Id>();
        Set<Id> countryAllocationIds = new Set<Id>();
        
        for(Brand_Country_Region_Allocation__c allocation : lstBrandCountryRegionAllocation) {
            if(String.isBlank(allocation.Name)) {
                regionIds.add(allocation.Region__c);
                countryAllocationIds.add(allocation.Brand_Country_Allocation__c);
            }
        }

        if(!regionIds.isEmpty() && !countryAllocationIds.isEmpty()) {
            Map<Id, Region__c> regionMap = SLT_SB2_Region.getRegionMap(regionIds);
            Map<Id, Brand_Country_Allocation__c> countryAllocationMap = SLT_SB2_BrandCountryAlloc.getCountryAllocationMap(countryAllocationIds);
            
            for(Brand_Country_Region_Allocation__c allocation : lstBrandCountryRegionAllocation) {
                if(String.isBlank(allocation.Name)) {
                    String countryAllocationName = countryAllocationMap.get(allocation.Brand_Country_Allocation__c).Name;
                    String regionName = regionMap.get(allocation.Region__c).Name;
                    allocation.Name = countryAllocationName + SB2_Constants.SEPERATOR + regionName;    
                }
            }
        }
    }

    /**
    *  @description : This method is use to check duplicate entry on insert.
    *  @args        : List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation
    **/
    public static void checkDuplicateRecord(List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation) {
        List<Brand_Country_Region_Allocation__c> existingAllocationList = getExistingRecords(lstBrandCountryRegionAllocation);
        if(!existingAllocationList.isEmpty()) {
            Set<String> existingAllocationSet = new Set<String>();
            for(Brand_Country_Region_Allocation__c exisitingAllocation : existingAllocationList) {
                existingAllocationSet.add(exisitingAllocation.Brand_Country_Allocation__c + ' - ' + exisitingAllocation.Region__c);
            }

            for(Brand_Country_Region_Allocation__c newAllocation : lstBrandCountryRegionAllocation) {
                String relatedRecordKey = newAllocation.Brand_Country_Allocation__c + ' - ' + newAllocation.Region__c;
                if(existingAllocationSet.contains(relatedRecordKey)) {
                    newAllocation.addError(Label.Allocation_Duplicate_Message);
                }
            }
        }
    }

    /**
    *  @description : This method is use to check if record is leaf node than allocation should be there.
    *  @args        : List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation
    **/
    public static void checkAllocationProvidedForLeafNode(List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation) {
        for(Brand_Country_Region_Allocation__c newAllocation : lstBrandCountryRegionAllocation) {
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
    *  @description : This method is use to cascade up the allocation per interval.
    *  @args        : List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation
    **/
    public static void cascadeUpAllocation(List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation) {
        Set<Id> brandCountryAlloactionIds = new Set<Id>();
        Boolean isAfterUpdate = Trigger.isAfter && Trigger.isUpdate;
        for(Brand_Country_Region_Allocation__c newAllocation : lstBrandCountryRegionAllocation ) {
            if(newAllocation.Is_Leaf_Node__c || isAfterUpdate) {
                brandCountryAlloactionIds.add(newAllocation.Brand_Country_Allocation__c);
            }
        }
        if(!brandCountryAlloactionIds.isEmpty()) {
            List<AggregateResult> lstResult = SLT_SB2_BrandCountryRegionAlloc.getBrandCountryRegionAllocationByBrandCountryAllocation(brandCountryAlloactionIds);
            
            List<Brand_Country_Allocation__c> recordsToUpdate = new List<Brand_Country_Allocation__c>();
            
            if(!lstResult.isEmpty()) {
                for(AggregateResult result : lstResult) {
                    recordsToUpdate.add(
                        new Brand_Country_Allocation__c(
                            Id = (Id) result.get('Brand_Country_Allocation__c'), 
                            Allocations_Per_Interval__c = (Decimal) result.get('expr0'),
                            Used_Allocations__c = (Decimal) result.get('expr1'),
                            Cancelled_Allocations__c = (Decimal) result.get('expr2'),
                            Carry_Forward_Units__c = (Decimal) result.get('expr3')
                        )
                    );
                }
            }

            if(!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
    }
    
    public static void upsertIntoAllocationReport(Map<Id, Brand_Country_Region_Allocation__c> newMapOfRegionAllocation, Map<Id, Brand_Country_Region_Allocation__c> oldMapOfRegionAllocation) {
        Boolean isAfterInsert = Trigger.isInsert && Trigger.isAfter;
        Boolean isAfterUpdate = Trigger.isUpdate && Trigger.isAfter;
        List<Allocation_Report__c> lstAllocationReportToInsert = new List<Allocation_Report__c>();
        Set<Id> regionAllocationIds = new Set<Id>();
        for(Brand_Country_Region_Allocation__c regionAllocation : newMapOfRegionAllocation.values()){
            if(isAfterInsert && regionAllocation.Is_Leaf_Node__c) {
                Allocation_Report__c allocationReport = new Allocation_Report__c();
                allocationReport.Brand_Allocation__c = regionAllocation.Brand_Allocation__c;
                allocationReport.Region_Allocation__c = regionAllocation.Id;
                allocationReport.Country_Allocation__c = regionAllocation.Brand_Country_Allocation__c;
                allocationReport.Barrels_Allocated__c = regionAllocation.Allocations_Per_Interval__c;
                allocationReport.Barrels_Used__c = regionAllocation.Used_Allocations__c;
                allocationReport.Leaf_Node_Status__c = 'Active';
                lstAllocationReportToInsert.add(allocationReport);
            } else if(isAfterUpdate && regionAllocation.Is_Leaf_Node__c && (regionAllocation.Allocations_Per_Interval__c != oldMapOfRegionAllocation.get(regionAllocation.Id).Allocations_Per_Interval__c
                      || regionAllocation.Used_Allocations__c != oldMapOfRegionAllocation.get(regionAllocation.Id).Used_Allocations__c)) {
                          regionAllocationIds.add(regionAllocation.Id);
                      }
        }
        if(!lstAllocationReportToInsert.isEmpty() && regionAllocationIds.isEmpty()) {
            insert lstAllocationReportToInsert;
        }
        if(!regionAllocationIds.isEmpty()) {
            List<Allocation_Report__c> lstAllocationReportToUpdate = [Select Id, Barrels_Allocated__c, Barrels_Used__c, Region_Allocation__c FROM Allocation_Report__c WHERE Region_Allocation__c IN :regionAllocationIds];
            for(Allocation_Report__c allocationReport : lstAllocationReportToUpdate) {
                if(newMapOfRegionAllocation.containsKey(allocationReport.Region_Allocation__c)) {
                    allocationReport.Barrels_Allocated__c = newMapOfRegionAllocation.get(allocationReport.Region_Allocation__c).Allocations_Per_Interval__c;
                    allocationReport.Barrels_Used__c = newMapOfRegionAllocation.get(allocationReport.Region_Allocation__c).Used_Allocations__c;
                    allocationReport.Leaf_Node_Status__c = 'Active';
                }
            }
            if(!lstAllocationReportToUpdate.isEmpty()) {
                update lstAllocationReportToUpdate;
            }
        }
        
    }
    

    /**
    *  @description : This helper method is use to fetch existing records.
    *  @args        : List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation
    *  @return      : List<Brand_Country_Region_Allocation__c>
    **/
    private static List<Brand_Country_Region_Allocation__c> getExistingRecords(List<Brand_Country_Region_Allocation__c> lstBrandCountryRegionAllocation) {
        Set<Id> brandCountryAllocationIds = new Set<Id>();
        Set<Id> regionIds = new Set<Id>();
        for(Brand_Country_Region_Allocation__c allocation : lstBrandCountryRegionAllocation) {
            brandCountryAllocationIds.add(allocation.Brand_Country_Allocation__c);
            regionIds.add(allocation.Region__c);
        }
        return SLT_SB2_BrandCountryRegionAlloc.getRegionAllocationByCountryAllocationAndRegion(brandCountryAllocationIds, regionIds);
    }
}