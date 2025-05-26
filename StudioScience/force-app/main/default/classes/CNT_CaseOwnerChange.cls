/**
    @company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 23/04/2020
    @description This class is used change case owner to self by Assign to me button of component rendered on Record Detail Page.
*/
public class CNT_CaseOwnerChange {
   /**
    *  @description : This method is use to fetch value for picklist on contact us page.
    *  @args        : String brand
    *  @return      : void
    **/
    @AuraEnabled 
    public static void updateStatus(Case obj,String recId){
        Case caseObject = obj;
        caseObject.Id = recId;
        caseObject.CaseClosedType__c='Agent Closed';
        try {
            update caseObject;
        } catch(Exception e) {
            String errorMessage = 'Error updating case owner ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_CaseOwnerChange', 'updateStatus', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        
    }
    
    /**
     * @description : This method is used to update the case details like case record type, priority,case subject
     * @args		: Case object, Record Id,Record Type Id,Case Number
     * @return		: void
     * **/
    
    @AuraEnabled
    public static void changeRecord(Case obj,String recId,String recordTypeId,String caseNumber)
    {
        Case caseObject= obj;
        caseObject.Id = recId;
        caseObject.Status='New';
        caseObject.RecordTypeId=recordTypeId;
        caseObject.isRecordTypeChanged__c = true;//added to stop mail sent to consumer on conversion to Quality Claim
        System.debug('caseObject.RecordTypeId==>'+caseObject.RecordTypeId);
        if(caseObject.RecordTypeId == CSConstants.QUALITY_CLAIM_RT_ID)
        {
            caseObject.RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID;
            caseObject.Priority = 'Medium';
            //caseObject.Subject = caseNumber +':'+ 'Consumer Inquiry';
            if(obj.AdditionalInformation__c == null){
                caseObject.Subject = caseNumber +':'+ obj.Brand__c + ' - ' + obj.How_can_we_help__c + ' - ';
            } else
            {
                caseObject.Subject = caseNumber +':'+ obj.Brand__c + ' - ' + obj.How_can_we_help__c + ' - ' + obj.AdditionalInformation__c;
            }        
        }
        else if(caseObject.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID)
        {
            caseObject.RecordTypeId = CSConstants.QUALITY_CLAIM_RT_ID;
            caseObject.Subject= caseNumber + ':' + CSConstants.QUALITY_CLAIM;
            caseObject.How_can_we_help__c = 'Product or Packaging issue';
        }
        
        try
        {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            caseObject.setOptions(dmo);
            update caseObject;
        }
        Catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }

    @AuraEnabled 
    public static Case getCaseRecord(String recId){
        
       return ([SELECT Id, Case_Record_Type__c 
                 FROM Case 
                 WHERE Id =: recId]);
    }
    
    @AuraEnabled 
    public static void escalateCaseApex(Case obj, String recId, String recordTypeId){
        Case caseObject = obj;
        caseObject.Id = recId;
        caseObject.RecordTypeId = recordTypeId;
        
        ConsumerServices__c consumerServices = ConsumerServices__c.getInstance();
        String superAgentEmail;
        if(caseObject.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID){
            superAgentEmail = consumerServices.Agent_Email__c;
            User superAgent = [Select Id, Name from User where Email = :superAgentEmail limit 1];
            if(superAgent != null){
                caseObject.OwnerId = superAgent.Id;
                caseObject.IsEscalated = true;
            }
        }
        else{
            caseObject.IsEscalated = true; 
        }

        try {
            update caseObject;
        } catch(Exception e) {
            String errorMessage = 'Error updating case owner ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_CaseOwnerChange', 'updateStatus', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        
    }
    
    @AuraEnabled
    public static boolean isUserAccessibleForCloning(String recId, String currentUserEmail){
        
        ConsumerServices__c consumerServices = ConsumerServices__c.getInstance();
        String emailsAccessibleToClone = consumerServices.CloneCaseUserAccessEmail__c;
        Case cse = [SELECT RecordTypeId, Status FROM Case WHERE ID = :recId];
        if(cse.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID && cse.Status == EmailMessageConstants.CASE_STATUS_CLOSED){
            return emailsAccessibleToClone.containsIgnoreCase(currentUserEmail);    
        }
        return false;
    }
    
    @AuraEnabled
    public static void cloneCaseMethod(Case obj, String recId){
        
        Case caseObject = obj;
        caseObject.Id = recId;
        case closedCase = new case();
        List<Schema.fieldSetMember> fieldMemberToCloneCase = SObjectType.Case.FieldSets.getMap().get('FieldsToBeClonedFromClosedCase').getFields();
        String closedCasesQuery = 'SELECT Id, Bypass_Assignment_Rules__c';
        for(Schema.FieldSetMember fieldSetMember : fieldMemberToCloneCase) {
            closedCasesQuery += ', ' + fieldSetMember.getFieldPath();
        }
        closedCasesQuery += ' FROM case WHERE (Id =: recId)';
        closedCase = Database.query(closedCasesQuery);
        Case cloneCase = closedCase.clone(false, true, false, false);
        cloneCase.Status = EmailMessageConstants.CASE_STATUS_NEW;
        cloneCase.OwnerId = UserInfo.getUserId();
        cloneCase.Bypass_Assignment_Rules__c = true;
        cloneCase.ParentId = closedCase.Id;
        insert cloneCase;
    } 
}