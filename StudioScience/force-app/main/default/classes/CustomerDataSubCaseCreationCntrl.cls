public class CustomerDataSubCaseCreationCntrl {
    @InvocableMethod(label='Create Customer Data Sub Case' description='This class is used to create the Customer Data Sub Case and updating Parent Case Status' category='CustomerDataCases')
    public static void CreateCustomerDataSubCase(List<Id>CaseIds){
        List<Case> CustomerDataParentCases = new List<Case>();
        CustomerDataParentCases = [SELECT id,CaseNumber,Status,KickoffCustomerData__c FROM Case WHERE ID IN:CaseIds];
        List<Case>CustomerDataSubCases = new List<Case>();
        for(Case caserec:CustomerDataParentCases){
            caserec.status ='Ready to Load';
            caserec.KickoffCustomerData__c = true;
            Case customersubCase = new Case();
            customersubCase = caserec.clone(false, false, false, false);
            customersubCase.status='New';
            customersubCase.ParentId =caserec.Id;
            customersubCase.RecordTypeId = CSConstants.CUSTOMER_DATA_SUB_CASE_RT_ID;
            CustomerDataSubCases.add(customersubCase);
        }
        //try{
           update CustomerDataParentCases;
           insert CustomerDataSubCases;
        //}catch(exception ex){
            
        //}
        
        
    }
}