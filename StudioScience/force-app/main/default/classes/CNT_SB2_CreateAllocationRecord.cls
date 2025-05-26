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
    @description This class is used to create allocation records from lightning component.
*/
public without sharing class CNT_SB2_CreateAllocationRecord {

    /**
    *  @description : This method is use to create Brand_Country_Allocation__c record.
    *  @args        : Brand_Country_Allocation__c recordToInsert
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> createBrandCountryAllocation(Brand_Country_Allocation__c recordToInsert, String recordName) {
        try {
            recordToInsert.Name = recordName;
            insert recordToInsert;
            return new Map<String, Object>{'Id' => recordToInsert.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }

    /**
    *  @description : This method is use to create Brand_Country_Region_Allocation__c record.
    *  @args        : Brand_Country_Region_Allocation__c recordToInsert
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> createBrandCountryRegionAllocation(Brand_Country_Region_Allocation__c recordToInsert, String recordName) {
        try {
            recordToInsert.Name = recordName;
            insert recordToInsert;
            return new Map<String, Object>{'Id' => recordToInsert.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }

    /**
    *  @description : This method is use to create Brand_Country_Region_State_Allocation__c record.
    *  @args        : Brand_Country_Region_State_Allocation__c recordToInsert
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> createBrandCountryRegionStateAllocation(Brand_Country_Region_State_Allocation__c recordToInsert, String recordName) {
        try {
            recordToInsert.Name = recordName;
            insert recordToInsert;
            return new Map<String, Object>{'Id' => recordToInsert.Id}; 
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }

    /**
    *  @description : This method is use to create Brand_Country_Region_State_Dist_Alloc__c record.
    *  @args        : Brand_Country_Region_State_Dist_Alloc__c recordToInsert
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> createBrandCountryRegionStateDistAlloc(Brand_Country_Region_State_Dist_Alloc__c recordToInsert) {
        try {
            insert recordToInsert;
            return new Map<String, Object>{'Id' => recordToInsert.Id};    
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }

}