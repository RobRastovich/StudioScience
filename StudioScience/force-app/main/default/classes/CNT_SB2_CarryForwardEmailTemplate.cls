public class CNT_SB2_CarryForwardEmailTemplate {
    public Id brandAllocationId {get;set;}
    public Boolean hasHierarchy {get; set;}
    public CNT_SB2_CarryForwardEmailTemplate(){
        hasHierarchy = false;
    }
    public Brand_Allocation__c getBrandAlloc(){
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(brandAllocationId);
        return lstBrandAllocation[0];
    }
    
    public Brand_Allocation__c getNewBrandAllocation()  {  
        List<String> nextInterval = new List<String>();
        String yearOfAlloc;
        String programType;
        String brandId;
        Set<String> lstBrandAllocationId = new Set<String>();
        List<String> timePeriod = new List<String>{SB2_Constants.MONTHLY, SB2_Constants.QUARTERLY, SB2_Constants.YEARLY};
            for(Brand_Allocation__c brandAlloc : SLT_SB2_BrandAllocation.getBrandAllocation(brandAllocationId)){
                if(brandAlloc.Is_Carry_Forward__c && brandAlloc.Is_Active__c && brandAlloc.Status__c == 'Expired'){
                    yearOfAlloc = String.valueOf((brandAlloc.Allocation_End_Date__c +1).year());
                    programType = brandAlloc.Program_Type__c;
                    brandId = brandAlloc.Brand__c;
                    nextInterval.add(SB2_Constants.mapOfIntegerMonth.get((brandAlloc.Allocation_End_Date__c +1).month()));
                    nextInterval.add(SB2_Constants.mapOfIntegerQuarter.get((brandAlloc.Allocation_End_Date__c +1).month()));
                    nextInterval.add('Year');
                    lstBrandAllocationId.add(String.valueOf(brandAlloc.Id).subString(0,15));
                }
            }
        List<Brand_Allocation__c> lstNewBrandAllocation = SLT_SB2_BrandAllocation.getSelectedBrandAllocation(brandId, true, yearOfAlloc,
                                                                                                             timePeriod, nextInterval, programType);
        return lstNewBrandAllocation[0];
    }
    public List<allocationWrapper> getAllocationWrapper() {
        List<String> nextInterval = new List<String>();
        String yearOfAlloc;
        String programType;
        String brandId;
        Set<String> lstBrandAllocationId = new Set<String>();
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(brandAllocationId);
        List<String> timePeriod = new List<String>{SB2_Constants.MONTHLY, SB2_Constants.QUARTERLY, SB2_Constants.YEARLY};
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
                if(brandAlloc.Is_Carry_Forward__c && brandAlloc.Is_Active__c){ //&& brandAlloc.Status__c == 'Expired'){
                    yearOfAlloc = String.valueOf((brandAlloc.Allocation_End_Date__c +1).year());
                    programType = brandAlloc.Program_Type__c;
                    brandId = brandAlloc.Brand__c;
                    nextInterval.add(SB2_Constants.mapOfIntegerMonth.get((brandAlloc.Allocation_End_Date__c +1).month()));
                    nextInterval.add(SB2_Constants.mapOfIntegerQuarter.get((brandAlloc.Allocation_End_Date__c +1).month()));
                    nextInterval.add('Year');
                    lstBrandAllocationId.add(String.valueOf(brandAlloc.Id).subString(0,15));
                }
            }
        List<Brand_Allocation__c> lstNewBrandAllocation = SLT_SB2_BrandAllocation.getSelectedBrandAllocation(brandId, true, yearOfAlloc,
                                                                                                             timePeriod, nextInterval, programType);
        map<String, String> mapOfOldNewBrandAlloc = new Map<String, String>();
        if(!lstNewBrandAllocation.isEmpty()){
            for(Integer i=0; i < lstNewBrandAllocation.size(); i++){
                mapOfOldNewBrandAlloc.put(lstBrandAllocation[i].Id, lstNewBrandAllocation[i].Id);
                lstBrandAllocationId.add(String.valueOf(lstNewBrandAllocation[i].Id).subString(0,15));
            }
        }
        List<Brand_Country_Allocation__c> lstCountryAlloc = SLT_SB2_BrandCountryAlloc.getBrandCountryAllocation(lstBrandAllocationId);
        map<String, List<Brand_Country_Allocation__c>> mapOfBrandAndCountryAlloc = new Map<String, List<Brand_Country_Allocation__c>>();
        map<String, List<Brand_Country_Region_Allocation__c>> mapOfCountryAndRegionAlloc = new Map<String, List<Brand_Country_Region_Allocation__c>>();
        Set<Id> setOfRegionAlloc = new Set<Id>();
        for(Brand_Country_Allocation__c countryAlloc : lstCountryAlloc) {
            if(mapOfBrandAndCountryAlloc.containsKey(countryAlloc.Brand_Allocation__c)){
                mapOfBrandAndCountryAlloc.get(countryAlloc.Brand_Allocation__c).add(countryAlloc);
            }else {
                mapOfBrandAndCountryAlloc.put(countryAlloc.Brand_Allocation__c, new List<Brand_Country_Allocation__c> {countryAlloc});
            }
            for(Brand_Country_Region_Allocation__c regionAlloc : countryAlloc.Brand_Country_Region_Allocations__r){
                if(mapOfCountryAndRegionAlloc.containsKey(regionAlloc.Brand_Country_Allocation__c)){
                    mapOfCountryAndRegionAlloc.get(regionAlloc.Brand_Country_Allocation__c).add(regionAlloc);
                } else {
                    mapOfCountryAndRegionAlloc.put(regionAlloc.Brand_Country_Allocation__c, new List<Brand_Country_Region_Allocation__c> {regionAlloc});
                }
                setOfRegionAlloc.add(regionAlloc.Id);
            }
        }
        List<Brand_Country_Region_State_Allocation__c> lstStateALloc = SLT_SB2_BrandCountryRegionStateAlloc.getListBrandCountryRegionStateAllocationFromRegion(setOfRegionAlloc);
        Map<String, List<Brand_Country_Region_State_Allocation__c>> mapOfRegionAndStateAlloc = new Map<String, List<Brand_Country_Region_State_Allocation__c>>();
        map<String, List<Brand_Country_Region_State_Dist_Alloc__c>> mapOfStateAndDistAlloc = new Map<String, List<Brand_Country_Region_State_Dist_Alloc__c>>();
        if(!lstStateALloc.isEmpty()) {
        for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateALloc){
            if(mapOfRegionAndStateAlloc.containsKey(stateAlloc.Brand_Country_Region_Allocation__c)){
                mapOfRegionAndStateAlloc.get(stateAlloc.Brand_Country_Region_Allocation__c).add(stateAlloc);
            } else {
                mapOfRegionAndStateAlloc.put(stateAlloc.Brand_Country_Region_Allocation__c, new List<Brand_Country_Region_State_Allocation__c> {stateAlloc});
            }
            for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : stateAlloc.Brand_Country_Region_State_Dist_Allocs__r){
                if(mapOfStateAndDistAlloc.containsKey(distAlloc.Brand_Country_Region_State_Allocation__c)){
                    mapOfStateAndDistAlloc.get(distAlloc.Brand_Country_Region_State_Allocation__c).add(distAlloc);
                } else {
                    mapOfStateAndDistAlloc.put(distAlloc.Brand_Country_Region_State_Allocation__c, new List<Brand_Country_Region_State_Dist_Alloc__c>{distAlloc});
                }
            }
        }
        }
        List<allocationWrapper> lstAllocWrapper= new List<allocationWrapper>();
        List<allocationWrapper> lstlostAllocWrapper = new List<allocationWrapper>();
        for(String oldBrandAllocationId : mapOfOldNewBrandAlloc.keySet()){
            List<Brand_Country_Allocation__c> lstOldCountryAlloc = new List<Brand_Country_Allocation__c>();
            if(mapOfBrandAndCountryAlloc.containsKey(oldBrandAllocationId)){
                lstOldCountryAlloc = mapOfBrandAndCountryAlloc.get(oldBrandAllocationId);
            }
            List<Brand_Country_Allocation__c> lstNewCountryAlloc = new List<Brand_Country_Allocation__c>();
            if(mapOfBrandAndCountryAlloc.containsKey(mapOfOldNewBrandAlloc.get(oldBrandAllocationId))) {
                lstNewCountryAlloc = mapOfBrandAndCountryAlloc.get(mapOfOldNewBrandAlloc.get(oldBrandAllocationId));
            }
            if(!lstOldCountryAlloc.isEmpty() && !lstNewCountryAlloc.isEmpty()){
                for(Integer i=0; i<lstOldCountryAlloc.size(); i++){
                    for(Integer j=0; j<lstNewCountryAlloc.size(); j++) {
                        if(lstOldCountryAlloc[i].country__c == lstNewCountryAlloc[j].Country__c && 
                           lstOldCountryAlloc[i].Is_Leaf_Node__c && lstNewCountryAlloc[j].Is_Leaf_Node__c && 
                           lstOldCountryAlloc[i].Remaining_Allocations__c > 0){
                               allocationWrapper allocWrapper = new allocationWrapper();
                               allocWrapper.brandName = lstOldCountryAlloc[i].Brand_Allocation__r.Brand__r.Name;
                               allocWrapper.programType = lstOldCountryAlloc[i].Brand_Allocation__r.Program_Type__c;
                               allocWrapper.brandAllocation = lstOldCountryAlloc[i].Brand_Allocation__r.Name;
                               allocWrapper.allocYear = lstOldCountryAlloc[i].Brand_Allocation__r.Year_Of_Allocation__c;
                               allocWrapper.allocTimeInterval = lstOldCountryAlloc[i].Brand_Allocation__r.Time_Interval__c;
                               allocWrapper.country = lstOldCountryAlloc[i].Country__r.Name;
                               allocWrapper.oldAllocation = String.valueOf(lstOldCountryAlloc[i].Allocations_Per_Interval__c);
                               allocWrapper.userAllocation = String.valueOf(lstOldCountryAlloc[i].Used_Allocations__c);
                               allocWrapper.remainingAlloc = String.valueOf(lstOldCountryAlloc[i].Remaining_Allocations__c);
                               allocWrapper.newAllocation = String.valueOf(lstNewCountryAlloc[j].Allocations_Per_Interval__c- lstOldCountryAlloc[i].Remaining_Allocations__c);
                               allocWrapper.carryForwaredAlloc = String.valueOf(lstOldCountryAlloc[i].Allocations_Per_Interval__c);
                               lstAllocWrapper.add(allocWrapper);
                           } else if(lstOldCountryAlloc[i].country__c == lstNewCountryAlloc[j].Country__c && 
                                     !lstOldCountryAlloc[i].Is_Leaf_Node__c && !lstNewCountryAlloc[j].Is_Leaf_Node__c &&
                                     lstOldCountryAlloc[i].Remaining_Allocations__c > 0){
                                         List<Brand_Country_Region_Allocation__c> lstOldRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
                                         List<Brand_Country_Region_Allocation__c> lstNewRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
                                         if(mapOfCountryAndRegionAlloc.containsKey(lstOldCountryAlloc[i].Id)) {
                                             lstOldRegionAlloc = mapOfCountryAndRegionAlloc.get(lstOldCountryAlloc[i].Id);}
                                         if(mapOfCountryAndRegionAlloc.containsKey(lstNewCountryAlloc[j].Id)){
                                             lstNewRegionAlloc = mapOfCountryAndRegionAlloc.get(lstNewCountryAlloc[j].Id);
                                         }
                                         if(!lstOldRegionAlloc.isEmpty() && !lstNewRegionAlloc.isEmpty()) {
                                             for(Integer a=0; a< lstOldRegionAlloc.size(); a++){
                                                 for(Integer b=0;b<lstNewRegionAlloc.size();b++){
                                                     if(lstOldRegionAlloc[a].region__c == lstNewRegionAlloc[b].region__c &&
                                                        lstOldRegionAlloc[a].Is_Leaf_Node__c && lstNewRegionAlloc[b].Is_Leaf_Node__c && 
                                                        lstOldRegionAlloc[a].Remaining_Allocations__c > 0) {
                                                            allocationWrapper allocWrapper = new allocationWrapper();
                                                            allocWrapper.brandName = lstOldRegionAlloc[a].Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name;
                                                            allocWrapper.programType = lstOldRegionAlloc[a].Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c;
                                                            allocWrapper.brandAllocation = lstOldRegionAlloc[a].Brand_Country_Allocation__r.Brand_Allocation__r.Name;
                                                            allocWrapper.allocYear = lstOldRegionAlloc[a].Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c;
                                                            allocWrapper.allocTimeInterval = lstOldRegionAlloc[a].Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c;
                                                            allocWrapper.country = lstOldRegionAlloc[a].Brand_Country_Allocation__r.Country__r.Name;
                                                            allocWrapper.region = lstOldRegionAlloc[a].Region__r.Name;
                                                            allocWrapper.oldAllocation = String.valueOf(lstOldRegionAlloc[a].Allocations_Per_Interval__c);
                                                            allocWrapper.userAllocation = String.valueOf(lstOldRegionAlloc[a].Used_Allocations__c);
                                                            allocWrapper.remainingAlloc = String.valueOf(lstOldRegionAlloc[a].Remaining_Allocations__c);
                                                            allocWrapper.newAllocation = String.valueOf(lstNewRegionAlloc[b].Allocations_Per_Interval__c- lstOldRegionAlloc[a].Remaining_Allocations__c);
                                                            allocWrapper.carryForwaredAlloc = String.valueOf(lstNewRegionAlloc[b].Allocations_Per_Interval__c);
                                                            lstAllocWrapper.add(allocWrapper);
                                                        } else if(lstOldRegionAlloc[a].region__c == lstNewRegionAlloc[b].region__c &&
                                                                  !lstOldRegionAlloc[a].Is_Leaf_Node__c && !lstNewRegionAlloc[b].Is_Leaf_Node__c && 
                                                                  lstOldRegionAlloc[a].Remaining_Allocations__c > 0){
                                                                      List<Brand_Country_Region_State_Allocation__c> lstOldStateAlloc = mapOfRegionAndStateAlloc.get(lstOldRegionAlloc[a].Id);
                                                                      List<Brand_Country_Region_State_Allocation__c> lstNewStateALloc = mapOfRegionAndStateAlloc.get(lstNewRegionAlloc[b].Id);
                                                                      if(!lstOldStateAlloc.isEmpty() && !lstNewStateALloc.isEmpty()) {
                                                                          for(Integer k=0; k<lstOldStateAlloc.size();k++){
                                                                              for(Integer l = 0; l<lstNewStateALloc.size();l++){
                                                                                  if(lstOldStateAlloc[k].State__c == lstNewStateALloc[l].state__c &&
                                                                                     lstOldStateAlloc[k].Is_Leaf_Node__c && lstNewStateALloc[l].Is_Leaf_Node__c &&
                                                                                     lstNewStateALloc[l].Is_Active__c && lstOldStateAlloc[k].Remaining_Allocations__c > 0){
                                                                                         lstNewStateALloc[l].Carry_Forward_Units__c = lstOldStateAlloc[k].Remaining_Allocations__c;
                                                                                         allocationWrapper allocWrapper = new allocationWrapper();
                                                                                         allocWrapper.brandName = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name;
                                                                                         allocWrapper.programType = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c;
                                                                                         allocWrapper.brandAllocation = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Name;
                                                                                         allocWrapper.allocYear = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c;
                                                                                         allocWrapper.allocTimeInterval = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c;
                                                                                         allocWrapper.country = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                                                                                         allocWrapper.region = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Region__r.Name;
                                                                                         allocWrapper.state = lstOldStateAlloc[k].State__r.Name;
                                                                                         allocWrapper.stateManager = lstOldStateAlloc[k].State__r.State_Manager__r.Name;
                                                                                         allocWrapper.oldAllocation = String.valueOf(lstOldStateAlloc[k].Allocations_Per_Interval__c);
                                                                                         allocWrapper.userAllocation = String.valueOf(lstOldStateAlloc[k].Used_Allocations__c);
                                                                                         allocWrapper.remainingAlloc = String.valueOf(lstOldStateAlloc[k].Remaining_Allocations__c);
                                                                                         allocWrapper.newAllocation = String.valueOf(lstNewStateALloc[l].Allocations_Per_Interval__c - lstOldStateAlloc[k].Remaining_Allocations__c);
                                                                                         allocWrapper.carryForwaredAlloc = String.valueOf(lstNewStateALloc[l].Allocations_Per_Interval__c);
                                                                                         lstAllocWrapper.add(allocWrapper);
                                                                                     } else if(lstOldStateAlloc[k].State__c == lstNewStateALloc[l].state__c &&
                                                                                               !lstOldStateAlloc[k].Is_Leaf_Node__c && !lstNewStateALloc[l].Is_Leaf_Node__c &&
                                                                                               lstNewStateALloc[l].Is_Active__c && lstOldStateAlloc[k].Remaining_Allocations__c > 0) {
                                                                                                   List<Brand_Country_Region_State_Dist_Alloc__c> lstOldDistAlloc = mapOfStateAndDistAlloc.get(lstOldStateAlloc[k].Id);
                                                                                                   List<Brand_Country_Region_State_Dist_Alloc__c> lstNewDistAlloc = mapOfStateAndDistAlloc.get(lstNewStateALloc[l].Id);
                                                                                                   if(!lstOldDistAlloc.isEmpty() && !lstNewDistAlloc.isEmpty()) {
                                                                                                       for(Integer c=0; c<lstOldDistAlloc.size();c++){
                                                                                                           for(Integer d=0;d< lstNewDistAlloc.size();d++){
                                                                                                               if(lstOldDistAlloc[c].Account__c == lstNewDistAlloc[d].Account__c &&
                                                                                                                  lstOldDistAlloc[c].Is_Leaf_Node__c && lstNewDistAlloc[d].Is_Leaf_Node__c &&
                                                                                                                  lstNewDistAlloc[d].Is_Active__c && lstOldDistAlloc[c].Remaining_Allocations__c > 0){
                                                                                                                      lstNewDistAlloc[d].Carry_Forward_Units__c = lstOldDistAlloc[c].Remaining_Allocations__c;
                                                                                                                      allocationWrapper allocWrapper = new allocationWrapper();
                                                                                                                      allocWrapper.brandName = lstOldStateAlloc[k].Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name;
                                                                                                                      allocWrapper.programType = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c;
                                                                                                                      allocWrapper.brandAllocation = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Name;
                                                                                                                      allocWrapper.allocYear = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c;
                                                                                                                      allocWrapper.allocTimeInterval = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c;
                                                                                                                      allocWrapper.country = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                                                                                                                      allocWrapper.region = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name;
                                                                                                                      allocWrapper.state = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.State__r.Name;
                                                                                                                      allocWrapper.stateManager = lstOldDistAlloc[c].Brand_Country_Region_State_Allocation__r.State__r.State_Manager__r.Name;
                                                                                                                      allocWrapper.distributor = lstOldDistAlloc[c].Account__r.Name;
                                                                                                                      allocWrapper.oldAllocation = String.valueOf(lstOldDistAlloc[c].Allocations_Per_Interval__c);
                                                                                                                      allocWrapper.userAllocation = String.valueOf(lstOldDistAlloc[c].Used_Allocations__c);
                                                                                                                      allocWrapper.remainingAlloc = String.valueOf(lstOldDistAlloc[c].Remaining_Allocations__c);
                                                                                                                      allocWrapper.newAllocation = String.valueOf(lstNewDistAlloc[d].Allocations_Per_Interval__c - lstOldDistAlloc[c].Remaining_Allocations__c);
                                                                                                                      allocWrapper.carryForwaredAlloc = String.valueOf(lstNewDistAlloc[d].Allocations_Per_Interval__c);
                                                                                                                      lstAllocWrapper.add(allocWrapper);
                                                                                                                  }
                                                                                                           }
                                                                                                       }
                                                                                                   }
                                                                                               }
                                                                              }
                                                                          }
                                                                      }
                                                                  }
                                                 }
                                                 
                                             }
                                         }
                                     }
                    }
                }
            }
            
        }
        if(lstAllocWrapper.isEmpty()) {
            hasHierarchy = true;
            lstAllocWrapper = getWriteOffAllocationWrapper();
        }
        return lstAllocWrapper;
    }
    
    public List<allocationWrapper> getWriteOffAllocationWrapper() {
        List<String> nextInterval = new List<String>();
        Set<String> lstBrandAllocationId = new Set<String>();
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(brandAllocationId);
        List<String> timePeriod = new List<String>{SB2_Constants.MONTHLY, SB2_Constants.QUARTERLY, SB2_Constants.YEARLY};
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
                if(!brandAlloc.Is_Carry_Forward__c && brandAlloc.Is_Active__c){ //&& brandAlloc.Status__c == 'Expired'){
                    lstBrandAllocationId.add(String.valueOf(brandAlloc.Id).subString(0,15));
                }
            }
        
        if(hasHierarchy){
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
                if( brandAlloc.Is_Active__c){ //&& brandAlloc.Status__c == 'Expired'){
                    lstBrandAllocationId.add(String.valueOf(brandAlloc.Id).subString(0,15));
                }
            }
        }
       
		System.debug('lstBrandAllocationId--'+lstBrandAllocationId);
        List<Brand_Country_Allocation__c> lstCountryAlloc = SLT_SB2_BrandCountryAlloc.getBrandCountryAllocation(lstBrandAllocationId);
        map<String, List<Brand_Country_Allocation__c>> mapOfBrandAndCountryAlloc = new Map<String, List<Brand_Country_Allocation__c>>();
        map<String, List<Brand_Country_Region_Allocation__c>> mapOfCountryAndRegionAlloc = new Map<String, List<Brand_Country_Region_Allocation__c>>();
        Set<Id> setOfRegionAlloc = new Set<Id>();
        for(Brand_Country_Allocation__c countryAlloc : lstCountryAlloc) {
            if(mapOfBrandAndCountryAlloc.containsKey(countryAlloc.Brand_Allocation__c)){
                mapOfBrandAndCountryAlloc.get(countryAlloc.Brand_Allocation__c).add(countryAlloc);
            }else {
                mapOfBrandAndCountryAlloc.put(countryAlloc.Brand_Allocation__c, new List<Brand_Country_Allocation__c> {countryAlloc});
            }
            for(Brand_Country_Region_Allocation__c regionAlloc : countryAlloc.Brand_Country_Region_Allocations__r){
                if(mapOfCountryAndRegionAlloc.containsKey(regionAlloc.Brand_Country_Allocation__c)){
                    mapOfCountryAndRegionAlloc.get(regionAlloc.Brand_Country_Allocation__c).add(regionAlloc);
                } else {
                    mapOfCountryAndRegionAlloc.put(regionAlloc.Brand_Country_Allocation__c, new List<Brand_Country_Region_Allocation__c> {regionAlloc});
                }
                setOfRegionAlloc.add(regionAlloc.Id);
            }
        }
        System.debug('mapOfCountryAndRegionAlloc--'+mapOfCountryAndRegionAlloc);
        List<Brand_Country_Region_State_Allocation__c> lstStateALloc = SLT_SB2_BrandCountryRegionStateAlloc.getListBrandCountryRegionStateAllocationFromRegion(setOfRegionAlloc);
        Map<String, List<Brand_Country_Region_State_Allocation__c>> mapOfRegionAndStateAlloc = new Map<String, List<Brand_Country_Region_State_Allocation__c>>();
        map<String, List<Brand_Country_Region_State_Dist_Alloc__c>> mapOfStateAndDistAlloc = new Map<String, List<Brand_Country_Region_State_Dist_Alloc__c>>();
        if(!lstStateALloc.isEmpty()) {
        for(Brand_Country_Region_State_Allocation__c stateAlloc : lstStateALloc){
            if(mapOfRegionAndStateAlloc.containsKey(stateAlloc.Brand_Country_Region_Allocation__c)){
                mapOfRegionAndStateAlloc.get(stateAlloc.Brand_Country_Region_Allocation__c).add(stateAlloc);
            } else {
                mapOfRegionAndStateAlloc.put(stateAlloc.Brand_Country_Region_Allocation__c, new List<Brand_Country_Region_State_Allocation__c> {stateAlloc});
            }
            for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : stateAlloc.Brand_Country_Region_State_Dist_Allocs__r){
                if(mapOfStateAndDistAlloc.containsKey(distAlloc.Brand_Country_Region_State_Allocation__c)){
                    mapOfStateAndDistAlloc.get(distAlloc.Brand_Country_Region_State_Allocation__c).add(distAlloc);
                } else {
                    mapOfStateAndDistAlloc.put(distAlloc.Brand_Country_Region_State_Allocation__c, new List<Brand_Country_Region_State_Dist_Alloc__c>{distAlloc});
                }
            }
        }
        }
        System.debug('mapOfRegionAndStateAlloc--'+mapOfRegionAndStateAlloc);
        SYstem.debug('mapOfStateAndDistAlloc--'+mapOfStateAndDistAlloc);
        List<allocationWrapper> lstAllocWrapper= new List<allocationWrapper>();
        for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
            List<Brand_Country_Allocation__c> lstOldCountryAlloc = new List<Brand_Country_Allocation__c>();
            if(mapOfBrandAndCountryAlloc.containsKey(brandAlloc.Id)){
                lstOldCountryAlloc = mapOfBrandAndCountryAlloc.get(brandAlloc.Id);
                if(!lstOldCountryAlloc.isEmpty()){
                    for(Brand_Country_Allocation__c countryAlloc : lstOldCountryAlloc){

                        if(countryAlloc.Is_Leaf_Node__c && countryAlloc.Remaining_Allocations__c > 0){
                            allocationWrapper allocWrapper = new allocationWrapper();
                            allocWrapper.brandName = countryAlloc.Brand_Allocation__r.Brand__r.Name;
                            allocWrapper.programType = countryAlloc.Brand_Allocation__r.Program_Type__c;
                            allocWrapper.brandAllocation = countryAlloc.Brand_Allocation__r.Name;
                            allocWrapper.allocYear = countryAlloc.Brand_Allocation__r.Year_Of_Allocation__c;
                            allocWrapper.allocTimeInterval = countryAlloc.Brand_Allocation__r.Time_Interval__c;
                            allocWrapper.country = countryAlloc.Country__r.Name;
                            allocWrapper.oldAllocation = String.valueOf(countryAlloc.Allocations_Per_Interval__c);
                            allocWrapper.userAllocation = String.valueOf(countryAlloc.Used_Allocations__c);
                            allocWrapper.remainingAlloc = String.valueOf(countryAlloc.Remaining_Allocations__c);
                            lstAllocWrapper.add(allocWrapper);

                        } else if(!countryAlloc.Is_Leaf_Node__c && countryAlloc.Remaining_Allocations__c > 0) {
                            List<Brand_Country_Region_Allocation__c> lstRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
                            if(mapOfCountryAndRegionAlloc.containsKey(countryAlloc.Id)){
                                lstRegionAlloc = mapOfCountryAndRegionAlloc.get(countryAlloc.Id);
                                if(!lstRegionAlloc.isEmpty()) {
                                	for(Brand_Country_Region_Allocation__c regionAlloc : lstRegionAlloc){
                                        System.debug('regionAlloc--'+regionAlloc);
                                        if(regionAlloc.Is_Leaf_Node__c && regionAlloc.Remaining_Allocations__c > 0) {
                                            allocationWrapper allocWrapper = new allocationWrapper();
                                            allocWrapper.brandName = regionAlloc.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name;
                                            allocWrapper.programType = regionAlloc.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c;
                                            allocWrapper.brandAllocation = regionAlloc.Brand_Country_Allocation__r.Brand_Allocation__r.Name;
                                            allocWrapper.allocYear = regionAlloc.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c;
                                            allocWrapper.allocTimeInterval = regionAlloc.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c;
                                            allocWrapper.country = regionAlloc.Brand_Country_Allocation__r.Country__r.Name;
                                            allocWrapper.region = regionAlloc.Region__r.Name;
                                            allocWrapper.oldAllocation = String.valueOf(regionAlloc.Allocations_Per_Interval__c);
                                            allocWrapper.userAllocation = String.valueOf(regionAlloc.Used_Allocations__c);
                                            allocWrapper.remainingAlloc = String.valueOf(regionAlloc.Remaining_Allocations__c);
                                            lstAllocWrapper.add(allocWrapper);
                                        } else if(!regionAlloc.Is_Leaf_Node__c && regionAlloc.Remaining_Allocations__c > 0){
                                            List<Brand_Country_Region_State_Allocation__c> lstAllStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
                                            if(mapOfRegionAndStateAlloc.containsKey(regionAlloc.Id)){
                                                lstAllStateAlloc = mapOfRegionAndStateAlloc.get(regionAlloc.Id);
                                                if(!lstAllStateAlloc.isEmpty()){
                                                    for(Brand_Country_Region_State_Allocation__c stateAlloc : lstAllStateAlloc){
                                                        if(stateAlloc.Is_Active__c && stateAlloc.Is_Leaf_Node__c && 
                                                          stateAlloc.Remaining_Allocations__c > 0) {
                                                            allocationWrapper allocWrapper = new allocationWrapper();
                                                            allocWrapper.brandName = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name;
                                                            allocWrapper.programType = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c;
                                                            allocWrapper.brandAllocation = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Name;
                                                            allocWrapper.allocYear = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c;
                                                            allocWrapper.allocTimeInterval = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c;
                                                            allocWrapper.country = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                                                            allocWrapper.region = stateAlloc.Brand_Country_Region_Allocation__r.Region__r.Name;
                                                            allocWrapper.state = stateAlloc.State__r.Name;
                                                            allocWrapper.stateManager = stateAlloc.State__r.State_Manager__r.Name;
                                                            allocWrapper.oldAllocation = String.valueOf(stateAlloc.Allocations_Per_Interval__c);
                                                            allocWrapper.userAllocation = String.valueOf(stateAlloc.Used_Allocations__c);
                                                            allocWrapper.remainingAlloc = String.valueOf(stateAlloc.Remaining_Allocations__c);
                                                            lstAllocWrapper.add(allocWrapper);
                                                        } else if(!stateAlloc.Is_Leaf_Node__c && stateAlloc.Remaining_Allocations__c > 0) {
                                                            List<Brand_Country_Region_State_Dist_Alloc__c> lstOldDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
                                                            if(mapOfStateAndDistAlloc.containsKey(stateAlloc.Id)){
                                                                lstOldDistAlloc = mapOfStateAndDistAlloc.get(stateAlloc.Id);
                                                                if(!lstOldDistAlloc.isEmpty()){
                                                                    for(Brand_Country_Region_State_Dist_Alloc__c distAlloc : lstOldDistAlloc) {
                                                                        if(distAlloc.Is_Leaf_Node__c && distAlloc.Remaining_Allocations__c > 0) {
                                                                               allocationWrapper allocWrapper = new allocationWrapper();
                                                                               allocWrapper.brandName = stateAlloc.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Brand__r.Name;
                                                                               allocWrapper.programType = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Program_Type__c;
                                                                               allocWrapper.brandAllocation = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Name;
                                                                               allocWrapper.allocYear = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Year_Of_Allocation__c;
                                                                               allocWrapper.allocTimeInterval = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Brand_Allocation__r.Time_Interval__c;
                                                                               allocWrapper.country = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Brand_Country_Allocation__r.Country__r.Name;
                                                                               allocWrapper.region = distAlloc.Brand_Country_Region_State_Allocation__r.Brand_Country_Region_Allocation__r.Region__r.Name;
                                                                               allocWrapper.state = distAlloc.Brand_Country_Region_State_Allocation__r.State__r.Name;
                                                                               allocWrapper.stateManager = distAlloc.Brand_Country_Region_State_Allocation__r.State__r.State_Manager__r.Name;
                                                                               allocWrapper.distributor = distAlloc.Account__r.Name;
                                                                               allocWrapper.oldAllocation = String.valueOf(distAlloc.Allocations_Per_Interval__c);
                                                                               allocWrapper.userAllocation = String.valueOf(distAlloc.Used_Allocations__c);
                                                                               allocWrapper.remainingAlloc = String.valueOf(distAlloc.Remaining_Allocations__c);
                                                                               lstAllocWrapper.add(allocWrapper);  
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } 
                    }
                }
            }
        }
        return lstAllocWrapper;
    }
    public class allocationWrapper {
        public String brandName{get; set;}
        public String programType{get; set;}
        public String brandAllocation{get; set;}
        public String allocYear{get; set;}
        public string allocTimeInterval{get; set;}
        public String country{get; set;}
        public String region{get; set;}
        public String state{get; set;}
        public String distributor{get; set;}
        public String stateManager{get; set;}
        public String oldAllocation{get; set;}
        public String userAllocation{get; set;}
        public String remainingAlloc{get; set;}
        public String newAllocation{get; set;}
        public String carryForwaredAlloc{get; set;}
    }
}