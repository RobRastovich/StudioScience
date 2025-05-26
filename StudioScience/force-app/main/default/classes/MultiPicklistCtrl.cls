public class MultiPicklistCtrl {

    /**************************************************************************************************************
    Description:    Returns picklist options for a field on the Incident object, as specified
                    by the apiName parameter
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    2/2019      Connor Gallaher    Initial Creation

    ***************************************************************************************************************/
	@AuraEnabled
    public static List<String> getIncidentPicklistValues(String apiName) {
        List<String> options = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Incident__c.getSObjectType().getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(apiName).getDescribe().getPickListValues();

        for (Schema.PicklistEntry ple : picklistValues) {
            options.add(ple.getLabel());
        }
        return options;
    }
}