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
    @date 17/02/2020
    @description This test class is created to test CNT_ReCaptcha.
*/
@IsTest(seeAllData = false)
public class TST_ReCaptcha {
    
    /**
    *  @description : This method is use setup data for test cases.
    **/
    @testSetup
    public static void makeData() {
        ContactUs_Setting__c contactUsSettingObj = new ContactUs_Setting__c();
        contactUsSettingObj.Name = 'Default';
        contactUsSettingObj.ReCaptchaEndPoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        contactUsSettingObj.ReCaptchaSecretKey__c = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe';
        contactUsSettingObj.ReCaptchaSiteKey__c = '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI';
        contactUsSettingObj.ReCaptchaRenderUrl__c = 'https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit';
        insert contactUsSettingObj;
    }
    
    /**
    *  @description : This method is use test getter & setter of CNT_ReCaptcha
    **/
    @IsTest
    public static void testReCaptcha() {
        CNT_ReCaptcha reCaptchaObj = new CNT_ReCaptcha();
        String actualReCaptchaSiteKey = ContactUs_Setting__c.getValues('Default').ReCaptchaSiteKey__c;
        String actualRecapchaRenderUrl = ContactUs_Setting__c.getValues('Default').ReCaptchaRenderUrl__c;
        System.assertEquals(actualReCaptchaSiteKey, reCaptchaObj.reCaptchaSiteKey);
        System.assertEquals(actualReCaptchaSiteKey, reCaptchaObj.reCaptchaSiteKey);
    }
}