public class SBP_LaphroaigCaseServices {
     /*******************************************************************************************************************************
Description:    This method is used to update the STO created date and STO created of cases.
<Date>          <Authors Name>     <Company>     <Brief Description of Change>
08/2022             Nishant Khandal     Metacube       Initial Creation
******************************************************************************************************************************/
    public static void updateSTOCreationDate(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case newCase: newCases){
            if(!String.isBlank(newCase.STO_Number__c) && String.isBlank(oldMap.get(newCase.Id).STO_Number__c) 
                                                 && newCase.STO_Number__c!= oldMap.get(newCase.Id).STO_Number__c){
                newCase.STO_Created_Date__c = System.now();
                newCase.STO_Created__c = true;
            }
        }
    }

    // LSB-153
    public static void updateCaseStatusAndSubStatus(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case recordCase: newCases){
            if(oldMap.get(recordCase.Id).Type == null 
                && recordCase.Type != oldMap.get(recordCase.Id).Type){
                    recordCase.Status = SBP_Constants.PREPARING_BARREL;
                    recordCase.Sub_Status__c = SBP_Constants.BOTTLING;
        	} else if (oldMap.get(recordCase.Id).SAP_Number__c == null 
                && recordCase.SAP_Number__c != oldMap.get(recordCase.Id).SAP_Number__c) {
                    recordCase.Status = SBP_Constants.PENDING_FINAL_DETAILS;
                    recordCase.Sub_Status__c = '';
            }
        }
    }
    
    //This method is used to update the subject of the case
    public static void updateCaseSubject(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case recordCase: newCases){
            if(oldMap.get(recordCase.Id).Type == null
               && recordCase.Type != oldMap.get(recordCase.Id).Type){
                   recordCase.Subject = recordCase.caseNumber +': '+ SBP_Constants.LAPHROAIG_SINGLE_CASK +'- '+ recordCase.Type;
               }
        }
    }
}