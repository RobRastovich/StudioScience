public class SLT_SOI_Sample_Kit_Shipping_Address {
    public static List<Sample_Kit_Shipping_Address__c> getShipAddressRecords(String country) {
        List<Sample_Kit_Shipping_Address__c> addressList = new List<Sample_Kit_Shipping_Address__c>();
        if(String.isNotBlank(country)) {
            addressList = [SELECT Id, Name, State__c
                              FROM Sample_Kit_Shipping_Address__c
                              WHERE Country__c =: country];  
        }
        return addressList;
    }
    
    public static List<Sample_Kit_Shipping_Address__c> filterOfficeValueByStateList(String country, String stateVal) {
        List<Sample_Kit_Shipping_Address__c> sampleAddressList = new List<Sample_Kit_Shipping_Address__c>();
        if(String.isNotBlank(country) && String.isNotBlank(stateVal)) {
            sampleAddressList = [SELECT Id, Name, Street__c, City__c, State__c, Zip_Code__c
                                    FROM Sample_Kit_Shipping_Address__c 
                                    WHERE Country__c =: country 
                                    AND State__c =: stateVal];
        }
        return sampleAddressList;
    }
}