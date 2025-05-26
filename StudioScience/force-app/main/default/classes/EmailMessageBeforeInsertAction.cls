/**********************************************************************************************************************
Apex Class Name     : EmailMessageBeforeInsertAction
Created Date        : 9/2021
Function            : Updating UserEmailAddress on Case object when the case is created from DAL_US oR DAL_INTERNATIONAL 
**************************************************************************************************************************/
public class EmailMessageBeforeInsertAction {
    
    @InvocableMethod(label='Updating CCAddress' description='Capturing the cc address when email to case is triggered')
    public static void updatingCcAddressOnCase(List<Id> emailIdList){
        try{
            List<EmailMessage> emailMessages = new List<EmailMessage>();      
            Set<Id> caseIds = new Set<Id>();
            
            emailMessages = [select id,	ParentId, FromAddress,ToAddress,CcAddress from EmailMessage where Id IN:emailIdList];            
            for(EmailMessage em : emailMessages){
                caseIds.add(em.ParentId);
            }
            
            List<Case> lstCases = [SELECT Id, CaseNumber, Subject, User_Email__c from Case where Id IN :caseIds];  
            for(Case c : lstCases){
                for(EmailMessage em : emailMessages){
                    if(em.CcAddress != null){   
                        String[] CcEmails = em.CcAddress.split(';');                                                             
                        c.User_Email__c = CcEmails[0];                                             
                    }
                }
            } 
            update lstCases;             
        }          
        catch(Exception e) {
            String errorMessage = 'Error creating case ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('EmailMessageBeforeInsertAction', 'UpdatingCCAddressOnCase', String.valueOf(errorMessage), 'Fatal');
        }       
    }  
}