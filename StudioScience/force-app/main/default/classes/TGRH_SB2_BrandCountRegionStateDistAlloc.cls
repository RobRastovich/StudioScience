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
    @description This Class is handler class for Brand Country Region state Dist Alloc Trigger
*/
public class TGRH_SB2_BrandCountRegionStateDistAlloc {
    /**
    *  @description : This method is use to handle before update operations.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation, Map<Id, Brand_Country_Region_State_Dist_Alloc__c> oldDistAllocationdMap
    **/
    public static void handleBeforeUpdate(List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation, 
                                          Map<Id, Brand_Country_Region_State_Dist_Alloc__c> oldDistAllocationdMap) {
        SRV_SB2_BrandCountryRegionStateDistAlloc.changeLeafNodeToState(lstDistAllocation, oldDistAllocationdMap);
    }

    /**
    *  @description : This method is use to handle after insert operations.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation
    **/
    public static void handleAfterInsert(List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation, 
                                         Map<Id, Brand_Country_Region_State_Dist_Alloc__c> newMapOfDistributorAllocation,
                                         Map<Id, Brand_Country_Region_State_Dist_Alloc__c> oldMapOfDistributorAllocation) {
        SRV_SB2_BrandCountryRegionStateDistAlloc.cascadeUpAllocation(lstDistAllocation);
        SRV_SB2_BrandCountryRegionStateDistAlloc.upsertIntoAllocationReport(newMapOfDistributorAllocation, oldMapOfDistributorAllocation);
    }

    /**
    *  @description : This method is use to handle before insert operations.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation
    **/
    public static void handleBeforeInsert(List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation) {
        SRV_SB2_BrandCountryRegionStateDistAlloc.checkDuplicateRecord(lstDistAllocation);
        SRV_SB2_BrandCountryRegionStateDistAlloc.checkAllocationProvidedForLeafNode(lstDistAllocation);
    }

    /**
    *  @description : This method is use to handle after update operations.
    *  @args        : List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation, Map<Id, Brand_Country_Region_State_Dist_Alloc__c> newDistAllocationdMap
    **/
    public static void handleAfterUpdate(List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAllocation,
                                         Map<Id, Brand_Country_Region_State_Dist_Alloc__c> newMapOfDistributorAllocation,
                                         Map<Id, Brand_Country_Region_State_Dist_Alloc__c> oldMapOfDistributorAllocation) {
    	SRV_SB2_BrandCountryRegionStateDistAlloc.cascadeUpAllocation(lstDistAllocation);
		SRV_SB2_BrandCountryRegionStateDistAlloc.upsertIntoAllocationReport(newMapOfDistributorAllocation, oldMapOfDistributorAllocation);
    }
}