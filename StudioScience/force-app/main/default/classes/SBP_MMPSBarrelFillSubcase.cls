/*
Author:			Yash Jain
Company:		Metacube
Description:	This class is used for creation of MMPS barrel fill subcase in diplomatic immunity project

History
<Date>           <Authors Name>    <Brief Description of Change>
15th June,2021    Yash Jain        creating MMPS barrel fill subcase for Makers Mark Brand
*/
public class SBP_MMPSBarrelFillSubcase {
    
    /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method creates subcase for Makers Mark brand and also triggers mails when staves are entered
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       Initial Creation

***************************************************************************************************************/
    
    @InvocableMethod 
    public static void createSubCaseForBarrelReady(List <Case> cases) {
        Id singleBarrelInquiryRId ;
        if(cases[0].Brand__c != 'Makers Mark')
            singleBarrelInquiryRId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Ready_to_Enter').getRecordTypeId();
        else
            singleBarrelInquiryRId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Laid_Down').getRecordTypeId();
        List <Case> casesToInsert = new List<Case>();
        Id queueID ;
        if(cases[0].Brand__c != 'Makers Mark')
            queueID = [SELECT Id,Name, Type FROM Group WHERE Type = 'Queue' AND Name = 'Barrel Queue'].Id;
        else
            queueID = [SELECT Id,Name, Type FROM Group WHERE Type = 'Queue' AND Name = 'MMPS Selected Barrels'].Id;
        for(Case c : cases){
            
            Case newSubCase = new Case();
            newSubCase.ParentId = c.Id;
            newSubCase.Status = 'New'; 
            newSubCase.OwnerId = queueID;
            newSubCase.Sub_Status__c = null;
            if(c.Product_Type__c != '')
                newSubCase.Product_Type__c = c.Product_Type__c;
            newSubCase.AccountId = c.AccountId;
            if(c.Retail_Account__c != null){
                newSubCase.Retail_Account__c = c.Retail_Account__c;
                newSubCase.Retail_Account_Name__c = c.Retail_Account__r.Name;
            }
            newSubCase.Brand__c = c.Brand__c;
            newSubCase.Submitter__c = c.Submitter__c;
            if(cases[0].Brand__c != 'Makers Mark')
                newSubCase.Type = 'Barrel Ready to Enter';
            else
            {
                newSubCase.Type = c.Type;
                if(c.Regional_Diplomat__c != null)
                    newSubCase.Regional_Diplomat__c = c.Regional_Diplomat__c;
                if(c.Heritage_Manager__c != null)
                    newSubCase.Heritage_Manager__c = c.Heritage_Manager__c;
                
                if(c.Type == 'Trip and Tour')
                    newSubCase.Case_Date__c = c.Plant_Event__r.Scheduled_Date__c;
                else if(c.Type == 'Remote Selection')
                    newSubCase.Case_Date__c = c.Remote_Selection_Date__c;
                else if(c.Type == 'Recent Recipes')
                    newSubCase.Case_Date__c = date.newinstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                
            }
            if(cases[0].Brand__c != 'Makers Mark'){
                newSubCase.Purchase_Order_Number__c   = c.Related_Barrel_PO_Number__c ;
                newSubCase.ContactId = c.ContactId;
            }
            newSubCase.RecordTypeId = singleBarrelInquiryRId ; 
            casesToInsert.add(newSubCase);
        }
        
        if (!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert[0];
                System.debug('cs '+casesToInsert[0]);
                if(cases[0].Brand__c == 'Makers Mark'){
                    cases[0].MMPS_Barrel_Fill_Subcase_Number__c = casesToInsert[0].Id;
                    cases[0].Case_Date__c = casesToInsert[0].Case_Date__c;                 
                    cases[0].Stave_Selection_Date__c = System.today();                  
                    update cases[0];
                    stavesEntryEmail(cases[0]);
                }                
            } catch (Exception e) {
                String errorMessage = 'Error creating cases ' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('BarrelReadySubcaseCreationcntrl', 'createSubCaseForBarrelReady', String.valueOf(errorMessage), 'Fatal');
                // throw so that we can detect issues before deploying
                //if (Test.isRunningTest()) {
                //  throw new CS_CustomException(e.getMessage());
                //}
            }
        }
        
    }
    
    /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used to send mails when staves are entered
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       	Mail sending when staves are entered

***************************************************************************************************************/
    
    public static void stavesEntryEmail(Case c)
    {
        List<Single_Barrel_Stave_Setting__mdt> staves = [select MasterLabel, Brand__c, isActive__c, Order__c, Static_Resource_Name__c, Stave_Name__c from Single_Barrel_Stave_Setting__mdt where isActive__c = true AND Brand__c = 'Makers Mark' order by Order__c asc];
        Map<String, Integer> listOfStaves = getStaveQuantity(staves, c.Id );
        List<String> recipientName = new List<String>();
        String diplomat = c.Regional_Diplomat__r.Name;
        String caseNumber = c.CaseNumber;
        String retailAccountName = c.Retail_Account__r.Name;
        String submitter = c.Submitter__r.Name;
        recipientName.add(diplomat);
        recipientName.add(submitter);
        String subjectText = 'Staves have been entered';
        Set<String> userEmail = new Set<String>();        
        User u = [Select id,Name,Email from User where Name =:diplomat limit 1];
        User u2 = [Select id,Name,Email from User where Name =:submitter limit 1];
        userEmail.add(u.Email);
        userEmail.add(u2.Email);
        User u3 = [Select id,Name from User where id=:UserInfo.getUserId() limit 1];
       	List<String> userEmailList = new List<String>(userEmail);
        system.debug('userEmail.size()---->' + userEmail.size());
        for(Integer i = 0 ; i < userEmail.size(); i++)
        { 
            String emailBody = 'Hello '+ recipientName[i] +',<br/><br/>';
            emailBody += 'The staves for barrel ' + caseNumber + ' for ' + retailAccountName + ' have been entered by ' + u3.Name + '. The account selected ' + listOfStaves + '. The barrel is now in the queue to be laid down by the MMPS plant team.<br/><br/>';
            emailBody += 'Thank you,<br/>';
            emailBody += 'The MMPS Team';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.toAddresses = new String[] {userEmailList[i]};
                email.setSubject(subjectText);
            email.setHtmlBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
    
    /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method is used to get stave quantity
History
<Date>      <Authors Name>     <Brief Description of Change>
6/2021     	Yash Jain       Get stave quantity of recipe

***************************************************************************************************************/
    
    @AuraEnabled 
    public static Map<String, Integer> getStaveQuantity(List<Single_Barrel_Stave_Setting__mdt> staveList,String recId){
        list<case> m = [select id,CaseNumber,Retail_Account_Name__c from case where Id = : recId];
        list<Barrel_Recipe__c> k = new list<Barrel_Recipe__c>();
        Map<String, Integer> m1 = new Map<String, Integer>();
        list<Barrel__c> t = [select id,Barrel_Recipe__c from Barrel__c where Case__c = :m[0].Id];
        k = [select Baked_American_Pure_2__c, Maker_s_46__c, Mendiant__c, Roasted_French_Mocha__c, Seared_French_Cuvee__c, Toasted_French_Spice__c from Barrel_Recipe__c where id =:t[0].Barrel_Recipe__c];
        for(Single_Barrel_Stave_Setting__mdt j : staveList)
        {
            String staveName = j.Stave_Name__c;
            if(staveName == 'Baked American Pure 2')
            { 
                m1.put(staveName,Integer.valueOf(k[0].Baked_American_Pure_2__c));
            }
            if(staveName == 'Maker\'s 46')
            {
                m1.put(staveName,Integer.valueOf(k[0].Maker_s_46__c));
            }
            if(staveName == 'Mendiant')
            {
                m1.put(staveName,Integer.valueOf(k[0].Mendiant__c));
            }
            if(staveName == 'Roasted French Mocha')
            {
                m1.put(staveName,Integer.valueOf(k[0].Roasted_French_Mocha__c));
            }
            if(staveName == 'Seared French Cuvee')
            {
                m1.put(staveName,Integer.valueOf(k[0].Seared_French_Cuvee__c));
            }
            if(staveName == 'Toasted French Spice')
            {
                m1.put(staveName,Integer.valueOf(k[0].Toasted_French_Spice__c));
            }
        }
        return m1;
    }
    
    
}