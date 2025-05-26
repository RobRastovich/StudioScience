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
    @date 04/05/2020
    @description This test class is created to test CNT_SB2_CreateAllocationRecord.
*/
@isTest(seeAllData = false)
public class TST_CNT_SB2_DynamicPicklistController {
        /**
    *  @description : This method is use to setup data for custom setting.
    **/
    @TestSetup
    public static void dataSetup(){
        List<Brand__c> lstBrand = new List<brand__c>();
        Brand__c newBrand = new Brand__c(Name = 'Test1',Is_Active__c = true);
        lstBrand.add(newBrand);
        insert lstBrand;
    }
    /**
    *  @description : This method is use to create brand country allocation.
    **/
    @isTest
    public static void testGetPicklistOptionsForBrand() {
        Test.startTest();
        	List<String> result = CNT_SB2_DynamicPicklistController.getPicklistOptions('Brand_Allocation__c', 'Brand__c');
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Brand Picklist is being fetched');
    }
    
    /**
    *  @description : This method is use to create brand country allocation.
    **/
    @isTest
    public static void testGetPicklistOptionsForYearOfAlloc() {
        Test.startTest();
        	List<String> result = CNT_SB2_DynamicPicklistController.getPicklistOptions('Brand_Allocation__c', 'Year_Of_Allocation__c');
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Brand Picklist is being fetched');
    }
    
    /**
    *  @description : This method is use to create brand country allocation.
    **/
    @isTest
    public static void testGetPicklistOptionsForStatus() {
        Test.startTest();
        	List<String> result = CNT_SB2_DynamicPicklistController.getPicklistOptions('Brand_Allocation__c', 'Status__c');
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Brand Picklist is being fetched');
    }
}