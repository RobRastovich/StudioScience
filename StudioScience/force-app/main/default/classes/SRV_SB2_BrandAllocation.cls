/**
@company : Copyright © 2019, BeamSuntory
All rights reserved.
Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMSRV
@author BeamSuntory
@version V_1.0
@date 16/04/2020
@description This Class is Service class for Brand Allocation Trigger
*/
public class SRV_SB2_BrandAllocation {
    /**
*  @description : This method is use to check for duplicate record on brand allocation
*  @args        : List Brand_Allocation__c
*  @return      : void
**/
    public static void setBrandAllocationName(List<Brand_Allocation__c> lstBrandAllocation) {
        Set<Id> setBrand = new Set<Id>();
        Set<String> setOfProgramType = new Set<String>();
        Set<String> setOfTimeInterval = new Set<String>();
        Set<String> SetOfYear = new Set<String>();
        Queue_Brand_Allocation_Assignment__c queueAssignment = new Queue_Brand_Allocation_Assignment__c();
        for(Brand_Allocation__c newBrandAllocation : lstBrandAllocation) {
            setBrand.add(newBrandAllocation.Brand__c);
            setOfProgramType.add(newBrandAllocation.Program_Type__c);
            setOfTimeInterval.add(newBrandAllocation.Time_Interval__c);
            SetOfYear.add(newBrandAllocation.Year_Of_Allocation__c);
        }
        List<Brand_Allocation__c> lstBrandAlloc = SLT_SB2_BrandAllocation.getBrandAllocationByBrandYearTimeInterval(
            setBrand, SetOfYear, setOfTimeInterval, setOfProgramType, false, 'Active');
        map<String, Brand_Allocation__c> mapOfNameBrand = new Map<String, Brand_Allocation__c>();
        for(Brand_Allocation__c brandAlloc : lstBrandAlloc){
            mapOfNameBrand.put(brandAlloc.Brand__c+'~'+brandAlloc.Program_Type__c+'~'+brandAlloc.Year_Of_Allocation__c+'~'+brandAlloc.Time_Interval__c, brandAlloc);
        }
        Map<Id, Brand__c> mapOfBrand = SLT_SB2_Brand.getBrandMap(setBrand);
        List<Brand_Allocation__c> lstUpdateBrandAlloc = new List<Brand_Allocation__C>();
        for(Brand_Allocation__c newBrandAllocation : lstBrandAllocation) {
            String brandName = mapOfBrand.get(newBrandAllocation.Brand__c).Name;
            queueAssignment = Queue_Brand_Allocation_Assignment__c.getValues(brandName);
            List<String> tempName = brandName.split(' ');
            String brandAllocName = '';
            for(Integer i =0; i<tempName.size();i++){
                brandAllocName += tempName[i].subString(0,1);
            }
            brandAllocName += '~';
            if(newBrandAllocation.Program_Type__c.contains('+')){
                List<String> tempProgramName = newBrandAllocation.Program_Type__c.split('\\+ ');
                for(Integer i =0;i<tempProgramName.size();i++){
                    brandAllocName += tempProgramName[i].subString(0,3);
                } 
            } else {
                brandAllocName += newBrandAllocation.Program_Type__c.subString(0,3);
            }
            brandAllocName += '~'+newBrandAllocation.Year_Of_Allocation__c+'~';
            if(newBrandAllocation.Time_Interval__c.contains(' ')){
                List<String> tempTimeInterval = newBrandAllocation.Time_Interval__c.split(' ');
                
                brandAllocName += tempTimeInterval[0].subString(0,3);
                brandAllocName += tempTimeInterval[1].subString(0,1);
            } else {
                brandAllocName += newBrandAllocation.Time_Interval__c.subString(0,3);
            }
            newBrandAllocation.Name = brandAllocName;
            if(queueAssignment != null && !String.isEmpty(queueAssignment.Queue_Name__c)) {
                Id queueId= [select Id, Name FROM Group where Type='Queue' and name =: queueAssignment.Queue_Name__c Limit 1].Id;
                newBrandAllocation.OwnerId = queueId;
            }
            if(newBrandAllocation.Time_Period__c == SB2_Constants.MONTHLY){
                newBrandAllocation.Allocation_End_Date__c = date.newInstance(
                    Integer.valueOf(newBrandAllocation.Year_Of_Allocation__c), 
                    SB2_Constants.mapOfMonth.get(newBrandAllocation.Time_Interval__c), 1).addMonths(1).addDays(-1);
            } else if(newBrandAllocation.Time_Period__c == SB2_Constants.QUARTERLY){
                newBrandAllocation.Allocation_End_Date__c = date.newInstance(
                    Integer.valueOf(newBrandAllocation.Year_Of_Allocation__c), 
                    SB2_Constants.mapOfQuarter.get(newBrandAllocation.Time_Interval__c), 1).addMonths(3).addDays(-1);     
            } else if(newBrandAllocation.Time_Period__c == SB2_Constants.YEARLY) {
                newBrandAllocation.Allocation_End_Date__c = date.newInstance(
                    Integer.valueOf(newBrandAllocation.Year_Of_Allocation__c), 1, 1).addMonths(12).addDays(-1);
            }
            
            if(mapOfNameBrand.containskey(newBrandAllocation.Brand__c+'~'+newBrandAllocation.Program_Type__c+'~'+newBrandAllocation.Year_Of_Allocation__c+'~'+newBrandAllocation.Time_Interval__c)){
                Brand_Allocation__C oldBrandAlloc = mapOfNameBrand.get(newBrandAllocation.Brand__c+'~'+newBrandAllocation.Program_Type__c+'~'+newBrandAllocation.Year_Of_Allocation__c+'~'+newBrandAllocation.Time_Interval__c);
                oldBrandAlloc.Status__c = 'overlap';
                lstUpdateBrandAlloc.add(oldBrandAlloc);
            }
            
        }
        if(!lstUpdateBrandAlloc.isEmpty()) {
            update lstUpdateBrandAlloc;
        }
    }
    
    /**
*  @description : This method is use to check for duplicate record on brand allocation
*  @args        : List Brand_Allocation__c
*  @return      : void
**/
    public static void checkDuplicateAllocation(List<Brand_Allocation__c> lstBrandAllocation) {
        List<Brand_Allocation__c> lstExistingBrandAllocation = getExistingBrandAllocation(lstBrandAllocation);
        Map<String,List<Brand_Allocation__c>> mapOfYearAndBrandAllocation = getMapExistingBrandAllocation(lstExistingBrandAllocation);
        for(Brand_Allocation__c newBrandAllocation : lstBrandAllocation) {
            if(!newBrandAllocation.Is_Active__c){
                newBrandAllocation.addError(Label.SB2_In_Active_Error);
            }
            if(checkForTimeOverlap(newBrandAllocation, mapOfYearAndBrandAllocation)){
                newBrandAllocation.addError(Label.SB2_TimeOverlap_Error);
            }
        }
    }
    
    /**
*  @description : This method is use to check for Time overlap for brand allocation
*  @args        : List Brand_Allocation__c, map <Stirng, List<Brand_Allocation__C>>
*  @return      : Boolean
**/
    private static Boolean checkForTimeOverlap(Brand_Allocation__c newBrandAllocation, Map<String,List<Brand_Allocation__c>> mapOfYearAndBrandAllocation){
        String programType = newBrandAllocation.Program_Type__c;
        String key = newBrandAllocation.Year_Of_Allocation__c;
        Boolean isAlreadyActive = false;
        if(newBrandAllocation.Time_Period__c == SB2_Constants.YEARLY){
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.YEARLY)) {
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.YEARLY)) {
                    if((bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c))
                       && bA.Time_Interval__c == newBrandAllocation.Time_Interval__c) {
                           return true;
                       }
                }
            }
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.MONTHLY)) {
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.MONTHLY)) {
                    if(bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c)) {
                        return true;
                    }
                }
            }
            else if (mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.QUARTERLY)){
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.QUARTERLY)) {
                    if(bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c)) {
                        return true;
                    }
                }
            }
        }
        else if(newBrandAllocation.Time_Period__c == SB2_Constants.QUARTERLY) {
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.QUARTERLY)) {
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.QUARTERLY)) {
                    if((bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c))
                       && bA.Time_Interval__c == newBrandAllocation.Time_Interval__c) {
                           return true;
                       }
                }
            }
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.YEARLY)) {
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.YEARLY)) {
                    if(bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c)) {
                        return true;
                    }
                }
            }
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.MONTHLY)){
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.MONTHLY)) {
                    if(SB2_Constants.mapOfQuarterMonth.containsKey(newBrandAllocation.Time_Interval__c)) {
                        List<String> lstOfMonth = SB2_Constants.mapOfQuarterMonth.get(newBrandAllocation.Time_Interval__c);
                        if(lstOfMonth.contains(bA.Time_Interval__c) && 
                           (bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c))) {
                               return true;
                           }
                    }
                }
            }
        }else if(newBrandAllocation.Time_Period__c == SB2_Constants.MONTHLY) {
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.MONTHLY)) {
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.MONTHLY)) {
                    if((bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c))
                       && bA.Time_Interval__c == newBrandAllocation.Time_Interval__c) {
                           return true;
                       }
                }
            }
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.YEARLY)) {
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.YEARLY)) {
                    if(bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c)) {
                        return true;
                    }
                }
            }
            if(mapOfYearAndBrandAllocation.containsKey(key+'-'+SB2_Constants.QUARTERLY)){
                for(Brand_Allocation__c bA : mapOfYearAndBrandAllocation.get(key+'-'+SB2_Constants.QUARTERLY)) {
                    if(SB2_Constants.mapOfMonthQuarter.containsKey(newBrandAllocation.Time_Interval__c)) {
                        if(SB2_Constants.mapOfMonthQuarter.get(newBrandAllocation.Time_Interval__c) == bA.Time_Interval__c && 
                           (bA.Program_Type__c.contains(programType) || programType.contains(bA.Program_Type__c))) {
                               return true;
                           }
                    }
                }
            }
            return isAlreadyActive;
        }
        return false;
    }
    
    /**
*  @description : This method is use to get map of unqiue combination with Brand ALlocation
*  @args        : List<brand_Allocation__c>
*  @return      : Map<String,List<Brand_Allocation__c>>
**/
    private static Map<String,List<Brand_Allocation__c>> getMapExistingBrandAllocation(List<Brand_Allocation__c> lstExistingBrandAllocation) {
        Map<String,List<Brand_Allocation__c>> mapOfYearAndBrandAllocation = new Map<String,List<Brand_Allocation__c>>();
        for(Brand_Allocation__c brandAllocation : lstExistingBrandAllocation){
            String programType = brandAllocation.Program_Type__c;
            String key = brandAllocation.Year_Of_Allocation__c+'-'+brandAllocation.Time_Period__c;
            if(mapOfYearAndBrandAllocation.containsKey(key)){
                List<Brand_Allocation__c> lstBA = mapOfYearAndBrandAllocation.get(key);
                lstBA.add(brandAllocation);
                mapOfYearAndBrandAllocation.put(key,lstBA);
            } else {
                mapOfYearAndBrandAllocation.put(key,new List<Brand_Allocation__c>{brandAllocation});
            }
        }
        return mapOfYearAndBrandAllocation;
    }
    
    /**
*  @description : This method is use to get already Brand ALlocation for particular brand
*  @args        : List<brand_Allocation__c>
*  @return      : List<Brand_Allocation__c>
**/
    private static List<Brand_Allocation__c> getExistingBrandAllocation(List<Brand_Allocation__c> lstBrandAllocation) {
        Set<Id> setBrand = new Set<Id>();
        for(Brand_Allocation__c brandAllocation : lstBrandAllocation) {
            setBrand.add(brandAllocation.Brand__c);
        }
        return SLT_SB2_BrandAllocation.getExistingBrandAllocation(setBrand);
    }
    
    /**
*  @description : This method is update carry forwarded barrels for brand allocations
*  @args        : List<brand_Allocation__c>
*  @return      : List<Brand_Allocation__c>
**/
    public static void updateCarryForwardBarrels(List<Brand_Allocation__c> lstBrandAllocation){
        List<String> nextInterval = new List<String>();
        String yearOfAlloc;
        String programType;
        String brandId;
        Set<String> lstBrandAllocationId = new Set<String>();
        List<String> timePeriod = new List<String>{SB2_Constants.MONTHLY, SB2_Constants.QUARTERLY, SB2_Constants.YEARLY};
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation){
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
        List<Brand_Country_Allocation__c> lstUpdateCountryAlloc = new List<Brand_Country_Allocation__c>();
        List<Brand_Country_Region_Allocation__c> lstUpdateRegionAlloc = new List<Brand_Country_Region_Allocation__c>();
        List<Brand_Country_Region_State_Allocation__c> lstUpdateStateAlloc = new List<Brand_Country_Region_State_Allocation__c>();
        List<Brand_Country_Region_State_Dist_Alloc__c> lstUpdateDistAlloc = new List<Brand_Country_Region_State_Dist_Alloc__c>();
        List<Allocation_Logger__c> lstAllocationLogger = new List<Allocation_Logger__c>();
        for(String oldBrandAllocationId : mapOfOldNewBrandAlloc.keySet()){
            List<Brand_Country_Allocation__c> lstOldCountryAlloc = mapOfBrandAndCountryAlloc.get(oldBrandAllocationId);
            List<Brand_Country_Allocation__c> lstNewCountryAlloc = mapOfBrandAndCountryAlloc.get(mapOfOldNewBrandAlloc.get(oldBrandAllocationId));
            if(!lstOldCountryAlloc.isEmpty() && !lstNewCountryAlloc.isEmpty()){
                for(Integer i=0; i<lstOldCountryAlloc.size(); i++){
                    for(Integer j=0; j<lstNewCountryAlloc.size(); j++) {
                        if(lstOldCountryAlloc[i].country__c == lstNewCountryAlloc[j].Country__c && 
                           lstOldCountryAlloc[i].Is_Leaf_Node__c && lstNewCountryAlloc[j].Is_Leaf_Node__c && 
                           lstOldCountryAlloc[i].Remaining_Allocations__c > 0){
                               lstNewCountryAlloc[j].Carry_Forward_Units__c = lstOldCountryAlloc[i].Remaining_Allocations__c;
                               if(lstNewCountryAlloc[j].Allocations_Per_Interval__c != null){
                                   lstNewCountryAlloc[j].Allocations_Per_Interval__c += lstNewCountryAlloc[j].Carry_Forward_Units__c;
                               } else {
                                   lstNewCountryAlloc[j].Allocations_Per_Interval__c = lstNewCountryAlloc[j].Carry_Forward_Units__c;
                               }
                               lstUpdateCountryAlloc.add(lstNewCountryAlloc[j]);
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
                                                            lstNewRegionAlloc[b].Carry_Forward_Units__c = lstOldRegionAlloc[a].Remaining_Allocations__c;
                                                            if(lstNewRegionAlloc[b].Allocations_Per_Interval__c != null){
                                                                lstNewRegionAlloc[b].Allocations_Per_Interval__c += lstNewRegionAlloc[b].Carry_Forward_Units__c;
                                                            } else {
                                                                lstNewRegionAlloc[b].Allocations_Per_Interval__c = lstNewRegionAlloc[b].Carry_Forward_Units__c;
                                                            }
                                                            Allocation_Logger__c newAllocationLogger = new Allocation_Logger__c();
                                                            newAllocationLogger = setAllocationLogger(lstOldRegionAlloc[a], lstNewRegionAlloc[b], null, null, null,null,lstOldRegionAlloc[a].Allocations_Per_Interval__c,
                                                                                                      lstOldRegionAlloc[a].Remaining_Allocations__c,lstOldRegionAlloc[a].Used_Allocations__c,
                                                                                                      lstNewRegionAlloc[b].Allocations_Per_Interval__c);
                                                            lstAllocationLogger.add(newAllocationLogger);
                                                            lstUpdateRegionAlloc.add(lstNewRegionAlloc[b]);
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
                                                                                         if(lstNewStateALloc[l].Allocations_Per_Interval__c != null){
                                                                                             lstNewStateALloc[l].Allocations_Per_Interval__c += lstNewStateALloc[l].Carry_Forward_Units__c;
                                                                                         } else {
                                                                                             lstNewStateALloc[l].Allocations_Per_Interval__c = lstNewStateALloc[l].Carry_Forward_Units__c;
                                                                                         }
                                                                                         Allocation_Logger__c newAllocationLogger = new Allocation_Logger__c();
                                                                                         newAllocationLogger = setAllocationLogger(lstOldRegionAlloc[a], lstNewRegionAlloc[b], lstOldStateAlloc[k],
                                                                                                                                   lstNewStateALloc[l], null, null, lstOldStateAlloc[k].Allocations_Per_Interval__c, 
                                                                                                                                   lstOldStateAlloc[k].Remaining_Allocations__c, lstOldStateAlloc[k].Used_Allocations__c, lstNewStateALloc[l].Allocations_Per_Interval__c);
                                                                                         lstAllocationLogger.add(newAllocationLogger);
                                                                                         lstUpdateStateAlloc.add(lstNewStateALloc[l]);
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
                                                                                                                      if(lstNewDistAlloc[d].Allocations_Per_Interval__c != null){
                                                                                                                          lstNewDistAlloc[d].Allocations_Per_Interval__c += lstNewDistAlloc[d].Carry_Forward_Units__c;
                                                                                                                      } else {
                                                                                                                          lstNewDistAlloc[d].Allocations_Per_Interval__c = lstNewDistAlloc[d].Carry_Forward_Units__c;
                                                                                                                      }
                                                                                                                      Allocation_Logger__c newAllocationLogger = new Allocation_Logger__c();
                                                                                                                      newAllocationLogger = setAllocationLogger(lstOldRegionAlloc[a], lstNewRegionAlloc[b], lstOldStateAlloc[k], lstNewStateALloc[l], 
                                                                                                                                                                lstOldDistAlloc[c], lstNewDistAlloc[d], lstOldDistAlloc[c].Allocations_Per_Interval__c,
                                                                                                                                                                lstOldDistAlloc[c].Remaining_Allocations__c , lstOldDistAlloc[c].Used_Allocations__c, lstNewDistAlloc[d].Allocations_Per_Interval__c);
                                                                                                                      lstAllocationLogger.add(newAllocationLogger);
                                                                                                                      lstUpdateDistAlloc.add(lstNewDistAlloc[d]);
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
        if(!lstUpdateCountryAlloc.isEmpty())
            update lstUpdateCountryAlloc;
        if(!lstUpdateRegionAlloc.isEmpty())
            update lstUpdateRegionAlloc;
        if(!lstUpdateStateAlloc.isEmpty())
            update lstUpdateStateAlloc;
        if(!lstUpdateDistAlloc.isEmpty())
            update lstUpdateDistAlloc;
        if(!lstAllocationLogger.isEmpty())
            insert lstAllocationLogger;
    }
    
    public static Allocation_Logger__c setAllocationLogger(Brand_Country_Region_Allocation__c regionAlloc, Brand_Country_Region_Allocation__c newRegionAlloc,
                                                           Brand_Country_Region_State_Allocation__c stateAlloc, Brand_Country_Region_State_Allocation__c newStateAlloc,
                                                           Brand_Country_Region_State_Dist_Alloc__c distAlloc, Brand_Country_Region_State_Dist_Alloc__c newDistAlloc,
                                                           Decimal allocatedBarrel, Decimal remainingBarrel, Decimal usedBarrel, Decimal newAllocatedBarrel){
                                                               Allocation_Logger__c newAllocationLogger = new Allocation_Logger__c();
                                                               newAllocationLogger.Change_Type__c = 'Carry Forward';
                                                               newAllocationLogger.Brand_Allocation__c = regionAlloc.Brand_Country_Allocation__r.Brand_Allocation__c;
                                                               newAllocationLogger.From_Region_Allocation__c = regionAlloc.Id;
                                                               newAllocationLogger.To_Region_Allocation__c = newRegionAlloc.Id;
                                                               if(stateAlloc!= null)
                                                                   newAllocationLogger.From_State_Allocation__c = stateAlloc.Id;
                                                               if(newStateAlloc != null)
                                                                   newAllocationLogger.To_State_Allocation__c = newStateAlloc.Id;
                                                               if(distAlloc != null)
                                                                   newAllocationLogger.From_Distributor_Allocation__c = distAlloc.Id;
                                                               if(newDistAlloc != null)
                                                                   newAllocationLogger.To_Distributor_Allocation__c = newDistAlloc.Id;
                                                               newAllocationLogger.From_Original_Allocation__c = 0;
                                                               newAllocationLogger.Barrels_Allocated_in_Previous_Time_Inter__c = allocatedBarrel;
                                                               newAllocationLogger.Barrels_Carried_Over__c = remainingBarrel;
                                                               newAllocationLogger.Barrels_Used_in_Previous_Time_Interval__c = usedBarrel;
                                                               newAllocationLogger.Previous_Allocation_for_Leaf_Node_for_N__c = newAllocatedBarrel - remainingBarrel;
                                                               newAllocationLogger.New_Allocation_Previous_Barrels_Carry__c  = newAllocatedBarrel;
                                                               return newAllocationLogger;
                                                           }
    
    public static Set<String> getBrandAllocationIdsForCurrentTimePeriod() {
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocationForCurrentYear();
        Set<String> brandAllocationIds = new Set<String>();
        for(Brand_Allocation__c brandAllocation : lstBrandAllocation) {

            if(brandAllocation.Time_Period__c == SB2_Constants.QUARTERLY) {
                List<String> lstMonth = SB2_Constants.mapOfQuarterMonth.get(brandAllocation.Time_Interval__c);
                if(SB2_Constants.mapOfMonth.get(lstMonth[0]) >= Date.today().month() || SB2_Constants.mapOfMonth.get(lstMonth[2]) >= Date.today().month()) {
                    brandAllocationIds.add(String.valueOf(brandAllocation.Id).substring(0, 15));
                }
            } else if(brandAllocation.Time_Period__c == SB2_Constants.MONTHLY) {
                if(SB2_Constants.mapOfMonth.get(brandAllocation.Time_Interval__c) >= Date.today().month()) {
                    brandAllocationIds.add(String.valueOf(brandAllocation.Id).substring(0, 15));
                }
            } else {
                brandAllocationIds.add(String.valueOf(brandAllocation.Id).substring(0, 15));
            }
        }
        return brandAllocationIds;
    }
}