public class CNT_SB2_DynamicPicklistController {
    /**
    *  @description : This method is get picklist value of year of allocation
    *  @args        : String objectName, String field_apiname,Boolean nullRequired
    *  @return      : List<String>
    **/
    @AuraEnabled
    public static List<String> getPicklistOptions(String objectName, String field){
        List<String> optionlist = new List<String>();   
        if(objectName == 'Brand_Allocation__c' && field == 'Brand__C'){
            List<Brand__c> lstBrand = SLT_SB2_Brand.getExistingBrand();
            for(Brand__c newBrand : lstBrand){
                optionlist.add(newBrand.Id+'-'+newBrand.Name);
            }
        }
        if(objectName == 'Brand_Allocation__c' && field == 'Year_Of_Allocation__c'){
            Integer yearOfAlloc = Date.today().year();
            for(Integer i =0; i<5;i++){
                optionlist.add(String.valueOf(yearOfAlloc+i));
            }
        } else{ 
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field).getDescribe().getPickListValues();             
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        }
        return optionlist;
    }
}