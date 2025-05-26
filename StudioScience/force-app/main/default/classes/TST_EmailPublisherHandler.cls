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
    @date 12/03/2020
    @description This class is used to test EmailPublisherHandler
*/
@isTest(seeAllData = false)
public class TST_EmailPublisherHandler {
    
    /**
    *  @description : This method is use to test onInitDefaults method
    **/
    @isTest
    static void testOnInitDefaults() {
        Case caseObj = new Case();
        caseObj.RecordTypeId = CSConstants.CONSUMER_INQUIRY_RT_ID;
        insert caseObj;
        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => caseObj.Id,
                'actionType' => 'SendEmail',
                'actionName' => 'Case.SendEmailComplaintInquiry',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = Test.newSendEmailQuickActionDefaults(caseobj.Id, null);
        Test.startTest();
        EmailPublisherHandler emailPublisherHandlerObj = new EmailPublisherHandler();
        emailPublisherHandlerObj.onInitDefaults(defaultsSettings);
        Test.stopTest();
    }
}