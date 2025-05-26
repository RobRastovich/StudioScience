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
    @date 17 Feb 2022
    @description This test class is to test SLT_DTC_CustomMetadata.
*/
@isTest(SeeAllData = false)
public class TST_SLT_DTC_CustomMetadata {

    @testSetup
    static void setUpTestData() {    
        Case newCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, true);
        Case getManageStatusRecordsCase = TST_TestDataFactory.createCase(DTC_Constants.CASE_DTC_RECORDTYPEID, false);
        getManageStatusRecordsCase.Status = 'New';
        getManageStatusRecordsCase.OrderID__c = 'test0619';
        getManageStatusRecordsCase.How_can_we_help__c = 'Whisky Drop – Membership Program';
        getManageStatusRecordsCase.AdditionalInformation__c = 'Other';
        insert getManageStatusRecordsCase;
    }
    
    @isTest
    private static void testCheckStatusFlowOfCaseStatusDTC() {
        Case newCase = [SELECT Id, AdditionalInformation__c FROM CASE LIMIT 1];
        Set<String> types = new Set<String>{newCase.AdditionalInformation__c};
        List<DTC_Status_Flow__mdt> dtcSFList = new List<DTC_Status_Flow__mdt>();

        Test.startTest();
            dtcSFList = SLT_DTC_CustomMetadata.getCaseStatusFlowDTC(types);
        Test.stopTest();

        System.assertNotEquals(null, dtcSFList , 'No Records returned when expected');
    }

    @isTest
    private static void testGetManageStatusRecords() {
        Case newCase = [SELECT Id, How_can_we_help__c, AdditionalInformation__c 
                           FROM CASE 
                           WHERE How_can_we_help__c = 'Whisky Drop – Membership Program'];
        Set<String> types = new Set<String>{newCase.AdditionalInformation__c};
        List<DTC_Manage_Status__mdt> statusList = new List<DTC_Manage_Status__mdt>();

        Test.startTest();
            statusList = SLT_DTC_CustomMetadata.getManageStatusRecords(types, newCase.How_can_we_help__c);
        Test.stopTest();

        System.assertNotEquals(null, statusList , 'No Records returned when expected');
    }
    
    @isTest
    private static void testGetTrackTypeList(){
    	
        Test.startTest();
        	Map<String, String> mapOfCodeAndDescription = SLT_DTC_CustomMetadata.getTrackTypeList();
        Test.stopTest();
        
        System.assertEquals(mapOfCodeAndDescription.get('TForce_D'), 'Delivered');
    }
}