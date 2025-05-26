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
    @date 17/02/2020
    @description This test class is created to test service method.
*/
@IsTest(seeAllData = false)
public class TST_CaseServices {
    
    /**
    *  @description : This method is use setup data for test cases.
    **/
    @TestSetup
    public static void makeData() {
        List<TriggerWords__c> lstTriggerWord = new List<TriggerWords__c>();
        lstTriggerWord.add(new TriggerWords__c(Name='Cut', Priority__c='Critical', Type__c='Complaint', Status__c='Active'));
        lstTriggerWord.add(new TriggerWords__c(Name='Urgent', Priority__c='High', Type__c='Complaint', Status__c='Active'));
        lstTriggerWord.add(new TriggerWords__c(Name='Nutritional Information', Priority__c='High', Type__c='Inquiry', Status__c='Active'));
        lstTriggerWord.add(new TriggerWords__c(Name='test', Priority__c='Low', Type__c='Inquiry', Status__c='Active'));
        insert lstTriggerWord;
        List<Case> lstCase = new List<Case>();
        Account acc = new Account();
        acc.FirstName = 'First';
        acc.LastName = 'Last';
        acc.PersonEmail = 'test@test.com';
        acc.RecordTypeId = CSConstants.CONSUMER_ACCOUNT_RT_ID;
        acc.PersonMailingCity = 'Jaipur';
        acc.PersonMailingState = 'Niwaroo';
        acc.PersonMailingCountry = 'India';
        acc.PersonMailingPostalCode = '302012';
        acc.PersonMailingStreet = 'Idk';
        acc.Phone = '9876543210';
        insert acc; 
        Id personContactId = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id].PersonContactId;
        
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'I got cut', Brand__c = 'Jim Beam', How_can_we_help__c = 'Where to Buy Product', Product_Type__c = 'BLACK', Subject = 'Case 1'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'urgent requirement', Brand__c = 'Jim Beam', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = 'APPLE', Subject = 'Case 2'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'I want nutritional information', Brand__c = 'Jim Beam', How_can_we_help__c = 'Where to Buy Product', Product_Type__c = 'BLACK', Subject = 'Case 3'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'test', Brand__c = 'Jim Beam', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = 'APPLE', Subject = 'Case 4'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'I want to tour distillery by today', Brand__c = 'Jim Beam', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = 'APPLE', Subject = 'Case 5'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'I want to tour distillery by tomorrow', Brand__c = 'Jim Beam', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = 'APPLE', Subject = 'Case 6'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'I want to tour distillery by this week', Brand__c = 'Jim Beam', How_can_we_help__c = 'Visiting the Distillery', Product_Type__c = 'APPLE', Subject = 'Case 7'));
	    lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'without trigger word', Brand__c = 'Jim Beam', How_can_we_help__c = 'Sponsorship or Charity', AdditionalInformation__c = 'Other', Product_Type__c = 'APPLE', Subject = 'Case 8'));
        lstCase.add(new Case(Origin = 'Web', ContactId = personContactId, RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID, Description = 'without trigger word test', Brand__c = 'Jim Beam', How_can_we_help__c = 'PR or Media Inquiry', Product_Type__c = 'APPLE', Subject = 'Case 9'));
        
        insert lstCase;
    }
    
    /**
    *  @description : This method is use to test case priority on the basis of trigger word
    **/
    @isTest
    public static void testSetCasePriority(){
        List<Case> lstCase = [Select Id, Priority, Description, Subject, Product_Type__c From Case];
        Map<String,Case> casesInserted = new Map<String,Case>();
        for(Case caseInstance : lstCase){
            casesInserted.put(caseInstance.Description,caseInstance);
        }
        System.assertEquals('Critical', casesInserted.get('I got cut').Priority);
        System.assertEquals('High', casesInserted.get('urgent requirement').Priority);
        System.assertEquals('High', casesInserted.get('I want nutritional information').Priority);
        System.assertEquals('Low', casesInserted.get('test').Priority);
        System.assertEquals('High', casesInserted.get('I want to tour distillery by today').Priority);
        System.assertEquals('High', casesInserted.get('I want to tour distillery by tomorrow').Priority);
        System.assertEquals('High', casesInserted.get('I want to tour distillery by this week').Priority);
        System.assertEquals('Low', casesInserted.get('without trigger word').Priority);
        System.assertEquals('Low', casesInserted.get('without trigger word test').Priority);
    }
    
}