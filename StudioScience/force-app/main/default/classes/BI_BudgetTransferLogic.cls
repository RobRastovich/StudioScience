public without sharing class BI_BudgetTransferLogic {
    
    public static void handleBudgetTransferAfterUpdate(List<MarketingPlanAdjustments__c> triggerNew, 
                                                       Map<ID, MarketingPlanAdjustments__c> triggerNewMap, 
                                                       List<MarketingPlanAdjustments__c> triggerOld, 
                                                       Map<ID, MarketingPlanAdjustments__c> triggerOldMap) {
                                                           
                                                           
                                                           List<MarketingPlanAdjustments__c> approvedTransfers = new List<MarketingPlanAdjustments__c>();	
                                                           
                                                           for(ID transferId : triggerNewMap.keySet() )
                                                           {
                                                               //Only Transfers that have CHANGED to Approved will be processed.
                                                               if(triggerOldMap.get(transferId).Request_Status__c != triggerNewMap.get(transferId).Request_Status__c &&
                                                                  triggerNewMap.get(transferId).Request_Status__c == BI_Constants.TRANSFERREQUEST_STATUS_APPROVED)
                                                               {
                                                                   System.debug(LoggingLevel.INFO,'BudgetTransfer changed to Approved: ' + transferId);
                                                                   approvedTransfers.add(triggerNewMap.get(transferId));
                                                                   
                                                               }  		
                                                           }	
                                                           if (!approvedTransfers.isEmpty()) {
                                                               
                                                               //The business expects ~400 Transfers per year. Due to small size and complexity, the trigger logic
                                                               //supports only a single Transfer being approved at a time. This is to avoid data integrity
                                                               //issues. 
                                                               if (approvedTransfers.size() == 1) {
                                                                   processTransfers(approvedTransfers.get(0));	
                                                               } else {
                                                                   for (MarketingPlanAdjustments__c t : approvedTransfers) {
                                                                       t.addError(BI_Constants.TRANSFERREQUEST_MULTIPLEAPPROVALS);
                                                                   }
                                                               }					
                                                           }	
                                                       }
    
    private static void processTransfers(MarketingPlanAdjustments__c transfer) {
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetTransferLogic.processTransfers');
        
        if (transfer == null) { return; }
        
        //Marketing Plans that will get adjusted and sent to UPDATE.
        //Map<Id, MarketingPlan__c> updatePlans = new Map<Id, MarketingPlan__c>();
        List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c>();
        
        //Audit Logs that will get created based on every touch of an MP's Budget field. 
        List<Audit_Log__c> auditLogs = new List<Audit_Log__c>(); 		
        
        //Get the full Yearly hierarchy of MPs.
        Map<Id, MarketingPlan__c> allPlans = retrievePlanHierarchy(transfer);
        
        //Get the Sender and Receiver MPs.
        MarketingPlan__c sender = allPlans.get(transfer.TransferringMarketingPlan__c);
        MarketingPlan__c receiver = allPlans.get(transfer.ReceivingMarketingPlan__c);
        System.debug(LoggingLevel.INFO,'Sender found: ' + sender);
        System.debug(LoggingLevel.INFO,'Receiver found: ' + receiver);
        
        //Find the Sender's and Receiver's lineage to Root.
        List<MarketingPlan__c> senderLineage = getLineageToRoot(sender, allPlans);
        List<MarketingPlan__c> receiverLineage = getLineageToRoot(receiver, allPlans);
        
        //Validate Sender has enough funds, or addError() to the Transfer.
        Boolean senderHasFunds = validateSenderHasEnoughFunds(transfer, sender);
        if (!senderHasFunds) {
            return;
        }		
        
        //Is the Sender an Ancestor of the Receiver?
        Boolean isSenderAncestor = isAncestor(sender, receiverLineage);		
        //Is the Receiver an Ancestor of the Sender?
        Boolean isSenderDescendant = isAncestor(receiver, senderLineage);
        
        //Transfer Scenarios - 3 exist.
        if (isSenderAncestor == true) {
            
            //Loop from the Receiver up to Sender, edit each MP on path, but don't edit the Sender.
            //Reverse the order so it goes Sender down to Receiver.
            list<MarketingPlan__c> tmpUpwardPlans = new list<MarketingPlan__c>();
            for (Integer j=0; j < receiverLineage.size(); j++) {
                
                //Once we get to the Sender, break because we don't want to edit that MP.
                if (receiverLineage.get(j).Id == sender.Id) { break; }
                tmpUpwardPlans.add(receiverLineage.get(j));													
            }
            //Loop the upwards list in reverse (AKA downwards from Sender to Receiver)
            for (Integer t = tmpUpwardPlans.size() - 1; t >= 0; t--) {
                //ADD the Transfer amount to each MP from Sender down to Receiver.
                //Create an Audit Log also.
                updateBudgetAndCreateLog(true, tmpUpwardPlans.get(t), transfer, auditLogs, updatePlans);	
            }					
            
        } else if (isSenderDescendant == true) {
            
            //Loop from the Sender up to the Receiver, edit each MP on path, but don't edit the Receiver.
            for (Integer k = 0; k < senderLineage.size(); k++) {
                
                //Once we get the Receiver, break because we don't want to edit that MP.
                if (senderLineage.get(k).Id == receiver.Id) { break; }
                
                //SUBTRACT the Transfer amount from each MP from Sender up to Receiver.
                //Create an Audit Log also.
                updateBudgetAndCreateLog(false, senderLineage.get(k), transfer, auditLogs, updatePlans);
            }
            
        } else {
            //Neither are ancestor of each other.
            //Need to find the common ancestor of them both, and update both sides of the transfer.
            System.debug(LoggingLevel.INFO,'Finding Commond Ancestor MP.');
            MarketingPlan__c commonAncestor = findCommonAncestor(senderLineage, receiverLineage);
            
            if (commonAncestor == null) {
                //Throw an error
                transfer.addError('It appears that the Sender and Receiver Marketing Plans are not part of the same Yearly hiearchy. Please contact your administrator.');
                return;
            }
            System.debug(LoggingLevel.INFO,'Common Ancestor: ' + commonAncestor);
            
            //Loop from the Sender up to the Common Ancestor, edit each MP on path, but don't edit the Common Ancestor.
            for (Integer s = 0; s < senderLineage.size(); s++) {
                //Once we get the Common Ancestor, break because we don't want to edit that MP.
                if (senderLineage.get(s).Id == commonAncestor.Id) { break; }
                
                //SUBTRACT the Transfer amount from each MP from Sender up to Common Ancestor.
                //Create an Audit Log also.
                updateBudgetAndCreateLog(false, senderLineage.get(s), transfer, auditLogs, updatePlans);		
            }
            
            //Loop from the Common Ancestor down to the Receiver (using list-reverse logic), edit each MP on path, but don't edit the Common Ancestor.
            list<MarketingPlan__c> tmpUpwardPlans = new list<MarketingPlan__c>();			
            for (Integer r = 0; r < receiverLineage.size();  r++) {
                
                //Once we get to the Common Ancestor, break because we don't want to edit that MP.
                if (receiverLineage.get(r).Id == commonAncestor.Id) { break; }	
                
                tmpUpwardPlans.add(receiverLineage.get(r));						
            }	
            //Loop the upwards list in reverse (AKA downwards from CommonAncestor to Receiver)
            for (Integer t = tmpUpwardPlans.size() - 1; t >= 0; t--) {
                //ADD the Transfer amount to each MP from Receiver up to Sender.
                //Create an Audit Log also.
                updateBudgetAndCreateLog(true, tmpUpwardPlans.get(t), transfer, auditLogs, updatePlans);	
            }
            
        }
        
        
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        try {
            // THIS IS BAD PRACTICE! THIS IS BAD PRACTICE! THIS IS BAD PRACTICE! 
            //The only reason why this is considered OK in this scenario is because
            //1) There is validation rule on MarketingPlan prevents sum of child MP Budgets to exceed parent Budget.
            //2) There will only ever be 1 Transfer record being processed, per trigger, as handled in the method handleBudgetTransferAfterUpdate.
            //3) There can only be 2N DML transactions to occur per the FOR loop, where N is the depth of Yearly MP hierarchy. 
            //4) Currently, Yearly MP hierarchy has deepest depth of 7. (2*7) = 14.
            //5) ~14 DML operations + other operating DMLs = ~20 DML statements.
            //6) Assume the plans in updatePlans is ordered correctly to move funds around hierarcy, 1-by-1.
            for (MarketingPlan__c p : updatePlans) {
                System.debug(LoggingLevel.INFO,'Updating MarketingPlan: ' + p);
                p.Budget_Changed_From_Transfer__c = true;
                update p;	
            }			
            insert auditLogs;
            
        }
        catch (Exception e) {
            System.debug(LoggingLevel.INFO,'Exception caught trying to automate Budget Transfer: ' + e.getMessage());
            
            //Rollback to the savepoint.
            Database.rollback(sp);
            
            transfer.addError(BI_Constants.TRANSFERREQUEST_UNKNOWN + e.getMessage());  			  			  			 	
        }
    }
    
    private static void updateBudgetAndCreateLog(Boolean doAddition, MarketingPlan__c affectedPlan, MarketingPlanAdjustments__c transfer, List<Audit_Log__c> auditLogs, List<MarketingPlan__c> updatePlans) {
        
        //Per business requirements, we do not need to handle multi-currency. There are Validation Rules
        //in place in SF to assure Sender/Receiver MPs have same Currency AND that the Transfer's Currency matches
        //the Sender/Receiver's Currency.
        //if (affectedPlan == null) {
        //	return;
        //}
        
        //Create a new MP record to make sure we only update the fields we care about.
        MarketingPlan__c updatePlan = new MarketingPlan__c();
        updatePlan.Id = affectedPlan.Id;
        if (doAddition == true) {
            updatePlan.Budget__c = affectedPlan.Budget__c + transfer.Amount__c;	
        } else {
            updatePlan.Budget__c = affectedPlan.Budget__c - transfer.Amount__c;
        }
        updatePlans.add(updatePlan);
        
        //Create the Audit Log.		
        Audit_Log__c theLog = createBudgetAuditLog(affectedPlan.Budget__c, updatePlan.Budget__c, transfer.ReasonforRequest__c, transfer.CurrencyIsoCode);
        theLog.Marketing_Plan_Transfer__c = transfer.Id;
        theLog.Related_Marketing_Plan__c = affectedPlan.Id;
        
        //Correctly show a positive/negative Transfer Amount.
        if (doAddition == true) {
            theLog.Amount_of_Adjustment__c = transfer.Amount__c;	
        } else {
            theLog.Amount_of_Adjustment__c = transfer.Amount__c * -1;
        }			
        auditLogs.add(theLog);						
    }
    
    public static Audit_Log__c createBudgetAuditLog(Decimal oldBudget, Decimal newBudget, String comments, String currencyIsoCode) {
        String theComments = 'No comment provided.';
        if (!String.IsBlank(comments)) {
            theComments = comments;	
        }
        //Create the Audit Log.		
        Audit_Log__c theLog = new Audit_Log__c();
        theLog.Old_Total_Value__c = oldBudget; //affectedPlan.Budget__c;
        theLog.New_Total_Value__c = newBudget; // updatePlan.Budget__c;
        theLog.CurrencyIsoCode = currencyIsoCode; // transfer.CurrencyIsoCode;
        theLog.Reason_for_Adjustment__c = comments; // transfer.ReasonforRequest__c;
        
        if (oldBudget != null && newBudget != null) {
            theLog.Amount_of_Adjustment__c = newBudget - oldBudget; 	
        } 
        
        return theLog;			
    }
    
    private static Boolean validateSenderHasEnoughFunds(MarketingPlanAdjustments__c transfer, MarketingPlan__c sender) {
        
        Boolean result = true;
        
        //Is the Sender Campaignable?
        Boolean isSenderCampaignable = isMPRecordTypeCampaignable(sender);
        
        if (isSenderCampaignable)	{
            result = sender.CampaignBalance__c >= transfer.Amount__c;
            if (!result) {
                transfer.addError(BI_Constants.TRANSFERREQUEST_CAMPAIGNSLUSH_TOOLOW);	
            }			
        } else {
            result = sender.UnallocatedBudget__c >= transfer.Amount__c;
            System.debug(LoggingLevel.INFO, 'Sender:'+sender.UnallocatedBudget__c);
            System.debug(LoggingLevel.INFO, 'Transfer:'+transfer.Amount__c);
            if (!result) {
                transfer.addError(BI_Constants.TRANSFERREQUEST_PLANSLUSH_TOOLOW);
            }			
        }
        return result;
    }
    
    private static MarketingPlan__c findCommonAncestor(List<MarketingPlan__c> senderLineage, List<MarketingPlan__c> receiverLineage) {
        
        for (Integer i = 0; i < senderLineage.size(); i++) {			
            for (Integer k = 0; k < receiverLineage.size(); k++) {
                if (senderLineage.get(i).Id == receiverLineage.get(k).Id) {
                    return senderLineage.get(i);
                }
            }
        }
        
        return null;	
    }
    
    private static Boolean isAncestor(MarketingPlan__c planA, List<MarketingPlan__c> planBLineage) {
        //Iterate from PlanB all the way to the Root. If PlanA exists in its lineage, A is an Ancestor of B.
        for (Integer i = 0; i < planBLineage.size(); i++) {
            if (planA.Id == planBLineage.get(i).Id) {
                return true;
            }				
        }
        return false;
    }
    
    private static Boolean isMPRecordTypeCampaignable(MarketingPlan__c plan) {
        List<String> recordTypeDevNames = new List<String> { BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED, BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS };
            
            //Get the Record Type ID for Campaignable MPs. There are two of them.
            Map<ID, String> campaignableTypes = BI_UtilityLogic.getRecordTypeIdsByDeveloperNames(
                BI_Constants.OBJECT_MARKETINGPLAN, 
                recordTypeDevNames);
        
        return campaignableTypes.containsKey(plan.RecordTypeId);	
    }
    
    private static List<MarketingPlan__c> getLineageToRoot(MarketingPlan__c startingPlan, Map<Id, MarketingPlan__c> allPlans) {
        System.debug(LoggingLevel.INFO,String.format('In getLineageToRoot. StartingPlanID: {0}, StartingPlanName: {1}', new list<String> {startingPlan.Id, startingPlan.Name}));
        List<MarketingPlan__c> lineage = new List<MarketingPlan__c>();		
        MarketingPlan__c tempPlan = startingPlan;		
        
        lineage.add(tempPlan);		
        while(tempPlan.ParentMarketingPlan__c != null) {
            tempPlan = allPlans.get(tempPlan.ParentMarketingPlan__c);
            if(tempPlan == null)
                break;
            lineage.add(tempPlan);
        }
        System.debug(LoggingLevel.INFO,'Lineage: ' + lineage);	
        return lineage;
    }
    
    private static Map<Id, MarketingPlan__c> retrievePlanHierarchy(MarketingPlanAdjustments__c transfer) {
        System.debug(LoggingLevel.INFO,'In retrievePlanHierarchy.');
        
        //Get the unique set of Years of which we are processing.
        String year = transfer.TransferringMPYearHidden__c;
        
        System.debug(LoggingLevel.INFO,'Year is: {0}' + year);		
        
        //Query for the entire MP Hierarchy(s) to avoid governor limits. Should be roughly ~1600 MPs per year so 
        //we don't need to worry about max rows returned.
        list<MarketingPlan__c> plansFound = 
            [SELECT Name, Id, RecordTypeId, ParentMarketingPlan__c, Year__c, Budget__c, AllocatedBudget__c, UnallocatedBudget__c, CampaignBudget__c, CampaignBalance__c 
             FROM MarketingPlan__c
             WHERE Year__c = :year];
        
        System.debug(LoggingLevel.INFO,'Number of plans found: ' + plansFound.size());	
        
        return new Map<Id, MarketingPlan__c>(plansFound);
    }
}