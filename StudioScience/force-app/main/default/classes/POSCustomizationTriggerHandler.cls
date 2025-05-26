public class POSCustomizationTriggerHandler {

	/*public static void handleBeforeInsert(List<POS_Customization__c> posItems) {
	}

	public static void handleBeforeUpdate(List<POS_Customization__c> posItems, Map<Id, POS_Customization__c> oldPosItems) {
	}

	public static void handleBeforeDelete(List<POS_Customization__c> posItems, Map<Id, POS_Customization__c> oldPosItems) {
	}
	*/
     public static void handleBeforeUpdate(List<POS_Customization__c> posItems, Map<Id, POS_Customization__c> oldPosItems) {
        if (POSCustomizationServices.runTrigger) {
            POSCustomizationServices.runTrigger = true;
            POSCustomizationServices.updateBottleLabelText(posItems);
        }      
    }
	public static void handleAfterDelete(Map<Id, POS_Customization__c> oldPosItems) {
        if (POSCustomizationServices.runTrigger) {
            POSCustomizationServices.runTrigger = false;
           POSCustomizationServices.uncheckBottleTextEnteredOnCase(oldPosItems);
        }      
    }
	public static void handleAfterInsert(List<POS_Customization__c> posItems, Map<Id, POS_Customization__c> oldPosItems) {
		if (POSCustomizationServices.runTrigger) {
			POSCustomizationServices.runTrigger = false;
			POSCustomizationServices.updateInsertTextWithAccountName(oldPosItems);
		}

	}
	public static void handleAfterUpdate(List<POS_Customization__c> posItems, Map<Id, POS_Customization__c> oldPosItems) {
		if (POSCustomizationServices.runTrigger) {
			POSCustomizationServices.runTrigger = false;
			POSCustomizationServices.updateInsertTextWithAccountName(oldPosItems);
			POSCustomizationServices.sendEmailonLabelTextUpdate(posItems,oldPosItems);
		}
	}

}