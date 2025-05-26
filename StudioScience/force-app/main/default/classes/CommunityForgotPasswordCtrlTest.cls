@isTest
private class CommunityForgotPasswordCtrlTest {
    
    @isTest static void testForgotPassword() {
        CommunityForgotPasswordController ctrl = new CommunityForgotPasswordController();
        ctrl.username = 'test@salesforce.com';
        ctrl.getAvailableLanguages();
        System.assertEquals(ctrl.forgotPassword(),null);
    }
    
    
    
}