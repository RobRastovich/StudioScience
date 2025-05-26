@isTest
public class ResolveGeneralQueueCasesTest {
    
    public static testMethod void resolveCasesTest() {
        Case c = (new Case( OwnerId='00G1J000002qy1PUAQ', Status='New',CreatedDate=System.Today().addDays(-60)));
        insert c;
        test.startTest();
        ResolveGeneralQueueCases sc = new ResolveGeneralQueueCases();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Testing', sch, sc);
        test.stopTest();
        System.assert(c.CreatedDate < System.Today());
    }
    
}