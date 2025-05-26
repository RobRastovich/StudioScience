public class SBP_EmailUtility {
    public static Map<String, String> brandToQueue = new Map<String, String> {
        'Knob Creek' => 'Knob Creek - Single Barrel'
    };
        
    public String accountApplicationId {get; set;}
    public String submitterId {get; set;}
    public Id barrelId {get; set;}
    public Id caseId {get; set;}
    public String distributorId {get; set;}
    public String sampleKitId {get; set;}
    public Case sampleKitCase {
        get{
            Sample_Kit__c sampleKit = [select id, Barrel_Order_Group__c, Tracking_Number__c from Sample_Kit__c
                                       where Id = :sampleKitId limit 1];

            return [select id, Submitter__c, CaseNumber, Account.Name, Retail_Account__r.Name, Brand__c, Product_Type__c
                    from Case where Barrel_Order_Group__c = :sampleKit.Barrel_Order_Group__c limit 1];
        } set;
    }
    public String baseUrl {
        get{
            return URL.getSalesforceBaseUrl().toExternalForm();
        }
        set;
    }

    public String submitterEmail {
        get {
            return [Select Id, email from User where id = : submitterId].email;
        }
        set;
    }

    public Sample_Kit__c sampleKit {
        get {
            return [Select Id, Case__r.CaseNumber, Case__r.Retail_Account__r.Name, Tracking_Number__c, Carrier__c 
                    from Sample_Kit__c where Id = : sampleKitId];
        }
        set;
    }

    public List<Barrel__c> completedBarrels {
        get {
            return [Select Id
            , Ship_Date__c
            , Expected_Ship_Date__c
            , PO_Number__c
            , Proof__c
            , Quantity__c
            , Brand__c
            , SKU__c
            , Barrel_Number__c
            , Case__r.SAP_Number__c
            , Case__c
            , Case__r.CaseNumber
            , Distributor__r.Name
            , Case__r.Account.Name
            , Case__r.Retail_Account__r.Name from Barrel__c where Id = : barrelId limit 1];
        }
        set;
    }

    public List<Case> salesRepCases {
        get{
            return [SELECT Id, Bottle_Text_Entered__c, POS_Items_Selected__c, Retail_Account__r.Name, Barrel_Selected__c, Type, Purchase_Order_Uploaded__c, Brand__c, CaseNumber, AccountId, Account.Name FROM Case WHERE Submitter__c = :submitterId
                      AND isClosed = false
                      AND Missing_Items__c = true And Status NOT IN ('Canceled','Cancelled - Kit Not Selected','Cancelled-Allocation','Canceled - Age/Variety','Closed','Closed - Abandoned')
                      AND RecordTypeId IN :SBP_Constants.caseSingleBarrelRtIds];
        }
        set;
    }

    public String distributorEmail {
        get {
            return [Select Id, email from Contact where id = : distributorId].email;
        }
        set;
    }

    public List<Case> cases {
        get{
            return [SELECT Id, Purchase_Order_Uploaded__c, Brand__c, Retail_Account_Name__c, Type, CaseNumber, Retail_Account__c, Retail_Account__r.Name, AccountId, Account.Name FROM Case WHERE ContactId = :distributorId
                      AND isClosed = false
                      AND Missing_PO__c = true
                      And Status NOT IN ('Canceled','Cancelled - Kit Not Selected','Cancelled-Allocation')
                      AND RecordTypeId IN :SBP_Constants.caseSingleBarrelRtIds];
        }
        set;
    }

    public List<Application_Response__c> questions {
        get{
            return [SELECT Id
            , Answer_Text__c
            , Question_Text__c
            , Account_Application__c
            , Account_Application__r.Account__r.ShippingCity
            , Account_Application__r.Account__r.TDL_Match_Code__c
            , Account_Application__r.Account__r.PremiseType__c
            , Account_Application__r.Account__r.Name from Application_Response__c
                    where Account_Application__c = :accountApplicationId];
        }
        set;
    }




    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/

    public static List<Messaging.SingleEmailMessage> sendMissingItemEmail(Set<Id> userIds, String emailTemplateName) {
        List<Messaging.SingleEmailMessage> emailMessagesToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, User> userMap = new Map<Id, User>();

        for (User u : [select Id, Email from User where Id IN :userIds AND IsActive = true])
        {
            userMap.put(u.Id, u);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];

        for (User user : userMap.values()) {

            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(String.valueOf(template.Id), user.Id, null);
            email.setToAddresses(new List<String> {user.Email});
            if ( SBP_Constants.singleBarrelOWEA != null ) 
                email.setOrgWideEmailAddressId(SBP_Constants.singleBarrelOWEA.Id);
            else 
                email.setSenderDisplayName('Single.Barrels@Beamsuntory.com');
            email.setSaveAsActivity(false);
            emailMessagesToSend.add(email);
        }
        return emailMessagesToSend;
    }


    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/

    public static List<Messaging.SingleEmailMessage> missingPurchaseOrderEmail(String emailTemplateName, Map<Id, List<String>> contactToCcemailMap) {
        List<Messaging.SingleEmailMessage> emailMessagesToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        for (Contact c : [select Id, Email from Contact where Id IN :contactToCcemailMap.keySet()]) {
            contactMap.put(c.Id, c);
        }

        List<Custom_Exception_Logs__c> errors = new List<Custom_Exception_Logs__c>();

        // loop through all distributors
        for (Contact contact : contactMap.values()) {
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(String.valueOf(template.Id), contact.Id, null);
            if (contactToCcemailMap.containsKey(contact.Id)) {
                List<String> ccEmails = contactToCcemailMap.get(contact.Id);
                if (String.isBlank(contact.Email)) {
                    errors.add(CreateExceptionLog.createExceptionLog('SBP_EmailUtility', 'missingPurchaseOrderEmail', 'Contact is missing and email address: ' + contact.Id, 'Warning', false));
                    continue;
                } else {
                    ccEmails.add(contact.Email);
                    email.setToAddresses(ccEmails);
                }

            } else {
                email.setToAddresses(new List<String> {contact.Email});
            }
            if ( SBP_Constants.singleBarrelOWEA != null ) 
                email.setOrgWideEmailAddressId(SBP_Constants.singleBarrelOWEA.Id);
            else 
                email.setSenderDisplayName('Single.Barrels@Beamsuntory.com');
            email.setSaveAsActivity(false);
            emailMessagesToSend.add(email);
        }

        return emailMessagesToSend;
    }

    public List<String> BottleTextEntered {
        get {
            
            Case c = [Select Id, CaseNumber, (Select Id, Name from Barrels__r) 
                      from Case where Id = :caseId LIMIT 1];
            if(c.Barrels__r[0].Id==null)
                return null;
            Id barrelId = c.Barrels__r[0].Id;
            
            Barrel__c b= [Select Id, Name, (Select Id, Name, Insert_Text__c, Type__c from POS_Customizations__r 
                                            Where Type__c='Bottle Plate Text' order by createdDate ASC) from Barrel__c WHERE Id = :barrelId LIMIT 1];
            
            
             List<String>BottleValues = new List<String>();
            integer i=1;
            for(POS_Customization__c cust: b.POS_Customizations__r ){
                if(cust.Insert_Text__c!=null){
                    BottleValues.add(cust.Insert_Text__c);
                }
                i++;
            }
            
            /*String Bottle_Text;
            
            if(!b.POS_Customizations__r.isEmpty() && b.POS_Customizations__r[0]!=null)
                Bottle_Text = b.POS_Customizations__r[0].Insert_Text__c;
            
            return Bottle_Text;
            */
            return BottleValues;
        } set;
    }
   //Added this method for city and state functionality 
   public List<String> BottleTextCityStateEntered {
        get {
            
            Case c = [Select Id, CaseNumber, (Select Id, Name from Barrels__r) 
                      from Case where Id = :caseId LIMIT 1];
            if(c.Barrels__r[0].Id==null)
                return null;
            Id barrelId = c.Barrels__r[0].Id;
            
            Barrel__c b= [Select Id, Name, (Select Id, Name, Insert_Text__c, Type__c from POS_Customizations__r 
                                            Where Type__c='Bottle Label Text City and State'  order by createdDate ASC) from Barrel__c WHERE Id = :barrelId LIMIT 1];
            
            
            List<String>BottleValues = new List<String>();
            integer i=1;
            for(POS_Customization__c cust: b.POS_Customizations__r ){
                if(cust.Insert_Text__c!=null){
                    BottleValues.add(cust.Insert_Text__c);
                }
                i++;
            }
            
            String Bottle_Text;
            
            if(!b.POS_Customizations__r.isEmpty() && b.POS_Customizations__r[0]!=null)
                Bottle_Text = b.POS_Customizations__r[0].Insert_Text__c;
            if(Bottle_Text =='' || Bottle_Text ==null)
                Bottle_Text = '';
            return BottleValues;
        } set;
    }
    
    
    public Sample_Kit__c sampleKitCancellationEmails
    {
        get {
            return [Select Id, Case__r.CaseNumber, Case__r.Retail_Account__r.Name, Tracking_Number_Creation_Date__c
                    from Sample_Kit__c where Id = : sampleKitId];
            }
        set;
    }
    
    
}