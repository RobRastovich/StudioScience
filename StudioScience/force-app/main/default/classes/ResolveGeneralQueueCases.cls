/*
Author:         Devyani Gupta
Company:        Metacube
Description:    This class is used to resolve General Queue cases which are new after 2 months

History
<Date>           <Authors Name>    <Brief Description of Change>
12th Oct,2021    Devyani Gupta      resolving general queue cases
*/

global class ResolveGeneralQueueCases Implements Schedulable
{
    
    global void execute(SchedulableContext sc)
    {
        resolveCases();
    }
    
            /**************************************************************************************************************
Author:        Devyani Gupta
Company:       Metacube
Description:    This method resolves cases when they are 2 months old
History
<Date>      <Authors Name>     <Brief Description of Change>
10/2021         Devyani Gupta       resolving general queue cases

***************************************************************************************************************/
    
    public static void resolveCases()
    {
        List<Case> gqCases = [SELECT Id, Case_Owner__c, CaseNumber, Status, CreatedDate FROM Case where Status = 'New' and Case_Owner__c ='CC_GENERAL_QUEUE' and CreatedDate < LAST_N_DAYS:60 order by CreatedDate desc];
        List<Case> casesToUpdate = new List<Case>();
        for (Case c: gqCases) {
            c.Status = 'Resolved';
            casesToUpdate.add(c);
        }
        if(casesToUpdate.size()>0)
            update casesToUpdate;
    } 
    
}