@isTest
public class TST_SendEmailHandler {
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
@date 11/18/2020
@description This test class is to test CNT_SendEmailHandler .
*/
    public static testMethod void testsendEmail() {
        
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.ccEmail__c = 'test@test.com';
        
        Test.startTest();     
        insert c;
        String WhatId= c.id;
        String ThreadId= c.Thread_Id__c;
        CNT_SendEmailHandler.processEmail(WhatId, 'test@tst2.com', 'test Subject', 'Survey Invitation Email', ThreadId);
        Test.stopTest();
    }

    public static testMethod void testSendEmailException(){
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'Test Case 2';
        c.Submitter__c = UserInfo.getUserId();
        c.Product_Destination_Country__c = 'Sri Lanka';
        c.ccEmail__c = 'test@test.com';
        
        Test.startTest();     
        insert c;
        String WhatId= '123456789';
        String ThreadId= c.Thread_Id__c;
        CNT_SendEmailHandler.processEmail(WhatId, 'test@tst2.com', 'test Subject', 'Survey Invitation Email', ThreadId);
        Test.stopTest();
    }
}