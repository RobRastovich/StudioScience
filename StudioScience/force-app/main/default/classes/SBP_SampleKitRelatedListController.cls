public class SBP_SampleKitRelatedListController {
    @AuraEnabled
    public static list<Sample_Kit__c> getAllSampleKits(string CaseRecId)
    {
        system.debug('CaseRecId'+CaseRecId);
        List<Sample_Kit__c> kitList=new List<Sample_Kit__c>();
        for(Sample_Kit__c obj:[Select id,Name,Sample_Selected__c,Tracking_Number_Creation_Date__c,Barrel_Order_Group__c,Delivery_Status__c,Tracking_Number__c,Case__c from Sample_Kit__c where Case__c=:CaseRecId  ORDER BY CreatedDate DESC LIMIT 1000])
        {
            kitList.add(obj);
        }
        
        return kitList;
    }
    @AuraEnabled
    public static Map<String, Object> getCaseDetails(string CaseRecId){
        Case caserec = new Case();
        //Added for LSB-143 Cask__c in query
        caserec = [SELECT id,CaseNumber, Cask__c, Barrel_Order_Group__c,Brand__c,Product_Type__c, Submitter__c from Case where id=:CaseRecId];
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('caseRecord', caserec);
        responseMap.put('recordTypeId', SBP_Constants.BRAND_TO_SAMPLE_BARREL_RT_ID.get(caserec.Brand__c));
        return responseMap;
    }
    @AuraEnabled
    public static Boolean DeleteSampleKitRecord(string samplekitdelId){
        Sample_kit__c samplekit = new Sample_Kit__c();
        samplekit= [SELECT ID FROM Sample_Kit__c WHERE ID=:samplekitdelId];
        if(samplekit!=null){
            delete samplekit;
            return true;
        }
        return false;
    }
    
    //Added by Mahesh, which will create new Sample
    @AuraEnabled
    public static Boolean createNewSamples(string samplekitId, String barrelId){
        System.debug('inside createNewSamples:::'+samplekitId+'barrelId is::'+barrelId);
        Id SamplekitCaseId;
        List<Barrel__c> barrelList = new List<Barrel__c>();
        List<Sample_Kit__c> sampleKitList = [Select id,Name,Case__c, Case__r.Brand__c, Case__r.Product_Type__c, Case__r.Barrel__r.Barrel_Number__c from Sample_Kit__c where Id=:samplekitId LIMIT 1];
        System.debug('sampleKitList is::'+sampleKitList);
        
        for(Sample_Kit__c obj : sampleKitList)
        {
            if(samplekitId!=null){
                System.debug('inside if:::'+samplekitId);
                
                SamplekitCaseId = obj.Case__c;
                
                Sample__c sample = new Sample__c();
                sample.Barrel__c = barrelId;
                sample.Sample_Kit__c = samplekitId;
                sample.SampleId__c = obj.Case__r.Barrel__r.Barrel_Number__c;    
                insert sample;
                
            }
        }
        
        //Update Barrel Brand & Record Type for El Tesoro
        List<case> caseList = [Select Id, Brand__c from case where Id=:SamplekitCaseId];
        List<Barrel__c> elTesoroBarrelList = [Select Brand__c, RecordTypeId from Barrel__c where Id=:barrelId];
        List<Barrel__c> elTesoroBarrelListNew = new List<Barrel__c>();
        List<Barrel__c> barrelUpdateList = new List<Barrel__c>();
        for(Case c:caseList){
            if(c.Brand__c == 'El Tesoro'){
                for(Barrel__c b: elTesoroBarrelList){
                    b.Brand__c = 'El Tesoro';
                    b.RecordTypeId = SBP_Constants.EL_TESORO_FULL_BARREL_RT_ID;
                    b.Product_Type__c = '';
                    update b;
                }
            }
            if(c.Brand__c == 'Baker\'s') {
                for(Barrel__c b: elTesoroBarrelList){
                    b.Brand__c = 'Baker\'s';
                    b.RecordTypeId = SBP_Constants.BAKER_SAMPLE_KIT_ID;
                    b.Product_Type__c = '';
                    update b;
                }
            }
            if(c.Brand__c == 'El Tesoro Laphroaig Cask'){             
                for(Barrel__c b: elTesoroBarrelList){
                    b.Brand__c = 'El Tesoro Laphroaig Cask';
                    b.RecordTypeId =  SBP_Constants.ETLC_SAMPLE_KIT_RT_ID;
                    b.Product_Type__c = '';
                    barrelUpdateList.add(b);
                }
                update barrelUpdateList;
            }

        }
        
        List<Sample__c> sampleList = [select Label__c, Sample_Kit__c from Sample__c where Sample_Kit__c=:samplekitId];
        List<Barrel__c> barrelListNew = [select Id, Barrel_Number__c, Case__c from Barrel__c where Case__c=:SamplekitCaseId];
        System.debug('sampleList is:::'+sampleList);
        if(sampleList.size()>0){
            System.debug('inside if:::');
            for(Integer k=0;k<sampleList.size();k++){
                if(barrelListNew.size()>0){
                    System.debug('inside barrel if:::'+barrelListNew);
                    for(Barrel__c b: barrelListNew){
                        System.debug('inside for:::');
                        if(sampleList.size()>=1){
                            sampleList[0].SampleId__c = String.isNotBlank(b.Barrel_Number__c) ? b.Barrel_Number__c + 'A' : 'A';
                            sampleList[0].Label__c = 'A'; 
                        }
                        
                        if(sampleList.size()>=2){
                            sampleList[1].SampleId__c = String.isNotBlank(b.Barrel_Number__c) ? b.Barrel_Number__c + 'B' : 'B';
                            sampleList[1].Label__c = 'B';
                        }
                        
                        if(sampleList.size()>=3){
                            sampleList[2].SampleId__c = String.isNotBlank(b.Barrel_Number__c) ? b.Barrel_Number__c + 'C' : 'C';
                            sampleList[2].Label__c = 'C';
                        }
                    }
                }
            }
            update sampleList;
            return true;
        }
        
        
        return false;
    }
    
    //Added by Mahesh which will return Sample Details for the respective SampleKit based on case id
    @AuraEnabled
    public static List<Sample__c> getSampleDetails(string CaseRecId ){
        
        List<Sample_Kit__c> kitList=[Select id,Name,Sample_Selected__c,Tracking_Number_Creation_Date__c,Barrel_Order_Group__c,Delivery_Status__c,Tracking_Number__c,Case__c from Sample_Kit__c where Case__c=:CaseRecId  ORDER BY CreatedDate DESC LIMIT 1000];
        List<Sample__c> sampleList = new List<Sample__c>();
        for(Sample__c sample: [select Id, Name, Sample_Kit__c from Sample__c where Sample_Kit__c IN :kitList]){
            sampleList.add(sample);
        }
        return sampleList;
    }
}