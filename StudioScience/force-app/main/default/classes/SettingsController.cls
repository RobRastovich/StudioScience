public with sharing class SettingsController 
{
    // custom settings instance name
    public final static String Company_Message='Company Message';
    
    // the custom settings instance being managed
    public GBS_Custom_Message__c msg{get; set;}
    
    // constructor - queries the custom setting instance from the cache
    public SettingsController()
    {
        msg=GBS_Custom_Message__c.getInstance(Company_Message);
    }
    
    // action method to save the changes to the custom setting
    public PageReference save()
    {
        update msg;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'All changes saved'));
        
        return null;
    }
}