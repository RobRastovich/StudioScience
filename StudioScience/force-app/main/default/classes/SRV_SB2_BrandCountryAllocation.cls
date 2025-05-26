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
    @author BeamSuntory\
    @version V_1.0
    @date 29/04/2020
    @description This service class is for Brand Country Allocation
*/
public class SRV_SB2_BrandCountryAllocation {

    /**
    *  @description : This method is use to set allocation name.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    **/
    public static void setAllocationName(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        Set<Id> countryIds = new Set<Id>();
        Set<Id> brandAllocationIds = new Set<Id>();
        
        for(Brand_Country_Allocation__c allocation : lstBrandCountryAllocation) {
            if(String.isBlank(allocation.Name)) {
                countryIds.add(allocation.Country__c);
                brandAllocationIds.add(allocation.Brand_Allocation__c);
            }
        }

        if(!countryIds.isEmpty() && !brandAllocationIds.isEmpty()) {
            Map<Id, Country__c> countryMap = SLT_SB2_Country.getCountryMap(countryIds);
            Map<Id, Brand_Allocation__c> brandAllocationMap = SLT_SB2_BrandAllocation.getBrandAllocationMap(brandAllocationIds);
            
            for(Brand_Country_Allocation__c allocation : lstBrandCountryAllocation) {
                if(String.isBlank(allocation.Name)) {
                    String brandAllocationName = brandAllocationMap.get(allocation.Brand_Allocation__c).Name;
                    String countryAlias = countryMap.get(allocation.Country__c).Alias__c;
                    allocation.Name = brandAllocationName + SB2_Constants.SEPERATOR + countryAlias;    
                }
            }
        }
    }

    /**
    *  @description : This method is use to check duplicate entry on insert.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    **/
    public static void checkDuplicateRecord(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        List<Brand_Country_Allocation__c> existingAllocationList = getExistingRecords(lstBrandCountryAllocation);
        if(!existingAllocationList.isEmpty()) {
            Set<String> existingAllocationSet = new Set<String>();
            for(Brand_Country_Allocation__c exisitingAllocation : existingAllocationList) {
                existingAllocationSet.add(exisitingAllocation.Brand_Allocation__c + ' - ' + exisitingAllocation.Country__c);
            }

            for(Brand_Country_Allocation__c newAllocation : lstBrandCountryAllocation) {
                
                String relatedRecordKey = newAllocation.Brand_Allocation__c + ' - ' + newAllocation.Country__c;
                if(existingAllocationSet.contains(relatedRecordKey)) {
                    newAllocation.addError(Label.Allocation_Duplicate_Message);
                }
            }
        }
    }

    /**
    *  @description : This method is use to check if record is leaf node than allocation should be there.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    **/
    public static void checkAllocationProvidedForLeafNode(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        for(Brand_Country_Allocation__c newAllocation : lstBrandCountryAllocation) {
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
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    **/
    public static void cascadeUpAllocation(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        Set<Id> brandAlloactionIds = new Set<Id>();
        Boolean isAfterUpdate = Trigger.isAfter && Trigger.isUpdate;
        for(Brand_Country_Allocation__c newAllocation : lstBrandCountryAllocation ) {
            if(newAllocation.Is_Leaf_Node__c || isAfterUpdate) {
                brandAlloactionIds.add(newAllocation.Brand_Allocation__c);
            }
        }
        if(!brandAlloactionIds.isEmpty()) {
            List<AggregateResult> lstResult = SLT_SB2_BrandCountryAlloc.getBrandCountryAllocationByBrandAllocation(brandAlloactionIds);

            List<Brand_Allocation__c> recordsToUpdate = new List<Brand_Allocation__c>();

            if(!lstResult.isEmpty()) {
                for(AggregateResult result : lstResult) {
                    recordsToUpdate.add(
                        new Brand_Allocation__c(
                            Id = (Id) result.get('Brand_Allocation__c'), 
                            Allocation_Per_Interval__c = (Decimal) result.get('expr0'),
                            Used_Allocations_Per_Interval__c = (Decimal) result.get('expr1'),
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

    /**
    *  @description : This helper method is use to fetch existing records.
    *  @args        : List<Brand_Country_Allocation__c> lstBrandCountryAllocation
    *  @return      : List<Brand_Country_Allocation__c>
    **/
    private static List<Brand_Country_Allocation__c> getExistingRecords(List<Brand_Country_Allocation__c> lstBrandCountryAllocation) {
        Set<Id> brandAllocationIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        for(Brand_Country_Allocation__c allocation : lstBrandCountryAllocation) {
            brandAllocationIds.add(allocation.Brand_Allocation__c);
            countryIds.add(allocation.Country__c);
        }
        return SLT_SB2_BrandCountryAlloc.getBrandCountrAllocationByBrandAllocationAndCountry(brandAllocationIds, countryIds);
    }

}