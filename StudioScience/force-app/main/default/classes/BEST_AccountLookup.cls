public with sharing class BEST_AccountLookup {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, SAP_Vendor_ID__c, billingstreet, billingcity, billingstate, billingPostalCode, BillingCountry, Account_Manager_Email__c, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                query += ' WHERE (Name LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
                query += ' OR SAP_Vendor_ID__c LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\') AND Account_Manager_Email__c != \'\' LIMIT 49999';
            }
	        for(SObject s : Database.query(query)) {
                String billAdd = '';
                if((String)s.get('billingstreet') != null)
                    billAdd += (String)s.get('billingstreet');
                if((String)s.get('billingcity') != null)
                    billAdd += ', '+(String)s.get('billingcity');
                if((String)s.get('billingstate') != null)
                    billAdd += ', '+(String)s.get('billingstate');
                if((String)s.get('billingPostalCode') != null)
                    billAdd += ', '+(String)s.get('billingPostalCode');
                if((String)s.get('BillingCountry') != null)
                    billAdd += ', '+(String)s.get('BillingCountry');
	            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id'), (String)s.get('SAP_Vendor_ID__c'), billAdd));
	        }
            return recordsDataList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }

    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String vendorId;
        @AuraEnabled public String address;
        public RecordsData(String label, String value, String vendorId, String address) {
            this.label = label;
            this.value = value;
            this.vendorId = vendorId;
            this.address = address;
        }
    }
}