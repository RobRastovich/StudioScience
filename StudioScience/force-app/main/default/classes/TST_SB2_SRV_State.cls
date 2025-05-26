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
    @date 18/04/2020
    @description This test class is created to test service method of region object.
*/
@IsTest(seeAllData = false)
public class TST_SB2_SRV_State {
    
    /**
    *  @description : This method is use to setup data for states.
    **/
    @TestSetup
    public static void prepareData(){
        Country__c country = new Country__c(Name = 'United States', Alias__c = 'US');
        insert country;
        List<Region__c> lstRegion = new List<Region__c>();
        for(Integer i = 0; i < 2; i++) {
            lstRegion.add(new Region__c(Name = 'Region ' + i, Country__c = country.Id));
        }
        insert lstRegion;
        List<State__c> lstState = new List<State__c>();
        Integer regionIndex = 0;
        for(Region__c region : lstRegion) {
            regionIndex++;
            for(Integer i = 0; i < 5; i++) {
                lstState.add(new State__c(
                    Name = 'State ' + i,
                    Country__c = country.Id,
                    region__c = region.Id,
                    Alias__c = 'S' + i + regionIndex,
                    State_Manager__c = UserInfo.getUserId()
                ));
            }
        }
        insert lstState;
    }
    
    /**
    *  @description : This method is use to test duplicate name on insert.
    **/
    @isTest
    public static void testStateNameDuplicateOnInsert() {
        Test.startTest();
        List<Region__c> lstRegion = [Select Id, Country__c From Region__c];
        List<State__c> lstState = new List<State__c>();
        for(Region__c region : lstRegion) {
            for(Integer i = 0; i < 2; i++) {
                lstState.add(new State__c(Name = 'State ' + i, Country__c = region.Country__c, Region__c = region.Id, Alias__c = 'S' + i));
            }
        }
        List<Database.SaveResult> insertResult = Database.insert(lstState, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(
                String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'state'}), 
                result.getErrors().get(0).getMessage()
            );
        }
    }
    
    /**
    *  @description : This method is use to test duplicate name on update.
    **/
    @IsTest
    public static void testStateNameDuplicateOnUpdate() {
        Test.startTest();
        List<State__c> lstState = [Select Id, Name From State__c Where Name = 'State 1' LIMIT 2 ];
        for(State__c state : lstState) {
            state.Name = 'State 2';
        }
        List<Database.SaveResult> updateResult = Database.update(lstState, false);
        Test.stopTest();
        
        for(Database.SaveResult result : updateResult) {
            system.assertEquals(
                String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'state'}), 
                result.getErrors().get(0).getMessage()
            );
        }
    }
    
    /**
    *  @description : This method is use to test that user not allowed to insert inactive state.
    **/
    @IsTest
    public static void testStateIsActive() {
        Test.startTest();
        
        Region__c region = [Select Id, Country__c From Region__c LIMIT 1];
        State__c state = new State__c();
        state.Name = 'xyz';
        state.Country__c = region.Country__c;
        state.Region__c = region.Id;
        state.IsActive__c = false;
        state.Alias__c = 'xy';
        Database.SaveResult insertResult = Database.insert(state, false);
        
        Test.stopTest();
        
        system.assertEquals(
            Label.SB2_State_Active_Message,
            insertResult.getErrors().get(0).getMessage()
        );
    }
    
    /**
    *  @description : This method is use to test that user not allowed to activate an inactive state.
    **/
    @IsTest
    public static void testActivateState() {
        Test.startTest();
        
        State__c state = [Select Id, IsActive__c From State__c LIMIT 1];
        state.IsActive__c = false;
        update state;
        state.IsActive__c = true;
        Database.SaveResult updateResult = Database.update(state, false);
        
        Test.stopTest();
        
        system.assertEquals(
            Label.SB2_State_Active_Inactive_Error_Message,
            updateResult.getErrors().get(0).getMessage()
        );
    }
    
    /**
    *  @description : This method is use to test the uniqueness of alias.
    **/
    @IsTest
    public static void testDuplicateAlias() {
        Test.startTest();
        
        State__c state = [Select Id, Alias__c, State_Manager__c, IsActive__c, Region__c, Country__c From State__c LIMIT 1];
        State__c stateToInsert = state.clone(false, false, false, false);
        stateToInsert.Name = 'Test State';
        Database.SaveResult insertResult = Database.insert(stateToInsert, false);
        
        Test.stopTest();
        
        system.assertEquals(
            Label.SB2_Duplicate_Alias_Error,
            insertResult.getErrors().get(0).getMessage()
        );
    }
}