public  class GetPOs
{
    public Id CaseId{get;set;}
    
    public List<Purchase_Order__c> getpos()
    {
        List<Purchase_Order__c> pos;
        pos = [SELECT Name,PO_Number__c FROM Purchase_Order__c WHERE Case__c=: caseId];
        return pos ;
    }
}