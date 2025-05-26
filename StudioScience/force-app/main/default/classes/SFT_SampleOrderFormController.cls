public without sharing class SFT_SampleOrderFormController { 
    
    @AuraEnabled
    public static Sample_Kit_Shipping_Address__c fetchShippingAddress( String stateValue) {        
        List<Sample_Kit_Shipping_Address__c> sampleAddress = [SELECT Id, Company__c, City__c, Zip_Code__c,
                                                              Country__c, State__c,Name, Street__c 
                                                              FROM Sample_Kit_Shipping_Address__c 
                                                              WHERE State__c = : stateValue 
                                                              AND Country__c = 'Canada'];
        if(sampleAddress.size() != 0)        
            return sampleAddress[0];
        else
            return new Sample_Kit_Shipping_Address__c();
    }
    
    @AuraEnabled
    public static List<String> filterStatesByCountry( String country) {        
        List<Sample_Kit_Shipping_Address__c> sampleAddress = [SELECT Id, Company__c, City__c, Zip_Code__c,
                                                              Country__c, State__c,Name, Street__c
                                                              FROM Sample_Kit_Shipping_Address__c 
                                                              WHERE Country__c =: country];
        Set<String> statesSet = new Set<String>();
        for(Sample_Kit_Shipping_Address__c sk : sampleAddress) {
            statesSet.add(sk.State__c);
        }
        List<String> stateList = new List<String>();
        for(String state : statesSet)
        {
            stateList.add(state);
        }
        return stateList;
    }
    
    @AuraEnabled
    public static List<String> filterOfficeValueByState( String country, String stateVal) {        
        List<Sample_Kit_Shipping_Address__c> sampleAddress = [SELECT Id, Company__c, City__c, Zip_Code__c,
                                                              Country__c, State__c,Name, Street__c
                                                              FROM Sample_Kit_Shipping_Address__c 
                                                              WHERE Country__c =: country 
                                                              AND State__c =: stateVal
                                                              AND Legal_to_receive_Sample_Kit__c = true];
        Set<String> nameSet = new Set<String>();
        for(Sample_Kit_Shipping_Address__c sk : sampleAddress) {
            nameSet.add(sk.Name);
        }
        List<String> nameList = new List<String>();
        for(String nm : nameSet)
        {
            nameList.add(nm);
        }
        return nameList;
    }
    
    @AuraEnabled
    public static Sample_Kit_Shipping_Address__c filterExactInfo( String country, String stateVal, String shipTo) {        
        List<Sample_Kit_Shipping_Address__c> sampleAddress = [SELECT Id, Company__c, City__c, Zip_Code__c,
                                                              Country__c, State__c,Name, Street__c
                                                              FROM Sample_Kit_Shipping_Address__c
                                                              WHERE Country__c =: country 
                                                              AND State__c =: stateVal 
                                                              AND Name =: shipTo];
        if(sampleAddress.size() != 0)        
            return sampleAddress[0];
        else
            return new Sample_Kit_Shipping_Address__c();
    }
    
    @AuraEnabled
    public static List<String> fetchOfficeValues() {        
        List<Sample_Kit_Shipping_Address__c> sampleAddress = [SELECT Id, Company__c, City__c, Zip_Code__c,
                                                              Country__c, State__c, Name
                                                              FROM Sample_Kit_Shipping_Address__c];
        Set<String> nameSet = new Set<String>();
        for(Sample_Kit_Shipping_Address__c sk : sampleAddress) {
            nameSet.add(sk.Name);
        }
        List<String> nameList = new List<String>();
        for(String name : nameSet)
        {
            nameList.add(name);
        }
        return nameList;
    }
    
    @AuraEnabled
    public static List<String> fetchFamilyValues() {        
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Is_Active__c = true];
        Set<String> familySet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            familySet.add(sk.Brand_Family__c);
        }
        List<String> familyList = new List<String>();
        for(String family : familySet)
        {
            familyList.add(family);
        }
        return familyList;
    }
    
    @AuraEnabled
    public static List<String> fetchVarietyValues() {        
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c, 
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c 
                                                                FROM Sample_Order_Material_Master__c 
                                                                WHERE Is_Active__c = true];
        Set<String> varietySet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            varietySet.add(sk.Brand_Variety__c);
        }
        List<String> varietyList = new List<String>();
        for(String variety : varietySet)
        {
            varietyList.add(variety);
        }
        return varietyList;
    }
    
    @AuraEnabled
    public static List<String> fetchMaterialDescValues() {        
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c 
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Is_Active__c = true];
        Set<String> matDescSet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            matDescSet.add(sk.Material_Description__c);
        }
        List<String> matDescList = new List<String>();
        for(String matDesc : matDescSet)
        {
            matDescList.add(matDesc);
        }
        return matDescList;
    }
    
    @AuraEnabled
    public static List<String> filterVarietyByFamilyValue(String family, String soldTo) { 
        String soldToValue = soldTo.split('\\(').get(0);
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Brand_Family__c =: family
                                                                AND Sold_to__c =: soldToValue
                                                                AND Is_Active__c = true];
        Set<String> varSet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            varSet.add(sk.Brand_Variety__c);
        }
        List<String> varList = new List<String>();
        for(String vari : varSet)
        {
            varList.add(vari);
        }
        return varList;
    }
    
    @AuraEnabled
    public static List<String> filterMaterialDescByVarietyValue(String family, String variety, String soldTo) {
        String soldToValue = soldTo.split('\\(').get(0);        
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Brand_Family__c =: family
                                                                AND Brand_Variety__c =: variety 
                                                                AND Sold_to__c =: soldToValue
                                                                AND Is_Active__c = true];
        Set<String> matDescSet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            matDescSet.add(sk.Material_Description__c);
        }
        List<String> matDescList = new List<String>();
        for(String matDesc : matDescSet)
        {
            matDescList.add(matDesc);
        }
        return matDescList;
    }
    
    @AuraEnabled
    public static List<String> filterUnitValues(String family, String variety, String description) {        
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Brand_Family__c =: family 
                                                                AND Brand_Variety__c =: variety 
                                                                AND Material_Description__c =: description 
                                                                AND Is_Active__c = true];
        Set<String> unitSet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            if(sk.Unit_of_measure__c == 'CS' || sk.Unit_of_measure__c == 'ZCFG') {
                unitSet.add('CS');
                //unitSet.add('BO');   //for SAL-2683
            } else if(sk.Unit_of_measure__c == 'EA' || sk.Unit_of_measure__c == 'ZCAS') {
                unitSet.add('EA');
            }
        }
        List<String> unitList = new List<String>();
        for(String unit : unitSet)
        {
            unitList.add(unit);
        }
        return unitList;
    }
    
    @AuraEnabled
    public static Sample_Order_Material_Master__c filterMaterialNoByDescValue(String family, String variety, String description, String soldTo) {        
        String soldToValue = soldTo.split('\\(').get(0);
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Brand_Family__c =: family 
                                                                AND Brand_Variety__c =: variety 
                                                                AND Material_Description__c =: description 
                                                                AND sold_to__c =: soldToValue
                                                                AND Is_Active__c = true];
        return sampleMaterial[0];
    }
    
    @AuraEnabled
    public static List<String> filterAllSoldToValues() {        
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c 
                                                                WHERE Is_Active__c = true];
        Set<String> soldToSet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            String soldTo = sk.Sold_to__c + '(' + sk.Customer_Number__c + ')';
            soldToSet.add(soldTo);
        }
        List<String> soldToList = new List<String>();
        for(String sol : soldToSet)
        {
            soldToList.add(sol);
        }
        return soldToList;
    }
    
    @AuraEnabled
    public static List<String> filterFamilyValueBySoldTo(String soldTo) { 
        String soldToValue = soldTo.split('\\(').get(0);
        List<Sample_Order_Material_Master__c> sampleMaterial = [SELECT Id, Brand_Family__c, Brand_Variety__c,
                                                                CMIR__c, Customer_Number__c, Is_Active__c,
                                                                Material_Description__c, Material_Master_ID__c,
                                                                Material_Number__c, Name, Sold_to__c, Unit_of_measure__c
                                                                FROM Sample_Order_Material_Master__c
                                                                WHERE Sold_to__c=: soldToValue 
                                                                AND Is_Active__c= true];
        Set<String> famSet = new Set<String>();
        for(Sample_Order_Material_Master__c sk : sampleMaterial) {
            famSet.add(sk.Brand_Family__c);
        }
        List<String> famList = new List<String>();
        for(String fam : famSet)
        {
            famList.add(fam);
        }
        return famList;
    }
    
    @AuraEnabled
    public static List<String> getCountryState(String country) { 
        List<Country_State__c> countryStateList = [Select Id, Name, Abbreviations__c, Country__c
                                                   FROM Country_State__c
                                                   WHERE Country__c = : country];
        List<String> stateList = new List<String>();
        for(Country_State__c c: countryStateList) {
            stateList.add(c.Name);
        }
        return stateList;
    }
    
    @AuraEnabled
    public static String getStateFullName(String stateVal) { 
        List<Country_State__c> stateList = [Select Id, Name, Abbreviations__c, Country__c 
                                            FROM Country_State__c 
                                            WHERE Abbreviations__c=: stateVal];
        return stateList[0].Name;
    }
    
    @AuraEnabled
    public static String saveCase(String jsonFormString) {
        SampleOrderWrapper orderWrapper = new SampleOrderWrapper();
        orderWrapper = (SampleOrderWrapper)system.JSON.deserialize(jsonFormString, SampleOrderWrapper.class);
        Case sampleOrderCase = new Case();
        sampleOrderCase.Status = 'New';
        sampleOrderCase.Priority = 'Medium';
        sampleOrderCase.Origin = 'Customer Portal';
        sampleOrderCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sample_Orders').getRecordTypeId();
        sampleOrderCase.Customer_Email_Address__c = orderWrapper.email;
        sampleOrderCase.Sample_Type__c = orderWrapper.sampleType;
        sampleOrderCase.Submitted_By__c = orderWrapper.submittedBy;
        sampleOrderCase.Customer_Phone_Number__c = orderWrapper.phone;
        sampleOrderCase.Cost_Center__c = orderWrapper.cost;
        sampleOrderCase.Do_you_need_this_sooner_than_the_normal__C = orderWrapper.normalTime;
        if(orderWrapper.courier == 'Yes') {
            sampleOrderCase.Is_a_courier_tracking_required__c = true;
        } else {
            sampleOrderCase.Is_a_courier_tracking_required__c = false;
        }
        sampleOrderCase.GL_Number__c = orderWrapper.gl;
        sampleOrderCase.WBS_element__c = orderWrapper.wbs;
        sampleOrderCase.Case_Country__c = orderWrapper.country;
        sampleOrderCase.Sample_Order_Information__c = System.JSON.serialize(orderWrapper);
        insert sampleOrderCase;
        
        if(!Test.isRunningTest()) {
            generatePdf(sampleOrderCase.Id, orderWrapper.submittedBy);
        }
        return sampleOrderCase.Id;
    }
    
    @AuraEnabled
    public static void generateEskerPdf(String caseId, String submittedPerson) {
        if(!Test.isRunningTest()) {
            generatePdfForEsker(caseId, submittedPerson);
        }
    }
    
    @future(callout=true)
    public static void generatePdf(String caseId, String submitterName) {
        PageReference pdfPage = new PageReference('/apex/SampleOrderPDF?id=' + caseId);
        Blob pdfBody ; 
        try{
            pdfBody = pdfPage.getContentasPdf();
        } catch(Exception e) {
            pdfBody = Blob.valueOf(e.getMessage());
        }
        List<Case> sampleCase = [SELECT Id, CaseNumber FROM Case WHERE Id =: caseId];
        String fileName = submitterName + ' Sample '+ sampleCase[0].CaseNumber + ' - Order Confirmation';
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = pdfBody;
        ContVerFile.Title = fileName; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient=fileName + '.pdf';
        insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId
                     FROM ContentVersion
                     WHERE Id =:ContVerFile.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = caseId;
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        sendEmailToSubmitter(caseId);
    }
    
    @future(callout=true)
    public static void generatePdfForEsker(String caseId, String submitterName) {
        PageReference pdfPage = new PageReference('/apex/SampleOrderPDFForEsker?id=' + caseId);
        Blob pdfBody ; 
        try{
            pdfBody = pdfPage.getContentasPdf();
        } catch(Exception e) {
            pdfBody = Blob.valueOf(e.getMessage());
        }
        List<Case> sampleCase = [SELECT Id, CaseNumber FROM Case WHERE Id =: caseId];
        String fileName = submitterName + ' Sample '+ sampleCase[0].CaseNumber + ' - Esker Form';
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = pdfBody;
        ContVerFile.Title = fileName; 
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient=fileName + '.pdf';
        insert ContVerFile;
        Id conDoc = [SELECT ContentDocumentId
                     FROM ContentVersion
                     WHERE Id =:ContVerFile.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = caseId;
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;
    }
    
    public static void sendEmailToSubmitter(Id caseId) {
        List<Case> cases = [SELECT Id, CaseNumber, Submitted_By__c 
                            FROM Case 
                            WHERE Id =: caseId];
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: cases[0].Id];
        List<Id> contentDocumentIdLst = new List<Id>();
        for(ContentDocumentLink cdl : cdLinkList) {
            contentDocumentIdLst.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId, ContentSize,
                                                   FileExtension, FileType, PathOnClient
                                                   FROM ContentVersion 
                                                   WHERE ContentDocumentId IN: contentDocumentIdLst];
        List<Id> contVerIdLst = new List<Id>();
        for(ContentVersion cv : contentVersionList) {
            if(cv.PathOnClient.containsIgnoreCase('Order Confirmation')) {
                contVerIdLst.add(cv.Id);
            }
        }
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'SC_NA_Samples@beamsuntory.com'];
        Id userId = UserInfo.getUserId();
        List<User> userLst = [SELECT Id, Name, Email FROM USER WHERE Id =: userId];
        String subjectText = 'Sample Order Form Submitted';
        String emailBody = 'Hi '+ userLst[0].Name +',<br/><br/>';
        emailBody += 'Your recent Sample Order has been submitted successfully! Attached is the PDF of your order, please reference this for further details. Please note the shipment may not arrive in entirety and is subject to delays if allocation limits have been reached.<br/><br/>';
        emailBody += 'The case number below is to be used as a reference for this order.<br/>';
        emailBody += 'Case #' + cases[0].CaseNumber + '<br/><br/>';
        emailBody += 'Please reach out to Customer Service Team for any questions. <br/><br/>';
        emailBody += 'Thank you';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setEntityAttachments(contVerIdLst);
        if(orgWideEmail.size()>0 && !Test.isRunningTest()) {
            email.setOrgWideEmailAddressId(orgWideEmail[0].Id);
        }
        email.toAddresses = new String[] {userLst[0].Email};
        email.setSubject(subjectText);
        email.setHtmlBody(emailBody);
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch(EmailException e) {
            if (e.getMessage().contains('UNVERIFIED_SENDER_ADDRESS')) {
            } else {
            throw e;
            }
        }
    }
    
    public class SampleOrderWrapper {
        @AuraEnabled
        public String avail{get;set;}
        @AuraEnabled
        public String mailroom{get;set;}
        @AuraEnabled
        public String req{get;set;}
        @AuraEnabled
        public Boolean normalTime{get;set;}
        @AuraEnabled
        public String expedited{get;set;}
        @AuraEnabled
        public Boolean beamCanada{get;set;}
        @AuraEnabled
        public String wbs{get;set;}
        @AuraEnabled
        public String notes{get;set;}
        @AuraEnabled
        public String courier{get;set;}
        
        @AuraEnabled
        public String submittedBy{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String sampleType{get;set;} 
        @AuraEnabled
        public String phone{get;set;} 
        @AuraEnabled
        public String purpose{get;set;} 
        @AuraEnabled
        public String soldTo{get;set;} 
        @AuraEnabled
        public String cost{get;set;} 
        @AuraEnabled
        public String gl{get;set;}
        @AuraEnabled
        public String shipTo{get;set;}
        @AuraEnabled
        public String company{get;set;}
        @AuraEnabled
        public String attn{get;set;}
        @AuraEnabled
        public String addr{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String country{get;set;}
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String zip{get;set;}
        @AuraEnabled
        public String pho{get;set;}
        @AuraEnabled
        public String stateAbb{get;set;}
        @AuraEnabled
        public List<OrderInformationTable> lss{get;set;}
        @AuraEnabled
        public String estimatedValueYes_NO{get;set;}
        @AuraEnabled
        public String estimatedInputValue{get;set;} 
    }
    
    public class OrderInformationTable {
        @AuraEnabled
        public String brandFamily{get;set;}
        @AuraEnabled
        public String brandVariety{get;set;}
        @AuraEnabled
        public String materialDesc{get;set;} 
        @AuraEnabled
        public String materialNo{get;set;} 
        @AuraEnabled
        public String cmir{get;set;} 
        @AuraEnabled
        public String qty{get;set;} 
        @AuraEnabled
        public String unit{get;set;}
        @AuraEnabled
        public List<SelectOptions> brandVarietyList{get;set;}
        @AuraEnabled
        public List<SelectOptions> materialDescList{get;set;}
        @AuraEnabled
        public List<SelectOptions> unitList{get;set;}
    }
    
    @AuraEnabled
    public static List<SelectOptions> getPicklistValues(String ObjectApi_name, String Field_name) {
        List<String> pickListValues = new List<String>();
        List<SelectOptions> picklistOptions = new List<SelectOptions>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) { 
            picklistOptions.add(new SelectOptions(a.getLabel(), a.getValue()));
        }
        return picklistOptions;
    }
    
    public class SelectOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public SelectOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
}