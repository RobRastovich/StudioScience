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
    @date 04 Jun 2020
    @description This class is used change send survey link email on Record Detail Page.
*/
public class CNT_SendSurveyEmail {
    /**
    *  @description : This method is used to send survey email to consumer.
    *  @args        : String brand
    *  @return      : void
    **/
	@AuraEnabled 
    public static List<SurveyInvitation> sendEmail(Case obj,String recId){
        Case caseObject = obj;
        caseObject.Id = recId;
        /** Metacube Added for SAL-1534 **/
        //Step-1 find out all surveyInvitations with same Submitter as this case
        //Step-2 surveyInvitations with case having record type as 'Changes' and 'Escalated Form'
        //Step-3 surveyInvitations with date greater than 30 days from creation date
        System.debug('SubmitterEmail'+ obj.Submitter__r.Email);
        List<String> caseRecordTypeList = new List<String>();
        caseRecordTypeList.add(CSConstants.ESCALATED_FORM);
        caseRecordTypeList.add(CSConstants.CHANGES);
        try {
            
            List<SurveyInvitation> csSurveyInvitations = [SELECT id, Case__c, Email__c, ParticipantId, CreatedDate, Case__r.Send_Survey_Link__c
                                                          FROM SurveyInvitation WHERE 
                                                          Case__r.RecordType.DeveloperName IN: caseRecordTypeList
                                                          AND (Email__c =: caseObject.Submitter__r.Email OR Email__c =: caseObject.ContactEmail OR Email__c =: caseObject.SuppliedEmail)
                                                          AND CreatedDate >= LAST_N_DAYS:30 //Uncomment this before moving to production
                                                          //AND CreatedDate >=: System.Now().addHours(-1) //This is for testing purpose Comment this before moving to production
                                                          ORDER BY CreatedDate DESC LIMIT 1];
            
            if(csSurveyInvitations.size() != 0){
                System.debug('Survey Invitation is already been sent!');
                return csSurveyInvitations;
            }
            else{
                caseObject.Send_Survey_Link__c = true;
            }
        /** End SAL-1534 **/
            System.debug('case object:'+ caseObject);
            
            if(caseObject != null) {
                update caseObject;
            }
        } catch(Exception e) {
        	String errorMessage = 'Error sending survey email ' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug('CNT_SendSurveyEmail'+ 'sendEmail'+ String.valueOf(errorMessage)+ 'Fatal');
            CreateExceptionLog.insertErrorLog('CNT_SendSurveyEmail', 'sendEmail', String.valueOf(errorMessage), 'Fatal');
            // throw so that we can detect issues before deploying
            if (Test.isRunningTest()) {
                throw new CS_CustomException(e.getMessage());
            }
        }
        return null;
    }
}