/**************************************************************************************
Apex Class          : BS_PR_EditPRDetailsListCtrl2
Test Class          : BS_PR_EditPRDetailsListCtrl2_Test
Author              : Harikrishna P 
Function            : Controller for BS_PR_PRDetailslist vf page

Updates :
*************************************************************************************/

public with sharing class BS_PR_EditPRDetailsListCtrl2 {
    
    id PR_Headerid;
    public final boolean isAccessible{get;set;}
    public final boolean isProcurementEditable{get;set;}
    //public boolean editallflag {get; set;}
    public boolean saveRowflag {get; set;}
    public boolean displaySaveAllflag {get; set;}
    public BS_PR_EditPRDetailsListCtrl2(ApexPages.StandardController controller) {
        PR_Headerid=ApexPages.currentPage().getParameters().get('id');
        isAccessible=Schema.sObjectType.PR_Detail__c.fields.Approved__c.isUpdateable();
        isProcurementEditable=Schema.sObjectType.PR_Detail__c.fields.GL_Details__c.isUpdateable();
        queryPRDetailsList();
    }    
    
    public map<id,PR_Detail__c> PR_Detail_Map=new map<id,PR_Detail__c>();
    set<id> filtered_recIds;
    public List<PR_Detail__c> PRDetailsList{get;set;}
    public List<PR_Detail__c> queryPRDetailsList(){
        PR_Detail_Map=new map<id,PR_Detail__c>();
        filtered_recIds=new set<id>();        
        PRDetailsList=PRDetails_QueryResults(filtered_recIds);
        return PRDetailsList;
    }
    public List<PR_Detail__c> PRDetails_QueryResults(set<id> prdrecIds){
        string queryString='SELECT id,name,Hidden_Edit__c,PR_Header__c,Campaign__c,Campaign_ID__c,Campaign_Name__c,IOCode__c,Brand__c,Territory__c,'+
                       'Description__c,GLAccountType__c,GL_Code_Description__c,GL_Code_Options__c,GL_Comments__c,GL_Details__c,GLDescription2__c,'+
                       'GL_Code2__c,Status_Flag__c,Campaign_Balance__c,Material_Group__c,Account_Assignment_Category2__c,EndMonth__c,StartMonth__c,'+
                       'Phasing_Type__c,PR_Amount__c,Phasing_Amount__c,Plant__c,Approved__c,Rejection_Comments__c,Finance_Approved__c,Help_Text__c,'+
                   'Phasing_Records_Count__c,Campaign_Balance_USD__c,Filter_Text__c '+
                       ' from PR_Detail__c Where PR_Header__c=:PR_Headerid';
        if(prdrecIds.size()>0) queryString+=' AND ID IN:prdrecIds';
        queryString+=' ORDER BY CreatedDate ASC';
        for(PR_Detail__c prd:database.query(queryString)){                                                
        PR_Detail_Map.put(prd.id,prd);
        }        
        return PR_Detail_Map.values();
    }
    public PageReference updatePRDetailsList() {                
        filtered_recIds=new set<id>();
        set<string> errorSet=new set<string>();
        for(PR_Detail__c prd:PR_Detail_Map.values()){
            prd.Hidden_Edit__c=false;
        }
        Database.saveResult [] saveResultList;
        try{
            saveResultList = database.update(PR_Detail_Map.values(),false);
        }catch(system.DmlException ex){
            system.debug('exception in save row...'+ex);           
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        } 
        system.debug('** updatePRDetailsList..saveResultList...'+saveResultList);            
        for (Database.saveResult sr : saveResultList) {
            system.debug('sr.isSuccess().....'+sr.isSuccess()+'...rec id::'+sr.getId());
            if(sr.isSuccess()){
              filtered_recIds.add(sr.getId());                             
            }
            else{
              for(Database.Error err : sr.getErrors()) {
                  if(err.getMessage().contains('duplicate'))
                  errorSet.add('This line is a duplicate of another line in the PR request. Please modify the GL code or delete the line.');
                    else errorSet.add(err.getMessage());   
                }                
            }
        }
                
        if(filtered_recIds.size()==PR_Detail_Map.size()){            
            system.debug('I am in queryPRDetailsList loop');
            queryPRDetailsList();
            saveRowflag=false;    
          displaySaveAllflag=false;
        }
        else{            
            system.debug('I am in else loop to filter the failed records');
            for(PR_Detail__c prd:PRDetailsList=PRDetails_QueryResults(filtered_recIds)){
                system.debug('in loop....'+prd);
                if(!filtered_recIds.contains(prd.id)){
                    prd.Hidden_Edit__c=true;
                    saveRowflag=false;
                    displaySaveAllflag=true;
                    system.debug('failed record updated back to edit=true....'+prd);
                }
                //else PR_Detail_Map.remove(prd.id);
          }            
      system.debug('PRDetailsList...'+PRDetailsList);
            system.debug('PR_Detail_Map...'+PR_Detail_Map);
        }
        if(errorSet.size()>0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'ERRORS: '+JSON.serialize(errorSet)));            
        }
        return null;
    }         
    public PageReference editRow() { 
        PR_Detail_Map.get(prdRecordID).Hidden_Edit__c=true;
        saveRowflag=true;          
        return null;
    }     
    public PageReference editAll() {                
        for(PR_Detail__c prd:PR_Detail_Map.values()){
            prd.Hidden_Edit__c=true;
        }
        //editallflag=true;
        displaySaveAllflag=true;
        saveRowflag=false; 
        return null;
    }
    public PageReference viewAll() { 
        //editallflag=false;
    displaySaveAllflag=false;        
        for(PR_Detail__c prd:PR_Detail_Map.values()){
            prd.Hidden_Edit__c=false;
        }        
        return null;
    }
    public PageReference saveRow() { 
        PR_Detail__c prdrecord=PR_Detail_Map.get(prdRecordID);
        prdrecord.Hidden_Edit__c=false;
        filtered_recIds=new set<id>{prdRecordID};
        try{
            update prdrecord;
            //queryPRDetailsList();            
            PRDetailsList=PRDetails_QueryResults(filtered_recIds);
            saveRowflag=false;
        }catch(system.DmlException ex){
            system.debug('exception in save row...'+ex);
            prdrecord.Hidden_Edit__c=true;            
            if(ex.getMessage().contains('DUPLICATE_VALUE'))
              ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'This line is a duplicate of another line in the PR request. Please modify the GL code or delete the line.'));
            else if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
              ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }                      
        return null;
    }
    
    public PageReference copyMonthValuesToPRDetails() {                
        filtered_recIds=new set<id>();
        set<string> errorSet=new set<string>();
    PR_Detail__c prdrecord=PR_Detail_Map.get(prdRecordID);
        for(PR_Detail__c prd:PR_Detail_Map.values()){
            prd.Hidden_Edit__c=false;
            if(prd.StartMonth__c==null && prd.EndMonth__c==null){
              prd.StartMonth__c=prdrecord.StartMonth__c;
        prd.EndMonth__c=prdrecord.EndMonth__c;    
            }            
        }
        Database.saveResult [] saveResultList;
        try{
            saveResultList = database.update(PR_Detail_Map.values(),false);
        }catch(system.DmlException ex){
            system.debug('exception in save row...'+ex);           
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }        
        return null;
    }
    public PageReference autoSaveRow() { 
        PR_Detail__c prdrecord=PR_Detail_Map.get(prdRecordID);
        prdrecord.Hidden_Edit__c=false;
        filtered_recIds=new set<id>{prdRecordID};
        try{
            update prdrecord;            
            PRDetailsList=PRDetails_QueryResults(filtered_recIds);
        }catch(system.DmlException ex){
            system.debug('exception in save row...'+ex);
            //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }           
        PR_Detail_Map.get(prdRecordID).Hidden_Edit__c=true;
        return null;
    }
    public PageReference clonePRDetailRecord() {
        PR_Detail__c prdrecord=PR_Detail_Map.get(prdRecordID);
        PR_Detail__c prd=new PR_Detail__c(
                PR_Header__c=PR_Headerid
                ,Campaign__c=prdrecord.Campaign__c
                ,Campaign_ID__c=prdrecord.Campaign_ID__c
                ,Campaign_Name__c=prdrecord.Campaign_Name__c
                ,Brand__c=prdrecord.Brand__c
                ,GLAccountType__c=prdrecord.GLAccountType__c
                //,GL_Code2__c=prdrecord.GL_Code2__c
                ,IOCode__c=prdrecord.IOCode__c
                ,Territory__c=prdrecord.Territory__c
                ,GLDescription2__c=prdrecord.GLDescription2__c
              ,Cloned_From__c=prdRecordID
                ,Unique_Key__c=PR_Headerid+prdrecord.Campaign_ID__c+prdrecord.IOCode__c+prdRecordID
        );
        try{
            insert prd;
            PRDetailsList=PRDetails_QueryResults(new set<id>{prd.id});
            PR_Detail_Map.get(prd.id).Hidden_Edit__c=true;
        }catch(system.DmlException ex){
            system.debug('exception in clonePRDetailRecord...'+ex);
            if(ex.getMessage().contains('DUPLICATE_VALUE'))
              ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'This line is a duplicate of another line in the PR request. Please modify the GL code or delete the line.'));
            else ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        saveRowflag=true;
        return null;
    }
    public PageReference deleteRow() { 
        PR_Detail_Map.get(prdRecordID).Hidden_Edit__c=false;
        try{
            delete PR_Detail_Map.get(prdRecordID);
            //queryPRDetailsList();
            PR_Detail_Map.remove(prdRecordID);
            PRDetailsList=PR_Detail_Map.values();
            //saveRowflag=false;
        }catch(system.DmlException ex){
            system.debug('exception in delete row...'+ex);
            //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }                 
        return null;
    }
    public PageReference cancelRow() { 
        PR_Detail_Map.get(prdRecordID).Hidden_Edit__c=false;
        filtered_recIds=new set<id>{prdRecordID};        
        PRDetailsList=PRDetails_QueryResults(filtered_recIds);
        saveRowflag=false;
    displaySaveAllflag=true;        
        return null;
    }
    public PageReference cancelAll() { 
        queryPRDetailsList();              
        saveRowflag=false;
        //editallflag=false;
    displaySaveAllflag=false;        
        return null;
    }
    
    public id prdRecordID {set;get;}
    public PR_Detail__c prdRecord {set;get;}    
    public List<PR_Phasing__c > PhasingList{set;get;}
    public List<PR_Phasing__c > queryPhasingData(){
        system.debug('prdRecordID...'+prdRecordID);        
        PhasingList=[select id,Name,Month__c,Phasing_Amount__c from PR_Phasing__c Where PR_Detail__c=:prdRecordID];
        system.debug('PhasingList...'+PhasingList);
        return PhasingList;
    }
    
    public boolean displayPopup {get; set;} 
    public boolean phEditMode{set;get;}
    public void showPopup(){
        queryPhasingData();
        prdRecord=PR_Detail_Map.get(prdRecordID);
        if(prdRecord.Phasing_Type__c=='Monthly') phEditMode=true;
        else phEditMode=false;
        displayPopup = true;
        
    } 
    public void closePopup(){      
        displayPopup = false;        
    }    
    public PageReference updatePRDetailRecord() {
        system.debug('prdRecord...'+prdRecord);
        try{
            update prdRecord;
            PR_Detail_Map.put(prdRecord.ID,prdRecord);
            showPopup();            
        }catch(system.DmlException ex){
            system.debug('DmlException...'+ex);
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }        
        return null;
    }
    
    public PageReference updatePhasingList() {
        system.debug('PhasingList...'+PhasingList);
        try{
            update PhasingList;
            //filtered_recIds=new set<id>{prdRecord.ID};        
            //PRDetails_QueryResults(filtered_recIds);
            //prdRecord=PR_Detail_Map.get(prdRecord.ID);
        }catch(system.DmlException ex){
            system.debug('DmlException...'+ex);             
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        displayPopup = true;
        return null;
    }  
    
}