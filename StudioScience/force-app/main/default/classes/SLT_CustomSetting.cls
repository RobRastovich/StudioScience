public class SLT_CustomSetting {
    public static List<CSG_Record_Type__c> getCSGRecordType(String accessGroup, String profileName, String language){
        List<CSG_Record_Type__c> lstCSGRecord = [SELECT 
                                                 	Name, Label__c, Access_Group__c, Language__c, Profile__c, Sort_Order__c, Value__c
                                                 FROM
                                                	CSG_Record_Type__c
                                                 WHERE
                                                	 Access_Group__c LIKE: accessGroup
                                               	 AND
                                                	 Profile__c LIKE: profileName
                                                 AND 
                                                	 Language__c LIKE: language
                                                 ORDER BY 
                                                	 Sort_Order__c ASC];
        return lstCSGRecord;
    }
    
    public static List<CSG_Type_Selection__c > getTypeSelection(String accessGroup, String profileName, String language, String recordTypeName){
        List<CSG_Type_Selection__c > lstCSGRecord = [SELECT 
                                                     Name, Label__c, Access_Group__c, Language__c, Profile__c, Sort_Order__c, Value__c
                                                     FROM
                                                     CSG_Type_Selection__c
                                                     WHERE
                                                     Access_Group__c LIKE: accessGroup
                                                     AND
                                                     Profile__c LIKE: profileName
                                                     AND 
                                                     Language__c LIKE: language
                                                     AND
                                                     Record_Type__c LIKE: recordTypeName
                                                     ORDER BY 
                                                     Sort_Order__c ASC];
        return lstCSGRecord;
    }
    
    public static List<CSG_Product_SIze__c> getProductSize(String accessGroup, String profileName, String language, String recordTypeName){
        List<CSG_Product_SIze__c> lstCSGRecord = [SELECT 
                                                  Name, Label__c, Access_Group__c, Language__c, Profile__c, Sort_Order__c, Value__c
                                                  FROM
                                                  CSG_Product_SIze__c
                                                  WHERE
                                                  Access_Group__c LIKE: accessGroup
                                                  AND
                                                  Profile__c LIKE: profileName
                                                  AND 
                                                  Language__c LIKE: language
                                                  AND
                                                  Record_Type__c LIKE: recordTypeName
                                                  ORDER BY 
                                                  Sort_Order__c ASC];
        return lstCSGRecord;
    }
    
    public static List<CSG_Quantity_Type__c> getQunatityType(String accessGroup, String profileName, String language, String recordTypeName){
        List<CSG_Quantity_Type__c> lstCSGRecord = [SELECT 
                                                   Name, Label__c, Access_Group__c, Language__c, Profile__c, Sort_Order__c, Value__c
                                                   FROM
                                                   CSG_Quantity_Type__c
                                                   WHERE
                                                   Access_Group__c LIKE: accessGroup
                                                   AND
                                                   Profile__c LIKE: profileName
                                                   AND 
                                                   Language__c LIKE: language
                                                   AND
                                                   Record_Type__c LIKE: recordTypeName
                                                   ORDER BY 
                                                   Sort_Order__c ASC];
        return lstCSGRecord;

    }
    
    public static List<CSG_Category__c > getCategory(String accessGroup, String profileName, String language, String recordTypeName, String typeSelection){
        List<CSG_Category__c > lstCSGRecord = [SELECT 
                                                   Name, Label__c, Access_Group__c, Language__c, Profile__c, Sort_Order__c, Value__c
                                                   FROM
                                                   CSG_Category__c 
                                                   WHERE
                                                   Access_Group__c LIKE: accessGroup
                                                   AND
                                                   Profile__c LIKE: profileName
                                                   AND 
                                                   Language__c LIKE: language
                                                   AND
                                                   Record_Type__c LIKE: recordTypeName
                                               	   AND
                                               	   Type_Selection__c =: typeSelection
                                                   ORDER BY 
                                                   Sort_Order__c ASC];
        return lstCSGRecord;

    }
    
    public static List<CSG_Sub_Category__c  > getSubCategory(String accessGroup, String profileName, String language, String recordTypeName, String category){
        List<CSG_Sub_Category__c  > lstCSGRecord = [SELECT 
                                                   Name, Label__c, Access_Group__c, Language__c, Profile__c, Sort_Order__c, Value__c
                                                   FROM
                                                   CSG_Sub_Category__c  
                                                   WHERE
                                                   Access_Group__c LIKE: accessGroup
                                                   AND
                                                   Profile__c LIKE: profileName
                                                   AND 
                                                   Language__c LIKE: language
                                                   AND
                                                   Record_Type__c LIKE: recordTypeName
                                               	   AND
                                               	   Category__c  =: category
                                                   ORDER BY 
                                                   Sort_Order__c ASC];
        return lstCSGRecord;

    }
    
      /**
    *  @description : This method is use to fetch all record of Custom setting in ASC Order(CRM).
    *  @args        : 
    *  @return      : List<Topic_Added_For_User__c>
    **/
    public static List<Topic_Added_For_User__c > getTopicsName(){
        List<Topic_Added_For_User__c  > lstTopicsRecord = new List<Topic_Added_For_User__c>();
        lstTopicsRecord = [SELECT Topic_Name__c, Name
                              FROM Topic_Added_For_User__c
                              ORDER BY Topic_Name__c ASC];
        return lstTopicsRecord;
    }
}