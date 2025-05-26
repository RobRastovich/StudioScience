public class BarrelTriggerHandler {
    
    public static void handleBeforeInsert(List<Barrel__c> barrels) {
        BarrelServices.addBarrelNumberToBarrelRecord(barrels);
        BarrelServices.updateTimestampForBarrel(barrels, null);
    }
    
    public static void handleBeforeUpdate(List<Barrel__c> barrels, Map<Id, Barrel__c> oldBarrels) {
        // BarrelServices.addErrorMsgBarrelNumberField(barrels,oldBarrels);
        //BarrelServices.addBarrelNumberToBarrelRecord(barrels);
        BarrelServices.checkIfBarrelWasSelected(barrels, oldBarrels);
        BarrelServices.updateSKUforKCBarrels(barrels, oldBarrels);
        BarrelServices.checkFinalDetailsOfBarrel(barrels, oldBarrels);
        BarrelServices.barrelHasShipped(barrels, oldBarrels);
        BarrelServices.updateTimestampForBarrel(barrels, oldBarrels);
        //BarrelServices.updateBarrelReadySubCaseWithBarrelPO(barrels,oldBarrels);   
    }
    
    /*public static void handleBeforeDelete(List<Barrel__c> barrels, Map<Id, Barrel__c> oldBarrels) {
}*/
    public static void handleAfterInsert(List<Barrel__c> barrels, Map<Id, Barrel__c> oldBarrels) {
    }
    
    public static void handleAfterUpdate(List<Barrel__c> barrels, Map<Id, Barrel__c> oldBarrels) {
        List<Barrel__c> barrelLaphroaigRecords = new List<Barrel__c>();  //Added for LSB-153
        for(Barrel__c barrel : barrels){
            if(barrel.recordTypeId == SBP_Constants.LAPHROAIG_SINGLE_CASK_FULL_BARREL_RT_ID) {
                barrelLaphroaigRecords.add(barrel);
            }
        }
        if(barrelLaphroaigRecords.size() > 0){
            BarrelServices.updateCaseStatusAndSubStatus(barrelLaphroaigRecords, (Map<Id, Barrel__c>) oldBarrels); //Added for LSB-153
        }
        BarrelServices.emailFinalBarrelDetails(barrels, oldBarrels);
        BarrelServices.updateBarrelReadySubCaseWithBarrelPO(barrels,oldBarrels);
        BarrelServices.updateParentCaseWithBarrelPO(barrels,oldBarrels);
        BarrelServices.emailBasedOnQuantityAndProof(barrels, oldBarrels);
        BarrelServices.sendEmailForLessQuantityOnKCBarrels(barrels, oldBarrels);
        //   BarrelServices.checkForDuplicates(barrels,oldBarrels);
    }
}