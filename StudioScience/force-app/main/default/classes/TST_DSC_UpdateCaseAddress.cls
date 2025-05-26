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
    @description This test class is created to test CNT_SendSurveyEmail class.
*/
@isTest(SeeAllData = false)
public class TST_DSC_UpdateCaseAddress {
    
    static Account accObj;
    /**
    *  @description : This method is use setup data for test cases.
    **/    
    public static void prepareData(){
        accObj= new Account(
            FirstName = 'First',
            LastName='testAddress',
            PersonEmail = 'testaddress@test.com',
            Recordtypeid=CSConstants.CONSUMER_ACCOUNT_RT_ID,
            PersonMailingCountry = 'Country ABC'
        );
        insert accObj;
        
        List<Contact> conObj = [SELECT Id FROM Contact WHERE email= :accObj.PersonEmail];
        Id conId;
        if(conObj.size() > 0) {
            conId = conObj[0].Id;
        }
        
        List<Case> lstcases = new List<Case>();
        for(Integer i=0; i<1; i++){
            //Consumer Inquiry Cases
            lstcases.add(new Case(
                How_can_we_help__c= 'Where to Buy Product',
                Brand__c = 'Jim Beam',
                RecordTypeId= CSConstants.CONSUMER_INQUIRY_RT_ID,
                accountId= accObj.Id,
                contactId = conId
            )
                        );
            
            //Quality Claim cases
            lstcases.add(new Case(
                How_can_we_help__c= 'Product or Packaging issue',
                Brand__c = 'Jim Beam',
                RecordTypeId= CSConstants.QC_RT_ID,
                accountId= accObj.Id,
                contactId = conId
            )
                        );
        }
        insert lstcases;
        
        //Update account with all address details
        accObj.personMailingCountry = 'Country ABC';
        accObj.personMailingStreet = 'Street ABC';
        accObj.personMailingCity = 'City ABC';
        accObj.personMailingPostalCode = 'Postal Code ABC123';
        accObj.personMailingState = 'State';
        
        update accObj;    
    }
    
    
    /**
    *  @description : This method is use to test if cases address fields are updated with account address details
    **/
    @IsTest
    public static void testUpdateCaseAddress() {
        prepareData();

        Test.startTest();
        BCH_DSC_UpdateCaseAddress objClass = new BCH_DSC_UpdateCaseAddress();
        try {
            Database.executeBatch (objClass);
        } catch (exception e) {
            System.debug(e.getMessage());  
        }
        Test.stopTest();
        
        List<Case> caseList = [SELECT id, accountId, How_can_we_help__c, RecordTypeId, RecordType.name,Consumer_Country__c, Consumer_Street__c, Consumer_City__c, Consumer_Postal_Code__c, Consumer_State__c FROM Case WHERE accountId =: accObj.Id];
        
        for(Case caseObj : caseList){
            System.assertEquals(caseObj.Consumer_Country__c, accObj.personMailingCountry);
            System.assertEquals(caseObj.Consumer_Street__c, accObj.personMailingStreet);
            System.assertEquals(caseObj.Consumer_City__c, accObj.personMailingCity);
            System.assertEquals(caseObj.Consumer_Postal_Code__c, accObj.personMailingPostalCode);
            System.assertEquals(caseObj.Consumer_State__c, accObj.personMailingState);
        }    
    }   
}