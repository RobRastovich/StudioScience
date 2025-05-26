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
    @date 20/04/2020
    @description This Class is Service class for Brand Trigger
*/
public class SRV_SB2_Brand {
    /**
    *  @description : This method is use to check for duplicate record on brand
    *  @args        : List Brand__c
    *  @return      : void
    **/
    public static void checkDuplicateAllocation(List<Brand__c> lstBrand, Map<Id, Brand__c> oldBrandMap) {
    	Set<String> lstExistingBrand = getExistingBrand();
        for(Brand__c newBrandAllocation : lstBrand) {
            if(oldBrandMap == null && !newBrandAllocation.Is_Active__c){
                newBrandAllocation.addError('Brand should be active');
            } else
            if((oldBrandMap == null || 
                (oldBrandMap.get(newBrandAllocation.Id).Name != newBrandAllocation.Name)) && lstExistingBrand.contains(newBrandAllocation.Name.toLowerCase())){
                newBrandAllocation.addError(Label.SB2_Brand_Duplicate_Error);
            }
        }
        
    }
    
    public static void deactivateBrandAllocationForBrand(List<Brand__c> lstBrand) {
        Set<Id> setBrandId = new Set<Id>();
        for(Brand__c newBrand : lstBrand) {
            if(!newBrand.Is_Active__c) {
                setBrandId.add(newBrand.Id);
            }
        }
        List<Brand_Allocation__c> lstBrandAllocation = getExistingBrandAllocationForBrand(setBrandId);
        if(!lstBrandAllocation.isEmpty()) {
            for(Brand_Allocation__c brandAllocation : lstBrandAllocation) {
                brandAllocation.Is_Active__c = false;
            }
            update lstBrandAllocation;
        }
        
    }
    
    /**
    *  @description : This method is use to get already Brand ALlocation for particular brand
    *  @args        : void
    *  @return      : List<Brand_Allocation__c>
    **/
    private static List<Brand_Allocation__c> getExistingBrandAllocationForBrand(Set<Id> setBrandId) {
		List<Brand_Allocation__c> lstExistingBrand = SLT_SB2_BrandAllocation.getExistingBrandAllocation(setBrandId);
        return lstExistingBrand;
    }
    /**
    *  @description : This method is use to get already Brand ALlocation for particular brand
    *  @args        : void
    *  @return      : Set<String>
    **/
    private static Set<String> getExistingBrand() {
		List<Brand__c> lstExistingBrand = SLT_SB2_Brand.getExistingBrand();
        Set<String> lstBrandName = new Set<String>();
        for(Brand__c existingBrand : lstExistingBrand) {
            lstBrandName.add(existingBrand.name.toLowerCase());
        }
        return lstBrandName;
    }
    
    /**
    *  @description : This method is use to ensure that an inactive record can't be activate again.
    *  @args        : List<Brand__c> lstStates, Map<Id, Brand__c> oldStatesMap
    **/
    public static void checkActivateBrand(List<Brand__c> lstBrand, Map<Id, Brand__c> oldBrandMap) {
        for(Brand__c Brand : lstBrand) {
            if(!oldBrandMap.get(Brand.Id).Is_Active__c && Brand.Is_Active__c) {
                Brand.addError('You cannot mark a Brand active again if it is marked as inactive.');
            }
        }
    }
}