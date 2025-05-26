public class CRM_CaseServices {
    /**************************************************************************************************************
Method name:    brandNotBlank
Object:         Case
Date:           4/2023       Milan Bilochi     Metacube  
Details and Notes:
Used to check that brand is mandatory when agent trying to changes the status.
***************************************************************************************************************/
    public static void mandatoryFieldNotBlank(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case currCase : newCases){
            if((currCase.Status!= oldMap.get(currCase.Id).Status || currCase.Brand__c!= oldMap.get(currCase.Id).Brand__c 
            || currCase.Product_Type__c!= oldMap.get(currCase.Id).Product_Type__c)
            && (currCase.Status == CRM_Constants.CASE_STATUS_CLOSED || currCase.Status == CRM_Constants.CASE_STATUS_RESOLVED))
            {
                if(String.isBlank(currCase.Brand__c)) {
                    currCase.Brand__c.addError(CRM_Constants.Brand_cannot_be_blank); 
                }
                if(String.isBlank(currCase.Product_Type__c) 
                    && CRM_Constants.Product_Type_Mandatory_Brands.contains(currCase.Brand__c)
                    && UserInfo.getName() != null
                    && UserInfo.getName() != CRM_Constants.Contact_Us_Community_Site_Guest_User
                    && UserInfo.getName() != CRM_Constants.SFDC_Integration) {
                    currCase.Product_Type__c.addError(CRM_Constants.Product_cannot_be_blank);
                } 
            }
        }
    }
    
    /**************************************************************************************************************
Method name:    updateDateTimeAssignedOnCase
Object:         Case
Date:           11/2023       Nishant Khandal     Metacube  
Details and Notes:
Used to update Date Time Assigned field with current DateTime when Status is either In Progress or Assigned.
***************************************************************************************************************/
    public static void updateDateTimeAssignedOnCase(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case currCase : newCases){
            if((currCase.Status == CRM_Constants.CASE_STATUS_ASSIGNED || currCase.Status == CRM_Constants.CASE_STATUS_IN_PROGRESS)
              && currCase.Status != oldMap.get(currCase.Id).Status
               && currCase.Date_Time_Assigned__c == null){
                   currCase.Date_Time_Assigned__c = System.now();
            }
        }
    }

    /**************************************************************************************************************
    Method name:    captureCasePickupTime
    Object:         Case
    Date:           01/2024       Jaiveer Jha       
    Details and Notes:
    This method is used to calculate the case pick-up time.
    ***************************************************************************************************************/
    public static void captureCasePickupTime(List<Case> newCases, Map<Id, Case> oldMap){
        for(Case currCase: newCases){
            if(
                CSConstants.qualityClaimRecordTypeIds.contains(currCase.RecordTypeId) &&
                oldMap.get(currCase.Id).Status.equalsIgnoreCase(CSConstants.NEW_STATUS) && 
                currCase.Status != oldMap.get(currCase.Id).Status && 
                CSConstants.capturePickUpTimeStatus.contains(currCase.Status)&&
                currCase.Business_Hours_To_Pick_on_Case__c == null
            ){
                currCase.Business_Hours_To_Pick_on_Case__c = EmailMessageServices.calculateFirstResponseTime(currCase.CreatedDate,
                                                                                                            system.now());
            }
        }
    }
}