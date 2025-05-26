public class POSCustomizationServices {
    public static Boolean runTrigger = true;
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:
Inputs:        accountId:
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateInsertTextWithAccountName(Map<Id, POS_Customization__c> posItemMap) {
        Map<Id, POS_Customization__c> posItemsToUpdate = new Map<Id, POS_Customization__c>();
        Map<Id, POS_Customization__c> posItemsToUpdateNew = new Map<Id, POS_Customization__c>();
        //Map<Id, POS_Customization__c> barrel
        
        Id caseId;//added by mahesh
        String insertText;//added by mahesh
        List<POS_Customization__c> posItems = [select Id
                                               , Type__c
                                               , Insert_Text__c
                                               , Barrel__c
                                               , Barrel__r.Case__c
                                               , Barrel__r.Brand__c
                                               , Get_Insert_Text_From__c
                                               , Barrel__r.Case__r.Account_Missing__c
                                               , Barrel__r.Case__r.POS_Label_Account_Name__c
                                               , Barrel__r.Case__r.Retail_Account_Name__c
                                               , Barrel__r.Case__r.Retail_Account__r.Name
                                               , Case__r.Barrel__r.Case__r.Account_Missing__c
                                               , Case__r.Barrel__r.Case__r.Retail_Account_Name__c
                                               , Case__r.Barrel__r.Case__r.Retail_Account__r.Name
                                               , RecordTypeId from POS_Customization__c where Id IN :posItemMap.keySet()];
        
        
        for (POS_Customization__c posItem : posItems) {
            System.debug('>>>>>>>>>>' + posItem);
            //Added by Mahesh
            if(posItem.Barrel__r.Case__c!=null){
                caseId = posItem.Barrel__r.Case__c;
                System.debug('caseId is:::'+caseId);
            }
            
            if(posItem.Type__c == 'Bottle Plate Text' && posItem.Insert_Text__c != null){
                insertText = posItem.Insert_Text__c;
                System.debug('insertText is:::'+insertText);
            }
            
            if (posItem.Get_Insert_Text_From__c == 'Account Name') {
                if (posItem.RecordTypeId == SBP_Constants.POS_FULL_BARREL_RT_ID) {
                    if (posItem.Barrel__r.Case__r.Account_Missing__c) {
                        posItem.Insert_Text__c = posItem.Barrel__r.Case__r.Retail_Account_Name__c;
                        posItemsToUpdate.put(posItem.Id, posItem);
                    } else if (posItem.Barrel__r.Brand__c == 'Jim Beam' || posItem.Barrel__r.Brand__c == 'Cruzan') {
                        posItem.Insert_Text__c = posItem.Barrel__r.Case__r.POS_Label_Account_Name__c;
                        posItemsToUpdate.put(posItem.Id, posItem);
                    } else {
                        posItem.Insert_Text__c = posItem.Barrel__r.Case__r.Retail_Account__r.Name;
                        posItemsToUpdate.put(posItem.Id, posItem);
                    }
                    
                } else if (posItem.RecordTypeId == SBP_Constants.POS_SPLIT_BARREL_RT_ID) {
                    if (posItem.Case__r.Barrel__r.Case__r.Account_Missing__c) {
                        posItem.Insert_Text__c = posItem.Case__r.Barrel__r.Case__r.Retail_Account_Name__c;
                        posItemsToUpdate.put(posItem.Id, posItem);
                    } else {
                        posItem.Insert_Text__c = posItem.Case__r.Barrel__r.Case__r.Retail_Account__r.Name;
                        posItemsToUpdate.put(posItem.Id, posItem);
                    }
                }
            }
        }
        
        //Added by Mahesh
        List<POS_Customization__c> posItemsNew = [select Id
                                                  , Type__c
                                                  , Insert_Text__c
                                                  , Barrel__c
                                                  , Get_Insert_Text_From__c
                                                  from POS_Customization__c where Barrel__r.Case__c=:caseId];
        for(POS_Customization__c posItemNew : posItemsNew){
            System.debug('posItemNew is:::'+posItemNew);
            if(posItemNew.Type__c == 'Bottle Plate Text' && posItemNew.Insert_Text__c != null){
                insertText = posItemNew.Insert_Text__c;
                System.debug('insertText is:::'+insertText);
            }
            
            if(posItemNew.Get_Insert_Text_From__c == 'Bottle Label Text'){
                if(insertText!=null){
                    System.debug('insertText value inside if:::'+insertText);
                    posItemNew.Insert_Text__c = insertText;
                    posItemsToUpdateNew.put(posItemNew.Id, posItemNew);
                }
                
            }
        }
        
        if (!posItemsToUpdate.isEmpty()) {
            update posItemsToUpdate.values();
        }
        //Added by Mahesh
        if (!posItemsToUpdateNew.isEmpty()) {
            update posItemsToUpdateNew.values();
        }
    }
    
    /**************************************************************************************************************
Method name:    updateBottleLabelText
Object:         POS Customization
Date:           4/2022
Details and Notes: SAL-2147
This method is used to update the Insert text value to Bottle Label Text field based on the type
*****************************************************************************************************************************/
    public static void updateBottleLabelText(List<POS_Customization__c> posItemList){
        List<String> barrelNumber = new List<String>();
        List<POS_Customization__c> bottlePlateText = new List<POS_Customization__c>();
        List<POS_Customization__c> bottleCityState = new List<POS_Customization__c>();
        for (POS_Customization__c pos : posItemList) {            
            if(pos.Barrel__c!=null){
                barrelNumber.add(pos.Barrel__c);                   
            }     
        }     
        
        for(POS_Customization__c posItem : [select Id, Type__c, Pos_Item_Seq__c, Insert_Text__c, Barrel__c from POS_Customization__c where Barrel__c =:barrelNumber]){
            if(posItem.Type__c=='Bottle Plate Text')
            {
                bottlePlateText.add(posItem);
                
            }  
            if(posItem.Type__c=='Bottle Label Text City and State')
            {
                bottleCityState.add(posItem);               
            }
        }       
        for(POS_Customization__c posFromList : posItemList){
            if(posFromList.Type__c == 'Bottle Label Text City and State')
            {
                for(POS_Customization__c posItemNew : bottlePlateText){                       
                   if(posItemNew.Barrel__c == posFromList.Barrel__c && posItemNew.Pos_Item_Seq__c == posFromList.Pos_Item_Seq__c)
                    {                  			
                        posFromList.Bottle_Label_Text__c = posItemNew.Insert_Text__c;                         
                    }
                }
            }
            else if(posFromList.Type__c == 'Bottle Plate Text')
            {
                for(POS_Customization__c posItemNew : bottleCityState){
                    if(posItemNew.Barrel__c == posFromList.Barrel__c && posItemNew.Pos_Item_Seq__c == posFromList.Pos_Item_Seq__c){                       
                        posFromList.Bottle_Label_Text__c = posItemNew.Insert_Text__c;                        
                    }
                }          
            }
        }
    }
 /**************************************************************************************************************
Method name:    uncheckBottleTextEnteredOnCase
Object:         POS Customization
Date:           9/2023
Details and Notes: SAL-4681
This method is used to uncheck the Bottle_Text_Entered__c field on Case if all the 'Bottle Label Text' related POS Items are deleted.
*****************************************************************************************************************************/
    public static void uncheckBottleTextEnteredOnCase(Map<Id, POS_Customization__c> posItemMap){
        
        Set<Id> barrelIds = new Set<Id>();
        
        for(POS_Customization__c posItem : posItemMap.values() ){
            if(posItem.Type__c =='Bottle Plate Text' || posItem.Type__c =='Bottle Label Text City and State' || posItem.Type__c =='ET Bottle Plate Line 1' || posItem.Type__c =='ET Bottle Plate Line 2' || posItem.Type__c =='ET Bottle Plate Line 3' || posItem.Type__c =='LSC Bottle Plate Line 1' ){
                barrelIds.add(posItem.Barrel__c);
            }
        }
        
        List<Barrel__c> barrelsOfCasesToBeUpdated = new List<Barrel__c>();
        
        for(Barrel__c barrel:[Select id,Case__c,Case__r.Bottle_Text_Entered__c,(Select Id,Type__c from POS_Customizations__r) from Barrel__c where id IN : barrelIds ]){
            Boolean found = false;
            for(POS_Customization__c singlePosItem : barrel.POS_Customizations__r ){
                if(singlePosItem.Type__c =='Bottle Plate Text' || singlePosItem.Type__c =='Bottle Label Text City and State' || singlePosItem.Type__c =='ET Bottle Plate Line 1' || singlePosItem.Type__c =='ET Bottle Plate Line 2' || singlePosItem.Type__c =='ET Bottle Plate Line 3' || singlePosItem.Type__c =='LSC Bottle Plate Line 1' ){
                    found = true;
                    break;
                }
            }
            if(found == false){
                barrelsOfCasesToBeUpdated.add(barrel);
            }
        }
        List<Case> casesToUpdate = new List<Case>();
        
        for(Barrel__c b : barrelsOfCasesToBeUpdated ){
            
            if(b.Case__r.Bottle_Text_Entered__c){
                Case newCase = new Case();
                newCase.Id = b.Case__c;
                newCase.Bottle_Text_Entered__c = false;
                casesToUpdate.add(newCase);
            }

        }
        
        if(casesToUpdate.size()>0){
            update casesToUpdate;
        }
    }

    public static void sendEmailonLabelTextUpdate(List<POS_Customization__c> posItemsList,Map<Id,POS_Customization__c> oldPosItemsMap){
        Set<Id> posRecordsIdSet = new Set<Id>();
        Set<Id> barrelId = new Set<Id>();
        List<String> posTextCityAndStatePosSeqList = new List<String>();
        List<POS_Customization__c> posItemSeqRecord = new List<POS_Customization__c>();
        EmailTemplate emailTemplate = [Select Id,Subject,Body from EmailTemplate where DeveloperName = 'Makers_Mark_Update_Custom_Bottle_Label_Email'];
        for(POS_Customization__c pos_record : posItemsList){
            if(pos_record.Type__c == 'Bottle Plate Text'&& pos_record.Insert_Text__c != oldPosItemsMap.get(pos_record.Id).Insert_Text__c){
                posRecordsIdSet.add(pos_record.Id);
                barrelId.add(pos_record.Barrel__c);
            }
            if(pos_record.Type__c== 'Bottle Label Text City and State'&& pos_record.Insert_Text__c != oldPosItemsMap.get(pos_record.Id).Insert_Text__c){
                posTextCityAndStatePosSeqList.add(pos_record.Pos_Item_Seq__c);
                if(!barrelId.contains(pos_record.Barrel__c)){
                    barrelId.add(pos_record.Barrel__c);
                }
            }
        }
        if(posTextCityAndStatePosSeqList.size()>0){
             posItemSeqRecord = [SELECT ID from POS_Customization__c WHERE Pos_Item_Seq__c IN: posTextCityAndStatePosSeqList AND Type__c = 'Bottle Plate Text' AND Barrel__c IN: barrelId];
        }
        if(posItemSeqRecord.size()>0){
            for(POS_Customization__c posRecord:posItemSeqRecord){
                if(!posRecordsIdSet.contains(posRecord.ID)){
                    posRecordsIdSet.add(posRecord.ID);
                }
            }
        }
        Map<Id, POS_Customization__c > posBarrelMap = new Map<Id,POS_Customization__c>([SELECT Id,Barrel__r.Case__r.Heritage_Manager__r.Email,Barrel__r.Case__r.Regional_Diplomat__r.Email,Barrel__r.Case__r.Submitter__r.Email,State__c,Barrel__r.Brand__c,Barrel__r.Case__r.CaseNumber,Email_Recipient__c from POS_Customization__c WHERE Id IN: posRecordsIdSet AND Barrel__r.Brand__c = 'Makers Mark']);
        Map<Id,Id> contentDocumentLinkMap = new Map<Id,Id>();
        if(!posBarrelMap.isEmpty()){
            List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId,ContentDocument.LatestPublishedVersion.Id,LinkedEntityid FROM contentDocumentLink WHERE LinkedEntityid IN: posRecordsIdSet];
            Set<Id> contentDocumentIdSet = new Set<Id>();
            for(ContentDocumentLink contentDocumentLink : contentDocumentLinkList){
                contentDocumentIdSet.add(contentDocumentLink.ContentDocumentId);
                contentDocumentLinkMap.put(contentDocumentLink.LinkedEntityid,contentDocumentLink.ContentDocument.LatestPublishedVersion.Id);
            }
            List<ContentDistribution> contentDistributionList = [SELECT Id,ContentDownloadUrl, DistributionPublicUrl,RelatedRecordId FROM ContentDistribution WHERE ContentVersionId IN: contentDocumentLinkMap.values()];
            Map<Id,String> contentDistributionMap = new Map<Id,String>();
            for(ContentDistribution contentDistribution:contentDistributionList){
                contentDistributionMap.put(contentDistribution.RelatedRecordId,contentDistribution.ContentDownloadUrl);
            }
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();OrgWideEmailAddress owea = new OrgWideEmailAddress();
            List<OrgWideEmailAddress> emailFrom = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='noreplymmps@makersmark.com'];
            for(POS_Customization__c pos_record : posBarrelMap.values()){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> ccList = new List<String>();
                ccList.add(posBarrelMap.get(pos_record.Id).Barrel__r.Case__r.Heritage_Manager__r.Email);
                ccList.add(posBarrelMap.get(pos_record.Id).Barrel__r.Case__r.Regional_Diplomat__r.Email);
                List<String> recipientList =  new List<String>();
                if( !String.isBlank(posBarrelMap.get(pos_record.Id).Email_Recipient__c)){
                    recipientList = posBarrelMap.get(pos_record.Id).Email_Recipient__c.split(',');
                }
                recipientList.add(posBarrelMap.get(pos_record.Id).Barrel__r.Case__r.Submitter__r.Email);
                if (!emailFrom.isEmpty()) {
                    email.setOrgWideEmailAddressId(emailFrom[0].Id);
                }
                email.setToAddresses(recipientList);
                email.setSubject(emailTemplate.Subject);
                String emailBody = emailTemplate.Body;
                emailBody +=  '\r\n\r\n\r\n\r\n\r\n' +'Re:'+ posBarrelMap.get(pos_record.Id).Barrel__r.Case__r.CaseNumber;
                emailBody = emailBody.replace('\r\n','<br>');
                emailBody = emailBody.replace('\n','<br>');
                emailBody = emailBody.replace('{Image}','<img src="'+contentDistributionMap.get(pos_record.Id)+'">' );
                email.setHtmlBody(emailBody);
                List<Id> imageIdList = new List<Id>();
                if(contentDocumentLinkMap.get(pos_record.Id) != null){
                    imageIdList.add(contentDocumentLinkMap.get(pos_record.Id));
                    if(!Test.isRunningTest()){
                        email.setCcAddresses(ccList);
                        email.setEntityAttachments(imageIdList);
                    }
                    emails.add(email);
                } 
            }
            if(emails.size()>0){
                List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
            }
        }
    }

}