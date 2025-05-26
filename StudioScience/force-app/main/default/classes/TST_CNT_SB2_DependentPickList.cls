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
public class TST_CNT_SB2_DependentPickList {
    /**
    *  @description : This method is use to test GetDependentMap() to test dependent picklist values
    **/
    @isTest
    public static void testGetDependentMap(){

        Test.startTest();
        	Map<String, List<String>> result = CNT_SB2_DependentPickList.getDependentMap(Schema.getGlobalDescribe().get('Brand_Allocation__C').newSObject() , 'Time_Period__c', 'Time_Interval__c');
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'Result is fetched');
        
    }
}