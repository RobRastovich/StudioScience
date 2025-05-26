/**************************************************************************************
Apex Class Name     : dhlCaseViewController
Created Date        : 3/2022
Function            : Apex Controller of LWC component 'dhlCase'
*************************************************************************************/
public with sharing class dhlCaseViewController {
    
    /**************************************************************************************************************
Method name:    getCaseRecord
Date:           3/2022       Arushi Jain     Metacube 
args:           String recordId
Details and Notes:
This method is used to fetch the case record according to passed recordId.
***************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Case getCaseRecord(String recordId) {
        String caseId = String.escapeSingleQuotes(recordId);
        Case recordCase = new Case();
        List<Case> getCaseRecords = [SELECT Id, CaseNumber,First_name__c,Last_name__c,Email_Address__c,
                                        Consumer_City__c,Consumer_Country__c,Consumer_Postal_Code__c,Consumer_State__c,
                                        Consumer_Street__c,OrderID__c, ContactPhone, ContactEmail, Customer_Phone_Number__c,
                                        Origin, AdditionalInformation__c,Program_Subscription__c
                                        FROM Case
                                        WHERE Id =:recordId];
        for (Integer i = 0; i < getCaseRecords.size(); i++) {
            if (!String.isEmpty(getCaseRecords[i].AdditionalInformation__c) &&
                getCaseRecords[i].AdditionalInformation__c == 'Membership Cancellation') {
                getCaseRecords[i].AdditionalInformation__c = 'Cancel Shipment';
            }
        }
        recordCase = getCaseRecords.size()>0? getCaseRecords[0]: null;
        return recordCase; 
    }
}