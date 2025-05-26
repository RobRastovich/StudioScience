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
public class TST_SB2_SRV_Region {
    
    /**
    *  @description : This method is use to setup data for regions.
    **/
    @TestSetup
    public static void prepareData() {
        List<Country__c> lstCountry = new List<Country__c>();
        lstCountry.add(new Country__c(Name = 'United States', Alias__c = 'UK'));
        lstCountry.add(new Country__c(Name = 'United Kingdom', Alias__c = 'US'));
        insert lstCountry;
        List<Region__c> lstRegion = new List<Region__c>();
        for(Country__c country : lstCountry) {
            for(Integer i = 0; i < 5; i++) {
                lstRegion.add(new Region__c(Name = 'Region ' + i, Country__c = country.Id));
            }
        }
        insert lstRegion;
    }
    
    /**
    *  @description : This method is use to test duplicate name on insert.
    **/
    @IsTest
    public static void testRegionNameDuplicateOnInsert() {
        Test.startTest();
        List<Country__c> lstCountry = [Select Id From Country__c];
        List<Region__c> lstRegion = new List<Region__c>();
        for(Country__c country : lstCountry) {
            for(Integer i = 0; i < 2; i++) {
                lstRegion.add(new Region__c(Name = 'Region ' + i, Country__c = country.Id));
            }
        }
        List<Database.SaveResult> insertResult = Database.insert(lstRegion, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(
                String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'region'}), 
                result.getErrors().get(0).getMessage()
            );
        }
    }
    
    /**
    *  @description : This method is use to test duplicate name on update.
    **/
    @IsTest
    public static void testRegionNameDuplicateOnUpdate() {
        Test.startTest();
        List<Region__c> lstRegion = [Select Id, Name From Region__c Where Name = 'Region 1' LIMIT 2 ];
        for(Region__c region : lstRegion) {
            region.Name = 'Region 2';
        }
        List<Database.SaveResult> updateResult = Database.update(lstRegion, false);
        Test.stopTest();
        
        for(Database.SaveResult result : updateResult) {
            system.assertEquals(
                String.format(Label.SB2_Duplicate_Record_Error, new List<Object> {'region'}), 
                result.getErrors().get(0).getMessage()
            );
        }
    }
    
}