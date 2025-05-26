public class ProcessSelectedIdsController {
    public string[] SelectedCaseIDs{get;set;}
    public string customIdsStr{get;set;}
    public string CaseString{get;set;}
    public ProcessSelectedIdsController(ApexPages.StandardSetController listcontroller){
        SelectedCaseIDs = new string[]{};
        for(Case caserec : (Case[])listcontroller.getSelected()){
            SelectedCaseIDs.add(caserec.Id);
        }
        system.debug('=============== selected caseid records==='+SelectedCaseIDs);
         CaseString = JSON.serialize(SelectedCaseIDs);

        List<String>BarrelIds = new List<String>();
   		List<Barrel__c>BarrelRecords =new List<Barrel__c>();
    	BarrelRecords = [SELECT ID,Case__c from Barrel__c WHERE Case__c IN:SelectedCaseIDs];
        for(Barrel__c Barrec : BarrelRecords){
            if(Barrec.Case__c!=null)
            BarrelIds.add(Barrec.ID);
        }
        system.debug('======barrel ids records ==='+BarrelIds);
        customIdsStr = JSON.serialize(BarrelIds);

    }
    @AuraEnabled
    public static Boolean updateShipDate(String shipDate,String[] BarrelIds) {
     Boolean isUpdated;
    try{
        Date shipDateFormatted = Date.valueOf(shipDate);
        system.debug('the value is ==='+shipDateFormatted);
        system.debug('barrel ids ===='+BarrelIds);
        List<Barrel__c> BarrelRecords = new List<Barrel__c>();
        if(!BarrelIds.isEmpty() ){
        BarrelRecords = [SELECT ID,Name,Ship_Date__c,Case__c from Barrel__c WHERE ID IN:BarrelIds];
        system.debug('=======barrrel records to be==='+BarrelRecords);
        }
        List<Barrel__c>BarrelRecordstoUpdate = new List<Barrel__c>();
        for(Barrel__c barrel: BarrelRecords){
            barrel.Ship_Date__c = shipDateFormatted;
            BarrelRecordstoUpdate.add(barrel);
            system.debug('=======barrel record to be updated===='+barrel);
        }
        isUpdated= false;
        if(BarrelRecordstoUpdate.size()>0){
			update BarrelRecordstoUpdate;
            isUpdated = true;
        }
                    
     }
     catch(Exception e){
      throw new AuraHandledException('Error Exception happend'+e.getMessage());
     }
        
    return isUpdated;
    }
}