global class BonusCouponBatchController implements Database.Batchable<sObject>, Schedulable {
    public Date dateOverride { get; set; }
    
    global void execute(SchedulableContext content) {
        BonusCouponBatchController batch = new BonusCouponBatchController();
        Database.executeBatch(batch, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Only execute scheduled job if today is the last day of the month
        if (Date.today().addDays(1).day() == 1) {
            return Database.getQueryLocator([SELECT Id, Name, Label__r.Name, Bonus__c FROM Bonus_Agreement__c WHERE Status__c = 'Active' LIMIT 50000]);
        }
        
        if (dateOverride != null) {
            return Database.getQueryLocator([SELECT Id, Name, Label__r.Name, Bonus__c FROM Bonus_Agreement__c WHERE Status__c = 'Active' LIMIT 50000]);
        }
        
        //Return empty record set
        return Database.getQueryLocator([SELECT Id FROM Bonus_Agreement__c WHERE Id = NULL]);
    }
    
    global void execute(Database.BatchableContext BC, List<Bonus_Agreement__c> pSource) {
        //Add one day to get to the first of the next month since job runs on last day of the month
        Date runDate = (dateOverride == null) ? Date.today() : dateOverride;
        Date startOfNextMonth = runDate.addDays(1);
        //Add one day and one month, then back up one day to get to the last day of the next month
        Date endOfNextMonth = runDate.addDays(1).addMonths(1).addDays(-1);
        
        Map<String, Bonus_Agreement__c> bonusMap = createBonusMap(pSource, runDate);
        Map<String, gvp__Sales_Goal_Plan__c> goalPlanMap = getGoalPlanMap(bonusMap.keySet());
        if (goalPlanMap == null || goalPlanMap.isEmpty()) {
            return;
        }
        
        List<String> bonusAgreementKey;
        // String clonedGoalPlanName;
        //String originalGoalPlanName;
        Id clonedGoalPlanId;
        Savepoint sp = Database.setSavepoint();
        try {
            for (String currentKey : goalPlanMap.keySet()) {
                gvp__Sales_Goal_Plan__c clonedPlan = goalPlanMap.get(currentKey).clone(false, true, false, false);
                List<String> originalGoalPlanNameList = goalPlanMap.get(currentKey).gvp__Goal_Plan_Name__c.split('-');
                bonusAgreementKey = currentKey.split('-');
                clonedPlan.gvp__Goal_Plan_Name__c = bonusAgreementKey[0] + '-' + bonusAgreementKey[1] + '-' + startOfNextMonth.year() + '-' + startOfNextMonth.month();
                clonedPlan.gvp__External_Id__c = clonedPlan.gvp__Goal_Plan_Name__c;
                clonedPlan.gvp__Goal_Plan_Description__c = startOfNextMonth.year() + '-' + startOfNextMonth.month() + ' ' + bonusMap.get(currentKey).Label__r.Name + ' ' + Integer.valueOf(bonusMap.get(currentKey).Bonus__c) + '%';
                try {
                    insert clonedPlan;
                    clonedGoalPlanId = clonedPlan.Id;
                    //clonedGoalPlanName = [SELECT Name FROM gvp__Sales_Goal_Plan__c WHERE Id = :clonedGoalPlanId].Name;
                } catch (Exception e) {
                    //if goal plan already exists, skip
                    break;
                }
                
                List<gvp__Sales_Goal__c> clonedSalesGoals = new List<gvp__Sales_Goal__c>();
                gvp__Sales_Goal__c tempGoal;
                List<String> tempGoalName;
                for (gvp__Sales_Goal__c currentGoal : clonedPlan.gvp__Sales_Goals__r) {
                    if (!currentGoal.gvp__Master__c && !currentGoal.gvp__Reference__c && currentGoal.gvp__Status__c != 'Approved') {
                        continue;
                    }
                    if (currentGoal.gvp__Master__c || currentGoal.gvp__Reference__c || currentGoal.Ultimate_End_Date__c == null || currentGoal.Ultimate_End_Date__c > Date.today()) {
                        tempGoal = currentGoal.clone(false, true, false, false);
                        tempGoalName = tempGoal.Name.split('-');
                        tempGoal.Name = tempGoalName[0] + '-' + tempGoalName[1] + '-' + startOfNextMonth.year() + '-' + startOfNextMonth.month();
                        tempGoal.gvp__Sales_Goal_Plan__c = clonedPlan.Id;
                        tempGoal.gvp__Start_Date__c = startOfNextMonth;
                        tempGoal.gvp__End_Date__c = endOfNextMonth;
                        tempGoal.gvp__Goal_Key__c = startOfNextMonth.year() + '-' + startOfNextMonth.month() + '-' + bonusMap.get(currentKey).Name + '-' + bonusMap.get(currentKey).Bonus__c;
                        tempGoal.gvp__Reference_Report_ID__c = null;
                        tempGoal.Coupon__c = null;
                        tempGoal.gvp__Reference_Value__c = null;
                        tempGoal.gvp__Reported_Result_Object_Id__c = null;
                        tempGoal.gvp__Reported_Result__c = null;
                        clonedSalesGoals.add(tempGoal);
                    }
                    if (!currentGoal.gvp__Master__c) {
                        tempGoal.gvp__Goal_Key__c = null;
                    }
                }
                insert clonedSalesGoals;
                
                List<gvp__Sales_Goal_Plan__c> plansToUpdate = [SELECT Id, gvp__Sales_Goal__c, (SELECT gvp__Master__c FROM gvp__Sales_Goals__r) FROM gvp__Sales_Goal_Plan__c WHERE Id = :clonedGoalPlanId];
                for (gvp__Sales_Goal_Plan__c currentPlan : plansToUpdate) {
                    for (gvp__Sales_Goal__c currentGoal : currentPlan.gvp__Sales_Goals__r) {
                        if (currentGoal.gvp__Master__c) {
                            clonedPlan.gvp__Sales_Goal__c = currentGoal.Id;
                            break;
                        }
                    }
                }
                update clonedPlan;
                break;
            }  
        } catch (Exception e) {
            System.debug(e.getMessage());
            Database.rollback(sp);       
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    private static Map<String, Bonus_Agreement__c> createBonusMap(List<Bonus_Agreement__c> pBonusList, Date pRunDate) {
        Map<String, Bonus_Agreement__c> bonusMap = new Map<String, Bonus_Agreement__c>();
        if (pBonusList == null || pBonusList.isEmpty()) {
            return bonusMap;
        }
        
        for (Bonus_Agreement__c currentBonus : pBonusList) {
            bonusMap.put(currentBonus.Name + '-' + pRunDate.year() + '-' + pRunDate.month(), currentBonus);
        }
        return bonusMap;
    }
    
    public static Map<String, gvp__Sales_Goal_Plan__c> getGoalPlanMap(Set<String> pBonusNameList) {
        Map<String, gvp__Sales_Goal_Plan__c> goalPlanMap = new Map<String, gvp__Sales_Goal_Plan__c>();
        if (pBonusNameList == null || pBonusNameList.isEmpty()) {
            return goalPlanMap;
        }
        
        Set<Id> goalPlanIds = new Set<Id>();
        String soql = String.format(
            'SELECT {0}, (SELECT {1} FROM gvp__Sales_Goals__r) FROM gvp__Sales_Goal_Plan__c WHERE gvp__Goal_Plan_Name__c IN :pBonusNameList LIMIT 50000',
            new String[] { 
                String.join(new List<String>( gvp__Sales_Goal_Plan__c.SObjectType.getDescribe().fields.getMap().keySet() ), ','),
                    String.join(new List<String>( gvp__Sales_Goal__c.SObjectType.getDescribe().fields.getMap().keySet() ), ',')
                    }
        );
        for (gvp__Sales_Goal_Plan__c currentPlan : Database.query(soql)) {
            goalPlanMap.put(currentPlan.gvp__Goal_Plan_Name__c, currentPlan);
        }
        return goalPlanMap;
    }
}