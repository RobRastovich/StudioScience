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
    @date 16/04/2020
    @description This class is used to get brand allocation info and to perform different operations on it
*/
public with sharing class CNT_SB2_ManageBrand {
    
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus validateBrandAllocation(Brand_Allocation__c newBrandAllocation){
        System.debug('newBrandAllocation--'+newBrandAllocation);
        if(newBrandAllocation.Year_Of_Allocation__c == String.valueOf(Date.today().year())){ 
        if(newBrandAllocation.Time_Period__c == SB2_Constants.QUARTERLY){
            List<String> lstMonth = SB2_Constants.mapOfQuarterMonth.get(newBrandAllocation.Time_Interval__c);
            if(SB2_Constants.mapOfMonth.get(lstMonth[2]) < Date.today().month()) {
                throw new AuraHandledException('Time Period Passed');
            }
        } else if(newBrandAllocation.Time_Period__c == SB2_Constants.MONTHLY && 
            SB2_Constants.mapOfMonth.get(newBrandAllocation.Time_Interval__c) < Date.today().month()){
            throw new AuraHandledException('Time Period Passed');
        }
        }
        
        return getDetails(newBrandAllocation);
    }
    @AuraEnabled 
    public static LightningComponentUtility.RequestStatus getFutureBrandAllocation(Brand_Allocation__c newBrandAllocation){
       return getDetails(newBrandAllocation); 
    }   
    
    private static LightningComponentUtility.RequestStatus getDetails(Brand_Allocation__c newBrandAllocation){
        String timeInterval = newBrandAllocation.Time_Interval__c;
        String timePeriod = newBrandAllocation.Time_Period__c;
        List<String> lstOfFurtherMonth = new List<String>();
        List<String> lstTimePeriod = new List<String> {SB2_Constants.MONTHLY, SB2_Constants.QUARTERLY};
        String yearOfAlloc = newBrandAllocation.Year_Of_Allocation__c;
        Integer startTimeInterval;
        if(newBrandAllocation.Time_Period__c == SB2_Constants.MONTHLY) {
            for(startTimeInterval = SB2_Constants.mapOfMonth.get(timeInterval); startTimeInterval <= 12; startTimeInterval++){
                lstOfFurtherMonth.add(SB2_Constants.mapOfIntegerMonth.get(startTimeInterval));
                lstOfFurtherMonth.add(SB2_Constants.mapOfIntegerQuarter.get(startTimeInterval));
            } 
        } else if(newBrandAllocation.Time_Period__c == SB2_Constants.QUARTERLY){
            for(startTimeInterval = SB2_Constants.mapOfQuarter.get(timeInterval); startTimeInterval <= 12; startTimeInterval++){
                lstOfFurtherMonth.add(SB2_Constants.mapOfIntegerMonth.get(startTimeInterval));
                lstOfFurtherMonth.add(SB2_Constants.mapOfIntegerQuarter.get(startTimeInterval));
            }
        }
        
        Map<String, Object> responseMap = new Map<String, Object>();
        System.debug('lstOfFurtherMonth--'+lstOfFurtherMonth);
        List<Brand_Allocation__c> lstExistingBrandAlloc = SLT_SB2_BrandAllocation.getSelectedBrandAllocation(
        newBrandAllocation.Brand__c, true, yearOfAlloc, lstTimePeriod, lstOfFurtherMonth, newBrandAllocation.Program_Type__c);
        if(!lstExistingBrandAlloc.isEmpty()) {
            for(Brand_Allocation__c oldBrandAlloc : lstExistingBrandAlloc){
                responseMap.put(oldBrandAlloc.Name , oldBrandAlloc);
            }
            return new LightningComponentUtility.RequestStatus(false, 'already existing Brand Allocation', responseMap);
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String, Object> deactivateBrandAllocation(List<String> lstBrandAlloc, String status){
       	try {
            
			List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocationByName(lstBrandAlloc);
            for(Brand_Allocation__c brandAlloc : lstBrandAllocation) {
                brandAlloc.Is_Active__c = false;
                brandAlloc.status__c = status;
            }
            update lstBrandAllocation;
            return new Map<String,Object>{'Id' => lstBrandAllocation[0].Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> insertCurrentBrandAllocation(Brand_Allocation__c newBrandAllocation){
       	try {
            
            insert newBrandAllocation;
            return new Map<String,Object>{'Id' => newBrandAllocation.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> insertBrandAllocation(Brand_Allocation__c newBrandAllocation){
       	try {
            String timeInterval = newBrandAllocation.Time_Interval__c;
            String timePeriod = newBrandAllocation.Time_Period__c;
            List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
            lstBrandAllocation.add(newBrandAllocation);
            if(timePeriod == SB2_Constants.MONTHLY) {
                Integer startTimeInterval;
                for(startTimeInterval = SB2_Constants.mapOfMonth.get(timeInterval)+1; startTimeInterval <= 12; startTimeInterval++) {
                    Brand_Allocation__c cloneBrandAllocation = newBrandAllocation.clone(false, false, false, false);
                    cloneBrandAllocation.Time_Interval__c = SB2_Constants.mapOfIntegerMonth.get(startTimeInterval);
                    lstBrandAllocation.add(cloneBrandAllocation);
                }
            } else if (timePeriod == SB2_Constants.QUARTERLY){
                if(timeInterval.contains(' ')){
                    Integer StartTimeInterval ;
                    for(StartTimeInterval = Integer.valueOf(timeInterval.split(' ')[1])+1;StartTimeInterval <= 4 ;StartTimeInterval++) {
                        Brand_Allocation__c cloneBrandAllocation = newBrandAllocation.clone(false, false, false, false);
                    	cloneBrandAllocation.Time_Interval__c = 'Quarter '+StartTimeInterval;
                    	lstBrandAllocation.add(cloneBrandAllocation);
                    }
                }
                
            }
            insert lstBrandAllocation;
            return new Map<String,Object>{'Id' => newBrandAllocation.Id};
        } catch (Exception e) {
            throw new AuraHandledException(UTL_String.getErrorMessage(e.getMessage()));
        }
    }
    /**
    *  @description : This method is use to fetch Brand allocation info
    *  @args        : String record Id
    *  @return      : List<Brand_Allocation__c>
    **/
    @AuraEnabled
    public static List<Brand_Allocation__c> getBrandAllocation(String recordId){
        List<Brand_Allocation__c> lstBrandAllocation = SLT_SB2_BrandAllocation.getBrandAllocation(recordId);
        if(!lstBrandAllocation.isEmpty()){
            return lstBrandAllocation;
        }
        return null;
    }
    
    /**
    *  @description : This method is use to deactivate Brand allocation
    *  @args        : String record Id
    *  @return      : Brand_Allocation__c
    **/
    @AuraEnabled
    public static Brand_Allocation__c updateAllocation(String recordId){
        try{
            Brand_Allocation__c brandAllocation = new Brand_Allocation__c(Id = recordId);
            brandAllocation.Is_Active__c = false;
            brandAllocation.Status__c = 'Inactive';
            update brandAllocation;
            return brandAllocation;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    
    @AuraEnabled
    public static Brand_Allocation__c updateCarryForwardAllocation(String recordId, Boolean isCarryforward){
        try{
            Brand_Allocation__c brandAllocation = new Brand_Allocation__c(Id = recordId);
            brandAllocation.Is_Carry_Forward__c = isCarryforward;
            update brandAllocation;
            return brandAllocation;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
    }
    /**
    *  @description : This method is use to Clone Brand allocation 
    *  @args        : String brandId, String isCarryForward, String programType, String timePeriod, 
    * 				  String timeInterval, String yearOfAllocation
    *  @return      : Brand_Allocation__c
    **/
    @AuraEnabled
    public static Brand_Allocation__c cloneBrandAllocation(String BrandId, String isCarryForward, String programType, 
                                                           String timePeriod, String timeInterval, String yearOfAllocation){
                                                               try{
                                                                   if(String.isEmpty(programType)|| String.isEmpty(timePeriod) ||
                                                                      String.isEmpty(timeInterval)) {
                                                                          throw new AuraHandledException('Please fill all required fields');
                                                                      }
                                                                   Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
                                                                   brandAllocation.Is_Active__c = true;
                                                                   brandAllocation.Brand__c =  BrandId;
                                                                   brandAllocation.Is_Carry_Forward__c = Boolean.valueOf(isCarryForward);
                                                                   brandAllocation.Program_Type__c = programType;
                                                                   brandAllocation.Time_Interval__c = timeInterval;
                                                                   brandAllocation.Time_Period__c = timePeriod;
                                                                   brandAllocation.Year_Of_Allocation__c = yearOfAllocation;              
                                                                   insert brandAllocation;
                                                                   return brandAllocation;}
                                                               catch(Exception e){
                                                                   String errorMsg = e.getMessage();
                                                                   if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                                                                       errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                                                                   }
                                                                   if(errorMsg.contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
                                                                       errorMsg = errorMsg.substringBetween('FIELD_FILTER_VALIDATION_EXCEPTION, ', ': ');
                                                                   }
                                                                   throw new AuraHandledException(errorMsg);  
                                                               }
                                                           }
    
    /**
    *  @description : This method is get picklist value of controlling and dependent picklist field
    *  @args        : sObject objDetail, string contrfieldApiName,string depfieldApiName
    *  @return      : Map<String, List<String>>
    **/
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = Util_SB2_Decimal.base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    /**
    *  @description : This method is get picklist value of year of allocation
    *  @args        : String objectName, String field_apiname,Boolean nullRequired
    *  @return      : List<String>
    **/
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
        if(nullRequired == true){
            optionlist.add('--None--');
        }       
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    
    
    /**
    *  @description : This method is get json string for wrapper class
    *  @args        : List<Schema.PicklistEntry> PLEs
    *  @return      : List<PicklistEntryWrapper>
    **/
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
    }
    
}