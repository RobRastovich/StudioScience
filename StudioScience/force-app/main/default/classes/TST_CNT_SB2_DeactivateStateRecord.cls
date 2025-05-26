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
    @date 26/04/2020
    @description This test class is created to test CNT_SB2_DeactivateStateRecord.
*/
@IsTest(seeAllData = false)
public class TST_CNT_SB2_DeactivateStateRecord {

    /**
    *  @description : This method is use to setup data for states.
    **/
    @TestSetup
    public static void prepareData() {
        Brand__c brand = new Brand__c(Name = 'Jim Beam');
        insert brand;
        Country__c country = new Country__c(Name = 'United States', Alias__c = 'US');
        insert country;
        Region__c region = new Region__c(Name = 'Region', Country__c = country.Id);
        insert region;
        State__c state = new State__c(Name = 'State', Country__c = country.Id, Region__c = region.Id, Alias__c = 'ST', State_Manager__c = UserInfo.getUserId());
        insert state;
        Brand_Allocation__c brandAllocation = TST_SB2_MasterDataFactory.createBrandAlloc(brand.Id, 'Sample Kit', '2020', 'Monthly', 'June');
        insert brandAllocation;
		Brand_Country_Allocation__c countryAllocation = TST_SB2_MasterDataFactory.createBrandCountryAlloc(brandAllocation.Id, country.Id, false, 0);
        insert countryAllocation;
        Brand_Country_Region_Allocation__c regionAllocation = TST_SB2_MasterDataFactory.createBrandCountryRegionAlloc(countryAllocation.Id, region.Id, false, 0);
        insert regionAllocation;
		Brand_Country_Region_State_Allocation__c stateAllocation = TST_SB2_MasterDataFactory.createBrandCountryRegionStateAlloc(regionAllocation.Id, state.Id, false, 0);
		insert stateAllocation;
        List<Account> lstDistributor = TST_SB2_MasterDataFactory.createDistributorAccount(1);
        Brand_Country_Region_State_Dist_Alloc__c distributorAllocation = TST_SB2_MasterDataFactory.createBrandCountryRegionStateDistAlloc(stateAllocation.Id, lstDistributor[0].Id, TRUE, 5);
        insert distributorAllocation;
    }

    /**
    *  @description : This method is use to test record is deactivated.
    **/
    @IsTest
    public static void testDeactivateRecord() {
        Test.startTest();
        
        State__c state = [Select Id, IsActive__c From State__c Where Name = 'State' LIMIT 1];
        State__c deactivatedState = CNT_SB2_DeactivateStateRecord.deactivateRecord(state.Id);
        
        Test.stopTest();
        
        System.assertEquals(false, deactivatedState.IsActive__c);
    }

    /**
    *  @description : This method is use to test exception scenario.
    **/
    @IsTest
    public static void testDeactivateRecordException() {
        try{
            Test.startTest();
            State__c state = [Select Id, IsActive__c From State__c Where Name = 'State' LIMIT 1];
            State__c deactivatedState = CNT_SB2_DeactivateStateRecord.deactivateRecord(state.Id + 'abcd');
            Test.stopTest();
        } catch (Exception e) {
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void testGetAccountByEmail(){
            Test.startTest();
            	List<Account> result = SLT_Account.getAccountByEmail('test@test.com');
            Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(),'Account record is fetched');
    }
    
    @isTest
    public static void testGetAccountsByStateCountryRecordType(){
        Test.startTest();
        List<Account> result = SLT_Account.getAccountsByStateCountryRecordType(CSConstants.DEFAULT_ACCOUNT_RT_ID, new Set<String>{'IL'}, new Set<String>{'USA'});
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(), 'account is fetched');
    }
    
    @isTest
    public static void testGetCasesInLastDaysForParticularUser(){
        Test.startTest();
        	List<Case> result = SLT_Case.getCasesInLastDaysForParticularUser(0, '50017000009SloLAAS', 'test@sdff.sd', 'sdf', 'sd','asd',
                                                                            'sdf','sdf',date.today(), 0);
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(),'cases are fetched');
    }
    
    @isTest
    public static void testGetCaseByEmailOrAddress(){
        Test.startTest();
        	List<Case> result = SLT_Case.getCaseByEmailOrAddress('50017000009SloLAAS', 'email@sdf', 'country', 'state', 'city', 'postalCode', 'street');
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(),'Cases are fetched');
    }
}