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
public class CNT_SB2_DeactivateStateAllocation {
    /**
    *  @description : This method is use to fetch Brand Country Region state allocation info
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Allocation__c> getBrandCountryRegionStateAllocation(String recordId){
        List<Brand_Country_Region_State_Allocation__c> lstBrandAllocation = SLT_SB2_BrandCountryRegionStateAlloc.getBrandCountryRegionStateAllocation(recordId);
        if(!lstBrandAllocation.isEmpty()){
            return lstBrandAllocation;
        }
        return null;
    }
    
    /**
    *  @description : This method is use to deactivate Brand Country Region State Allocation
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Allocation__c>
    **/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Allocation__c> deactivateStateAllocation(String recordId){
        List<Brand_Country_Region_State_Allocation__c> lstBrandCountryRegionStateAllocation = new List<Brand_Country_Region_State_Allocation__c>();
		Brand_Country_Region_State_Allocation__c newBrandCountryRegionStateAllocation = new Brand_Country_Region_State_Allocation__c();
        newBrandCountryRegionStateAllocation.Id = recordId;
        newBrandCountryRegionStateAllocation.Is_Active__c = false;
        lstBrandCountryRegionStateAllocation.add(newBrandCountryRegionStateAllocation);
        lstBrandCountryRegionStateAllocation = SLT_SB2_BrandCountryRegionStateAlloc.updateLstBrandCountryRegionStateAllocation(lstBrandCountryRegionStateAllocation);
        return lstBrandCountryRegionStateAllocation;
    }
    
    /**
    *  @description : This method is use to fetch Brand Country Region state Distributor allocation info
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
    **/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Dist_Alloc__c> getBrandCountryRegionStateDistributorAllocation(String recordId){
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAllocation = SLT_SB2_BrandCountryRegionStateDistAlloc.getBrandCountryRegionStateDistAllocation(recordId);
        if(!lstDistributorAllocation.isEmpty()){
            return lstDistributorAllocation;
        }
        return null;
    }
    
    /**
    *  @description : This method is use to deactivate Brand Country Region State Distributor Allocation
    *  @args        : String record Id
    *  @return      : List<Brand_Country_Region_State_Dist_Alloc__c>
    **/
    @AuraEnabled
    public static List<Brand_Country_Region_State_Dist_Alloc__c> deactivateDistributorAllocation(String recordId){
        List<Brand_Country_Region_State_Dist_Alloc__c> lstDistributorAllocation = new List<Brand_Country_Region_State_Dist_Alloc__c>();
		Brand_Country_Region_State_Dist_Alloc__c newDistributorAllocation = new Brand_Country_Region_State_Dist_Alloc__c();
        newDistributorAllocation.Id = recordId;
        newDistributorAllocation.Is_Active__c = false;
        lstDistributorAllocation.add(newDistributorAllocation);
        lstDistributorAllocation = SLT_SB2_BrandCountryRegionStateDistAlloc.updateLstBrandCountryRegionStateDistAllocation(lstDistributorAllocation);
        return lstDistributorAllocation;
    }
}