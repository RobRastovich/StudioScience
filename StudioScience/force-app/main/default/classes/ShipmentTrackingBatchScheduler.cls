global with sharing class ShipmentTrackingBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
        String oSourceName = SBP_Constants.SAMPLE_KIT_APINAME;
		String sCarrierName = SBP_Constants.SAMPLE_KIT_FEDEXCARRIERNAME;				
		ShipmentTrackingBatch colBatch = new ShipmentTrackingBatch(oSourceName, sCarrierName);			 
		Id batchprocessid = Database.executeBatch(colBatch,30);		   	
	}
}