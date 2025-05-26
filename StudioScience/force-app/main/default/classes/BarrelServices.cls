public class BarrelServices {
    public static final Id MAKERS_MARK_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark_Full_Barrel').getRecordTypeId();
    public static final Id ELTESORO_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro_Full_Barrel').getRecordTypeId();
    public static final Id ELTESORO_REMOTE_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro_Remote_Selection').getRecordTypeId();
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:    Once a barrel has been selected the case attached to the barrel will need to be updated
to reflect that
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void checkIfBarrelWasSelected(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        Set<Id> caseIdsToUpdate = new Set<Id>();
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        Map<Id, Barrel__c> barrelToUpdateMap = new Map<Id, Barrel__c>();
        
        // check to see if case related to barrel is a split barrel
        for (Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);           
            if (SBP_Constants.fullBarrelRtIds.contains(barrel.RecordTypeId)  || barrel.RecordTypeId == SBP_Constants.BAKERS_SAMPLE_KIT_RT_ID || barrel.RecordTypeId == SBP_Constants.ETLC_SAMPLE_KIT_RT_ID) {               
                if (oldBarrel.Selection_Date__c == null && barrel.Selection_Date__c != null) {
                    caseIdsToUpdate.add(barrel.Case__c);
                    barrelToUpdateMap.put(barrel.Case__c,barrel);
                }
            }
        }
        // if case related to barrel is not of type split barrel then we can update the case directly
        for (Case c : [select Id, Barrel_Selected__c, Status from Case where Id IN :caseIdsToUpdate]) {
            if(c.Status == 'Canceled' || c.Status == 'Canceled - Age/Variety' || c.Status == 'Cancelled - Kit Not Selected' || c.Status == 'Closed - Abandoned'){
                barrelToUpdateMap.get(c.Id).addError('Barrel can\'t be selected as Case is cancelled.');
            }else if(!c.Barrel_Selected__c)
            {
                c.Barrel_Selected__c = true;
                c.Barrel_Selected_Date__c = Datetime.now();
                casesToUpdateMap.put(c.Id, c);
            }
        }
        CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
        if (!casesToUpdateMap.isEmpty()) {
            update casesToUpdateMap.values();
        }
        
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void checkFinalDetailsOfBarrel(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        Set<Id> caseIdsToUpdate = new Set<Id>();
        Map<Id, Case> casesToUpdateMap = new Map<Id, Case>();
        
        // check to see if case related to barrel is a split barrel
        for (Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);
            // for standard barrel order
            if (SBP_Constants.standardBarrelRTIds.contains(barrel.RecordTypeId)) {
                if (oldBarrel.Brand__c!='Knob Creek' && 
                     ((oldBarrel.Quantity__c == null && barrel.Quantity__c != null) ||
                     (String.isBlank(oldBarrel.SKU__c) && String.isNotBlank(barrel.SKU__c)) ||
                     (oldBarrel.Ship_Date__c == null && barrel.Ship_Date__c != null))) {
                         caseIdsToUpdate.add(barrel.Case__c);
                     }
                else if (oldBarrel.Brand__c=='Knob Creek' && 
                         ((oldBarrel.Quantity__c == null && barrel.Quantity__c != null) ||
                          (oldBarrel.Ship_Date__c == null && barrel.Ship_Date__c != null))) {
                              caseIdsToUpdate.add(barrel.Case__c);
                          }
            }
            // for Proof specific barrel orders
            else if (SBP_Constants.proofSpecificBarrelRTIds.contains(barrel.RecordTypeId)) {
                if ((oldBarrel.Quantity__c == null && barrel.Quantity__c != null) ||
                    (String.isBlank(oldBarrel.SKU__c) && String.isNotBlank(barrel.SKU__c))) {
                        
                        caseIdsToUpdate.add(barrel.Case__c);
                    }
            }
        }
        
        // if case related to barrel is not of type split barrel then we can update the case directly
        for (Case c : [select Id, Status, RecordTypeId from Case where Id IN :caseIdsToUpdate]) {
            if (c.RecordTypeId == SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID) {
                c.Status = SBP_Constants.PENDING_FINAL_DETAILS;
                casesToUpdateMap.put(c.Id, c);
            } else if (c.RecordTypeId == SBP_Constants.SINGLE_BARREL_PROOF_SPECIFIC_RT_ID) {
                c.Status = SBP_Constants.PENDING_PURCHASE_ORDER;
                casesToUpdateMap.put(c.Id, c);
            }
            
        }
        
        if (!casesToUpdateMap.isEmpty()) {
            update casesToUpdateMap.values();
        }
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:    Once the final details are entered for the barrel orders they will be sent out to the Sales Rep,
Distributor Contact and any additional people that are listed in the ccEmail field
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void emailFinalBarrelDetails(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :SBP_Constants.BARREL_FINAL_DETAILS_EMAIL_TEMPLATE_NAME limit 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id, Barrel__c> newBarrelMap = new Map<Id, Barrel__c>();
        
        for (Barrel__c barrel : [select id, Case__r.Submitter__c, Case__r.Submitter__r.Email, Case__r.Contact.Email, Case__r.CcEmail__c from Barrel__c where Id IN: barrelMap.keySet()]) {
            newBarrelMap.put(barrel.Id, barrel);
        }
        
        for (Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);
            if (!oldBarrel.Barrel_Approved__c && barrel.Barrel_Approved__c) {
                List<String> emailsToSendTo = new List<String>();
                // add submitter email(Sales Rep)
                if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.Submitter__r.Email)) {
                    emailsToSendTo.add(newBarrelMap.get(barrel.Id).Case__r.Submitter__r.Email);
                }
                // add contact email
                if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.Contact.Email)) {
                    emailsToSendTo.add(newBarrelMap.get(barrel.Id).Case__r.Contact.Email);
                }
                
                if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.CcEmail__c)) {
                    String ccEmails = newBarrelMap.get(barrel.Id).Case__r.CcEmail__c;
                    List<String> emailAddresses = ccEmails.split(',');
                    emailsToSendTo.addAll(emailAddresses);
                }
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'single.barrels@beamsuntory.com'];
                
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setToAddresses(emailsToSendTo);
                singleMail.setTargetObjectId(newBarrelMap.get(barrel.Id).Case__r.Submitter__c);
                singleMail.setTemplateId(template.Id);
                singleMail.setWhatId(barrel.Id);
                singleMail.setSaveAsActivity(false);
                singleMail.setReplyTo('single.barrels@beamsuntory.com');
                singleMail.setOrgWideEmailAddressId(owea[0].Id);
                //singleMail.setSenderDisplayName('Beam Suntory Customer Service');
                emails.add(singleMail);
            }
        }
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
    }
    
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:    Barrel Numbers need to be incremented per brand so a custom object stores the next barrel number
and each time a barrel is created, that number will be updated and the barrel number object
will also be updatd to reflect the next barrel number
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void addBarrelNumberToBarrelRecord(List<Barrel__c> barrels) {
        System.debug('inside addBarrelNumberToBarrelRecord:::'+barrels);
        Map<String, String> brandToInteger = new Map<String, String>();
        Map<String, Id> brandToBarrelNumberRecord = new Map<String, Id>();
        List<Barrel_Number__c> barrelNumbersToUpdate = new List<Barrel_Number__c>();
        String elTesoroBarrelNumber;
        Integer nextBarrelNumber;
        String bakersNumber;
        String elTesoroLaphroaigCaskBarrelNumber;
        
        for (Barrel_Number__c barrelNumber : [select id, Brand__c, Product_Type__c, Next_Barrel_Number__c from Barrel_Number__c]) {
            System.debug('inside for::::'+barrelNumber);
            String brandTypeKey;
            if(barrelNumber.Brand__c == SBP_Constants.LAPHROAIG_SINGLE_CASK){
                brandTypeKey = barrelNumber.Brand__c;
            }else{
                brandTypeKey = barrelNumber.Brand__c + '-' + barrelNumber.Product_Type__c; 
            }
            //Added for El Tesoro Laphroaig Cask
            if(barrelNumber.Brand__c!= 'Baker\'s' && barrelNumber.Brand__c!= 'El Tesoro Laphroaig Cask'){
                brandToInteger.put(brandTypeKey , barrelNumber.Next_Barrel_Number__c);
                brandToBarrelNumberRecord.put(brandTypeKey, barrelNumber.Id);          
            }
            
            //Added for El Tesoro
            if(barrelNumber.Brand__c=='El Tesoro'){
                elTesoroBarrelNumber=barrelNumber.Next_Barrel_Number__c;               
                brandToInteger.put(brandTypeKey , elTesoroBarrelNumber);              
            }
            
            //Added for Baker\'s as product type is not defined for Baker's
            if(barrelNumber.Brand__c=='Baker\'s'){
                brandTypeKey = barrelNumber.Brand__c;
                bakersNumber=barrelNumber.Next_Barrel_Number__c;
                brandToInteger.put(brandTypeKey , bakersNumber);
                brandToBarrelNumberRecord.put(brandTypeKey, barrelNumber.Id);
            }
            
            //Added for El Tesoro Laphroaig Cask
            if(barrelNumber.Brand__c == 'El Tesoro Laphroaig Cask'){
                brandTypeKey = barrelNumber.Brand__c;
                elTesoroLaphroaigCaskBarrelNumber = barrelNumber.Next_Barrel_Number__c;
                brandToInteger.put(brandTypeKey , elTesoroLaphroaigCaskBarrelNumber);
                brandToBarrelNumberRecord.put(brandTypeKey, barrelNumber.Id);
            }
            
            System.debug('elTesoroBarrelNumber is:::'+elTesoroBarrelNumber + 'brandToInteger is::' +brandToInteger);
        }
        
        for (Barrel__c barrel : barrels) {
            String brandTypeKey;
            if(barrel.Brand__c == SBP_Constants.LAPHROAIG_SINGLE_CASK){
                brandTypeKey = barrel.Brand__c;
            }else{
                brandTypeKey = barrel.Brand__c + '-' + barrel.Product_Type__c; 
            }
            
            
            
            if (brandToInteger.containsKey(brandTypeKey) && SBP_Constants.fullBarrelRtIds.contains(barrel.RecordTypeId) && (String.isBlank(barrel.Barrel_Number__c) || barrel.Barrel_Number__c == null)) {
                System.debug('inside Barrel If:::');
                barrel.Barrel_Number__c = brandToInteger.get(brandTypeKey);
                nextBarrelNumber = Integer.valueOf(barrel.Barrel_Number__c) + 1;
                brandToInteger.put(brandTypeKey , String.valueOf(nextBarrelNumber));
                System.debug('brandToInteger::'+brandToInteger);
            }
            
            //Added for El Tesoro
            if(barrel.Brand__c=='El Tesoro' && (String.isBlank(barrel.Barrel_Number__c) || barrel.Barrel_Number__c == null)){
                brandTypeKey = barrel.Brand__c + '-' + 'Full Barrel';
                barrel.Barrel_Number__c = elTesoroBarrelNumber;
                System.debug('barrel Number is:::'+barrel.Barrel_Number__c);
                nextBarrelNumber = Integer.valueOf(barrel.Barrel_Number__c) + 1;
                System.debug('nextBarrelNumber is:::'+nextBarrelNumber);
                brandToInteger.put(brandTypeKey , String.valueOf(nextBarrelNumber));
                System.debug('brandToInteger::'+brandToInteger);
            }
            //Added for Baker\'s as product type is not specified for Baker's
            if(barrel.Brand__c=='Baker\'s' && (String.isBlank(barrel.Barrel_Number__c) || barrel.Barrel_Number__c == null)){
                brandTypeKey = barrel.Brand__c;
                barrel.Barrel_Number__c = bakersNumber;
                nextBarrelNumber = Integer.valueOf(barrel.Barrel_Number__c) + 1;                
                brandToInteger.put(brandTypeKey , String.valueOf(nextBarrelNumber));
            }
            
            //Added for El Tesoro Laphroaig Cask
            if(barrel.Brand__c== 'El Tesoro Laphroaig Cask' && (String.isBlank(barrel.Barrel_Number__c) || barrel.Barrel_Number__c == null)){
                brandTypeKey = barrel.Brand__c;
                barrel.Barrel_Number__c = elTesoroLaphroaigCaskBarrelNumber;            
                nextBarrelNumber = Integer.valueOf(barrel.Barrel_Number__c) + 1;             
                brandToInteger.put(brandTypeKey , String.valueOf(nextBarrelNumber));
            }
            
        }
        
        for (String barrelKey : brandToBarrelNumberRecord.keySet()) {
            System.debug('barrelKey is:::'+barrelKey);
            if (brandToInteger.containsKey(barrelKey)) {
                System.debug('inside brandToInteger if::::'+brandToInteger.get(barrelKey));
                Barrel_Number__c bNumber = new Barrel_Number__c();
                bNumber.put('Id', brandToBarrelNumberRecord.get(barrelKey));
                bNumber.put('Next_Barrel_Number__c', brandToInteger.get(barrelKey));
                barrelNumbersToUpdate.add(bNumber);
                System.debug('barrelNumbersToUpdate:::'+barrelNumbersToUpdate);
            }
        }
        
        if (!barrelNumbersToUpdate.isEmpty()) {
            System.debug('inside if (!barrelNumbersToUpdate.isEmpty())');
            update barrelNumbersToUpdate;
        }
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:    Once the ship date of the barrel is reached then a workflow will update the barrel record and
this method will update the status of the case to "Order Shipped"
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018      Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void barrelHasShipped(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        
        for (Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);
            String brandTypeKey = barrel.Brand__c + '-' + barrel.Product_Type__c;
            if (!oldBarrel.Order_Shipped__c && barrel.Order_Shipped__c && barrel.Ship_Date__c != null) {
                caseIds.add(barrel.Case__c);
            }
        }
        
        /* for (Case c : [select id, Status from Case where Id IN :caseIds]) {
c.Status = SBP_Constants.ORDER_SHIPPED;
casesToUpdate.put(c.Id, c);
}

if (!casesToUpdate.isEmpty()) {
update casesToUpdate.values();
} */
    } 
    
    /**************************************************************************************************************
Author:        Sripal Kotha
Company:       TCS
Description:   Once the SKU is Entered on the barrel object the SKU Entered Date should update the time stamp for Insert and Update operation
History
<Date>      <Authors Name>     <Brief Description of Change>
9/2019      Sripal Kotha          Initial Creation

***************************************************************************************************************/
    public static void updateTimestampForBarrel(List<Barrel__c> barrels, Map<Id, Barrel__c> oldMap) {
        for (Barrel__c barrelToUpdate : barrels) {
            //Added Laphroaig SIngle Cask RT By Nishant
            if (barrelToUpdate.RecordTypeId.equals(MAKERS_MARK_FULL_BARREL_RT_ID) || barrelToUpdate.RecordTypeId.equals(ELTESORO_FULL_BARREL_RT_ID)
                || barrelToUpdate.RecordTypeId.equals(ELTESORO_REMOTE_BARREL_RT_ID)
                || barrelToUpdate.RecordTypeId.equals(SBP_Constants.LAPHROAIG_SINGLE_CASK_FULL_BARREL_RT_ID)) {
                if (oldMap != null) {
                    Barrel__c oldBarrelRecord = oldMap.get(barrelToUpdate.Id);
                    if (String.isNotBlank(barrelToUpdate.SKU__c) && (oldBarrelRecord.SKU__c != barrelToUpdate.SKU__c)) {
                        barrelToUpdate.SKU_Entered_Date__c = Datetime.now();
                    }
                } else {
                    if (String.isNotBlank(barrelToUpdate.SKU__c)) {
                        barrelToUpdate.SKU_Entered_Date__c = Datetime.now();
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
Description: SR-179687 Added By Ajeeta Soni(TCS)
History : 
8/2020     Ajeeta           Initial Creation
11/2020    Jai Kumar Garg   Modified for SR_192293
**************************************************************************************************************/
    public static void updateBarrelReadySubCaseWithBarrelPO(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        Id JimFullRId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Full_Barrel').getRecordTypeId();
        Id JimKitRId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Sample_Kit').getRecordTypeId();
        Map<Id, Case> mapOfCaseToUpdate = new Map<Id, Case>();
        Set<Id> barrelCaseIds = new Set<Id>();
        for(Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);
            if(barrel.PO_Number__c != null) {
                if((barrel.RecordTypeId != JimFullRId) && (barrel.RecordTypeId != JimKitRId) && (barrel.Case__c != null)) {
                    barrelCaseIds.add(barrel.Case__c);
                }   
            }
        }
        List<Barrel__c> lstBarrel = [SELECT 
                                     Id, Case__c, PO_Number__c 
                                     FROM 
                                     Barrel__c 
                                     WHERE 
                                     Case__c IN: barrelCaseIds];
        List<Case> lstBarrelReadyToEnterCase = [SELECT 
                                                Id, Status, ParentId, Purchase_Order_Number__c, PO_Number__c, RecordTypeId 
                                                FROM 
                                                Case 
                                                WHERE 
                                                ParentId IN: barrelCaseIds
                                                AND
                                                RecordTypeId =: SBP_Constants.BARREL_READY_TO_ENTER_RT_ID];
        Map<Id, Case> mapOfBarrelReadyToEnterCaseToParent = new Map<Id, Case>();
        for(Case barrelReadyToEnterCase : lstBarrelReadyToEnterCase) {
            mapOfBarrelReadyToEnterCaseToParent.put(barrelReadyToEnterCase.ParentId, barrelReadyToEnterCase);
        }
        for(Barrel__c barrel : lstBarrel) {
            Case barrelReadyToEnterCase = mapOfBarrelReadyToEnterCaseToParent.get(barrel.Case__c);
            if(barrelReadyToEnterCase != null) {
                barrelReadyToEnterCase.Purchase_Order_Number__c = barrel.PO_Number__c;
                mapOfCaseToUpdate.put(barrelReadyToEnterCase.Id, barrelReadyToEnterCase);
            }
        }
        if (!mapOfCaseToUpdate.isEmpty()) {
            update mapOfCaseToUpdate.values();
        }
    }
    
    /**************************************************************************************************************
Description: SR-179687 Added By Ajeeta Soni(TCS)
History : 
8/2020     Ajeeta       	Initial Creation
10/2020    Jai Kumar Garg   Modification for SR_191644
11/2020    Jai Kumar Garg   Modification for SR_192293
01/2021	   Jai Kumar Garg	Modification for INC0019129
**************************************************************************************************************/
    public static void updateParentCaseWithBarrelPO(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        Id JimFullRId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Full_Barrel').getRecordTypeId();
        Id JimKitRId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Sample_Kit').getRecordTypeId();
        List<Barrel__c> lstBarrel = new List<Barrel__c>();
        Set<Case> lstParenCase = new Set<Case>();
        Set<Id> barrelCaseIds = new Set<Id>();
        for(Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);
            if((barrel.RecordTypeId != JimFullRId) && 
               (barrel.RecordTypeId != JimKitRId) && 
               (barrel.Case__c != null) &&
               (barrel.PO_Number__c != oldBarrel.PO_Number__c || barrel.SKU__c != oldBarrel.SKU__c)) {
                   Case parentCase = new Case(Id = barrel.Case__c);
                   parentCase.Related_Barrel_PO_Number__c = barrel.PO_Number__c;
                   parentCase.Related_Barrel_SKU__c = barrel.SKU__c;
                   lstParenCase.add(parentCase);
               } 
        }
        List<Case> cse = new List<Case>();
        cse.addAll(lstParenCase);
        if(!cse.isEmpty()) {
            update cse;
        }    
    }
    
    /*********************************************************************************************************************
Description: Once the Quantity and Proof is Entered on the barrel object then send an email to Submitter and Diplomat
<Date>      <Authors Name>     <Brief Description of Change>
11/2021          Sahana      Initial Creation
Description: Added Automated Notification Email to the recipients list
09/2022          Pavan Kumar  Modifications for SAL-3140(SCTASK0100653)
***************************************************************************************************************/
    public static void emailBasedOnQuantityAndProof(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :SBP_Constants.BARREL_QUANTITY_PROOF_ADDED limit 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id, Barrel__c> newBarrelMap = new Map<Id, Barrel__c>();
        
        for (Barrel__c barrel : [select id, Case__r.Submitter__c, Case__r.Submitter__r.Email,Case__r.Regional_Diplomat__c, Case__r.Regional_Diplomat__r.email,Case__r.Automated_Notification_Email__c
                                 from Barrel__c where Id IN: barrelMap.keySet()]) {
                                     newBarrelMap.put(barrel.Id, barrel);
                                 }
        
        for (Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);              
            if(barrel.Brand__c== 'Makers Mark' || oldBarrel.Brand__c == 'Makers Mark'){
                if((barrel.Quantity__c != oldBarrel.Quantity__c  || barrel.Proof__c != oldBarrel.Proof__c ) && (barrel.Quantity__c != null && barrel.Proof__c != null)){                                                                                               
                    List<String> emailsToSendTo = new List<String>();
                    // add submitter email(Sales Rep)
                    if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.Submitter__r.Email)) {
                        emailsToSendTo.add(newBarrelMap.get(barrel.Id).Case__r.Submitter__r.Email);
                    }
                    // add Regional Diplomat email                                                                         
                    if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.Regional_Diplomat__r.email)) {
                        emailsToSendTo.add(newBarrelMap.get(barrel.Id).Case__r.Regional_Diplomat__r.email);
                    } 
                    // add Automated Notification Email 
                    if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.Automated_Notification_Email__c)) {
                        emailsToSendTo.add(newBarrelMap.get(barrel.Id).Case__r.Automated_Notification_Email__c);
                    } 
                    
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'single.barrels@beamsuntory.com'];
                    
                    Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    singleMail.setToAddresses(emailsToSendTo);
                    singleMail.setTargetObjectId(newBarrelMap.get(barrel.Id).Case__r.Submitter__c);
                    singleMail.setTemplateId(template.Id);
                    singleMail.setWhatId(barrel.Id);
                    singleMail.setSaveAsActivity(false);
                    singleMail.setReplyTo('single.barrels@beamsuntory.com');
                    singleMail.setOrgWideEmailAddressId(owea[0].Id);
                    emails.add(singleMail);
                }
            }
        }
        if(!emails.isEmpty()) {
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
        }      
        
    }

    /*********************************************************************************************************************
Description: Send email to submitter and contact when Quantity is less than or equal to 19 for KC Bourbon. (SAL-3364)
<Date>      <Authors Name>     <Brief Description of Change>
12/2022      Vikash Kumar      Initial Creation

***************************************************************************************************************/
    public static void sendEmailForLessQuantityOnKCBarrels(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap){
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = :SBP_Constants.LOW_QUANTITY_TEMPLATE limit 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id, Barrel__c> newBarrelMap = new Map<Id, Barrel__c>();
        for (Barrel__c barrel : [select id, Case__r.Submitter__c, Case__r.Submitter__r.Email,Case__r.ContactEmail 
                                 from Barrel__c where Id IN: barrelMap.keySet()]) {
                                     newBarrelMap.put(barrel.Id, barrel);
                                 }
        
        for (Barrel__c barrel : barrels) {
            Barrel__c oldBarrel = barrelMap.get(barrel.Id);              
            if(barrel.Brand__c== 'Knob Creek' || oldBarrel.Brand__c == 'Knob Creek'){
                if((barrel.Quantity__c != oldBarrel.Quantity__c) && (barrel.Product_Type__c=='Bourbon') && (barrel.Quantity__c <= 19)){                                                                                               
                    List<String> emailsToSendTo = new List<String>();
                    List<String> emailsToSendCc = new List<String>();
                    String ccAddress = '';
                    // add submitter email(Sales Rep)
                    if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.Submitter__r.Email)) {
                        emailsToSendTo.add(newBarrelMap.get(barrel.Id).Case__r.Submitter__r.Email);
                    }
                    // add Contact email                                                                         
                    if (String.isNotBlank(newBarrelMap.get(barrel.Id).Case__r.ContactEmail)) {
                        emailsToSendCc.add(newBarrelMap.get(barrel.Id).Case__r.ContactEmail);
                    } 
                  
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'single.barrels@beamsuntory.com'];
                    
                    Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    singleMail.setToAddresses(emailsToSendTo);
                    singleMail.setCcAddresses(emailsToSendCc);
                    singleMail.setTargetObjectId(newBarrelMap.get(barrel.Id).Case__r.Submitter__c);
                    System.debug('Targ Obj here: '+ newBarrelMap.get(barrel.Id).Case__r.Submitter__c);
                    singleMail.setTemplateId(template.Id);
                    singleMail.setWhatId(barrel.Id);
                    System.debug('What Id here: - '+ barrel.Id);
                    singleMail.setSaveAsActivity(false);
                    singleMail.setReplyTo('single.barrels@beamsuntory.com');
                    singleMail.setOrgWideEmailAddressId(owea[0].Id);
                    emails.add(singleMail);
                }
            }
        }
        if(!emails.isEmpty()) {
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
        }      
        
        
    }
    
/*********************************************************************************************************************
Description: Updates SKU on Barrel for Knob Creek when barrel selection date is inserted. (SAL-2293)
<Date>      <Authors Name>     <Brief Description of Change>
05/2022      Devyani Gupta      Initial Creation
05/2023      Pavan Kumar        Modifications for SAL-4175

***************************************************************************************************************/
    public static void updateSKUforKCBarrels(List<Barrel__c> barrels, Map<Id, Barrel__c> oldMap) {
        for (barrel__c b : barrels) {
            Barrel__c oldBarrel = oldMap.get(b.Id);           
            if (oldBarrel.Selection_Date__c == Null && b.Selection_Date__c != Null && b.Brand__c=='Knob Creek'){
                if(b.Product_Type__c=='Rye'){
                    b.SKU__c = 'US116265';
                }
                if(b.Product_Type__c=='Bourbon'){
                    b.SKU__c = 'US116261';
                }
                System.debug('SKU___________'+b.SKU__c);
            }
        }
    }
        
    /**************************************************************************************************************    
Description: SR_186925 Added By MaheshBabu M(TCS)
History : This method will update sample selected to true on samplekit if barrel selected is true on case
9/2020     MaheshBabu M       Initial Creation
*************************************************************************************************************
public static void updateSampleSelectedToTrue(List<Barrel__c> barrels, Map<Id, Barrel__c> barrelMap) {
Set<Id> barrelIds = new Set<Id>();
Set<Id> caseIds = new Set<Id>();
Set<Id> sampleKitIds = new Set<Id>();
Map<Id, Sample_Kit__c> samplekitsToUpdateMap = new Map<Id, Sample_Kit__c>();
Map<Id, Sample__c> samplesToUpdateMap = new Map<Id, Sample__c>();
List<Barrel__c> barrelList = new List<Barrel__c>();

for (Barrel__c barrel : barrels) {
Barrel__c oldBarrel = barrelMap.get(barrel.Id);
if (barrel.RecordTypeId == SBP_Constants.KNOB_CREEK_FULL_BARREL_RT_ID && barrel.Case__c !=null) {
if(barrel.Warehouse__c !=null && barrel.Selection_Date__c !=null){
barrelIds.add(barrel.Id);
caseIds.add(barrel.Case__c);
}

}
}

for(Sample_Kit__c samplekit: [Select Id, Sample_Selected__c,Case__r.Barrel_Selected__c from Sample_Kit__c where Case__c IN:caseIds]){
if(samplekit.Case__r.Barrel_Selected__c == true){
samplekit.Sample_Selected__c = true;
samplekitsToUpdateMap.put(samplekit.Id,samplekit);
}
}

if (!samplekitsToUpdateMap.isEmpty()) {
update samplekitsToUpdateMap.values();
}

} */	   
    
    /**************************************************************************************************************    
Description: SCTASK0026311 Added By Pranjal Agrawal(Metacube)
History : This method does not allow 2 barrels with the same barrel number for the same brand
4/2021     Pranjal Agrawal       Initial Creation
**************************************************************************************************************/
    /* public static void checkForDuplicates(List<Barrel__c> barrels,Map<Id, Barrel__c> oldBarrels) {
Map<String,Id> barrelNumbersToId = new Map<String,Id>();
Set<String> brands = new Set<String>();
for(Barrel__c barrel : barrels){
brands.add(barrel.Brand__c);
if((barrel.Barrel_Number__c < oldBarrels.get(barrel.Id).Barrel_Number__c) && (barrel.Barrel_Number__c != null && barrel.Barrel_Number__c != ''))
barrel.addError(Label.Barrel_Number_Cannot_be_Decreased);
else if(!barrelNumbersToId.containskey(barrel.Barrel_Number__c))
barrelNumbersToId.put(barrel.Barrel_Number__c,barrel.id);
else
barrel.Barrel_Number__c.addError(Label.Duplicate_Barrel_Number);
}
List<Barrel__c> barrelsWithSameBarrelNumber = [SELECT ID,Barrel_Number__c,Brand__c FROM Barrel__c where Barrel_Number__c in: barrelNumbersToId.keyset() AND id not in :barrelNumbersToId.values() AND Brand__C in :brands AND Barrel_Number__c != '' LIMIT 200];
if(barrelsWithSameBarrelNumber.size()>0)
barrels[0].Barrel_Number__c.addError(Label.Duplicate_Barrel_Number);  
}*/
    
    /**************************************************************************************************************
Description:  This method is used to throw an error when the user is trying to change barrel number from portal
<Date>      <Authors Name>     <Company>     <Brief Description of Change>
6/2021        Devyani Gupta       Metacube       Initial Creation
**************************************************************************************************************/    
    /*  public static void addErrorMsgBarrelNumberField(List<Barrel__c> barrels,  Map<Id, Barrel__c> oldBarrels){   
String ntwrkId = Network.getNetworkId();     
if(ntwrkId != null){
ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);           
if(comm != null && comm.name == 'Beam Suntory Customer Community'){  
for(Barrel__c c : barrels){ 
if(c.Brand__c == 'Knob Creek' || c.Brand__c =='Cruzan' || c.Brand__c == 'Makers Mark' ||
c.Brand__c =='El Tesoro' || c.Brand__c == 'El Tesoro Laphroaig Cask' ||c.Brand__c == 'Baker\'s'){   
if(c.Barrel_Number__c != oldBarrels.get(c.Id).Barrel_Number__c){                              
c.addError(Label.Unable_to_edit_barrel_number);                       
}
}
}      
}  
} 
}*/
    //LSB-153
    public static void updateCaseStatusAndSubStatus(List<Barrel__c> newBarrels, Map<Id, Barrel__c> oldMap){
        Map<Id, Id> mapOfBarrelIdToCaseId = new Map<Id, Id>();
        List <Case> listOfCasesToUpdate = new List <Case>();
        for(Barrel__c recordBarrel: newBarrels){
            if(oldMap.get(recordBarrel.Id).Bottling_Date__c == null 
                && recordBarrel.Bottling_Date__c != oldMap.get(recordBarrel.Id).Bottling_Date__c){
                    mapOfBarrelIdToCaseId.put(recordBarrel.Id, recordBarrel.Case__c);
        	} else if ((oldMap.get(recordBarrel.Id).SKU__c == null
                || oldMap.get(recordBarrel.Id).Quantity__c == null
                || oldMap.get(recordBarrel.Id).Proof__c == null
                || oldMap.get(recordBarrel.Id).Barrel_Proof__c == null)
                && (recordBarrel.SKU__c != null && recordBarrel.Quantity__c != null && recordBarrel.Proof__c != null
                    && recordBarrel.Barrel_Proof__c != null)) {
                        mapOfBarrelIdToCaseId.put(recordBarrel.Id, recordBarrel.Case__c);
            }
        }
        if (!mapOfBarrelIdToCaseId.isEmpty()) {
            Map <Id, Case> mapOfCases = new Map<Id, Case>(SLT_Case.getCasesListById(new Set<Id>(mapOfBarrelIdToCaseId.values())));
            if (!mapOfCases.isEmpty()) {
                for(Barrel__c barrel: newBarrels){
                    if (mapOfBarrelIdToCaseId.containsKey(barrel.Id) && barrel.Case__c != null
                        && mapOfCases.containsKey(barrel.Case__c)) {
                            Case recordCase = mapOfCases.get(barrel.Case__c);
                            if (barrel.SKU__c != null && barrel.Quantity__c != null && barrel.Proof__c != null
                                && barrel.Barrel_Proof__c != null) {
                                    recordCase.Status = SBP_Constants.PREPARING_BARREL;
                                    recordCase.Sub_Status__c = SBP_Constants.AWAITING_DISTRIBUTOR_PO;
                                    recordCase.Barrel__c = barrel.Id;
                            } else if(barrel.Bottling_Date__c != null) {
                                recordCase.Status = SBP_Constants.PREPARING_BARREL;
                                recordCase.Sub_Status__c = SBP_Constants.PREPARING_STO;
                            }
                            listOfCasesToUpdate.add(recordCase);
                    }
                }
                if (listOfCasesToUpdate != null && !listOfCasesToUpdate.isEmpty()) {
                    UPDATE listOfCasesToUpdate;
                }
            }    
        }
    }
}