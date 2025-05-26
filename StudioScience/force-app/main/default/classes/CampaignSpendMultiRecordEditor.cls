public with sharing class CampaignSpendMultiRecordEditor extends PageControllerBase {
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
 
    public CampaignSpendMultiRecordEditor(ApexPages.StandardController stdController) {
        this.standardController = stdController;
        Id recordId = standardController.getId();
        Campaign__c currCampaign = (Campaign__c) this.standardController.getRecord();
        String recordTypeName = [SELECT Id, RecordType.DeveloperName FROM Campaign__c WHERE Id=:recordId].RecordType.DeveloperName;
        Boolean isWBSEnabled = BI_Constants.isWBSCampaign(recordTypeName);
        MyAllowAdd = false;
        MyAllowEdit = false;
        MyAllowDelete = false;
        MyBlockTitle = 'Campaign Spend';
        MysObj = 'Campaign_Spend__c';
        MyRecId = '' + recordId; 
        MyRelationField = 'ParentCampaign__c';
        MyFieldList = new list<String> {
            'RecordTypeId',
            'Amount__c',
            'Committed_Type__c',            
            'Vendor__c',
            'Document_Number__c',
            'Line_Item_Number__c', 
            'Document_Text__c',
            'Line_Item_Text__c',        
            'Document_Date__c',
            'Posting_Date__c',
            'Debit_Date__c',
            'GLAccount__c', 
            'GLDescription__c' 
        };
        if(!isWBSEnabled){
            MyFieldList.add('IOCode__c');
        } else{
            MyFieldList.add('WBSCode__c');
        }
        MySearchFieldList = new list<String> { 
            'Vendor__c',
            'Document_Number__c', 
            'Line_Item_Number__c',       
            'Committed_Type__c',
            'Document_Text__c',
            'Line_Item_Text__c',
            'GLAccount__c',
            'GLDescription__c' };
        MyFilter = ' ( RecordType.Name LIKE \'%Actual%\' OR RecordType.Name LIKE \'%Committed%\' OR RecordType.Name LIKE \'%Pending%\') ';
        MySort = 'RecordTypeId';
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