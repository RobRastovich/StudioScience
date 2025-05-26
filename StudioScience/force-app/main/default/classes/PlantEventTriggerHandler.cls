public class PlantEventTriggerHandler {

	
    public static void handleBeforeInsert(List<Plant_Event__c> events) {
        PlantEventServices.restrictDuplicateEntryOfBookingsForInsert(events);
	}
	

	public static void handleBeforeUpdate(List<Plant_Event__c> events, Map<Id, Plant_Event__c> oldEvents) {
		PlantEventServices.updateRelatedCaseWhenTripIsToday(events, oldEvents);
        PlantEventServices.restrictDuplicateEntryOfBookingsForUpdate(events, oldEvents);
	}
/*
	public static void handleBeforeDelete(List<Plant_Event__c> events, Map<Id, Plant_Event__c> oldEvents) {
	}
*/
	public static void handleAfterInsert(List<Plant_Event__c> events) {
        PlantEventServices.deleteDateHoldsForPlantTeamForInsert(events);
	}
    
	public static void handleAfterUpdate(List<Plant_Event__c> events, Map<Id, Plant_Event__c> oldEvents) {
		PlantEventServices.deleteDateHoldsForPlantTeamForUpdate(events, oldEvents);
	}
    //Added LSB-139
    public static void handleAfterDelete(List<Plant_Event__c> events, Map<Id, Plant_Event__c> oldEvents) {
        List<Plant_Event__c> plantEventRecords = new List<Plant_Event__c>();
        for(Plant_Event__c recordPlantEvent : events){
            if(recordPlantEvent.recordTypeId == SBP_Constants.LAPHROAIG_SINGLE_CASK_EVENT_RT_ID
               && recordPlantEvent.Brand__c == SBP_Constants.LAPHROAIG_SINGLE_CASK) {
                   plantEventRecords.add(recordPlantEvent);
               }
        }
        if(!plantEventRecords.isEmpty() && plantEventRecords.size() > 0){
            PlantEventServices.updateTrippedBookedWhenPlantEventDelete(plantEventRecords);  
        }
    }



}