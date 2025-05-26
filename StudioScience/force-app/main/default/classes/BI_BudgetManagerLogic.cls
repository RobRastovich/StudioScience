public without sharing class BI_BudgetManagerLogic {
    
    /**
* @description      : Handles before insert logic for Marketing Plans, namely converting 'Budget__c' to USD
* @param triggerNew : List of newly inserted Marketing Plans
*/    
    public static void handleMarketingPlanBeforeInsert(List<MarketingPlan__c> triggerNew){
        //Always calculate the budget for all marketing plans before insert
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleMarketingPlanBeforeInsert');
        CurrencyConversionUtility.ConversionConfiguration cfg = 
            new CurrencyConversionUtility.ConversionConfiguration('Budget__c', 'Year__c', 'Budget_USD_Hidden__c', 'MarketingPlan__c');
        //CurrencyConversionUtility.ConversionConfiguration cfg2 = 
        //  new CurrencyConversionUtility.ConversionConfiguration('AllocatedBudget__c', 'Year__c', 'AllocatedBudget_USD_Hidden__c', 'MarketingPlan__c');
        CurrencyConversionUtility.convertCurrencyTrigger(cfg, triggerNew, true);
        //CurrencyConversionUtility.convertCurrencyTrigger(cfg2, triggerNew, true);
    }
    
    public static void handleMarketingPlanBeforeUpdate(Map<Id, MarketingPlan__c> triggerOldMap, 
                                                       Map<Id, MarketingPlan__c> triggerNewMap){
                                                           System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleMarketingPlanBeforeUpdate');
                                                           CurrencyConversionUtility.ConversionConfiguration cfg = 
                                                               new CurrencyConversionUtility.ConversionConfiguration('Budget__c', 'Year__c', 'Budget_USD_Hidden__c', 'MarketingPlan__c');
                                                           CurrencyConversionUtility.ConversionConfiguration cfg2 =
                                                               new CurrencyConversionUtility.ConversionConfiguration('CampaignBudgetHidden__c', 'Year__c', 'CampaignBudgetNativeHidden__c', 'MarketingPlan__c');
                                                           //CurrencyConversionUtility.ConversionConfiguration cfg3 = 
                                                           //  new CurrencyConversionUtility.ConversionConfiguration('AllocatedBudget__c', 'Year__c', 'AllocatedBudget_USD_Hidden__c', 'MarketingPlan__c');
                                                           List<MarketingPlan__c> changedBudgetMarketingPlans = new List<MarketingPlan__c>();
                                                           List<MarketingPlan__c> changedCampaignBudgetMarketingPlans = new List<MarketingPlan__c>();
                                                           //Compile list of applicable marketing plans where:
                                                           //The budget was changed in the update or
                                                           //The calculated budget was manually changed for some reason
                                                           for(Id mpId: triggerNewMap.keySet()){
                                                               if((triggerNewMap.get(mpId).Budget__c != triggerOldMap.get(mpId).Budget__c) ||
                                                                  (triggerNewMap.get(mpId).Budget_USD_Hidden__c != triggerOldMap.get(mpId).Budget_USD_Hidden__c) ||
                                                                  //(triggerNewMap.get(mpId).AllocatedBudget_USD_Hidden__c != triggerOldMap.get(mpId).AllocatedBudget_USD_Hidden__c) ||
                                                                  (triggerNewMap.get(mpId).CurrencyIsoCode != triggerOldMap.get(mpId).CurrencyIsoCode)){
                                                                      changedBudgetMarketingPlans.add(triggerNewMap.get(mpId));
                                                                  }
                                                               //If the Campaign Budget rollup changes, it must be recalculated
                                                               if(triggerNewMap.get(mpId).CampaignBudgetHidden__c != triggerOldMap.get(mpId).CampaignBudgetHidden__c){
                                                                   changedCampaignBudgetMarketingPlans.add(triggerNewMap.get(mpId));
                                                               }
                                                           }
                                                           //Only calculate applicable marketing plans
                                                           CurrencyConversionUtility.convertCurrencyTrigger(cfg, changedBudgetMarketingPlans, true);
                                                           CurrencyConversionUtility.convertCurrencyTrigger(cfg2, changedCampaignBudgetMarketingPlans, false);
                                                           //CurrencyConversionUtility.convertCurrencyTrigger(cfg3, changedBudgetMarketingPlans, true);
                                                       }
    
    public static void handleMarketingPlanAfterInsert(List<MarketingPlan__c> triggerNew) {        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleMarketingPlanAfterInsert');
        
        //Insert event - ALWAYS calculate AllocatedBudget for the inserted records' Parents.
        //Do Rollups
        rollupAllocatedBudget(triggerNew);      
    }
    
    public static void handleMarketingPlanAfterUpdate(List<MarketingPlan__c> triggerNew, 
                                                      Map<ID, MarketingPlan__c> triggerNewMap, 
                                                      List<MarketingPlan__c> triggerOld, 
                                                      Map<ID, MarketingPlan__c> triggerOldMap) {
                                                          
                                                          System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleMarketingPlanAfterUpdate');
                                                          
                                                          List<MarketingPlan__c> childrenToProcess = new List<MarketingPlan__c>();
                                                          List<Audit_Log__c> budgetAuditLogs = new List<Audit_Log__c>();
                                                          
                                                          for(ID planId : triggerNewMap.keySet() )
                                                          {
                                                              //Update event - CONDITIONALLY calculate AllocatedBudget for the updated records' Parents, ONLY IF Budget changed on a child.
                                                              if(triggerOldMap.get(planId).Budget__c != triggerNewMap.get(planId).Budget__c)
                                                              {
                                                                  System.debug(LoggingLevel.INFO,'Budget has changed on MarketingPlan: ' + planId);
                                                                  
                                                                  MarketingPlan__c oldPlan = triggerOldMap.get(planId);
                                                                  MarketingPlan__c newPlan = triggerNewMap.get(planId);               
                                                                  
                                                                  childrenToProcess.add(newPlan);
                                                                  
                                                                  //Logic for creating a Budget Audit Log.
                                                                  //Comments__c
                                                                  //Budget_Changed_From_Transfer__c
                                                                  System.debug(LoggingLevel.INFO,'Old Budget changed: ' + oldPlan.Budget_Changed_From_Transfer__c );
                                                                  System.debug(LoggingLevel.INFO,'New Budget changed: ' + newPlan.Budget_Changed_From_Transfer__c);
                                                                  if (!newPlan.Budget_Changed_From_Transfer__c) {
                                                                      
                                                                      //Create the Audit Log.     
                                                                      Audit_Log__c theLog = BI_BudgetTransferLogic.createBudgetAuditLog(oldPlan.Budget__c, newPlan.Budget__c, newPlan.Comments__c, newPlan.CurrencyIsoCode);
                                                                      theLog.Related_Marketing_Plan__c = planId;
                                                                      budgetAuditLogs.add(theLog);                    
                                                                  }
                                                              }   
                                                              
                                                              //Update event - CONDITIONALLY calculate AllocatedBudget for the OLD and NEW version of the updated records' Parents, ONLY IF ParentMarketingPlan__c changed on a child.
                                                              if(triggerOldMap.get(planId).ParentMarketingPlan__c != triggerNewMap.get(planId).ParentMarketingPlan__c)
                                                              {
                                                                  System.debug(LoggingLevel.INFO,'ParentMarketingPlan has changed on MarketingPlan: ' + planId);
                                                                  childrenToProcess.add(triggerOldMap.get(planId));
                                                                  childrenToProcess.add(triggerNewMap.get(planId));
                                                              }       
                                                          }
                                                          
                                                          if (!childrenToProcess.isEmpty()) {         
                                                              //Do Rollups
                                                              rollupAllocatedBudget(childrenToProcess);           
                                                          }        
                                                          
                                                          if(!budgetAuditLogs.isEmpty()) {
                                                              insert budgetAuditLogs;
                                                          }
                                                      }
    
    public static void handleMarketingPlanAfterDelete(List<MarketingPlan__c> triggerOld) {        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleMarketingPlanAfterDelete');              
        //Delete event - ALWAYS calculate AllocatedBudget for the deleted records' Parents, but using Trigger.old     
        //Do Rollups
        rollupAllocatedBudget(triggerOld);     
    }
    
    public static void handleMarketingPlanAfterUndelete(List<MarketingPlan__c> triggerNew) {        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleMarketingPlanAfterUndelete');        
        //Undelete event - ALWAYS calculate AllocatedBudget for the undeleted records' Parents. Same as insert.
        //Do Rollups
        rollupAllocatedBudget(triggerNew);                  
    }
    
    public static void handleCampaignAfterInsert(List<Campaign__c> triggerNew) {        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleCampaignAfterInsert');
        Map<ID,Schema.RecordTypeInfo> rt_Map = Campaign__c.sObjectType.getDescribe().getRecordTypeInfosById();
        Set<ID> masterCampaignIDSet = new Set<ID>();
        Map<ID,ID> childToParentIDMap = new Map<ID,ID>();
        
        for(Campaign__c camp:triggerNew){
            masterCampaignIDSet.add(camp.Child_Campaign__c);
            childToParentIDMap.put(camp.ID, camp.Child_Campaign__c);
        }
        
        Map<ID, Campaign__c> masterCampaignMap=new Map<ID, Campaign__c>([Select id,Has_Child_Campaigns__c, Child_Campaign__c from Campaign__c where id IN :masterCampaignIDSet]);
        Map<ID, Campaign__c> ChildIDtoMasterCampaignMap = new Map<ID, Campaign__c>();
        
        for(Campaign__c c:triggerNew)
        {
            ChildIDtoMasterCampaignMap.put(c.Id, masterCampaignMap.get(childToParentIDMap.get(c.Id)));
        }
        
        list<Campaign__c> createForecastRecords = new list<Campaign__c>();
        List<Campaign__c> MasterCampaignstoUpdate = new List<Campaign__c>();
        for(Campaign__c c:triggerNew)
        {     
            System.debug('++++++RecordType.Name+++++++'+rt_map.get(c.recordTypeID).getName());
            if(rt_map.get(c.recordTypeID).getName().containsIgnoreCase(BI_Constants.RECORDTYPE_CAMPAIGN_CHILD))
            {
                Campaign__c master=ChildIDtoMasterCampaignMap.get(c.Id);
                //create map for master and child campaigns
                System.debug('Before update++++++'+master);
                if(master!=null && master.Has_Child_Campaigns__c!=True)
                {
                    master.Has_Child_Campaigns__c=true;
                    MasterCampaignstoUpdate.add(master);
                    System.debug('After update++++++'+master);   
                }
            }
            else{
                createForecastRecords.add(c);
            }
        }
        
        Update MasterCampaignstoUpdate;
        
        //Auto-create Forecast records based on Start/End Date
        insertCampaignForecasts(createForecastRecords);
    }
    
    public static void handleCampaignAfterUpdate(List<Campaign__c> triggerNew, 
                                                 Map<ID, Campaign__c> triggerNewMap, 
                                                 List<Campaign__c> triggerOld, 
                                                 Map<ID, Campaign__c> triggerOldMap) { 
                                                     
                                                     System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleCampaignAfterUpdate');
                                                     List<Audit_Log__c> budgetAuditLogs = new List<Audit_Log__c>();
                                                     //Set to hold campaignIds that need to be updated
                                                     Set<Id> campaignIdsForForecastEvaluation = new Set<Id>();
                                                     //List to hold campaign records needed for forecast evaluation
                                                     List<Campaign__c> campaignRecordsForForecastEvaluation = new List<Campaign__c>();
                                                     //If Campaign Budget changed, create an Audit record.
                                                     for(ID campaignId : triggerNewMap.keySet())
                                                     {
                                                         //Update event - if Budget changed on Campaign
                                                         if(triggerOldMap.get(campaignId).PlannedCampaignSpend__c != triggerNewMap.get(campaignId).PlannedCampaignSpend__c)
                                                         {
                                                             System.debug(LoggingLevel.INFO,'Budget has changed on Campaign: ' + campaignId);
                                                             
                                                             Campaign__c oldCampaign = triggerOldMap.get(campaignId);
                                                             Campaign__c newCampaign = triggerNewMap.get(campaignId);
                                                             
                                                             //Create the Audit Log.
                                                             Audit_Log__c theLog = BI_BudgetTransferLogic.createBudgetAuditLog(oldCampaign.PlannedCampaignSpend__c, newCampaign.PlannedCampaignSpend__c, newCampaign.Comments__c, newCampaign.CurrencyIsoCode);
                                                             theLog.Related_Campaign_Record__c = campaignId;
                                                             budgetAuditLogs.add(theLog);
                                                         }
                                                         //If the Campaign__c.PlannedCampaignSpend__c changes to 0 then add the Campaign__c Id to the campaignIdsForForecastEvaluation Set
                                                         if(triggerOldMap.get(campaignId).PlannedCampaignSpend__c != 0 && triggerNewMap.get(campaignId).PlannedCampaignSpend__c == 0){
                                                             campaignIdsForForecastEvaluation.add(campaignId);
                                                             campaignRecordsForForecastEvaluation.add(triggerNewMap.get(campaignId));
                                                         }
                                                     }
                                                     if(!budgetAuditLogs.isEmpty()) {
                                                         insert budgetAuditLogs;
                                                     }
                                                     //If campaignIdsForForecastEvaluation is not empty then call the evaluateForecastRecordsAfterCampaignUpdate() method to zero out the related Campaign_Spend__c records
                                                     if(!campaignIdsForForecastEvaluation.isEmpty() && !campaignRecordsForForecastEvaluation.isEmpty()){
                                                         evaluateForecastRecordsAfterCampaignUpdate(campaignIdsForForecastEvaluation, campaignRecordsForForecastEvaluation);
                                                     }
                                                 }
    
    public static void handleCampaignAfterDelete(List <Campaign__c> triggerOld){
        String childCampaignRTName =BI_Constants.RECORDTYPE_CAMPAIGN_CHILD;
        Id childCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(childCampaignRTName).getRecordTypeId();
        Set<ID> masterCampaignIDSet = new Set<ID>();
        Map<ID,ID> childToParentIDMap = new Map<ID,ID>();
        
        for(Campaign__c camp:triggerOld){
            masterCampaignIDSet.add(camp.Child_Campaign__c);
            childToParentIDMap.put(camp.ID, camp.Child_Campaign__c);
        }
        
        Map<ID, Campaign__c> masterCampaignMap=new Map<ID, Campaign__c>([Select id, Has_Child_Campaigns__c, Child_Campaign__c from Campaign__c where id IN :masterCampaignIDSet]);
        Map<ID, Campaign__c> ChildIDtoMasterCampaignMap = new Map<ID, Campaign__c>();
        Map<ID, list<Campaign__c>> ParentIDtoChildCampaignsMap = new Map<ID, list<Campaign__c>>();
        list<Campaign__c> allChildCampaignsList = [Select id, Has_Child_Campaigns__c, Child_Campaign__c from Campaign__c where (Child_Campaign__c!=null AND Child_Campaign__c IN:masterCampaignIDSet) ];
        
        //Create a map with child campaign Id as key to Parent Campaign as value
        for(Campaign__c c:triggerOld){
            ChildIDtoMasterCampaignMap.put(c.Id, masterCampaignMap.get(childToParentIDMap.get(c.Id)));
        }
        
        //Create a map with Parent ID as key to Child Campaigns list as value
        for(Campaign__c c:allChildCampaignsList){
            if(ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c)==null)
                ParentIDtoChildCampaignsMap.put(c.Child_Campaign__c, new list<Campaign__c>{c});
            else
                ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c).add(c);
        }
        
        list<Campaign__c> masterCampaignstoUpdate = new list<Campaign__c>(); 
        for(Campaign__c c:triggerOld)
        {
            //Set the field Has_child_campaigns for a parent campaign to false if all the child campaigns have been deleted
            if(c.recordTypeID == childCampaignRecordTypeId)
            { 
                List<Campaign__c> childList= ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c);
                Campaign__c master = ChildIDtoMasterCampaignMap.get(c.Id);
                System.debug('Before update++++++'+master);
                
                if(!ParentIDtoChildCampaignsMap.containsKey(c.Child_Campaign__c))
                {
                    master.Has_Child_Campaigns__c=false;
                    masterCampaignstoUpdate.add(master);
                    System.debug('After update++++++'+master);
                }
            }
        }
        Update masterCampaignstoUpdate;
        
    }
    
    
    public static void handleCampaignBeforeInsert(List<Campaign__c> triggerNew) {        
        List<Campaign__c> notChildCampaigns = new List<Campaign__c>();
        String childCampaignRTName =BI_Constants.RECORDTYPE_CAMPAIGN_CHILD;
        Id childCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(childCampaignRTName).getRecordTypeId();
        
        /*Set<ID> masterCampaignIDSet = new Set<ID>();
Map<ID,ID> childToParentIDMap = new Map<ID,ID>();

for(Campaign__c camp:triggerNew){
masterCampaignIDSet.add(camp.Child_Campaign__c);
childToParentIDMap.put(camp.ID, camp.Child_Campaign__c);
}

Map<ID, Campaign__c> masterCampaignMap=new Map<ID, Campaign__c>([Select id, PlannedCampaignSpend__c, Child_Campaign__c from Campaign__c where id IN :masterCampaignIDSet]);
Map<ID, Campaign__c> ChildIDtoMasterCampaignMap = new Map<ID, Campaign__c>();
Map<ID, list<Campaign__c>> ParentIDtoChildCampaignsMap = new Map<ID, list<Campaign__c>>();
list<Campaign__c> allChildCampaignsList = [Select id, PlannedCampaignSpend__c, Child_Campaign__c from Campaign__c where (Child_Campaign__c != null AND Child_Campaign__c IN :masterCampaignIDSet)];

//Create a map with child campaign Id as key to Parent Campaign as value
for(Campaign__c c:triggerNew){
ChildIDtoMasterCampaignMap.put(c.Id, masterCampaignMap.get(childToParentIDMap.get(c.Id)));
}

//Create a map with Parent ID as key to Child Campaigns list as value
for(Campaign__c c:allChildCampaignsList){
if(ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c)==null)
ParentIDtoChildCampaignsMap.put(c.Child_Campaign__c, new list<Campaign__c>{c});
else
ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c).add(c);
}*/
        
        for(Campaign__c c:triggerNew)
        {
            //Decimal totalchild=0.0;
            System.debug('++++++c.Child_Campaign__c++++++'+c.Child_Campaign__c);   
            if(childCampaignRecordTypeId == c.recordTypeID)
            {
                /*//To check that the sum of child Campaigns budget does not exceed parent campaign budget
Campaign__c masterCampaign = ChildIDtoMasterCampaignMap.get(c.Id);
System.debug('++++++mastercampbudget++++++'+masterCampaign);   
List<Campaign__c> childCampaigns = ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c);
System.debug('++++++childcampaigns++++++'+childcampaigns);
if(childCampaigns!=null && !childCampaigns.isEmpty())
for(Campaign__c d:childCampaigns){
totalchild+=d.PlannedCampaignSpend__c;
} 

totalchild+=c.PlannedCampaignSpend__c;    

System.debug('++++++++totalchild++++++++'+totalchild);
if(totalchild>masterCampaign.PlannedCampaignSpend__c)
c.PlannedCampaignSpend__c.adderror('You cannot exceed the total campaign budget');
*/
                
                //Copy the value of Participating state to MultiSelect picklist for reporting purpose
                if(c.ParticipatingState__c != null)
                    c.ParticipatingStates__c = c.ParticipatingState__c;
            }
            else
            {
                notChildCampaigns.add(c);
                //Copying Participating State value from Multiselect picklist for Parent Campaign
                if(c.ParticipatingStates__c != null){
                    List<String> casePartcipatingStates = (c.ParticipatingStates__c).split(';');
                    if(casePartcipatingStates.size()>0)
                        c.ParticipatingState__c = casePartcipatingStates[0];
                }
                // Below lines added by Sripal 07/10/2020 for updating the Single picklist field on Parent record if Multipicklist value is null
                else{
                    c.ParticipatingState__c = '';
                }
            }
        }
        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleCampaignBeforeInsert');
        //Pre-populate picklist "Campaign Brand" based on Campaign's parent MP's "Brand" Tag lookup
        prePopulateCampaignFields(triggerNew);

        CampaignServices.updateContactAndTouchpoint(triggerNew, null);
        
        CurrencyConversionUtility.ConversionConfiguration cfg = 
            new CurrencyConversionUtility.ConversionConfiguration('PlannedCampaignSpend__c', 'Year__c', 'PlannedCampaignSpend_USD_Hidden__c', 'Campaign__c');
        CurrencyConversionUtility.convertCurrencyTrigger(cfg, notChildCampaigns, true);
    }
    
    public static void handleCampaignBeforeUpdate(Map<Id, Campaign__c> triggerOldMap, Map<Id, Campaign__c> triggerNewMap){
        
        
        //Add Child Campaign record type name in BI_Constants utility class
        String childCampaignRTName = BI_Constants.RECORDTYPE_CAMPAIGN_CHILD;
        Id childCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(childCampaignRTName).getRecordTypeId();
        
        /*
List<Campaign__c> notChildCampaigns = new List<Campaign__c>();
Set<ID> masterCampaignIDSet = new Set<ID>();
Map<ID,ID> childToParentIDMap = new Map<ID,ID>();

for(Campaign__c camp:triggerNewMap.values()){
masterCampaignIDSet.add(camp.Child_Campaign__c);
childToParentIDMap.put(camp.ID, camp.Child_Campaign__c);
}

Map<ID, Campaign__c> masterCampaignMap = new Map<ID, Campaign__c>([Select id, PlannedCampaignSpend__c, Child_Campaign__c from Campaign__c where id IN :masterCampaignIDSet]);
Map<ID, Campaign__c> ChildIDtoMasterCampaignMap = new Map<ID, Campaign__c>();
Map<ID, list<Campaign__c>> ParentIDtoChildCampaignsMap = new Map<ID, list<Campaign__c>>();
list<Campaign__c> allChildCampaignsList = [Select id, PlannedCampaignSpend__c, Child_Campaign__c from Campaign__c where (Child_Campaign__c != null AND Child_Campaign__c IN :masterCampaignIDSet)];

//Create a map with child campaign Id as key to Parent Campaign as value       
for(Campaign__c c:triggerNewMap.values()){
ChildIDtoMasterCampaignMap.put(c.Id, masterCampaignMap.get(childToParentIDMap.get(c.Id)));
}

//Create a map with Parent ID as key to Child Campaigns list as value
for(Campaign__c c:allChildCampaignsList){
if(ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c)==null)
ParentIDtoChildCampaignsMap.put(c.Child_Campaign__c, new list<Campaign__c>{c});
else
ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c).add(c);
}
*/
        
        for(Campaign__c c:triggerNewMap.values())
        {
            //Decimal totalchild=0.0;
            System.debug('++++++c.Child_Campaign__c++++++'+c.Child_Campaign__c);   
            if(c.Child_Campaign__c!=null)
            {
                /*
Campaign__c masterCampaign = ChildIDtoMasterCampaignMap.get(c.Id);
System.debug('++++++mastercampbudget++++++'+masterCampaign);   
List<Campaign__c> childcampaigns = ParentIDtoChildCampaignsMap.get(c.Child_Campaign__c);
System.debug('++++++childcampaigns++++++'+childcampaigns);   
if(childCampaigns!=null && !childCampaigns.isEmpty())
for(Campaign__c d:childcampaigns){
If(d.ID!=c.ID)
totalchild+=d.PlannedCampaignSpend__c;
}    

totalchild+=c.PlannedCampaignSpend__c;    

System.debug('++++++++totalchild++++++++'+totalchild);
if(totalchild > masterCampaign.PlannedCampaignSpend__c)
c.PlannedCampaignSpend__c.adderror('You cannot exceed the total campaign budget');
//Copying the participating state value to multiselect picklist of Child Campaign for reporting purposes
*/
                if(c.ParticipatingState__c != triggerOldMap.get(c.ID).ParticipatingState__c)
                {
                    c.ParticipatingStates__c= c.ParticipatingState__c;
                }
            }
            //Copying the First value of Multiselect picklist value to the participating state for Parent campaign
            if(c.RecordTypeId != childCampaignRecordTypeId && c.ParticipatingStates__c != null){ 
                if(c.ParticipatingStates__c != null)
                {
                    List<String> casePartcipatingStates = (c.ParticipatingStates__c).split(';');
                    if(casePartcipatingStates.size()>0)
                        c.ParticipatingState__c = casePartcipatingStates[0];
                }
            }
            
            // Below lines added by Sripal 07/10/2020 for updating the Single picklist field on Parent record if Multipicklist value is null 
            if(c.RecordTypeId != childCampaignRecordTypeId && c.ParticipatingStates__c==null){
                 c.ParticipatingState__c = '';
            }
            
            
        }
        
        CurrencyConversionUtility.ConversionConfiguration cfg = 
            new CurrencyConversionUtility.ConversionConfiguration('PlannedCampaignSpend__c', 'Year__c', 'PlannedCampaignSpend_USD_Hidden__c', 'Campaign__c');
        List<Campaign__c> changedCampaigns = new List<Campaign__c>();
        //Compile list of applicable campaigns where:
        //The budget was changed in the update or
        //The calculated budget was manually changed for some reason
        for(Id cId: triggerNewMap.keySet()){
            if(((triggerNewMap.get(cId).PlannedCampaignSpend__c != triggerOldMap.get(cId).PlannedCampaignSpend__c) ||
                (triggerNewMap.get(cId).PlannedCampaignSpend_USD_Hidden__c != triggerOldMap.get(cId).PlannedCampaignSpend_USD_Hidden__c) ||
                (triggerNewMap.get(cId).CurrencyIsoCode != triggerOldMap.get(cId).CurrencyIsoCode)) &&
               (triggerNewMap.get(cId).recordTypeID != childCampaignRecordTypeId)){
                   changedCampaigns.add(triggerNewMap.get(cId));
               }
        }
        //Only calculate applicable marketing plans
        CurrencyConversionUtility.convertCurrencyTrigger(cfg, changedCampaigns, true);
        
        //Commenting this code on 12/12/2018 as part of the  [BCR-7] Changing trigger to prevent WBS creation on budget change
        /*List<Campaign__c> australiaCampaigns = CampaignServices.getAUSCampaigns(triggerNewMap.values());
if(!australiaCampaigns.isEmpty())
{
CampaignServices.checkForWBSUpdates(australiaCampaigns, triggerOldMap);
}
*/
        CampaignServices.populateProgramAndPlatforms(triggerNewMap.values());
        CampaignServices.updateContactAndTouchpoint(triggerNewMap.values(), triggerOldMap);
    }
    
    public static void handleCampaignSpendBeforeInsert(List<Campaign_Spend__c> triggerNew) {        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleCampaignSpendBeforeInsert');
        CurrencyConversionUtility.ConversionConfiguration cfg = 
            new CurrencyConversionUtility.ConversionConfiguration('Amount__c', 'Posting_Date__c', 'Amount_USD__c', 'Campaign_Spend__c');
        CurrencyConversionUtility.ConversionConfiguration cfg2 = 
            new CurrencyConversionUtility.ConversionConfiguration('Amount__c', 'Forecast_Month_Date__c', 'Amount_USD__c', 'Campaign_Spend__c');
        List<Campaign_Spend__c> nonForecastCampaignSpends = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> forecastCampaignSpends = new List<Campaign_Spend__c>();
        for(Campaign_Spend__c cs: triggerNew){
            if(cs.RecordTypeId == Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST).getRecordTypeId()){
                forecastCampaignSpends.add(cs);
            } else if(cs.RecordTypeId != Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Campaign_Planning_Forecasting).getRecordTypeId()){
                nonForecastCampaignSpends.add(cs);
            }
        }
        CurrencyConversionUtility.convertCurrencyTrigger(cfg, nonForecastCampaignSpends, true);
        CurrencyConversionUtility.convertCurrencyTrigger(cfg2, forecastCampaignSpends, true);        
    }
    
    public static void handleCampaignSpendBeforeUpdate(Map<Id, Campaign_Spend__c> triggerOldMap, Map<Id, Campaign_Spend__c> triggerNewMap) {        
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.handleCampaignSpendBeforeUpdate');
        CurrencyConversionUtility.ConversionConfiguration cfg = 
            new CurrencyConversionUtility.ConversionConfiguration('Amount__c', 'Posting_Date__c', 'Amount_USD__c', 'Campaign_Spend__c');
        CurrencyConversionUtility.ConversionConfiguration cfg2 = 
            new CurrencyConversionUtility.ConversionConfiguration('Amount__c', 'Forecast_Month_Date__c', 'Amount_USD__c', 'Campaign_Spend__c');
        List<Campaign_Spend__c> nonForecastCampaignSpends = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> forecastCampaignSpends = new List<Campaign_Spend__c>();
        //Compile list of applicable campaign spends where:
        //The amount was changed in the update or
        //The calculated amount was manually changed for some reason
        for(Id csId: triggerNewMap.keySet()){
            if((triggerNewMap.get(csId).Amount__c != triggerOldMap.get(csId).Amount__c) ||
               (triggerNewMap.get(csId).Amount_USD__c != triggerOldMap.get(csId).Amount_USD__c) ||
               (triggerNewMap.get(csId).CurrencyIsoCode != triggerOldMap.get(csId).CurrencyIsoCode)){
                   if(triggerNewMap.get(csId).RecordTypeId == Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST).getRecordTypeId() || triggerNewMap.get(csId).RecordTypeId == '0124B0000000Xv0' || triggerNewMap.get(csId).RecordTypeId == '0124B0000000XzM'){
                       forecastCampaignSpends.add(triggerNewMap.get(csId));
                   } else  if(triggerNewMap.get(csId).RecordTypeId != Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Campaign_Planning_Forecasting).getRecordTypeId()){
                       nonForecastCampaignSpends.add(triggerNewMap.get(csId));
                   }
               }
        }
        //Only calculate applicable marketing plans
        CurrencyConversionUtility.convertCurrencyTrigger(cfg, nonForecastCampaignSpends, true);
        CurrencyConversionUtility.convertCurrencyTrigger(cfg2, forecastCampaignSpends, true);
    }
    
    private static void rollupAllocatedBudget(List<MarketingPlan__c> records) {
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.rollupAllocatedBudget');
        
        try {
            //Should we put a TryCatch around this?     
            if (records != null && !records.isEmpty()) {
                
                list<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition> {
                    new RollUpSummaryUtility.fieldDefinition('SUM', 'Budget_USD_Hidden__c', 'AllocatedBudget__c')
                        };
                            
                            RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, records, 
                                                               'MarketingPlan__c', 'ParentMarketingPlan__c', 'MarketingPlan__c', '', 'Year__c');    
            }
        }
        catch (Exception e) {
            for (MarketingPlan__c plan : records) {
                plan.addError(BI_Constants.PLAN_ALLOCATEDBUDGET_VIOLATION); 
            }       
        }                   
    }
    
    private static String getMonthString(Date theDate) {
        if (theDate.month() == 1) {
            return 'Jan';
        } else if (theDate.month() == 2) {
            return 'Feb';
        } else if (theDate.month() == 3) {
            return 'Mar';
        } else if (theDate.month() == 4) {
            return 'Apr';
        } else if (theDate.month() == 5) {
            return 'May';
        } else if (theDate.month() == 6) {
            return 'Jun';
        } else if (theDate.month() == 7) {
            return 'Jul';
        } else if (theDate.month() == 8) {
            return 'Aug';
        } else if (theDate.month() == 9) {
            return 'Sep';
        } else if (theDate.month() == 10) {
            return 'Oct';
        } else if (theDate.month() == 11) {
            return 'Nov';
        } else if (theDate.month() == 12) {
            return 'Dec';
        } else {
            return null;
        }
    }
    
    /***
* insertCampaignForecasts - When a Campaign is inserted, 12 Campaign_Spend__c records are created related to that Campaign__c record.  The PlannedCampaignSpend__c
amount is divided between the Campaign_Spend__c months that are in the Start and End Date range of the campaign.
***/
    public static void insertCampaignForecasts(List<Campaign__c> campaigns) {
        try{
            //List to hold all the Forecasts that will be inserted.
            List<Campaign_Spend__c> newForecasts = new List<Campaign_Spend__c>();
            
            //Get the Record Type ID for Forecasts
            ID forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
                                                                      BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
            
            //Iterate through each campaign, calculate number of Forecast records for each.
            for (Campaign__c campaign : campaigns) {
                if (campaign.InitialStartDate__c != null && campaign.InitialEndDate__c != null && campaign.PlannedCampaignSpend__c != null) {
                    Date startDate = campaign.InitialStartDate__c.toStartOfMonth();
                    Date endDate = campaign.InitialEndDate__c.toStartOfMonth();
                    //Determine how many months
                    Integer countMonths = startDate.monthsBetween(endDate) + 1;
                    if (countMonths <= 0) { countMonths = 1; }
                    
                    //Build Map of months contained in the Start Date and End Date range of the campaign
                    Map<Integer, Date> campaignMonths = new Map<Integer, Date>();
                    for (Date dt = startDate; dt <= endDate; dt = dt.addMonths(1)) {
                        campaignMonths.put(dt.Month(), dt);
                    }
                    
                    //Divide campaign by months, rounding down to 2 decimals. Remember the remainder.
                    Decimal dividedAmount = campaign.PlannedCampaignSpend__c.divide(countMonths, 2, System.RoundingMode.DOWN);
                    Decimal remainderForLastRecord = campaign.PlannedCampaignSpend__c - (countMonths * dividedAmount);
                    
                    //Iterate through every month in a calendar year in order to split out the budget by months inside of the
                    //Start Date and End Date range for the campaign.  Also create placeholder Campaign_Spend__c records for months 
                    //not in that range.
                    for(Integer month = 1; month <= BI_Constants.TOTAL_MONTHS_IN_YEAR; month++){
                        Campaign_Spend__c forecast = new Campaign_Spend__c();
                        //Check if the month value exists in the Start Date and End Date range of the campaign
                        if(campaignMonths.containsKey(month)){
                            forecast.RecordTypeId = forecastRecordTypeId;
                            forecast.Forecast_Month__c = getMonthString(campaignMonths.get(month));
                            forecast.CurrencyIsoCode = campaign.CurrencyIsoCode;
                            
                            //If this is the last forecasted month, add the remainder to the amount.
                            if (campaignMonths.get(month).addMonths(1) > endDate) {
                                forecast.Amount__c = dividedAmount + remainderForLastRecord;
                            } else {
                                forecast.Amount__c = dividedAmount;
                            }
                            
                            forecast.ParentCampaign__c = campaign.Id;
                        } else {
                            //Create Placeholder Date to hold month for the placeholder Campaign_Spend__c record
                            Date placeholderDate = Date.newInstance(Integer.valueOf(campaign.Year__c), month, 1);
                            
                            //Set up Campaign_Spend__c record for months not in the Start Date and End Date range of the campagin
                            forecast.RecordTypeId = forecastRecordTypeId;
                            forecast.Forecast_Month__c = getMonthString(placeholderDate);
                            forecast.CurrencyIsoCode = campaign.CurrencyIsoCode;
                            forecast.Amount__c = 0;
                            forecast.ParentCampaign__c = campaign.Id;
                        }
                        newForecasts.add(forecast);
                    }
                }
            }
            if (!newForecasts.isEmpty()) {
                insert newForecasts;
            }
        } catch(Exception ex){
            CreateExceptionLog.insertErrorLog('BI_BudgetManagerLogic', 'insertCampaignForecasts', String.valueOf(ex), 'Error');
        }
    }
    
    public static void prePopulateCampaignFields(List<Campaign__c> triggerNewCampaigns) {
        System.debug(LoggingLevel.INFO,'Entered BI_BudgetManagerLogic.prePopulateCampaignFields');
        
        Map<ID,Schema.RecordTypeInfo> rt_Map = Campaign__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        //Unique set of parent MarketingPlan IDs
        Set<ID> parentPlanIds = new Set<ID>();
        //Map from MP ID to "CampaignBrand" picklist value
        Map<ID,String> campaignBrandValues = new Map<ID,String>();
        
        //Iterate each campaign, add MP to set
        for (Campaign__c campaign : triggerNewCampaigns) {
            System.debug(LoggingLevel.INFO,'inside: Iterate each campaign for:::');
            if (campaign.ParentMarketingPlan__c != null  ) {
                System.debug(LoggingLevel.INFO,'inside: Iterate each campaign if:::::'); 
                parentPlanIds.add(campaign.ParentMarketingPlan__c);
            }
        }
        System.debug(LoggingLevel.INFO,'Parent MP Ids: ' + parentPlanIds);
        
        //Query MPs and retrieve the "campaign brand" lookup
        List<MarketingPlan__c> plans = [Select Id, Name, Brand__c, Brand__r.CampaignBrand__c 
                                        FROM MarketingPlan__c
                                        WHERE Id IN :parentPlanIds];
        
        //Map Plan ID to CampaignBrand__c value
        for (MarketingPlan__c p : plans) {
            if (p.Brand__r != null && p.Brand__r.CampaignBrand__c != null) {
                campaignBrandValues.put(p.Id, p.Brand__r.CampaignBrand__c);
            }
        }
        System.debug(LoggingLevel.INFO,'Parent Plan Id to CampaignBrand mappings: ' + campaignBrandvalues);
        
        //Update all the Campaigns with the correct value.
        //NOTE: Assume that this method is called from BEFORE INSERT trigger and the
        // CampaignBrand__c value will pass-through to the platform save.
        for (Campaign__c c : triggerNewCampaigns) {
            String mappedValue = campaignBrandValues.get(c.ParentMarketingPlan__c);
            System.debug(LoggingLevel.INFO,'Mapped Value for ' + c.ParentMarketingPlan__c + ' is ' + mappedValue);
            if (mappedValue != null) {
                c.CampaignBrand__c = mappedValue;
            }
        }
    }
    
    /***
* evaluateForecastRecordsAfterCampaignUpdate - When the Campaign PlannedCampaignSpend__c field is set to 0 then update the
related Campaign_Spend__c records to 0
***/
    public static void evaluateForecastRecordsAfterCampaignUpdate(Set<Id> campaignIds, List<Campaign__c> campaignList) {
        try{
            //Get the Record Type ID for Forecasts
            Id forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
                                                                      BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
            //Query for related Campaign_Spend__c records
            List<Campaign_Spend__c> forecastRecordsForCampaigns = [SELECT Id, Amount__c, ParentCampaign__c FROM Campaign_Spend__c WHERE ParentCampaign__c IN :campaignIds AND RecordTypeId = :forecastRecordTypeId];
            Map<Id, List<Campaign_Spend__c>> forecastMap = new Map<Id, List<Campaign_Spend__c>>();
            //build map of Campaign__c to List<Campaign_Spend__c> for evaluation
            for(Campaign_Spend__c forecast : forecastRecordsForCampaigns){
                List<Campaign_Spend__c> forecastList = new List<Campaign_Spend__c>();
                if(forecastMap.containsKey(forecast.ParentCampaign__c)){
                    forecastList = forecastMap.get(forecast.ParentCampaign__c);
                }
                forecastList.add(forecast);
                forecastMap.put(forecast.ParentCampaign__c, forecastList);
            }
            List<Campaign_Spend__c> forecastRecordsToUpdate = new List<Campaign_Spend__c>();
            //Iterate through List of Campaign__c records
            for (Campaign__c campaign : campaignList) {
                //get list of Campaign_Spend__c records for the campaign Id
                for (Campaign_Spend__c forecast : forecastMap.get(campaign.Id)) {
                    //set forecast amount to 0
                    forecast.Amount__c = 0;
                    forecastRecordsToUpdate.add(forecast);
                }
            }
            //update Campaign_Spend__c records
            if(!forecastRecordsToUpdate.isEmpty()){
                update forecastRecordsToUpdate;
            }
        } catch(Exception ex){
            CreateExceptionLog.insertErrorLog('BI_BudgetManagerLogic', 'evaluateForecastRecordsAfterCampaignUpdate', String.valueOf(ex), 'Error');
        }
    }
    
    /***
* insertCampaignPlanningMonthlyRecords - When a CampaignPlanning record is inserted, 12 Campaign Planning Monthly records 
are created with the default amount as 0.0
***/                
    
    public static void insertCampaignPlanningMonthlyRecords(List<Campaign_Spend__c> campaignSpends) {
        System.debug('Inside insertCampaignPlanningMonthlyRecords:::');
        
        List<Campaign_Spend__c> newCampaignPlanninMonthlyRecordsList = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> newCampaignPlanningRecordsList = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> campaignPlanningRecords = new List<Campaign_Spend__c>();
        
        ID monthlyPlanAUSRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
                                                                        BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Monthly_Plan_AUS);
        ID campaignPlanningANDForecastingRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Campaign_Planning_Forecasting).getRecordTypeId();
        Set<ID> parentCampaignIds = new Set<ID>();
        Set<ID> campaignPlanningIds = new Set<ID>();
        
        for(Campaign_Spend__c cs: campaignSpends){
            if(cs.RecordTypeId == campaignPlanningANDForecastingRecordTypeId 
               && cs.ParentCampaign__c!=null){
                   parentCampaignIds.add(cs.ParentCampaign__c);
                   campaignPlanningIds.add(cs.Id);
               }
        }
        
        Map<Id, Campaign__c> campaignMap = new Map<Id, Campaign__c>([select id, Name, CurrencyIsoCode, InitialStartDate__c, InitialEndDate__c, PlannedCampaignSpend__c, Year__c, Country__c from Campaign__c where id IN: parentCampaignIds AND Country__c='AUS']);       
        
        //List<Campaign__c> campaigns = [select id, Name, CurrencyIsoCode, InitialStartDate__c, InitialEndDate__c, PlannedCampaignSpend__c, Year__c, Country__c from Campaign__c where id IN: parentCampaignIds AND Country__c='AUS'];
        for(Campaign__c campaign:campaignMap.values()){
            if (campaign.InitialStartDate__c != null && campaign.InitialEndDate__c != null && campaign.PlannedCampaignSpend__c != null) {
                Date startDate = campaign.InitialStartDate__c.toStartOfMonth();
                Date endDate = campaign.InitialEndDate__c.toStartOfMonth();
                //Determine how many months
                Integer countMonths = startDate.monthsBetween(endDate) + 1;
                if (countMonths <= 0) { countMonths = 1; }
                
                //Build Map of months contained in the Start Date and End Date range of the campaign
                Map<Integer, Date> campaignMonths = new Map<Integer, Date>();
                for (Date dt = startDate; dt <= endDate; dt = dt.addMonths(1)) {
                    campaignMonths.put(dt.Month(), dt);
                }
                
                for(Integer month = 1; month <= BI_Constants.TOTAL_MONTHS_IN_YEAR; month++){
                    Campaign_Spend__c monthlyAUSCampaignPlanning = new Campaign_Spend__c();
                    //Check if the month value exists in the Start Date and End Date range of the campaign
                    if(campaignMonths.containsKey(month)){
                        monthlyAUSCampaignPlanning.RecordTypeId = monthlyPlanAUSRecordTypeId;
                        monthlyAUSCampaignPlanning.Planning_Month__c = getMonthString(campaignMonths.get(month));
                        monthlyAUSCampaignPlanning.CurrencyIsoCode = campaign.CurrencyIsoCode;
                        monthlyAUSCampaignPlanning.Amount__c = 0;
                        for(Id csId:campaignPlanningIds){
                            monthlyAUSCampaignPlanning.Monthly_Planning__c = csId; 
                        }
                        
                        monthlyAUSCampaignPlanning.ParentCampaign__c = campaign.Id;
                        monthlyAUSCampaignPlanning.Posting_Date__c = Date.today();
                    }
                    else {
                        //Create Placeholder Date to hold month for the placeholder Campaign_Spend__c record
                        Date placeholderDate = Date.newInstance(Integer.valueOf(campaign.Year__c), month, 1);
                        
                        //Set up Campaign_Spend__c record for months not in the Start Date and End Date range of the campagin
                        monthlyAUSCampaignPlanning.RecordTypeId = monthlyPlanAUSRecordTypeId;
                        monthlyAUSCampaignPlanning.Planning_Month__c = getMonthString(placeholderDate);
                        monthlyAUSCampaignPlanning.CurrencyIsoCode = campaign.CurrencyIsoCode;
                        monthlyAUSCampaignPlanning.Amount__c = 0;
                        for(Id csId:campaignPlanningIds){
                            monthlyAUSCampaignPlanning.Monthly_Planning__c = csId; 
                        }
                        monthlyAUSCampaignPlanning.ParentCampaign__c = campaign.Id;
                        monthlyAUSCampaignPlanning.Posting_Date__c = Date.today();
                    }
                    newCampaignPlanninMonthlyRecordsList.add(monthlyAUSCampaignPlanning);
                }
                
            }
        }
        
        if (!newCampaignPlanninMonthlyRecordsList.isEmpty()) {
            insert newCampaignPlanninMonthlyRecordsList;
        }
        if (!newCampaignPlanningRecordsList.isEmpty()) {
            update newCampaignPlanningRecordsList;
        }
    }
    
    
    public static void calculateTotalPlanningBudgetAfterUpdate(List<Campaign_Spend__c> campaignSpends,Map<Id, Campaign_Spend__c> triggerOldMap, Map<Id, Campaign_Spend__c> triggerNewMap) {
        
        ID monthlyPlanAUSRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
                                                                        BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Monthly_Plan_AUS);
        ID campaignPlanningANDForecastingRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Campaign_Planning_Forecasting).getRecordTypeId();
        List<Campaign_Spend__c> monthlyBudgetChangedRecords = new List<Campaign_Spend__c>();
        Set<ID> campaignPlanningIds = new Set<ID>();
        Set<Id> setParentPlanningANDForeCastCampaignId = new Set<Id>();
        List<Campaign_Spend__c> campaignPlanningRecords = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> updateCampaignPlanningRecords = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> campaignPlanningANDForecastingRecords = new List<Campaign_Spend__c>();
        
        for(Campaign_Spend__c cs:campaignSpends){
            system.debug('inside for::::RecordTypeId is:::'+cs.Monthly_Planning__c);
            if(cs.RecordTypeId == monthlyPlanAUSRecordTypeId){
                //cs.Monthly_Planning__r.RecordTypeId == campaignPlanningANDForecastingRecordTypeId){
                if(triggerNewMap.get(cs.Id).Amount__c != triggerOldMap.get(cs.Id).Amount__c){
                    setParentPlanningANDForeCastCampaignId.add(cs.Monthly_Planning__c);
                }   
            }
        }
        
        for(Campaign_Spend__c cs2:[SELECT Id,Total_Planning_Amount__c,RecordTypeId,
                                   (SELECT Id,Amount__c,Planning_Month__c,RecordTypeId FROM MonthlyPlanning__r) from Campaign_Spend__c 
                                   Where Id IN:setParentPlanningANDForeCastCampaignId]){
                                       System.debug('inside for1::::');
                                       Decimal newTotalBudget = 0.0;                           
                                       if(cs2.MonthlyPlanning__r!=null){
                                           for(Campaign_Spend__c cs3:cs2.MonthlyPlanning__r){
                                               System.debug('inside for2::::');
                                               if(cs3.RecordTypeId==monthlyPlanAUSRecordTypeId && 
                                                  cs3.Amount__c!=null && cs3.Planning_Month__c!=null){
                                                      System.debug('Amount is:::'+cs3.Amount__c);
                                                      newTotalBudget+=cs3.Amount__c;
                                                  }
                                           }
                                       }
                                       cs2.Total_Planning_Amount__c = newTotalBudget;
                                       updateCampaignPlanningRecords.add(cs2);
                                   }
        
        if(!updateCampaignPlanningRecords.isEmpty()){
            update updateCampaignPlanningRecords;
        }
    }
    
    
    
    public static void calculateTotalPlanningBudgetAfterInsert(List<Campaign_Spend__c> campaignSpends, Map<Id, Campaign_Spend__c> triggerNewMap) {
        
        ID monthlyPlanAUSRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
                                                                        BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Monthly_Plan_AUS);
        ID campaignPlanningANDForecastingRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Campaign_Planning_Forecasting).getRecordTypeId();
        List<Campaign_Spend__c> monthlyBudgetChangedRecords = new List<Campaign_Spend__c>();
        Set<ID> campaignPlanningIds = new Set<ID>();
        Set<Id> setParentPlanningANDForeCastCampaignId = new Set<Id>();
        List<Campaign_Spend__c> campaignPlanningRecords = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> updateCampaignPlanningRecords = new List<Campaign_Spend__c>();
        List<Campaign_Spend__c> campaignPlanningANDForecastingRecords = new List<Campaign_Spend__c>();
        
        for(Campaign_Spend__c cs:campaignSpends){
            system.debug('inside for::::RecordTypeId is:::'+cs.Monthly_Planning__c);
            if(cs.RecordTypeId == monthlyPlanAUSRecordTypeId){
                //cs.Monthly_Planning__r.RecordTypeId == campaignPlanningANDForecastingRecordTypeId){
                if(triggerNewMap.get(cs.Id).Amount__c != null){
                    setParentPlanningANDForeCastCampaignId.add(cs.Monthly_Planning__c);
                }   
            }
        }
        
        for(Campaign_Spend__c cs2:[SELECT Id,Total_Planning_Amount__c,RecordTypeId,
                                   (SELECT Id,Amount__c,Planning_Month__c,RecordTypeId FROM MonthlyPlanning__r) from Campaign_Spend__c 
                                   Where Id IN:setParentPlanningANDForeCastCampaignId]){
                                       System.debug('inside for1::::');
                                       Decimal newTotalBudget = 0.0;                           
                                       if(cs2.MonthlyPlanning__r!=null){
                                           for(Campaign_Spend__c cs3:cs2.MonthlyPlanning__r){
                                               System.debug('inside for2::::');
                                               if(cs3.RecordTypeId==monthlyPlanAUSRecordTypeId && 
                                                  cs3.Amount__c!=null && cs3.Planning_Month__c!=null){
                                                      System.debug('Amount is:::'+cs3.Amount__c);
                                                      newTotalBudget+=cs3.Amount__c;
                                                  }
                                           }
                                       }
                                       cs2.Total_Planning_Amount__c = newTotalBudget;
                                       updateCampaignPlanningRecords.add(cs2);
                                   }
        
        if(!updateCampaignPlanningRecords.isEmpty()){
            update updateCampaignPlanningRecords;
        }
    }
    
    
    public static void insertCampaignBudgetMonthlyRecords(List<Campaign__c> campaigns) {
        
        List<Campaign_Spend__c> newCampaignBudgetMonthlyRecordsList = new List<Campaign_Spend__c>();
        
        ID AUSCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGN_AUSTRALIA_WBS).getRecordTypeId();
        //System.debug('AUSCampaignRecordTypeId is:::'+AUSCampaignRecordTypeId);
        //ID AUSCampaignRecordTypeId = '0121J000001DatE';
        ID CampaignSpendMonthlyBudgetAUSRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Monthly_Budget_AUS).getRecordTypeId();
        
        for (Campaign__c campaign : campaigns) {
            if (campaign.InitialStartDate__c != null && campaign.InitialEndDate__c != null && 
                campaign.PlannedCampaignSpend__c != null && campaign.RecordTypeId == AUSCampaignRecordTypeId) {
                    Date startDate = campaign.InitialStartDate__c.toStartOfMonth();
                    Date endDate = campaign.InitialEndDate__c.toStartOfMonth();
                    //Determine how many months
                    Integer countMonths = startDate.monthsBetween(endDate) + 1;
                    if (countMonths <= 0) { countMonths = 1; }
                    
                    //Build Map of months contained in the Start Date and End Date range of the campaign
                    Map<Integer, Date> campaignMonths = new Map<Integer, Date>();
                    for (Date dt = startDate; dt <= endDate; dt = dt.addMonths(1)) {
                        campaignMonths.put(dt.Month(), dt);
                    }
                    
                    for(Integer month = 1; month <= BI_Constants.TOTAL_MONTHS_IN_YEAR; month++){
                        Campaign_Spend__c monthlyAUSCampaignPlanning = new Campaign_Spend__c();
                        //Check if the month value exists in the Start Date and End Date range of the campaign
                        if(campaignMonths.containsKey(month)){
                            monthlyAUSCampaignPlanning.RecordTypeId = CampaignSpendMonthlyBudgetAUSRecordTypeId;
                            monthlyAUSCampaignPlanning.Budget_Month__c = getMonthString(campaignMonths.get(month));
                            monthlyAUSCampaignPlanning.CurrencyIsoCode = campaign.CurrencyIsoCode;
                            monthlyAUSCampaignPlanning.Amount__c = 0;
                            monthlyAUSCampaignPlanning.ParentCampaign__c = campaign.Id;
                            monthlyAUSCampaignPlanning.Posting_Date__c = Date.today();
                        }
                        else {
                            //Create Placeholder Date to hold month for the placeholder Campaign_Spend__c record
                            Date placeholderDate = Date.newInstance(Integer.valueOf(campaign.Year__c), month, 1);
                            
                            //Set up Campaign_Spend__c record for months not in the Start Date and End Date range of the campagin
                            monthlyAUSCampaignPlanning.RecordTypeId = CampaignSpendMonthlyBudgetAUSRecordTypeId;
                            monthlyAUSCampaignPlanning.Budget_Month__c = getMonthString(placeholderDate);
                            monthlyAUSCampaignPlanning.CurrencyIsoCode = campaign.CurrencyIsoCode;
                            monthlyAUSCampaignPlanning.Amount__c = 0;
                            monthlyAUSCampaignPlanning.ParentCampaign__c = campaign.Id;
                            monthlyAUSCampaignPlanning.Posting_Date__c = Date.today();
                        }
                        newCampaignBudgetMonthlyRecordsList.add(monthlyAUSCampaignPlanning);    
                    }   
                }
        }
        if (!newCampaignBudgetMonthlyRecordsList.isEmpty()) {
            insert newCampaignBudgetMonthlyRecordsList;
        } 
    }
    
    /*public static void calculateTotalMonthlyBudgetAfterUpdate(List<Campaign_Spend__c> campaignSpends,Map<Id, Campaign_Spend__c> triggerOldMap, Map<Id, Campaign_Spend__c> triggerNewMap) {
        
        ID CampaignSpendMonthlyBudgetAUSRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Monthly_Budget_AUS).getRecordTypeId();
        ID AUSCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGN_AUSTRALIA_WBS).getRecordTypeId();
        Set<Id> setParentCampaignId = new Set<Id>();
        Set<Id> setCampaignSpendId = new Set<Id>();
        List<Campaign__c> updateCampaignRecords = new List<Campaign__c>();
        for(Campaign_Spend__c cs:campaignSpends){
            System.debug('inside for:::'+cs);
            if(cs.RecordTypeId == CampaignSpendMonthlyBudgetAUSRecordTypeId){
                System.debug('inside if:::'+cs.RecordTypeId);
                if(triggerNewMap.get(cs.Id).Amount__c != null){
                if(triggerNewMap.get(cs.Id).Amount__c != triggerOldMap.get(cs.Id).Amount__c){
                    setParentCampaignId.add(cs.ParentCampaign__c);
                    setCampaignSpendId.add(cs.Id);
                }
              }
            }
        }
        System.debug('setCampaignSpendId is:::'+setCampaignSpendId);
        
        for(Campaign__c camp:[Select id,name,Total_Budget__c,RecordTypeId,
                                   (Select Id,Amount__c,Budget_Month__c,RecordTypeId FROM Campaign_Spend__r) from Campaign__c 
                                   Where Id IN:setParentCampaignId]){
                                       Decimal totalBudget = 0.0;
                                       if(camp.RecordTypeId == AUSCampaignRecordTypeId && (camp.Campaign_Spend__r).size()>0){
                                           for(Campaign_Spend__c cs:camp.Campaign_Spend__r){
                                               if(cs.RecordTypeId == CampaignSpendMonthlyBudgetAUSRecordTypeId && cs.Amount__c !=null){
                                                   totalBudget+=cs.Amount__c;
                                                   System.debug('Amount is:::'+totalBudget);
                                               }
                                           }
                                       }
                                       camp.Total_Budget__c = totalBudget;
                                       updateCampaignRecords.add(camp);
                                   }
        
           
        if(!updateCampaignRecords.isEmpty()){
            update updateCampaignRecords;
        }
    }
    
    public static void calculateTotalMonthlyBudgetAfterInsert(List<Campaign_Spend__c> campaignSpends,Map<Id, Campaign_Spend__c> triggerOldMap, Map<Id, Campaign_Spend__c> triggerNewMap) {
        ID CampaignSpendMonthlyBudgetAUSRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGNSPEND_Monthly_Budget_AUS).getRecordTypeId();
        ID AUSCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().
            get(BI_Constants.RECORDTYPE_CAMPAIGN_AUSTRALIA_WBS).getRecordTypeId();
        Set<Id> setParentCampaignId = new Set<Id>();
        Set<Id> setCampaignSpendId = new Set<Id>();
        List<Campaign__c> updateCampaignRecords = new List<Campaign__c>();
        for(Campaign_Spend__c cs:campaignSpends){
            System.debug('inside for:::'+cs);
            if(cs.RecordTypeId == CampaignSpendMonthlyBudgetAUSRecordTypeId){
                System.debug('inside if:::'+cs.RecordTypeId);
                if(triggerNewMap.get(cs.Id).Amount__c != null){
                    setParentCampaignId.add(cs.ParentCampaign__c);
                    setCampaignSpendId.add(cs.Id);
              }
            }
        }
        System.debug('setCampaignSpendId is:::'+setCampaignSpendId);
        
        for(Campaign__c camp:[Select id,name,Total_Budget__c,RecordTypeId,
                                   (Select Id,Amount__c,Budget_Month__c,RecordTypeId FROM Campaign_Spend__r) from Campaign__c 
                                   Where Id IN:setParentCampaignId]){
                                       Decimal totalBudget = 0.0;
                                       if(camp.RecordTypeId == AUSCampaignRecordTypeId && (camp.Campaign_Spend__r).size()>0){
                                           for(Campaign_Spend__c cs:camp.Campaign_Spend__r){
                                               if(cs.RecordTypeId == CampaignSpendMonthlyBudgetAUSRecordTypeId && cs.Amount__c !=null){
                                                   totalBudget+=cs.Amount__c;
                                                   System.debug('Amount is:::'+totalBudget);
                                               }
                                           }
                                       }
                                       camp.Total_Budget__c = totalBudget;
                                       updateCampaignRecords.add(camp);
                                   }
        
           
        if(!updateCampaignRecords.isEmpty()){
            update updateCampaignRecords;
        }
    }*/
}