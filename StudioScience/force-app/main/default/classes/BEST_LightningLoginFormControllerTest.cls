@IsTest(SeeAllData = true)
public with sharing class BEST_LightningLoginFormControllerTest {

 @IsTest
 static void BEST_LightningLoginFormControllerInstantiation() {
  BEST_LightningLoginFormController controller = new BEST_LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assert(BEST_LightningLoginFormController.getIsUsernamePasswordEnabled() != null);
 }
    
    @IsTest
    static void testsetExperienceId() {
        System.assert(BEST_LightningLoginFormController.setExperienceId('a') != null);
    }
    
    @IsTest
    static void testgetForgotPasswordUrl() {
        System.assert(BEST_LightningLoginFormController.getForgotPasswordUrl() == null);
    }
    
    @IsTest
    static void testlogin() {
        System.assert(BEST_LightningLoginFormController.login('a','b','c') == null);
        System.assert(BEST_LightningLoginFormController.login('','','') != null);
    }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, BEST_LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, BEST_LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = BEST_LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
}