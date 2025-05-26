public with sharing class CommunityForgotPasswordController {
    public String username {get; set;}
      public string selectedLang{get;set;}

    public CommunityForgotPasswordController() {
        
    }
    public List<SelectOption>getAvailableLanguages(){
    
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('en','English'));
        options.add(new selectOption('de','German'));
        options.add(new selectOption('es','Spanish'));
        options.add(new selectOption('fr','French'));
        options.add(new selectOption('es_MX','Spanish (Mexico) '));
        options.add(new selectOption('zh_CN','Chinese (Simplified)'));
        options.add(new selectOption('ko','Korean'));
        
        return options;
    
    }
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = System.Page.CommunityForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }
}