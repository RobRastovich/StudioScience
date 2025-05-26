@isTest
public class SBP_DeleteExpiredDateHoldsTest {
    
    public static testMethod void removeDateHoldsTest() {
        Plant_Event__c p = (new Plant_event__c(Scheduled_Date__c = System.Today().addDays(41)));
        insert p;
        test.startTest();
        SBP_DeleteExpiredDateHolds sc = new SBP_DeleteExpiredDateHolds();
        String sch = '0 0 23 * * ?'; 
        System.schedule('DeleteExpiredDateHolds Check', sch, sc);
        test.stopTest();
        System.assert(p.Scheduled_Date__c > System.Today());
    }
    
}