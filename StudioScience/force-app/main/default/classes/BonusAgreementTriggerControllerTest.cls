@isTest
private class BonusAgreementTriggerControllerTest {

    private static @isTest void defaultTest() {
        gvp__Brand__c brand = new gvp__Brand__c(
            gvp__Brand_Key__c = 'brand'
        );
        insert brand;
        gvp__Label__c label = new gvp__Label__c(
        	gvp__Brand__c = brand.Id,
            gvp__Label_Key__c = 'label'
        );
        insert label;
        Bonus_Agreement__c bonus1 = new Bonus_Agreement__c(
        	Label__c = label.Id,
            Buy_Start_Date__c = Date.newInstance(2018, 7, 1),
            Status__c = 'Active' 
        );
        insert bonus1;
        
        bonus1 = [SELECT Name, Bonus__c FROM Bonus_Agreement__c WHERE Id = :bonus1.Id];
        gvp__Sales_Goal_Plan__c plan = [SELECT Id, gvp__Goal_Plan_Name__c, gvp__External_Id__c, gvp__Goal_Plan_Description__c FROM gvp__Sales_Goal_Plan__c];
        plan.gvp__External_Id__c = '2018-6-' + bonus1.Name + '-' + bonus1.Bonus__c;
        plan.gvp__Goal_Plan_Name__c = bonus1.Name + '-2018-6';
        plan.gvp__Goal_Plan_Description__c = '2018-06 Test Label 100%';
        update plan;
        
        System.assertNotEquals(null, plan.Id, 'Goal Plan Created');
        
        Test.startTest();
        BonusCouponBatchController batch = new BonusCouponBatchController();
        batch.dateOverride = Date.newInstance(2018, 6, 30);
		Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}