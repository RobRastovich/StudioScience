public with sharing class BSMemailHelper {
  // In a separate class so that it can be used elsewhere
    public Bonus_Coupon__c coupon {get;set;} 
    public list<gvp__Sales_Goal__c> goals {get;set;}
    public Contact couponContact {get;set;}
    public EmailTemplate couponTemplate;
    public boolean hasContact {get;set;}
    public boolean hasEmail {get;set;}
    public string userLang {get;set;}
    public string userEmail {get;set;}
    public boolean emailUser { get; set;}

    public BSMemailHelper(ApexPages.StandardController stdController) { 
        
        //coupon = (Bonus_Coupon__c)stdController.getRecord();

        coupon = [select Id,Account__c,contact__c, Status__c, Amount__c, Pin__c, Wholesaler_Name__c, gvc_Reported_Wholesaler__c, Coupon_Code__c, AccountName__c, Correspondientes__c, Date_Time_Issued__c, Redemption_End_Date__c, Wholesaler_Redeemed__c 
                  from Bonus_Coupon__c 
                  where Id=: stdController.getId() ];

        goals = [select Id, gvp__End_Date__c, gvp__Goal_Quantity__c, gvp__Product_Name__c, gvp__Custom_Fact_1__c, gvp__Label__r.MSRP__c, Bonus_Value__c,  gvp__Reported_Result__c from gvp__Sales_Goal__c where Coupon__c =: stdController.getId()]; 

        if (coupon.Contact__c != null) {
            hasContact = true;
            couponContact = [select Id, Name, Email 
                            from Contact 
                            where Id = : coupon.contact__c ];
            if (couponContact.email != null) {
                hasEmail= true;
            } else {
                hasEmail=false;
            }
        } else {
            hasContact = false;
        }

        couponTemplate = [select Id 
                          from EmailTemplate 
                          where DeveloperName='BSM_Bonus_Coupon'];

        User currentUser = [Select email,LanguageLocaleKey 
                            from User 
                            where username = :UserInfo.getUserName() limit 1];

        userLang= currentUser.LanguageLocaleKey;
        userEmail=currentUser.email;
        
    }
     
    //Redirect to standard email editor NO LONGER USED
    /*
    public  PageReference sendEmail() {
        PageReference emailPage = new PageReference('/email/author/emailauthor.jsp?');
        Map<String, String> params = emailPage.getParameters();
        params.put('p3_lkid',coupon.ID);
        params.put('p2_lkid',couponContact.ID); //email will be attached to the activity history of the account where the button was clicked using the acct.ID
        params.put('template_id','00X2a000000LylA'); /// template ID of the email template to be shown goes here
        //params.put('rtype','003');
        params.put('p24',couponContact.email); //currentUser.Email showing in "Additional to" field
        //params.put('p5','test@beamsuntory.com'); //email address showing in Bcc field
        //params.put('new_template','1'); 
        params.put('retURL',coupon.id); //after send button is clicked, go back to the page where the button was clicked
        params.put('ISDTP','MN'); // disable header and sidebar, use minimal UI
        system.debug('Page Reference is >>>>>>'+emailPage);
        emailPage.setRedirect(true);
        return emailPage;
    } 
    */

    //Send email using Apex Email utility
      
    Public PageReference sendApexEmail(){

        system.debug('***Email User Value***' +emailUser);
        String templateId= couponTemplate.Id;
        String contactId= couponContact.Id;
        String whatId= coupon.Id;

        Messaging.SingleEmailMessage mail=Messaging.renderStoredEmailTemplate(templateId,contactId,whatId);
        List<string> toAddress = new List<string>();
        List<String> ccAddress = new List<String>();
        toAddress.add(couponContact.email);
        ccAddress.add(userEmail);
        mail.setToAddresses(toAddress);

        system.debug('***Email User Value***' +emailUser);
       
        if(emailUser==true) {

            System.debug('**** Email User True block');
            mail.setCcAddresses(ccAddress); 
        }
        mail.setSaveAsActivity(true);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        allmsg.add(mail);
        system.debug('Debug *****'+allmsg);
       
        try {

            //Messaging.sendEmail(allmsg,false);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg);

            if(results[0].success) {

                system.debug('***Email delivery successful***');
                PageReference pageRef= new PageReference ('/' + coupon.Id);
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.BSM_Coupon_Email_Success));
               // pageRef.setRedirect(true);
               // return pageRef;
            } 
            
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.BSM_Coupon_Email_Failure));
          }

          return null;

        
    } 

    //Method to handle cancel action in VF page

    public PageReference cancel() {

        PageReference pageRef= new PageReference ('/' + coupon.Id);
        pageRef.setRedirect(true);
        return pageRef;   

    } 

    
  
}