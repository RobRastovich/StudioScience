public with sharing class ForecastMultiRecordEditor extends PageControllerBase {
	public Boolean MyAllowAdd {get; set;}
    public Boolean MyAllowEdit {get; set;}
	public Boolean MyAllowView {get; set;}
    public Boolean MyAllowDelete {get; set;}
    public String MysObj {get; set;}
    public String MyRecId {get; set;}
    public String MyRelationField {get; set;}
    public list<String> MyFieldList {get; set;}
    public list<String> MySearchFieldList {get; set;}
    public list<String> MyLabelOverrideFieldList {get; set;}
    public list<String> MyLabelOverrideTextList {get; set;}
    public list<String> MyDefaultValueFieldList {get; set;}
    public list<String> MyDefaultValueTextList {get; set;}
    public String MyBlockTitle {get; set;}
    
    public String MyFilter {get; set; }
    public String MySort {get; set; }
    
    private ApexPages.StandardController standardController;
 
    public ForecastMultiRecordEditor(ApexPages.StandardController stdController) {
    	this.standardController = stdController;
    	Id recordId = standardController.getId();
    	
        Boolean isPermissionAllowed= getIsMemberOfGroup();
        MyAllowAdd = isPermissionAllowed;
        MyAllowEdit = isPermissionAllowed;
        MyAllowView= isPermissionAllowed;
        MyAllowDelete = isPermissionAllowed;
        MyBlockTitle = 'Edit Forecasts';
        MysObj = 'Campaign_Spend__c';
        MyRecId = '' + recordId; // '001i000000JqJAa';  // fill in your record Id here
        MyRelationField = 'ParentCampaign__c';
        MyFieldList = new list<String> {'Forecast_Month__c', 'Amount__c'};
        MySearchFieldList = new list<String> { 	'Forecast_Month__c' };
        MyFilter = 'RecordType.Name = \'Forecast\'';
        MySort = 'Forecast_Month__c';
        MyLabelOverrideFieldList = new list<String> { };
        MyLabelOverrideTextList = new list<String> { };
        MyDefaultValueFieldList = new list<String> { };
        MyDefaultValueTextList = new list<String> { };
    }
	
	// Returns false is user is related to 2 specific AUStralia profiles
	public Boolean getIsMemberOfGroup()
	{
        Id profileId=UserInfo.getProfileId();
        Set<String> profileRestricted= new Set<String>();
        for(Profile profile: [Select Id,Name from Profile where Id=:profileId AND Name in ('AUS Marketing - Platform', 'AUS Finance - Platform') ]){
            profileRestricted.add(profile.Name);
            system.debug('ProfileName'+profile.Name);
        }

        if(!profileRestricted.isEmpty())
            return false;
		
		return true;
	}
	
    public override void RefreshPage() {
    	//Without Test.isRunningTest(), this lines errors because of the following sObject error:
    	//System.SObjectException: You cannot call reset when the data is being passed into the controller by the caller.
    	if (!Test.isRunningTest()) {
    		this.standardController.reset();	
    	}    	
  	}
}