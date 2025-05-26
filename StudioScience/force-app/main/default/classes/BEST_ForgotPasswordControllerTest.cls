@IsTest(SeeAllData = true)
public with sharing class BEST_ForgotPasswordControllerTest {

 /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
 @IsTest
 static void testLightningForgotPasswordControllerInvalidUserName() {
  System.assertEquals(BEST_LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), 'Enter a valid email address.');
  System.assertEquals(BEST_LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), 'Enter a valid email address.');
  System.assertEquals(BEST_LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), 'Enter a valid email address.');
 }

 /* Verifies that null checkEmailRef url throws proper exception. */
 @IsTest
 static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
  System.assertEquals(BEST_LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
  System.assertEquals(BEST_LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
 }
    
    @IsTest
    static void testsetExperienceId() {
        System.assert(BEST_LightningForgotPasswordController.setExperienceId('a') != null);
    }

 /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
 @IsTest
 static void BEST_LightningForgotPasswordControllerInstantiation() {
  BEST_LightningForgotPasswordController controller = new BEST_LightningForgotPasswordController();
  System.assertNotEquals(controller, null);
 }
}