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
    @date 17/04/2020
    @description This test class is to test CNT_SB_ManageBrand Controller .
*/
@IsTest(seeAllData = false)
public class TST_TGR_SB2_Brand {

    /**
    *  @description : This method is use to test successfull insertion of Brand Allocation
    **/
    @isTest
    public static void testBrandSuccessInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = New List<Brand__c>();
        Brand__c newBrand = new Brand__c();
        newBrand.Name = 'Test';
        newBrand.Is_Active__c = true;
        lstBrand.add(newBrand);
        List<Database.SaveResult> insertResult = Database.insert(lstBrand, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(true,result.isSuccess());
        }
    }
    
    /**
    *  @description : This method is use to test Brand Insertion for duplicate record
    **/
    @isTest
    public static void testBrandFailureInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = New List<Brand__c>();
        Brand__c newBrand = new Brand__c();
        newBrand.Name = 'Test';
        newBrand.Is_Active__c = true;
        insert newBrand;
        Brand__c newBrand1 = new Brand__c();
        newBrand1.Name = 'Test';
        newBrand1.Is_Active__c = true;
        lstBrand.add(newBrand1);
        List<Database.SaveResult> insertResult = Database.insert(lstBrand, false);
        Test.stopTest();
        
        for(Database.SaveResult result : insertResult) {
            system.assertEquals(Label.SB2_Brand_Duplicate_Error,result.getErrors().get(0).getMessage());
        }
    }
    
    /**
    *  @description : This method is use to test Brand Insertion for duplicate record
    **/
    @isTest
    public static void testBrandInActiveInsert() {
        Test.startTest();
        List<Brand__c> lstBrand = New List<Brand__c>();
        Brand__c newBrand = new Brand__c();
        newBrand.Name = 'Test';
        newBrand.Is_Active__c = true;
        insert newBrand;
		Brand_Allocation__c brandAllocation = new Brand_Allocation__c(Brand__c = newBrand.Id, Program_Type__c = 'Sample Kit',
        Time_Period__c = 'Monthly', Time_Interval__c = 'April', Year_Of_Allocation__c = '2020');
        insert brandAllocation;
        newBrand.Is_Active__c = false;
        update newBrand;
        Test.stopTest();
        
		List<Brand_Allocation__c> lstBrandAllocation = [Select Id, Is_Active__c From Brand_Allocation__c where Brand__c =: newBrand.Id];
        System.assertEquals(false, lstBrandAllocation.isEmpty(), 'results are fetched');
        System.assertEquals(false, lstBrandAllocation[0].Is_Active__c, 'Brand Allocation is also deactivated');
    }
    
    @isTest
    public static void testGetErrorMessage() {
        Test.startTest();
        	UTL_String.getErrorMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION test');
        	UTL_String.getErrorMessage('FIELD_FILTER_VALIDATION_EXCEPTION test');
        	UTL_String.getErrorMessage('');
        	UTL_String.getErrorMessage('DUPLICATE_VALUE duplicate value found: test_test__c id:');
        Test.stopTest();
    }
}