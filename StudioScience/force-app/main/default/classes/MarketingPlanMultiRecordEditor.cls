public with sharing class MarketingPlanMultiRecordEditor extends PageControllerBase {
    public Boolean MyAllowAdd {get; set;}
    public Boolean MyAllowEdit {get; set;}
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
 
    public MarketingPlanMultiRecordEditor(ApexPages.StandardController stdController) {
        this.standardController = stdController;
        Id recordId = standardController.getId();
        
        MyAllowAdd = true;
        MyAllowEdit = true;
        MyAllowDelete = false;
        MyBlockTitle = 'Edit Related Marketing Plans';
        MysObj = 'MarketingPlan__c';
        MyRecId = '' + recordId; 
        MyRelationField = 'ParentMarketingPlan__c';
        MyFieldList = new list<String> {
            'Name',
            'Budget__c',
            'Comments__c',
            'AllocatedBudget__c',
            'UnallocatedBudget__c',
            'CampaignBudget__c',
            'CampaignBalance__c',
            'OwnerId',
            'Year__c',
            'Country__c',
            'Brand__c',
            'Region__c',
            'Division__c',
            'Territory__c',
            'Program__c'                    
        };
        MySearchFieldList = new list<String> { 
            'Name',
            'Region__c',
            'Division__c' };
        MyFilter = '';
        MySort = 'Name';
        MyLabelOverrideFieldList = new list<String> { };
        MyLabelOverrideTextList = new list<String> { };
        MyDefaultValueFieldList = new list<String> { };
        MyDefaultValueTextList = new list<String> { };
    }
    public override void RefreshPage() {
        //Without Test.isRunningTest(), this lines errors because of the following sObject error:
        //System.SObjectException: You cannot call reset when the data is being passed into the controller by the caller.
        if (!Test.isRunningTest()) {
            this.standardController.reset();    
        } 
    }
}