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
	@date 25/01/2021
	@description This batch is used to update PR details on Vendor
*/
public class BCH_PR_UpdateVendorPRDetails implements Database.Batchable<sObject>, Schedulable {
    //current and previous year
    public final String CURRENT_YEAR = String.valueOf(Date.Today().Year());
    public final String PREVIOUS_YEAR = String.valueOf(Date.Today().Year() - 1);
    //PR status which will be added in PR amount
    public final List<String> ACCEPTABLE_PR_STATUSES = new List<String>{'Submitted', 'Approved By Procurement', 'Approved By Finance', 'Completed'};
    //send email after batch run
    public String [] email = new String[] {'SFDC@BeamSuntory.com'};
        
    //set limit via constructor
    public Integer setLimit = 0;
    //pass specific ids
    public List<String> specifiedIds = new List<String>();
    
    public Decimal currentYearPrAmount = 0;
    public Decimal previousYearPrAmount = 0;
    
    //default batch constructor
    public BCH_PR_UpdateVendorPRDetails() {
        
    }
    
    //To set limit or for specific ids
    public BCH_PR_UpdateVendorPRDetails(Integer setLimit, List<String> specifiedIds) {
        this.setLimit = setLimit;
        this.specifiedIds = specifiedIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Name, Total_PR_amount_Current_year__c, PRs_Over_50K_Current_year__c, PRs_Over_50K_Previous_year__c,'
            + ' (SELECT Id, Status__c, PR_Year__c, Total_PR_Amount_USD__c FROM PR_Headers__r'
            + ' WHERE (PR_Year__c =:CURRENT_YEAR OR PR_Year__c = :PREVIOUS_YEAR) AND Status__c IN :ACCEPTABLE_PR_STATUSES)'
            + ' FROM Account WHERE RecordType.Name = \'Vendor\' AND SAP_Vendor_ID__c != null';
        
        if(specifiedIds != null && specifiedIds.size() > 0) {
            query += ' AND Id IN :specifiedIds';
        }
        if(setLimit != 0) {
            query += ' LIMIT :setLimit';
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> records){
        List<Account> accountsToUpdate = new List<Account>();
        for(Account a : records) {
            currentYearPrAmount = 0;
            previousYearPrAmount = 0;
            
            for(PR_Header__c p : a.PR_Headers__r) {
                if(p.PR_Year__c == CURRENT_YEAR) {
                    currentYearPrAmount += p.Total_PR_Amount_USD__c;
                } else if(p.PR_Year__c == PREVIOUS_YEAR) {
                    previousYearPrAmount += p.Total_PR_Amount_USD__c;
                }
            }
            a.Total_PR_amount_Current_year__c = currentYearPrAmount;
            a.PRs_Over_50K_Current_year__c = currentYearPrAmount >=50000;
            a.PRs_Over_50K_Previous_year__c = previousYearPrAmount >=50000;
            accountsToUpdate.add(a);
        }
        update accountsToUpdate;
    }
    
    //send mail on finish
    public void finish(Database.BatchableContext BC){
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
		mail.setSubject('Batch BCH_PR_UpdateVendorPRDetails Processing '+ job.Status);
		mail.setPlainTextBody('The Batch Apex job BCH_PR_UpdateVendorPRDetails processed '
								+ job.TotalJobItems+' batches with '+ job.NumberOfErrors +' failures. Job Item processed are ' + job.JobItemsProcessed);
	  	Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});  
    }
    
    //Schedulable execute
    public void execute(System.SchedulableContext SC) {
        BCH_PR_UpdateVendorPRDetails b = new BCH_PR_UpdateVendorPRDetails();
        database.executebatch(b,200);
    }
    
}