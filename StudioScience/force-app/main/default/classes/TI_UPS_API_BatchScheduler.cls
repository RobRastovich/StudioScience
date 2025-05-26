global with sharing class TI_UPS_API_BatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
        String oSourceName = SBP_Constants.barrelObject;
		String sCarrierName = SBP_Constants.carrierName;				
		TI_UPS_API_Batch colBatch = new TI_UPS_API_Batch(oSourceName, sCarrierName);			 
		Id batchprocessid = Database.executeBatch(colBatch,1);		   	
	}
}