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
	@date 28/04/2020
	@description This batch is used to put address details on case from account
*/
global class BCH_DSC_UpdateCaseAddress implements Database.Batchable<sObject>, Database.Stateful {

	global String [] email = new String[] {'shobhit.bhatnagar@metacube.com', 'chirag.jain@metacube.com', 'saurabh.gupta1@metacube.com'};
		
	/**
	*  @description : This method is called at the starting of a batch job to collect the data on which the batch job will be operating.
	*  @args        : Database.BatchableContext bc
	*  @return      : Database.getQueryLocator
	**/
	global Database.QueryLocator start(Database.BatchableContext bc){
	   Set<Id> acceptedCaseRecordTypeIds = new Set<Id>();
	   acceptedCaseRecordTypeIds.add(CSConstants.CONSUMER_INQUIRY_RT_ID);
	   acceptedCaseRecordTypeIds.add(CSConstants.QC_RT_ID);
		
		String query = 'Select id, Account.name, Account.PersonMailingCountry,'+
				' Account.PersonMailingStreet, Account.PersonMailingCity, Account.PersonMailingPostalCode, Account.PersonMailingState,'+
				' Consumer_Country__c, Consumer_Street__c, Consumer_City__c, Consumer_Postal_Code__c, Consumer_State__c FROM Case'+
				' WHERE (account.RecordTypeID =\''+ CSConstants.CONSUMER_ACCOUNT_RT_ID +'\'' + ' AND RecordTypeID IN :acceptedCaseRecordTypeIds)' +
				' AND( (Consumer_Country__c = null AND account.PersonMailingCountry != null)'+
				' OR (Consumer_Street__c = null AND account.PersonMailingStreet != null)'+
				' OR (Consumer_City__c = null AND account.PersonMailingCity != null)'+
				' OR (Consumer_Postal_Code__c = null AND account.PersonMailingPostalCode != null)'+
				' OR (Consumer_State__c = null AND account.PersonMailingState != null) )';
		return Database.getQueryLocator(query);
	}
	
	/**
	*  @description : This method executes after the Start method, and it does the actual processing for each batch, separately.
	*  @args        : Database.BatchableContext bc, List<Case> lstCase
	*  @return      : void
	**/
	global void execute(Database.BatchableContext bc, List<Case> lstCase){
		List<Case> cases = new List<Case>();
		Boolean recordUpdated = false;
		for(Case caseInfo : lstCase){
			recordUpdated = false;
			if(caseInfo.Consumer_Country__c == null) {
				caseInfo.Consumer_Country__c = caseInfo.account.personMailingCountry;
				recordUpdated = true;
			}
			if(caseInfo.Consumer_Street__c == null) {
				caseInfo.Consumer_Street__c = caseInfo.account.personMailingStreet;
				recordUpdated = true;
			}
			if(caseInfo.Consumer_City__c == null) {
				caseInfo.Consumer_City__c = caseInfo.account.personMailingCity;
				recordUpdated = true;
			}
			if(caseInfo.Consumer_Postal_Code__c == null) {
				caseInfo.Consumer_Postal_Code__c = caseInfo.account.personMailingPostalCode;
				recordUpdated = true;
			}
			if(caseInfo.Consumer_State__c == null) {
				caseInfo.Consumer_State__c = caseInfo.account.personMailingState;
				recordUpdated = true;
			}
			if(recordUpdated) {
				cases.add(caseInfo);
			}
		}
		
		try {
			if(cases.size() > 0) {
			// Update the Case Record
			update cases;
			}
		} catch(Exception e) {
			String errorMessage = 'Error updating case address details ' + e.getMessage() + '\n' + e.getStackTraceString();
			CreateExceptionLog.insertErrorLog('BCH_UpdateCaseAddress', 'execute', String.valueOf(errorMessage), 'Fatal');
			// throw so that we can detect issues before deploying
			if (Test.isRunningTest()) {
				throw new CS_CustomException(e.getMessage());
			}
		}
		
	}
	
	/**
	*  @description : This method will be called at last. It is responsible to perform post-processing operations such as sending an email.
	* 					When this process is called all batches are already executed.
	*  @args        : Database.BatchableContext bc
	*  @return      : void
	**/
	global void finish(Database.BatchableContext bc){
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Below code will fetch the job Id
		AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
			JobItemsProcessed,
			TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob
			WHERE Id = :bc.getJobId()];
			   
		// call some utility to send email
		mail.setToAddresses(email);
		mail.setSenderDisplayName('Apex Batch Processing Module');
		mail.setSubject('Batch Processing '+ job.Status);
		mail.setPlainTextBody('The Batch Apex job processed '
								+ job.TotalJobItems+' batches with '+ job.NumberOfErrors+' failures'+' Job Item processed are ' + job.JobItemsProcessed);
	  	Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});   
		
	}
}