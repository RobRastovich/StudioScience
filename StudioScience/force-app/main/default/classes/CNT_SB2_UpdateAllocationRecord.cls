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
    @date 06/05/2020
    @description This class is used to updated allocation records from lightning component.
*/
public without sharing class CNT_SB2_UpdateAllocationRecord {

    /**
    *  @description : This method is use to update Brand_Country_Allocation__c record.
    *  @args        : Id recordId, Integer allocation
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> updateDistributorAllocation(Id recordId, Integer allocation) {
        try {
            Brand_Country_Region_State_Dist_Alloc__c distributorAllocation = new Brand_Country_Region_State_Dist_Alloc__c();
            distributorAllocation.Id = recordId;
            distributorAllocation.Is_Leaf_Node__c = true;
            distributorAllocation.Allocations_Per_Interval__c = allocation;
            update distributorAllocation;
            return new Map<String,Object>{'Id' => distributorAllocation.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }


    /**
    *  @description : This method is use to update Brand_Country_Allocation__c record.
    *  @args        : Id recordId, Integer allocation
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> updateStateAllocation(Id recordId, Integer allocation) {
        try {
            Brand_Country_Region_State_Allocation__c stateAllocation = new Brand_Country_Region_State_Allocation__c();
            stateAllocation.Id = recordId;
            stateAllocation.Is_Leaf_Node__c = true;
            stateAllocation.Allocations_Per_Interval__c = allocation;
            update stateAllocation;
            return new Map<String,Object>{'Id' => stateAllocation.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
    
    /**
    *  @description : This method is use to update Brand_Country_Allocation__c record.
    *  @args        : Id recordId, Integer allocation
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> updateRegionAllocation(Id recordId, Integer allocation) {
        try {
            Brand_Country_Region_Allocation__c regionAllocation = new Brand_Country_Region_Allocation__c();
            regionAllocation.Id = recordId;
            regionAllocation.Is_Leaf_Node__c = true;
            regionAllocation.Allocations_Per_Interval__c = allocation;
            update regionAllocation;
            return new Map<String,Object>{'Id' => regionAllocation.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
    
    /**
    *  @description : This method is use to update Brand_Country_Allocation__c record.
    *  @args        : Id recordId, Integer allocation
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> updateCountryAllocation(Id recordId, Integer allocation) {
        try {
            Brand_Country_Allocation__c countryAllocation = new Brand_Country_Allocation__c();
            countryAllocation.Id = recordId;
            countryAllocation.Is_Leaf_Node__c = true;
            countryAllocation.Allocations_Per_Interval__c = allocation;
            update countryAllocation;
            return new Map<String,Object>{'Id' => countryAllocation.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
}