public with sharing class ApexHelperController {
    
    @AuraEnabled
    public static List<sObject> executeSoql(String soql) {
      List<sObject> result = Database.query(soql);
      return result;
    }
  }