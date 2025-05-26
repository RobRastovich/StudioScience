/*
** Name: CalendarProgramSettingsScheduler
** Description: This Scheduler class is responsible to update the calendar values for all the filter Picklist value 
				in the calendar values custom settings from Program__c object and also schedule batch 
				class- CalendarDistributorUpdateBatch to update distributor values for Filter 
** Version History
Date            Version         By                    Description
---------------------------------------------------------------------------------------
01/20/2016			1	    TCS DEV team          created CalendarProgramSettingsScheduler

*/
global class CalendarProgramSettingsScheduler implements Schedulable {
   
    
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals; 

    }
    
    /* This standard execute method insert picklist metadata and also run batch for adding distributor*/ 
    global void execute(SchedulableContext SC) {
        insertProgramMetaValue();
        CalendarDistributorUpdateBatch batch = new  CalendarDistributorUpdateBatch();
        database.executeBatch(batch ,100);
       
    }
    
    /*This method get the object prefix from salesforce schema*/
    private static string getObjectprefix(String ObjectApi_name){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        String keyPrefix = sobject_describe.getKeyPrefix();
        return keyPrefix ;
        
    
    }
    
   /*This method insert the newly added picklist value in the calendar values custom settings and delete all the old values*/
    private  static void insertProgramMetaValue(){
        List<Calendar_Settings__c> programCalendarSeetingLst= Calendar_Settings__c.getall().values();//Get All settings Data from Custom settings 
        List<Calendar_Values__c> refreshCalendarValuesLst= new List<Calendar_Values__c>();
        List<Calendar_Values__c> existingCalendarSettingsVallist=Calendar_Values__c.getall().values();
        List<Calendar_Values__c> notValidCalendarValuesLst= new List<Calendar_Values__c>();

        MAp<string,Calendar_Values__c> mapCalendarValues= new Map<string,Calendar_Values__c>();
        for(Calendar_Values__c CalVal: existingCalendarSettingsVallist){
            if(CalVal.IsData__c!=true){
                mapCalendarValues.put(CalVal.Setting__c+':'+ CalVal.Value__c,CalVal);
            }   
        
        }
        system.debug('&&&& mapCalendarValues'+mapCalendarValues);
        
        for(Calendar_Settings__c setting: programCalendarSeetingLst){
            if(setting.Type__c.contains('Picklist') ){
                system.debug('!!!! Picklist'+setting.Field__c);
                
                List<string> picklistVal=getPicklistValues(setting.Object__c,setting.Field__c);
                
                if(picklistVal!=null &&!picklistVal.isEmpty()){

                    for(string pickVal: picklistVal){
                    system.debug('!!!! map value check'+setting.Name+':'+pickVal);
                        if(mapCalendarValues.get(setting.Name+':'+pickVal)==null){
                            Calendar_Values__c newCalValue= new Calendar_Values__c();
                            newCalValue.Name=pickVal+String.valueOf(Math.random()).substring(2, 6);
                            newCalValue.Setting__c=setting.Name;
                            newCalValue.Value__c=pickVal;
                            newCalValue.isdata__c=false;
                            refreshCalendarValuesLst.add(newCalValue);
                        }
                        else{
                            refreshCalendarValuesLst.add(mapCalendarValues.get(setting.Name+':'+pickVal));
                            mapCalendarValues.remove(setting.Name+':'+pickVal);
                        }
                        
                        
                        
                    }
                }
            }
        }
        system.debug('refreshCalendarValuesLst'+refreshCalendarValuesLst);
        notValidCalendarValuesLst=mapCalendarValues.values();
   
        try{
            
            if(refreshCalendarValuesLst!=null &&!refreshCalendarValuesLst.isEmpty()){
                upsert refreshCalendarValuesLst Name;
                delete notValidCalendarValuesLst;
            }
            if(notValidCalendarValuesLst!=null &&!notValidCalendarValuesLst.isEmpty()){
                delete notValidCalendarValuesLst;
            }
        }
        catch(DmlException e){
            system.debug('Exception Occured'+ e.getmessage());
        }
        string objectPrefix=getObjectprefix('Calendar_Values__c');
        string query='select id, Name from Calendar_Values__c where isdata__c=false and (NOT Name LIKE \'' + objectPrefix+'%\''+')';
        system.debug('######## query'+query);
        List<Calendar_Values__c> updateValList=Database.Query(query);
        if(updateValList!=null && !updateValList.isEmpty()){
            for(Calendar_Values__c c:updateValList){
                c.Name=c.Id;
            }
            update updateValList;
         }    
        
    }

}