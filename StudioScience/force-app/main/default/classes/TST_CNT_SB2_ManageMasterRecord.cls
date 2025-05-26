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
    @description This test class is created to test CNT_SB2_ManageMasterRecord.
*/
@IsTest(seeAllData = false)
public class TST_CNT_SB2_ManageMasterRecord {
    
    public static Country__c country;
    public static List<Region__c> lstRegion;
    /**
    *  @description : This method is use to setup data for states.
    **/
    public static void prepareData() {
        country = TST_SB2_MasterDataFactory.createCountry();
        lstRegion = TST_SB2_MasterDataFactory.createRegion(country);
    }
    
    /**
    *  @description : This method is use to test createstate method.
    **/
    @isTest
    public static void testCreateState() {
        prepareData();
        Test.startTest();
        
        State__c state = new State__c();
        state.Country__c = country.Id;
        state.Region__c = lstRegion[0].Id;
        state.Name = 'New York';
        state.Alias__c = 'NY';
        state.State_Manager__c = UserInfo.getUserId();
        
        Map<String, Object> returnValue = CNT_SB2_ManageMasterRecord.createState(state);

        Test.stopTest();

        System.assert(returnValue.containsKey('Id') && returnValue.get('Id') != null);
    }
    
    /**
    *  @description : This method is use to test create state exception.
    **/
    @isTest
    public static void testCreateStateException() {
        prepareData();
        try {
            Test.startTest();
        
            State__c state = new State__c();
            state.Country__c = country.Id;
            state.Region__c = lstRegion[0].Id;
            state.Name = 'New York';
            
            Map<String, Object> returnValue = CNT_SB2_ManageMasterRecord.createState(state);
    
            Test.stopTest();
        } catch(Exception e) {
         	System.assert(String.isNotBlank(e.getMessage()));   
        }
    }
    
    
    
}