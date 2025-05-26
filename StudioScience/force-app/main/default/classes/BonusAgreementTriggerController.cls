public class BonusAgreementTriggerController {

    public static void createGoalPlan(Map<Id, Bonus_Agreement__c> pBonusAgreements) {
        if (pBonusAgreements == null || pBonusAgreements.isEmpty()) {
            return;
        }
        
        Map<Id, Bonus_Agreement__c> pBonusAgreementWithReferences = new Map<Id, Bonus_Agreement__c>([SELECT Id, Label__r.Name FROM Bonus_Agreement__c WHERE Id IN :pBonusAgreements.keySet()]);
        Map<Id, gvp__Sales_Goal_Plan__c> goalPlans = new Map<Id, gvp__Sales_Goal_Plan__c>();
        
        Date todaysDate = Date.today();
        Date firstOfMonth = Date.newInstance(todaysDate.year(), todaysDate.month(), 1);
        Date lastOfMonth = firstOfMonth.addMonths(1).addDays(-1);
        for (Bonus_Agreement__c currentBonus : pBonusAgreements.values()) {
            goalPlans.put(
                currentBonus.Id,
                new gvp__Sales_Goal_Plan__c(
                    gvp__External_Id__c = currentBonus.Name + '-' + todaysDate.year() + '-' + todaysDate.month(),
                    //gvp__External_Id__c = todaysDate.year() + '-' + todaysDate.month() + '-' + currentBonus.Name + '-' + currentBonus.Bonus__c,
                    gvp__Goal_Level__c = 'attr.acct_univ_dim.acct_univ_id',
                    gvp__Goal_Plan_Name__c = currentBonus.Name + '-' + todaysDate.year() + '-' + todaysDate.month(),
                    gvp__Goal_Plan_Description__c = todaysDate.year() + '-' + todaysDate.month() + ' ' + pBonusAgreementWithReferences.get(currentBonus.Id).Label__r.Name + ' ' + Integer.valueOf(currentBonus.Bonus__c) + '%',
                    gvp__Is_Active__c = TRUE
                )
            );
        }
        insert goalPlans.values();
        
        Set<Id> goalPlanIds = new Set<Id>();
        for (gvp__Sales_Goal_Plan__c currentPlan : goalPlans.values()) {
            goalPlanIds.add(currentPlan.Id);
        }
        Map<Id, gvp__Sales_Goal_Plan__c> goalPlansWithName = new Map<Id, gvp__Sales_Goal_Plan__c>([SELECT Name FROM gvp__Sales_Goal_Plan__c WHERE Id IN :goalPlanIds]);
        
        gvp__Sales_Goal_Plan__c plan;
        Bonus_Agreement__c bonus;
        gvp__Sales_Goal__c salesGoalMaster;
        gvp__Sales_Goal__c salesGoalReference;
        List<gvp__Sales_Goal__c> goalsToInsert = new List<gvp__Sales_Goal__c>();
        
        for (Id currentId : goalPlans.keySet()) {
            plan = goalPlansWithName.get(goalPlans.get(currentId).Id);
            bonus = pBonusAgreements.get(currentId);
            salesGoalMaster = new gvp__Sales_Goal__c(
                Name = plan.Name + ' - Master',
                gvp__Master__c = TRUE,
                gvp__Custom_Fact_1__c = bonus.Bonus__c,
                Bonus_Offer__c = bonus.Id,
                gvp__Sales_Goal_Plan__c = plan.Id,
                gvp__Start_Date__c = firstOfMonth,
                gvp__End_Date__c = lastOfMonth,
                gvp__Goal_Key__c =  todaysDate.year() + '-' + todaysDate.month() + '-' + bonus.Name + '-' + bonus.Bonus__c,
                gvp__Goal_Quantity__c = bonus.Buy_Quantity__c,
                gvp__Goal_Transaction_Type__c = 'RAD',
                gvp__Goal_Type__c = 'BSM Bottle Sales Goal',
                gvp__Label__c = bonus.Label__c
            );
            salesGoalReference = salesGoalMaster.clone(false, true, false, false);
            salesGoalReference.Name = plan.Name + ' - Reference';
            salesGoalReference.gvp__Custom_Fact_1__c = null;
            salesGoalReference.gvp__Master__c = false;
            salesGoalReference.gvp__Reference__c = true;
            salesGoalReference.gvp__Goal_Key__c = null;
            goalsToInsert.add(salesGoalMaster);
            goalsToInsert.add(salesGoalReference);
        }
        insert goalsToInsert;
        
        List<gvp__Sales_Goal_Plan__c> plansToUpdate = [SELECT Id, gvp__Sales_Goal__c, (SELECT gvp__Master__c FROM gvp__Sales_Goals__r) FROM gvp__Sales_Goal_Plan__c WHERE Id IN :goalPlanIds];
        for (gvp__Sales_Goal_Plan__c currentPlan : plansToUpdate) {
            for (gvp__Sales_Goal__c currentGoal : currentPlan.gvp__Sales_Goals__r) {
                if (currentGoal.gvp__Master__c) {
                    currentPlan.gvp__Sales_Goal__c = currentGoal.Id;
                    break;
                }
            }
        }
        update plansToUpdate;
    }
}