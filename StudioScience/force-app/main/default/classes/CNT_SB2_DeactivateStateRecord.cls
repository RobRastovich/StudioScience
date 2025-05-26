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
    @date 24/04/2020
    @description This class is used to deactive a state record
*/
public with sharing class CNT_SB2_DeactivateStateRecord {

    /**
    *  @description : This method is use to deactivate state record.
    *  @args        : String recordId
    *  @return      : State__c
    **/
    @AuraEnabled
    public static State__c deactivateRecord(String recordId) {
        try {
            State__c state = new State__c(Id = recordId);
            state.IsActive__c = false;
            update state;
            List<Brand_Country_Region_State_Dist_Alloc__c> lstDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
            List<Brand_Country_Region_State_Allocation__c> lstStateAlloc = SLT_SB2_BrandCountryRegionStateAlloc.getStateAllocationWithState(new Set<Id> {recordId});
            for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateAlloc){
                stateAlloc.Is_Active__c = false;
                for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : stateAlloc.Brand_Country_Region_State_Dist_Allocs__r){
                    distAlloc.Is_Active__c = false;
                    lstDistAlloc.add(distAlloc);
                }
            }
            SLT_SB2_BrandCountryRegionStateAlloc.updateLstBrandCountryRegionStateAllocation(lstStateAlloc);
            SLT_SB2_BrandCountryRegionStateDistAlloc.updateLstBrandCountryRegionStateDistAllocation(lstDistAlloc);
            return state;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }

}