public with sharing class CampaignPlanningEditor extends PageControllerBase {
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
 
    public CampaignPlanningEditor(ApexPages.StandardController stdController) {
        this.standardController = stdController;
        Id recordId = standardController.getId();
        
        MyAllowAdd = true;
        MyAllowEdit = true;
        MyAllowDelete = true;
        MyBlockTitle = 'Campaign Planning';
        MysObj = 'Campaign_Spend__c';
        MyRecId = '' + recordId;  // record Id
        MyRelationField = 'ParentCampaign__c';
        MyFieldList = new list<String> {'Spend_Type__c', 'Notes__c', 'Customer__c', 'Vendor__c', 'Quantity__c', 'Unit_Cost__c', 'Total_Estimate__c', 'Jan_Budget__c', 'Feb_Budget__c', 'Mar_Budget__c', 'Apr_Budget__c', 'May_Budget__c', 'Jun_Budget__c', 'Jul_Budget__c', 'Aug_Budget__c', 'Sep_Budget__c', 'Oct_Budget__c', 'Nov_Budget__c', 'Dec_Budget__c', 'Full_Year_Budget__c'};
        MySearchFieldList = new list<String> {  };
        MyFilter = 'RecordType.Name = \'Campaign Planning & Forecasting\'';
        MySort = 'Spend_Type__c';
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