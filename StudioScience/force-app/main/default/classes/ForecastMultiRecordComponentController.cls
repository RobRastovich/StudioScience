public with sharing class ForecastMultiRecordComponentController extends ComponentControllerBase {
    
    //Object details, object fields, overrides for columns headers
    public String sObjectType {get; set;} //component attribute
    private sObject parentRecord;
    public Campaign__c parentCamapignRecord {get; set;}
    public String ParentRecId {get; set;} //component attribute
    public String RelationField {get; set;} //component attribute
    public list<String> FieldList {get; set;} //component attribute
    
    public list<String> LabelOverrideFieldList {get; set;} //component attribute
    public list<String> LabelOverrideTextList {get; set;} //component attribute
    private map<String, String> LabelOverrideMap;
    private Boolean IsInitialized;
    
    public list<String> DefaultValueFieldList {get; set;} //component attribute
    public list<String> DefaultValueTextList {get; set;} //component attribute
    private map<String, String> DefaultValueMap;
        
    //SOQL string, Column and Row data binding  
    private String QuerySelect;
    public String DefaultRelatedListFilter {get; set;} //component attribute
    public list<ObjectWrapper> ObjectList {get; set;}
    public set<Id> SelectedObjectSet {get; set;}
    private list<ColumnWrapper> ColumnWrapList;
    public list<ColumnWrapper> ColumnList {
        get {        
            if (ColumnWrapList == null) {
                //Make sure to use correct Column Header overrides.
                InitValues();
                // load fields for table columns                
                ColumnWrapList = LoadColumnList(sObjectType, FieldList, LabelOverrideMap, SearchFieldList);
                // load records in the table once columns are loaded. Can't simply call BuildQuery() from 
                // constructor because Component Attributes haven't loaded yet, and BuildQuery is dependent
                // on values coming from Component Attributes.
                BuildQuery();
            }
            return ColumnWrapList;
        }        
        set;
    } 
    private list<QueryWhereFilter> ColumnQueryFilters;
    public list<QueryWhereFilter> FilterList { 
        get {
            if (ColumnQueryFilters == null) {
                //Make sure to use correct Column Header overrides.
                InitValues();       
                //Load filters for the filter pane.     
                ColumnQueryFilters = LoadFilterList(sObjectType, FieldList, LabelOverrideMap, SearchFieldList);
            }
            return ColumnQueryFilters;  
        }
        set;        
    } 

    //Pagination
    public String RecPerPage {get; set;}
    public Integer TotalPages {
        get {
            if(StdSetController != null) {
                Integer tempPages = integer.valueof(Math.floor((StdSetController.getResultSize() / StdSetController.getPageSize())));
                if (Math.mod(StdSetController.getResultSize(), integer.valueOf(RecPerPage)) > 0 ) {
                    tempPages++;
                }                   
                return tempPages;
            }   
            return 1;
        } 
        set; 
    }
    public list<SelectOption> RecPerPageOption {get; set;} 
    public ApexPages.StandardSetController StdSetController {
        get {
            if(StdSetController == null) {              
                StdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(QuerySelect));
                StdSetController.setPageSize(Integer.valueOf(RecPerPage));
            }
            return StdSetController;
        }
        set;
    }
    
    //Filtering      
    public list<String> SearchFieldList {get; set;} //component attribute
    public Boolean FilterVisible {get; set;}
    public Boolean IsFilterable {
        get { if (SearchFieldList != null && SearchFieldList.size() > 0) { return true; } return false; }
        set;
    }
    public String ActionFilterFieldName {get; set;}
    public list<String> AlphaList {get; set;} // not used yet
    public String AlphaFilter {get; set;} // not used yet
        
    //Sorting
    public String DefaultSort {get; set;} //component attribute
    public String SortFieldSave {get; set;}
    public String SortField {
        get { if (SortField == null) {SortField = 'Name'; } return SortField;  }
        set; 
    }
    public String SortDirection {
        get { if (SortDirection == null) {  SortDirection = 'asc'; } return SortDirection;  }
        set;
    }
    
    //Navigation/redirection
    public Boolean ShouldRedirect {get; set;}
    public String RedirectUrl {get; set;}
    
    //Actions, Buttons
    private Integer AddedRowCount;
    public String ActionId {get; set;}
    public String ActionRowNumber {get; set;}    
    public Integer SelectedCheckboxCount {get; set;}
    
    public Boolean ShowAutoForecast {get; set;} //component attribute
    public Boolean AllowAdd {get; set;} //component attribute
    public Boolean AllowEdit {get; set;} //component attribute
    public Boolean AllowDelete {get; set;} //component attribute    
    public Boolean DisableSave {get; set;}
    public Boolean DisableEdit {get; set;}
    public Boolean DisableCancel {get; set;}
    public Boolean UserHasCreatePermission {get; set; }
    public Boolean UserHasDeletePermission {get; set; }

    //hold sObjectType for Campagin__c
    public Schema.sObjectType campaignExpected {get; set;}
    
    //Constructor    
    public ForecastMultiRecordComponentController() {
        IsInitialized = false;
        ShouldRedirect = false;
        RedirectUrl = '';

        //initialize Campaign__c sObjectType for comparison
        campaignExpected = Schema.Campaign__c.getSObjectType();
        
        QuerySelect = '';
        ObjectList = new list<ObjectWrapper>();
        SelectedObjectSet = new set<Id>(); 
        
        SearchFieldList = new list<string>();
        DisableSave = true;
        DisableCancel = true;
        AddedRowCount = 0;
               
        FilterVisible = false;
        
        //records for page initialization
        //TODO: make this a component attribute.
        RecPerPageOption = new list<SelectOption>();
        RecPerPageOption.add(new SelectOption('10','10'));
        RecPerPageOption.add(new SelectOption('25','25'));
        RecPerPageOption.add(new SelectOption('50','50'));
        RecPerPageOption.add(new SelectOption('100','100'));
        RecPerPageOption.add(new SelectOption('200','200'));
        RecPerPage = '25'; //default records per page
        
        UserHasCreatePermission = false;
        UserHasDeletePermission = false;

        parentCamapignRecord = new Campaign__c();
    }

    private void InitValues() {
        //InitValues() gets called by ColumnList and FilterList getters upon the first time they are accessed. Don't process
        //things more than once.
        //if (IsInitialized) {
        //  return;
        //}
        
        // convert field label override lists to a map for easier lookup
        // Salesforce apex:attribute of type map doesn't current work properly.
        // this can updated to a map when/if SF fixes the attribute for maps
        LabelOverrideMap = new map<String, String>();
        if (LabelOverrideFieldList != null && LabelOverrideTextList != null) {
            System.debug(LoggingLevel.INFO,LabelOverrideFieldList + ':::' + LabelOverrideTextList);
            for (Integer i=0; i < LabelOverrideFieldList.size(); i++) {
                if (i < LabelOverrideTextList.size()) {
                    LabelOverrideMap.put(LabelOverrideFieldList[i], LabelOverrideTextList[i]);
                }
            }
        }
        System.debug(LoggingLevel.INFO,'LabelOverrideMap' + LabelOverrideMap);
 
        DefaultValueMap = new map<String, String>();
        if (DefaultValueFieldList != null && DefaultValueTextList != null) {
            System.debug(LoggingLevel.INFO,DefaultValueFieldList + ':::' + DefaultValueTextList);
            for (Integer i=0; i < DefaultValueFieldList.size(); i++) {
                if (i < DefaultValueTextList.size()) {
                    DefaultValueMap.put(DefaultValueFieldList[i], DefaultValueTextList[i]);
                }
            }
        }
        System.debug(LoggingLevel.INFO,'DefaultValueMap' + DefaultValueMap); 
        
        //Race condition here I think. Only set the SortField to the DefaultSort if the user has sorted before 
        //opening the Show Filters page??    
        if (SortFieldSave != SortField) {
            SortField = DefaultSort;
            SortFieldSave = SortField;
            SortDirection = 'asc';    
        }       
    }
    
    
    public void DoRefreshParentFields() {
        if (this.pageController != null) {
            this.pageController.RefreshPage();
        }
    }
    
 
    public void DoRedirect(Boolean doTheRedirect) {
        ShouldRedirect = false;
        /*
        if (doTheRedirect) {
            ShouldRedirect = true;
            RedirectUrl = '/' + ParentRecId;
        } else {
            ShouldRedirect = false;
            RedirectUrl = '';
        }
        */
    }
    public void DoAdd() {
        DisableSave = false;
        DisableCancel = false;
        ObjectWrapper TmpObjWrap = new ObjectWrapper(Schema.getGlobalDescribe().get(sObjectType).newSObject(), true, false);
        TmpObjWrap.obj.put(RelationField, ParentRecId);
        for (String s : DefaultValueMap.keySet()) {
            TmpObjWrap.obj.put(s, DefaultValueMap.get(s));
        }
        AddedRowCount += 1;
        TmpObjWrap.AddedRowNumber = String.valueOf(AddedRowCount);
        
        //Let's put the new row in the FRONT of the list so users don't have to scroll down, but it has to be below recently ADDed
        //rows otherwise Visualforce's dynamically generated IDs will get re-used, causing picklist dependencies and lookups
        //to behave incorrectly.
        List<ObjectWrapper> tmpNewList = new List<ObjectWrapper>();
        List<ObjectWrapper> tmpExistingList = new List<ObjectWrapper>();
        
        //First, find all the NEW rows in the order they were added.
        for(Integer i=0; i < ObjectList.size(); i++) {
            if (ObjectList[i].obj.Id == null) {
                tmpNewList.add(ObjectList[i]);  
            }   
        }
        //Second, find all the EXISTING rows in the order they appear.
        for(Integer i=0; i < ObjectList.size(); i++) {  
            if (ObjectList[i].obj.Id != null) {
                tmpExistingList.add(ObjectList[i]);
            }   
        }
        
        //Order will be all New rows in the order they were added, then the TmpObjWrap that was just created, then the Existing rows.
        ObjectList.clear();
        ObjectList.addAll(tmpNewList);
        ObjectList.add(TmpObjWrap);
        ObjectList.addAll(tmpExistingList);
    }
 
    /***
    * DoCancel - remove added lines and change lines back to display mode
    ***/
    public void DoCancel() {
        //SaveSearchText = '';
        DisableSave = true;
        DisableCancel = true;
        for (Integer i=0; i < ObjectList.size(); i++) {
            // remove added lines that were not saved
            if (ObjectList[i].obj.Id == null) {
                ObjectList.remove(i);
                i--;
                continue;
            }
            // change to display mode
            ObjectList[i].IsEditMode = false;
        }
        //To reset data in case of error.
        DoRedirect(false);
        BuildQuery();
    }
 
    /***
    * DoSave - Save edited and added records. then refresh/requery the list
    ***/
    public PageReference DoSave() {
        
        list<sObject> UpdateList = new list<sObject>();
        list<sObject> InsertList = new list<sObject>();
        for (ObjectWrapper o : ObjectList) {
            if (o.IsEditMode == true) {
                if (o.obj.Id == null) {
                    InsertList.add(o.obj);
                } else {
                    UpdateList.add(o.obj);
                }
            }
        }
        System.Savepoint sp1 = Database.setSavepoint();
        try {
            System.debug(LoggingLevel.INFO,'UpdateList: ' + UpdateList);
            System.debug(LoggingLevel.INFO,'InsertList: ' + InsertList);
            if (UpdateList.size() > 0) {
                update UpdateList;
            }
            if (InsertList.size() > 0) {
                insert InsertList;
            }
            
            DisableSave = true;
            DisableCancel = true;
            
        } catch (exception e) {
            System.debug(LoggingLevel.INFO,'error: ' + e);
            Database.rollback(sp1);
            String friendlyMessage = GetFriendlyMessage(e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, friendlyMessage));
            DoRedirect(false);
            return null;
        }
        // requery in case field list contains fields referencing related objects
        if (UpdateList.size() > 0 || InsertList.size() > 0) {            
            BuildQuery();
        }
        
        
        if (UpdateList.size() >0 && sObjectType=='Campaign__c'){
            
            Set<Id> resultIds = (new Map<Id,SObject>(UpdateList)).keySet();
            List<Campaign__c> lstCampaign= [select name, Is_Budget_Change__c, Has_Child_Campaigns__c from Campaign__c where id in : resultIds and Is_Budget_Change__c=true ];
            if(lstCampaign.size()>0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Please_update_the_forecast));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Please_Update_Child_Campaign_Budget));
            }
            for(Campaign__c c:lstCampaign){
                c.Is_Budget_Change__c=false;
                
            }
             update lstCampaign;
        }
       
        //DoRedirect(true);
        DoRefreshParentFields();
        return null;
    }

    @TestVisible
    private String GetFriendlyMessage(String theMessage) {
        String theResult = 'An error occurred. Please try again or contact your administrator.';
        if (theMessage == null) {
            return theResult;
        }
        
        if (theMessage.contains('VALIDATION_EXCEPTION,')) {
            //Parse out the actual message in order to hide all the long-winded Salesforce garble.
            String[] splitResult = theMessage.split('VALIDATION_EXCEPTION,');
            //An error occurred saving the records: Update failed. First exception on row 0 with id a00q0000004Bz73AAC; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, A Comment is required when changing a Marketing Plan Budget value.: []
            if (splitResult.size() > 1) {
                theResult = splitResult[1];
                theResult = theResult.replace(': []', '');
            }
        }
        return theResult;
    }
    
    /***
    * SearchAccount - set search criteria fields and refresh Account table
    ***/
    public PageReference DoSearch() {
        System.debug(LoggingLevel.INFO,'In DoSearch: ' + FilterList);
        if (FilterList != null && FilterList.size() > 0) {
            for (QueryWhereFilter qwf : FilterList) {
                qwf.SaveFilterText = qwf.FilterText;
                if (qwf.SaveSelectedOptions == null) {
                    qwf.SaveSelectedOptions = new List<String>();
                }
                qwf.SaveSelectedOptions.clear();
                if (qwf.SelectedOptions != null) {
                    qwf.SaveSelectedOptions.addAll(qwf.SelectedOptions);    
                }               
            }   
        }       
        BuildQuery(); 
        DoRedirect(false);
        return null;
    }
 
    public void DoDelete() {
        if (ActionId == null || ActionId.trim().length() == 0) {
            return;
        }
        try {
            database.delete(ActionId);
            for (Integer i=0; i < ObjectList.size(); i++) {
                if (ActionId == ObjectList[i].obj.Id) {
                    ObjectList.remove(i);
                    break;
                }
            }
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        ActionId = null;
        DoRedirect(false);
        return;
    }
 
    public void DoRemove() {
        if (ActionRowNumber == null || ActionRowNumber.trim().length() == 0) {
            return;
        }
        for (Integer i=0; i < ObjectList.size(); i++) {
            if (ActionRowNumber == ObjectList[i].AddedRowNumber) {
                ObjectList.remove(i);
                break;
            }
        }
        ActionRowNumber = null;
        DoRedirect(false);
        return;
    }
 
    public void DoEdit() {
        if (ActionId == null || ActionId.trim().length() == 0) {
            return;
        }
        DisableSave = false;
        DisableCancel = false;
        for (ObjectWrapper o : ObjectList) {
            if (o.obj.Id != null && ActionId == o.obj.Id) {
                o.IsEditMode = true;
                break;
            }
        }
        ActionId = null;
        DoRedirect(false);
        return;
    }
    public void DoEditAll() {
        DisableSave = false;
        DisableCancel = false;
        for (ObjectWrapper o : ObjectList) {
            o.IsEditMode = true;
        }
        ActionId = null;
        DoRedirect(false);
        return;
    }
 
    public void BuildQuery() {
        StdSetController = null;
        String QueryWhere = '';
        //list<ObjectWrapper> ObjWrapList = new list<ObjectWrapper>();
        list<String> QueryFieldList = new list<String>();
        QueryFieldList.addAll(FieldList);
 
        if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        }
 
        QuerySelect = 'SELECT ' + String.escapeSingleQuotes(String.join(QueryFieldList,', ')) + 
            ' FROM ' + String.escapeSingleQuotes(sObjectType);
        /*
        if (AlphaFilter == 'Other') {
            QueryWhere = BuildWhere(QueryWhere, '(' + String.escapeSingleQuotes(SortField) + ' < \'A\' OR ' + 
                                    String.escapeSingleQuotes(SortField) + ' > \'Z\') AND (NOT ' + 
                                    String.escapeSingleQuotes(SortField) + ' LIKE \'Z%\') ');
        } else if (AlphaFilter != 'All') {
            QueryWhere = BuildWhere(QueryWhere, '(' + String.escapeSingleQuotes(SortField) + ' LIKE \'' + String.escapeSingleQuotes(AlphaFilter) + '%\')' );
        } */
        
        //Always do default Related List filtering to narrow down by Parent, and possible other default filters.  
        QueryWhere = BuildWhere(QueryWhere, ' ' + String.escapeSingleQuotes(RelationField) + '=\'' + String.escapeSingleQuotes(ParentRecId) + '\'', false);
        
        //Is there a Default Filter
        If (!String.IsBlank(DefaultRelatedListFilter)) {
            QueryWhere = BuildWhere(QueryWhere, ' ' + DefaultRelatedListFilter + ' ', false);
        } 
        
        
        System.debug(LoggingLevel.INFO,'Filters before query: ' + this.ColumnQueryFilters);
        if (this.ColumnQueryFilters != null) {
            
        
            for (QueryWhereFilter qw : this.ColumnQueryFilters) {
                if (qw.AllowFilter) {
                    
                    if (qw.FieldType == 'String' && !String.IsBlank(qw.SaveFilterText)) {
                        QueryWhere = BuildWhere(QueryWhere, ' ' + qw.FieldName + ' LIKE \'%' + String.escapeSingleQuotes(qw.SaveFilterText) + '%\' ', false);   
                    }
                    
                    if (qw.FieldType == 'Picklist' && qw.SaveSelectedOptions != null && qw.Options != null) {
                        
                        if (qw.SaveSelectedOptions.size() > 0 && qw.SaveSelectedOptions.size() < qw.Options.size()) {   
                            //If any (but not all) are selected, query all of the selected values.                                       
                            List<String> tmpQuotedList = new List<String>();
                            for (String pValue : qw.SaveSelectedOptions) {
                                tmpQuotedList.add('\'' + pValue + '\'');
                            }
                            String picklistString = String.join(tmpQuotedList,', ');
                            QueryWhere = BuildWhere(QueryWhere, ' ' + qw.FieldName + ' IN (' + picklistString + ' ) ', false);
                        } else if (qw.SaveSelectedOptions.size() == 0) {
                            //If all are deselected, then find only NULL rows
                            QueryWhere = BuildWhere(QueryWhere, ' ' + qw.FieldName + ' = null', false);     
                        }
                    }
                }
            }
        }
         
        QuerySelect += QueryWhere;
        QuerySelect += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 10000';
 
        System.debug(LoggingLevel.INFO,'QuerySelect:' + QuerySelect);
        
        
        ObjectList = new list<ObjectWrapper>();

        if(ParentRecId != null){
            List<Campaign__c> campaignRecord = [SELECT ForecastedCampaignSpend__c, CurrencyIsoCode, PlannedCampaignSpend__c, UnforecastedCampaignBudget__c FROM Campaign__c WHERE Id = :ParentRecId];
            if(!campaignRecord.isEmpty()){
                parentCamapignRecord = campaignRecord[0];
            }
        }

        for (sObject a : (list<sObject>)StdSetController.getRecords()) {
            ObjectList.add(new ObjectWrapper(a, false, false));
        }
    }

    public String BuildWhere(String QW, String Cond, Boolean useOr) {
        
        if (String.IsBlank(QW)) {
            return ' WHERE ' + Cond;
        } else {
            if (useOr == true) {
                return QW + ' OR ' + Cond;
            } 
            else {
                return QW + ' AND ' + Cond;
            } 
        }
    }
   
    public list<ColumnWrapper> LoadColumnList(String InitSObj, list<String> InitFieldList, map<String, String> LabelOverrideMap, list<String> InitSearchFields) {
        list<ColumnWrapper> TmpColumnList = new list<ColumnWrapper>();
        System.debug(LoggingLevel.INFO,'sObj:' + InitSObj);
        
        //Get object describe and set Create/Delete object-level permission
        Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(InitSObj).getDescribe();
        UserHasCreatePermission = objResult.isCreateable();
        UserHasDeletePermission = objResult.isDeletable();
        
        // map of fields for the object        
        map<String, Schema.sObjectField> FieldMap = objResult.fields.getMap(); // Schema.getGlobalDescribe().get(InitSObj).getDescribe().fields.getMap();
 
        for (String s : InitFieldList) {
            Schema.sObjectField FieldObj;
            Schema.DescribeFieldResult DescField;
            Schema.DisplayType TmpFieldType = null;
            String TmpFieldTypeString;
            String TmpLabel;
            Boolean TmpIsEditable;
            Boolean TmpIsObjField;
            Boolean TmpIsSearchable;
            //Added field to check for currency
            Boolean TmpIsCurrency;
            
            // defaults
            TmpIsEditable = false;
            TmpIsObjField = false;
            TmpIsSearchable = false;
            TmpLabel = s;
            TmpFieldTypeString = '';
            List<SelectOption> tmpOptions = new List<SelectOption>();
            System.debug(TmpLabel);
            // fields of the object retrieve label and permissions, related object fields do not
            FieldObj = FieldMap.get(s);
            if (FieldObj != null) {
                DescField = FieldObj.getDescribe();
                if (DescField != null) {
                    if (DescField.isAccessible() == false) {
                        System.debug(LoggingLevel.INFO,'Field: ' + s + ' is not accessable for the user. Field ignored.');
                        continue;
                    }
 
                    if (DescField.isUpdateable() == true || DescField.isCreateable() == true) {
                        TmpIsEditable = true;
                    }
                    TmpFieldType = DescField.getType();
                    System.debug(LoggingLevel.INFO,'Field Type: ' + TmpFieldType);
                    if (TmpFieldType == Schema.DisplayType.String) {
                        TmpFieldTypeString = 'String';
                    }
                    if (TmpFieldType == Schema.DisplayType.Picklist || TmpFieldType == Schema.DisplayType.MultiPicklist) {
                        TmpFieldTypeString = 'Picklist';
                        list<Schema.PicklistEntry> values = DescField.getPickListValues();
                        for (Schema.PicklistEntry a : values){ 
                            tmpOptions.add(new SelectOption(a.getLabel(), a.getLabel())); 
                        }
                        System.debug(LoggingLevel.INFO,'Options: ' + tmpOptions);           
                    }
                    TmpLabel = DescField.getLabel();
                    TmpIsObjField = true;
                    TmpIsCurrency = (TmpFieldType == Schema.DisplayType.Currency);
                }
            }
 
            // use override label when found
            if (LabelOverrideMap.containsKey(s) == true) {
                TmpLabel = LabelOverrideMap.get(s);
            }
            
            //Is searching allowed on this field? If so create a filter.
            for (String sf : InitSearchFields) {
                if (sf == s && !String.IsBlank(TmpFieldTypeString)) {
                    //destFilters.add(new QueryWhereFilter(s, TmpLabel, TmpFieldTypeString, tmpOptions, true)); 
                }
            }
            TmpColumnList.add(new ColumnWrapper(s, TmpLabel, TmpIsEditable, TmpIsObjField, TmpIsCurrency));
        }
        System.debug(LoggingLevel.INFO,'ColumnList: ' + TmpColumnList);
        return TmpColumnList;
    }
    public static list<QueryWhereFilter> LoadFilterList(String InitSObj, list<String> InitFieldList, map<String, String> LabelOverrideMap, list<String> InitSearchFields) {
        list<QueryWhereFilter> TmpColumnList = new list<QueryWhereFilter>();
        System.debug(LoggingLevel.INFO,'sObj:' + InitSObj);
        // map of fields for the object
        map<String, Schema.sObjectField> FieldMap = Schema.getGlobalDescribe().get(InitSObj).getDescribe().fields.getMap();
 
        for (String s : InitSearchFields) {
            Schema.sObjectField FieldObj;
            Schema.DescribeFieldResult DescField;
            Schema.DisplayType TmpFieldType = null;
            String TmpFieldTypeString;
            String TmpLabel;
            Boolean TmpIsEditable;
            Boolean TmpIsObjField;
            Boolean TmpIsSearchable;
            
            // defaults
            TmpIsEditable = false;
            TmpIsObjField = false;
            TmpIsSearchable = false;
            TmpLabel = s;
            TmpFieldTypeString = '';
            List<SelectOption> tmpOptions = new List<SelectOption>();
 
            // fields of the object retrieve label and permissions, related object fields do not
            FieldObj = FieldMap.get(s);
            if (FieldObj != null) {
                DescField = FieldObj.getDescribe();
                if (DescField != null) {
                    if (DescField.isAccessible() == false) {
                        System.debug(LoggingLevel.INFO,'Field: ' + s + ' is not accessable for the user. Field ignored.');
                        continue;
                    }
 
                    if (DescField.isUpdateable() == true && DescField.isCreateable() == true) {
                        TmpIsEditable = true;
                    }
                    TmpFieldType = DescField.getType();
                    System.debug(LoggingLevel.INFO,'Field Type: ' + TmpFieldType);
                    if (TmpFieldType == Schema.DisplayType.String || 
                        TmpFieldType == Schema.DisplayType.URL || 
                        TmpFieldType == Schema.DisplayType.Email || 
                        TmpFieldType == Schema.DisplayType.ID) {
                        TmpFieldTypeString = 'String';
                    }
                    if (TmpFieldType == Schema.DisplayType.Picklist || TmpFieldType == Schema.DisplayType.MultiPicklist) {
                        TmpFieldTypeString = 'Picklist';
                        list<Schema.PicklistEntry> values = DescField.getPickListValues();
                        for (Schema.PicklistEntry a : values){ 
                            tmpOptions.add(new SelectOption(a.getLabel(), a.getLabel())); 
                        }                                   
                    }
                    TmpLabel = DescField.getLabel();
                    TmpIsObjField = true;  
                    
                    // use override label when found
                    if (LabelOverrideMap.containsKey(s) == true) {
                        TmpLabel = LabelOverrideMap.get(s);
                    }            
                                
                    TmpColumnList.add(new QueryWhereFilter(s, TmpLabel, TmpFieldTypeString, tmpOptions, true));               
                }
            }   
        }
        System.debug(LoggingLevel.INFO,'FilterList: ' + TmpColumnList);
        return TmpColumnList;
    }
  
    public class QueryWhereFilter {     
        public String FieldName {get; set;}
        public String FieldLabel {get; set;}
        
        public String FieldType {get; set;} //Note - FieldType is either 'String' or 'Picklist'
        public Boolean AllowFilter {get; set;}
        public Boolean IsFiltered {get; set;}
        
        //user input values
        public String FilterText {get; set;}
        private String SaveFilterText;
        
        public List<String> SelectedOptions {get; set;}
        private List<String> SaveSelectedOptions;
        
        //picklist options (if applicable)
        public List<SelectOption> Options { get; set; }
                
        public QueryWhereFilter(String fieldName, String fieldLabel, String FieldType, List<SelectOption> PicklistOptions, Boolean TmpIsSearchable) {
            this.FieldName = fieldName;
            this.FieldLabel = fieldLabel;
            this.FieldType = FieldType; 
            this.AllowFilter = TmpIsSearchable;         
            this.SaveSelectedOptions = new List<String>();
            this.SelectedOptions = new List<String>();    
            this.Options = new List<SelectOption>();
                        
            if (PicklistOptions != null && PicklistOptions.size() > 0) {                
                this.Options.addAll(PicklistOptions);               
                //pre-populate them all as selected, which means no Option search will occur (for performance benefits)
                for (SelectOption so : PicklistOptions) {
                    this.SelectedOptions.add(so.getValue());
                    this.SaveSelectedOptions.add(so.getValue());    
                }
            }
        }
        
        public void ToggleAllSelectedOptions() {        
            //If they are all checked, uncheck them. Otherwise, check them all.
            if (this.SelectedOptions.size() == this.Options.size()) {
                this.SelectedOptions.clear();
            } else {
                this.SelectedOptions.clear();
                for (Integer i = 0; i < this.Options.size(); i++) {
                    this.SelectedOptions.add(Options[i].getValue());        
                }   
            }
        }        
    }
    
    /***
    * ColumnWrapper - subclass for field properties of columns that will be displayed in the list
    * 7/28/2016 - Adding IsCurrency field to the wrapper
    * Justification - When "Parenthetical Currency Conversion" is disabled in a multi-currency org,
    *                   Currency formula fields will still display a converted value to the user's set currency.
    *                   To avoid this, we add IsCurrency so the Visualforce page can determine if the current field
    *                   needs special formatting.
    ***/
    public class ColumnWrapper { 
        public String FieldName {get; set;}
        public String FieldLabel {get; set;}
        public Boolean IsEditable {get; set;}
        public Boolean IsObjField {get; set;}
        public Boolean IsCurrency {get; set;}
        
        public ColumnWrapper(String FieldName, String FieldLabel, Boolean IsEditable, Boolean IsObjField, Boolean IsCurrency) {
            this.FieldName = FieldName; 
            this.FieldLabel = FieldLabel;
            this.IsEditable = IsEditable;
            this.IsObjField = IsObjField;
            this.IsCurrency = IsCurrency;
        }
    }

    /***
    * ObjectWrapper - subclass for the sObject record with additional properties
    ***/
    public class ObjectWrapper { 
        public sObject obj {get; set;}
        public Boolean IsEditMode {get; set;}
        public String AddedRowNumber {get; set;}
        public Boolean IsSelected {get; set;}
 
        public ObjectWrapper(sObject obj, Boolean IsEditMode, Boolean IsSelected) {
            this.obj = obj;
            this.IsEditMode = IsEditMode;
            this.IsSelected = IsSelected;
        }
    }
   
    public void SortToggle() {
        System.debug(LoggingLevel.INFO,'In SortToggle. SortField: ' + SortField + ' SortFieldSave: '  + SortFieldSave);
        SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        // reset alpha filter and sort sequence when sorted field is changed
        if (SortFieldSave != SortField) {
            SortDirection = 'asc';
            AlphaFilter = 'All';
            //SortFieldSave = SortField;
        }
        SortFieldSave = SortField;
        // run the query again
        BuildQuery();
        return;
    } 
    public void DoFilterToggle() {
        FilterVisible = !FilterVisible;
    }
    public void DoToggleCheckboxFilter() {
        if (ActionFilterFieldName == null || 
            ActionFilterFieldName.trim().length() == 0 || 
            ColumnQueryFilters == null || 
            ColumnQueryFilters.size() == 0) {
            return;
        }
        
        for (Integer i=0; i < ColumnQueryFilters.size(); i++) {
            if (ActionFilterFieldName == ColumnQueryFilters[i].FieldName && ColumnQueryFilters[i].FieldType == 'Picklist') {
               
                ColumnQueryFilters[i].ToggleAllSelectedOptions();
                DoSearch();
                break;
            }
        }
        ActionFilterFieldName = null; 
        return; 
    }  
    
    public PageReference ClearAllFilters(){
        StdSetController = null;
        
        if (this.ColumnQueryFilters.size() > 0) {
            for (QueryWhereFilter f : this.ColumnQueryFilters) {
                f.FilterText = '';
                f.SaveFilterText = '';
                
                if (f.Options != null && f.Options.size() > 0) {
                    if (f.SelectedOptions != null) {
                        f.SelectedOptions.clear();
                    } else {
                        f.SelectedOptions = new List<String>();
                    }
                    if (f.SaveSelectedOptions != null) {
                        f.SaveSelectedOptions.clear();
                    } else {
                        f.SaveSelectedOptions = new List<String>();
                    }
                    for (SelectOption so : f.Options) {
                        f.SelectedOptions.add(so.getValue());
                        f.SaveSelectedOptions.add(so.getValue());
                    }
                }
            }
        }
        AlphaFilter = 'All';
        BuildQuery(); 
        return null;
    }
    public void DoNext(){ 
        if(this.StdSetController.getHasNext()) {
            this.StdSetController.next();
            ObjectList = new list<ObjectWrapper>();
            for (sObject a : (list<sObject>)StdSetController.getRecords()) {
                ObjectList.add(new ObjectWrapper(a, false, false));
            }
            DisableSave = true;
            DisableCancel = true;
        }
    }
    public void DoPrevious(){
 
        if(this.StdSetController.getHasPrevious()) {
            this.StdSetController.previous();
            ObjectList = new list<ObjectWrapper>();
            for (sObject a : (list<sObject>)StdSetController.getRecords()) {
                ObjectList.add(new ObjectWrapper(a, false, false));
            }
            DisableSave = true;
            DisableCancel = true;
        }
    }

    /***
    * DoAutoForecast - Automatically splits the campaign budget between the active forecast months on the campaign
    ***/
    public PageReference DoAutoForecast(){
        try{
            //variable to see if there are active months to forecast for
            Boolean activeMonths = true;
            //check to make sure ParentRecId is not null and available to be used in the below query
            if(ParentRecId != null){
                //Get the Record Type ID for Forecasts
                Id forecastRecordTypeId = BI_UtilityLogic.getRecordTypeId(BI_Constants.OBJECT_CAMPAIGNSPEND, 
                        BI_Constants.RECORDTYPE_CAMPAIGNSPEND_FORECAST);
                //returning the Campaign__c record
                List<Campaign__c> campaignRecord = [SELECT Id, InitialStartDate__c, InitialEndDate__c, 
                                                    UnforecastedCampaignBudget__c, PlannedCampaignSpend__c, Year__c FROM Campaign__c 
                                                    WHERE Id = :ParentRecId LIMIT 1];
                if(!campaignRecord.isEmpty()){
                    //Null check for dates and making sure PlannedCampaignSpend__c != null
                    if (campaignRecord[0].InitialStartDate__c != null && campaignRecord[0].InitialEndDate__c != null 
                        && campaignRecord[0].PlannedCampaignSpend__c != null) {
                        //find the related Campaign_Spend__c records for the campaign
                        List<Campaign_Spend__c> forecastRecordsForCampaign = [SELECT Id, ParentCampaign__c, Forecast_Month_Date__c, Amount__c FROM Campaign_Spend__c WHERE ParentCampaign__c = :campaignRecord[0].Id AND RecordTypeId = :forecastRecordTypeId];

                        Date startDate = campaignRecord[0].InitialStartDate__c.toStartOfMonth();
                        Date endDate = campaignRecord[0].InitialEndDate__c.toStartOfMonth();
                        //setting todaysDate in order to get only active months on the campaigns date range
                        Date todaysDate = Date.newInstance(Integer.valueOf(campaignRecord[0].Year__c), Date.Today().month(), 1);
                        Date initialDate;
                        if(startDate <= todaysDate){
                            initialDate = todaysDate;
                        } else {
                            initialDate = startDate;
                        }
                        //build set of active campaign months to split the remaining budget between
                        Set<Integer> campaignMonths = new Set<Integer>();
                        for (Date dt = initialDate; dt <= endDate; dt = dt.addMonths(1)) {
                            campaignMonths.add(dt.Month());
                        }
                        //check if there are no active months
                        if(campaignMonths.isEmpty()){
                            activeMonths = false;
                        }

                        if(activeMonths){
                            //Determine how many months are active still
                            Integer countMonths = initialDate.monthsBetween(endDate) + 1;
                            if (countMonths <= 0) { countMonths = 1; }
                            //vaiable to hold amount of campaign budget forecasted in the past
                            Decimal pastAmountForecasted = 0.00;
                            for(Campaign_Spend__c forecast : forecastRecordsForCampaign){
                                if(!campaignMonths.contains(forecast.Forecast_Month_Date__c.Month()) && (forecast.Amount__c != 0 && forecast.Amount__c != null)){
                                    pastAmountForecasted += forecast.Amount__c;
                                }
                            }
                            Decimal amountAvailableToForecast = campaignRecord[0].PlannedCampaignSpend__c - pastAmountForecasted;
                            //Divide campaign by months, rounding down to 2 decimals. Remember the remainder.
                            Decimal dividedAmount = amountAvailableToForecast.divide(countMonths, 2, System.RoundingMode.DOWN);
                            Decimal remainderForLastRecord = amountAvailableToForecast - (countMonths * dividedAmount);

                            List<Campaign_Spend__c> forecastRecordsToUpdate = new List<Campaign_Spend__c>();
                            //Iterate through Campaign_Spend__c records to update Amount field
                            for(Campaign_Spend__c forecast : forecastRecordsForCampaign){
                                //check to pull in the Campaign_Spend__c records that match the active months on the Campaign__c record
                                if(campaignMonths.contains(forecast.Forecast_Month_Date__c.Month())){
                                    //If this is the last forecasted month, add the remainder to the amount.
                                    if (forecast.Forecast_Month_Date__c.addMonths(1) > endDate) {
                                        forecast.Amount__c = dividedAmount + remainderForLastRecord;
                                    } else {
                                        forecast.Amount__c = dividedAmount;
                                    }
                                    forecastRecordsToUpdate.add(forecast);
                                }
                            }
                            //update forecastedRecords
                            if(!forecastRecordsToUpdate.isEmpty()){
                                update forecastRecordsToUpdate;
                            }
                        }
                    }
                    //if there are active months then refresh the component
                    if(activeMonths){
                        //reset values on MultiComponent Page
                        BuildQuery();
                        DoRefreshParentFields();
                        return null;
                    } else {
                        //if there are no active months then show an error
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Auto ReForecast button will not forecast for months in the past'));
                        return null;
                    }
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error!, That campaign record is invalid'));
                return null;
            }
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Internal Error!, Please see your administrator'));
            CreateExceptionLog.insertErrorLog('ForecastMultiRecordComponentController', 'DoAutoForecast', String.valueOf(ex), 'Error');
            return null;
        }
        return null;
    }

    /***
    * refreshPage() - resets values on page when Forecast popup is clicked
    ***/
    public PageReference refreshPage() {
        BuildQuery();
        DoRefreshParentFields();
        return null;
    }
}