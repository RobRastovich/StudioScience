public with sharing class SBP_NewPOSCustomizationCmpCtrl {
    @AuraEnabled(cacheable=true)
    public static List<POS_Customization__c> getPOSItems(Id caseId) {
        List<Barrel__c> barrelRecords = [Select id, name from Barrel__C where Case__c =: caseId];
        List<Id> barrelIds = new List<Id>();
        for (Barrel__c b : barrelRecords) {
            barrelIds.add(b.id);
        }
        return [SELECT Id, Name, Type__c, Get_Insert_Text_From__c, Insert_Text__c FROM POS_Customization__c where Barrel__c in :barrelIds];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Barrel__C> getRelatedBarrels(Id caseId){
        return [Select id, name, Brand__c from Barrel__C where Case__c =: caseId];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getPOSMetaData(Id caseId){
        List<Id> srIds = new List<Id>(); 
        Map<Id,String> srIdToName = new Map<Id,String>();
        Map<String, Boolean> typeOptionsMap = new Map<String, Boolean>();
        
        Case c = [Select Id, Brand__c, Account_State__c, Premise_Type__c, State__c from Case where Id =: caseId];
        
        for (POS_Static_Resource__mdt sr : POS_Static_Resource__mdt.getAll().values()) {
            if (sr.Brand__c == c.Brand__c) {
                srIds.add(sr.Id);
                srIdToName.put(sr.Id, sr.Item_Text__c);
            }
        }
        
        for (POS_State_Setting__mdt ss : POS_State_Setting__mdt.getAll().values()) {
            if (srIds.contains(ss.POS_Static_Resource__c) && ss.Is_Active__c && ss.Premise_Type__c == c.Premise_Type__c && 
                (ss.State__c=='' || ss.State__c==null || (ss.State__c=='Oregon' && c.Account_State__c=='OR') || 
                 (ss.State__c=='New York' && c.Account_State__c=='NY'))) {
                String ssLabel = srIdToName.get(ss.POS_Static_Resource__c);
                if (!typeOptionsMap.containsKey(ssLabel)) {
                    if(ssLabel != null) {
                        typeOptionsMap.put(ssLabel, ss.Show_Text_Options__c);
                    }
                }
            }
        }
        return typeOptionsMap;
    }

    @AuraEnabled
    public static POS_Customization__c insertPOSItem(String type, Id uploadedBy, String insertTextValue, 
                    DateTime POSdate, Id barrelId, Integer quantity, String street, String state, 
                    String insertText, String carrier, Boolean signatureCheckbox, String attEmail,
                    String status, Boolean staveCheckbox, String IOCode, String company, String zip,
                    String attention, String city, String phone, String trackId, String trackUrl)
    {
        POS_Customization__c newPOS = new POS_Customization__c();
        newPOS.RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID;
        newPOS.Type__c = type;
        newPOS.Uploaded_by__c = uploadedBy;
        if(insertTextValue!=null || insertTextValue=='') {
        	newPOS.Get_Insert_Text_From__c = insertTextValue;
        }
        newPOS.Uploaded_Date__c = POSdate;
        newPOS.Barrel__c = barrelId;
        newPOS.Quantity__c = quantity;
        newPOS.Street__c = street;
        newPOS.State__c = state;
        newPOS.Insert_Text__c = insertText;
        newPOS.Carrier__c = carrier;
        newPOS.Include_Signature_on_Label__c = signatureCheckbox;
        newPOS.Attention_Email__c = attEmail;
        if(status!=null || status==''){
            newPOS.Status__c = status;
        }
        newPOS.Include_Stave_Selection_on_Label__c = staveCheckbox;
        newPOS.IO_Code__c = IOCode;
        newPOS.Company__c = company;
        newPOS.Zip__c = zip;
        newPOS.Attention__c = attention;
        newPOS.City__c = city;
        newPOS.Phone__c = phone;
        newPOS.Tracking_Number__c = trackId;
        newPOS.Tracking_URL__c = trackUrl;
        insert newPOS;
        return newPOS;
    }
}