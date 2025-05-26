public class ProcessSelectedCaseIDsController {
    
    public string[] SelectedCaseIDs{get;set;}
    public string CaseString{get;set;}
    public List<Case> caseList = new List<Case>();
    public ProcessSelectedCaseIDsController(ApexPages.StandardSetController listcontroller){
        SelectedCaseIDs = new string[]{};
            for(Case caserec : (Case[])listcontroller.getSelected()){
                SelectedCaseIDs.add(caserec.Id);
            }
        system.debug('=============== selected caseid records==='+SelectedCaseIDs);
        CaseString = JSON.serialize(SelectedCaseIDs);
        system.debug('=============== CaseString ==='+CaseString);
    }
    
    @AuraEnabled
    public static CaseRecordTypeListWrapper getRecordType(String[] CaseIds)
    {
        CaseRecordTypeListWrapper caseWrapper = new CaseRecordTypeListWrapper();
        string CaseStringserialize;
        Set<String> RecordTypeIdSet = new Set<String>();
        String recordTypeId = 'default';
        List<Case> caseRecord = [Select id, Type, RecordTypeId, Case_Record_Type__c from Case where ID IN:CaseIds];
        for(Case c:caseRecord){
            recordTypeIdSet.add(c.RecordTypeId);    
        }
        system.debug('recordTypeIdSet---->');
        system.debug(recordTypeIdSet);
        CaseStringserialize = JSON.serialize(caseRecord);
        if(recordTypeIdSet.size()==1){
            recordTypeId = (new List<String>(recordTypeIdSet).get(0));
            caseWrapper.caseRecordType = recordTypeId;
            caseWrapper.caseList = CaseStringserialize;
            return caseWrapper;
        } 
        else if(recordTypeIdSet.size()>1){
            recordTypeId = 'multiple';
            caseWrapper.caseRecordType = recordTypeId;
            return caseWrapper;
        }
        else{
            caseWrapper.caseRecordType = recordTypeId;
            return caseWrapper;    
        } 
    }
    
    public class CaseRecordTypeListWrapper{
        @AuraEnabled
        public String caseRecordType{get;set;}
        @AuraEnabled
        public String caseList{get;set;}
    }
    
    @AuraEnabled
    public static Boolean updateType(String type,String CaseIds) {
        System.debug('Entered class aura method');
        Boolean isUpdated;
        try{
            system.debug('the value is ==='+type);
            system.debug('case List ===='+CaseIds);
            List<Case> CaseRecords = new List<Case>();
            if(String.isBlank(CaseIds) == false){
               CaseRecords = (List<Case>)JSON.deserialize(CaseIds, list<Case>.class); 
            }
            List<Case>CaseRecordstoUpdate = new List<Case>();
            for(Case c: CaseRecords){
                c.Type = type;
                CaseRecordstoUpdate.add(c);
                system.debug('=======case record to be updated===='+c.casenumber);
            }
            //system.assert(false,CaseRecordstoUpdate.size());
            isUpdated= false;
            if(CaseRecordstoUpdate.size()>0){
                update CaseRecordstoUpdate;
                isUpdated=True;
            }
        }
        catch(Exception e){
            system.debug('=======got error===='+e.getMessage());
            throw new AuraHandledException('Error Exception happend'+e.getMessage());
        }
        system.debug('isUpdated---'+isUpdated);
        return isUpdated;
    }
    
    @AuraEnabled
    public static Boolean updateDistributorCategory(String distributorCategory,String[] CaseIds) {
        System.debug('Entered class aura method');
        Boolean isUpdated;
        try{
            system.debug('the value is ==='+distributorCategory);
            system.debug('case ids ===='+CaseIds);
            List<Case> CaseRecords = new List<Case>();
            if(!CaseIds.isEmpty() ){
                CaseRecords = [SELECT ID,CaseNumber,Distributor_Category__c from Case WHERE ID IN:CaseIds];
                
                system.debug('=======case records retrieved==='+CaseRecords);
            }
            List<Case>CaseRecordstoUpdate = new List<Case>();
            for(Case c: CaseRecords){
                c.Distributor_Category__c = distributorCategory;
                CaseRecordstoUpdate.add(c);
                system.debug('=======case record to be updated===='+c.casenumber);
            }
            //system.assert(false,CaseRecordstoUpdate.size());
            isUpdated= false;
            if(CaseRecordstoUpdate.size()>0){
                update CaseRecordstoUpdate;
                isUpdated=True;
            }
        }
        catch(Exception e){
            system.debug('=======got error===='+e.getMessage());
            throw new AuraHandledException('Error Exception happend'+e.getMessage());
        }
        return isUpdated;
    }

    public PageReference doRedirect(){
        String userId = UserInfo.getUserId();
        PageReference pageRef = new PageReference('/lightning/o/Case/list?');
        pageRef.getParameters().put('UserId',userId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}