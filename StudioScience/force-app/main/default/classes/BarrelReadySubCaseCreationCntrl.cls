public class BarrelReadySubCaseCreationCntrl {
    
/**************************************************************************************************************
    Description:     SR-179687 Added By Ajeeta Soni(TCS)   
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    6/2020      Ajeeta Soni       Initial Creation
    
***************************************************************************************************************/    
    @InvocableMethod 
    public static void createSubCaseForBarrelReady(List <Case> cases) {
    Id singleBarrelInquiryRId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Ready_to_Enter').getRecordTypeId();       
    List <Case> casesToInsert = new List<Case>();
        Id queueID ;
        queueID = [SELECT Id,Name, Type FROM Group WHERE Type = 'Queue' AND Name = 'Barrel Queue'].Id;
        for(Case c : cases){
            
                Case newSubCase = new Case();
                newSubCase.ParentId = c.Id;
                newSubCase.Status = 'New'; 
                newSubCase.OwnerId = queueID;
                newSubCase.Sub_Status__c = null;
                newSubCase.Product_Type__c = c.Product_Type__c;
                newSubCase.AccountId = c.AccountId;
                newSubCase.Retail_Account__c = c.Retail_Account__c;
                newSubCase.ContactId = c.ContactId;
                newSubCase.Brand__c = c.Brand__c;
                newSubCase.Submitter__c = c.Submitter__c;
                newSubCase.Type = 'Barrel Ready to Enter';
                newSubCase.Purchase_Order_Number__c   = c.Related_Barrel_PO_Number__c ;
                newSubCase.RecordTypeId = singleBarrelInquiryRId ; 
                casesToInsert.add(newSubCase);
          
               }
           
        if (!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert;
             } catch (Exception e) {
                String errorMessage = 'Error creating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('BarrelReadySubcaseCreationcntrl', 'createSubCaseForBarrelReady', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                if (Test.isRunningTest()) {
                    throw new CS_CustomException(e.getMessage());
                }
            }
        }
        
    }


}