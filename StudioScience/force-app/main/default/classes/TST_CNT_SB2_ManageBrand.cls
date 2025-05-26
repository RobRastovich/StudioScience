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
public class TST_CNT_SB2_ManageBrand {
    
    /**
    *  @description : This method is use to setup data for custom setting.
    **/
    @TestSetup
    public static void dataSetup(){
        List<Brand__c> lstBrand = new List<brand__c>();
        Brand__c newBrand = new Brand__c(Name = 'Test1',Is_Active__c = true);
        lstBrand.add(newBrand);
        insert lstBrand;
        List<Brand_Allocation__c> lstBrandAlloc = new List<Brand_Allocation__c>{
            TST_SB2_MasterDataFactory.createBrandAlloc(lstBrand[0].Id, 'Sample Kit','2019', 'Monthly', 'June'),
            TST_SB2_MasterDataFactory.createBrandAlloc(lstBrand[0].Id, 'Sample Kit','2019', 'Monthly', 'July')};
                lstBrandAlloc[0].Is_Carry_Forward__c = true;   
        insert lstBrandAlloc;
    }
    
    /**
    *  @description : This method is use to test GetBrandAllocation() to get result.
    **/
    @isTest
    public static void testGetBrandAllocation(){
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
		Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        
        List<Brand_Allocation__c> result = CNT_SB2_ManageBrand.getBrandAllocation(lstBrandAllocation[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'result is fetched');
    }
    
    /**
    *  @description : This method is use to test updateBrandAllocation() to deactivate Brand Allocation
    **/
    @isTest
    public static void testUpdateBrandAllocation(){
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
		Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        
        Brand_Allocation__c result = CNT_SB2_ManageBrand.updateAllocation(lstBrandAllocation[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, result.Is_Active__c, 'result is updated');
    }

    /**
    *  @description : This method is use to test zcloneBrandAllocation() to Clone Brand Allocation
    **/    
    @isTest
    public static void testCloneBrandAllocation(){
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        
        Brand_Allocation__c result = CNT_SB2_ManageBrand.cloneBrandAllocation(String.valueOf(lstBrand[0].Id), 'true', 'Sample Kit', 
                                                           'Monthly', 'April', '2020');
        Test.stopTest();
        
        System.assertEquals(true, result.Is_Active__c, 'result is updated');
    }
    
    /**
    *  @description : This method is use to test CloneBrandAllocation() to clone with same values
    **/
    @isTest
    public static void testCloneNotAllowedBrandAllocation(){
        Test.startTest();
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        List<Brand_Allocation__c> lstBrandAllocation = new List<Brand_Allocation__c>();
		Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = 'April';
        brandAllocation.Year_Of_Allocation__c = '2020';
        lstBrandAllocation.add(brandAllocation);
        List<Database.SaveResult> insertResult = Database.insert(lstBrandAllocation, false);
        try{
            Brand_Allocation__c result = CNT_SB2_ManageBrand.cloneBrandAllocation(String.valueOf(lstBrand[0].Id), 'true', 'Sample Kit', 
                                                           'Monthly', 'April', '2020');
        }catch(exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test dependent picklist values
    **/
    @isTest
    public static void testGetDependentMap(){

        Test.startTest();
        	Map<String, List<String>> result = CNT_SB2_ManageBrand.getDependentMap(Schema.getGlobalDescribe().get('Brand_Allocation__C').newSObject() , 'Time_Period__c', 'Time_Interval__c');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Result is fetched');
        
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testGetPicklistvalues(){
        Test.startTest();
        	List<String> result = CNT_SB2_ManageBrand.getPicklistvalues('Brand_Allocation__c', 'Year_Of_Allocation__c', true);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testValidateBrandAllocation(){
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = 'Monthly';
        brandAllocation.Time_Interval__c = SB2_Constants.mapOfIntegerMonth.get(Date.today().month());
        brandAllocation.Year_Of_Allocation__c = String.valueOf(Date.today().year());
        
        Test.startTest();
        	LightningComponentUtility.RequestStatus result = CNT_SB2_ManageBrand.validateBrandAllocation(brandAllocation);
        Test.stopTest();
        
        System.assertEquals(false, result != null, 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testValidateBrandAllocationQuaretly(){
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = SB2_Constants.QUARTERLY;
        brandAllocation.Time_Interval__c = SB2_Constants.mapOfIntegerQuarter.get(Date.today().month());
        brandAllocation.Year_Of_Allocation__c = String.valueOf(Date.today().year());
        
        Test.startTest();
        	LightningComponentUtility.RequestStatus result = CNT_SB2_ManageBrand.validateBrandAllocation(brandAllocation);
        Test.stopTest();
        
        System.assertEquals(false, result != null, 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testGetFutureBrandAllocation(){
        Brand_Allocation__c brandAlloc = [select Id,Time_Interval__c,Time_Period__c,Year_Of_Allocation__c,Brand__c,Program_Type__c from Brand_Allocation__c where Time_Interval__c = 'June' and Year_Of_Allocation__c = '2019' limit 1];
        
        Test.startTest();
        	LightningComponentUtility.RequestStatus result = CNT_SB2_ManageBrand.getFutureBrandAllocation(brandAlloc);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testDeactivateBrandAllocation(){
        Brand_Allocation__c brandAlloc = [select Id,Name, Time_Interval__c,Time_Period__c,Year_Of_Allocation__c,Brand__c,Program_Type__c from Brand_Allocation__c where Time_Interval__c = 'June' and Year_Of_Allocation__c = '2019' limit 1];
        
        Test.startTest();
        Map<String, Object> result = CNT_SB2_ManageBrand.deactivateBrandAllocation(new List<String> {brandAlloc.Name},'Inactive');
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testInsertCurrentBrandAllocation(){
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = SB2_Constants.QUARTERLY;
        brandAllocation.Time_Interval__c = SB2_Constants.mapOfIntegerQuarter.get(Date.today().month());
        brandAllocation.Year_Of_Allocation__c = String.valueOf(Date.today().year());
        
        Test.startTest();
        	Map<String, Object> result = CNT_SB2_ManageBrand.insertCurrentBrandAllocation(brandAllocation);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testInsertBrandAllocation(){
        List<Brand__c> lstBrand = [Select Id, Name From Brand__c limit 1];
        Brand_Allocation__c brandAllocation = new Brand_Allocation__c();
        brandAllocation.Brand__c = lstBrand[0].Id;
        brandAllocation.Is_Active__c = true;
        brandAllocation.Program_Type__c = 'Sample Kit';
        brandAllocation.Time_Period__c = SB2_Constants.QUARTERLY;
        brandAllocation.Time_Interval__c = SB2_Constants.mapOfIntegerQuarter.get(Date.today().month());
        brandAllocation.Year_Of_Allocation__c = String.valueOf(Date.today().year());
        
        Test.startTest();
        	Map<String, Object> result = CNT_SB2_ManageBrand.insertBrandAllocation(brandAllocation);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Result is fetched');
    }
    
    /**
    *  @description : This method is use to test GetDependentMap() to test picklist values
    **/
    @isTest
    public static void testUpdateCarryForwardAllocation(){
        Brand_Allocation__c brandAlloc = [select Id,Name, Time_Interval__c,Time_Period__c,Year_Of_Allocation__c,Brand__c,Program_Type__c from Brand_Allocation__c where Time_Interval__c = 'June' and Year_Of_Allocation__c = '2019' limit 1];
        
        Test.startTest();
        	Brand_Allocation__c result = CNT_SB2_ManageBrand.updateCarryForwardAllocation(brandAlloc.Id, true);
        Test.stopTest();
        
        System.assertEquals(true, result != null, 'Result is fetched');
    }
}