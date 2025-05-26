public class CommunitySelfRegController {

    public static final String DEFAULT_ACCT_NAME = 'Customer';
    public string email {get; set;}
    public string company {get; set;}
    public string firstName {get; set;}
    public string lastName {get; set;}
    public string streetAddress {get; set;}
    public string city {get; set;}
    public string postalCode {get; set;}
    public string country {get; set;}
    public boolean vendor {get; set;}
    public string comments {get; set;}
    public string phone {get; set;}
    public string invoiceNumber {get; set;}
    public string tinVatNumber {get; set;}
    public String state {get; set;}
    public string business {get; set;}
    public string selectedLang{get;set;}

    public String invalidDomains {get; set;}

    public string language {
        get;
        set{
            language = ApexPages.currentPage().getParameters().get('language');
            if (String.isBlank(language)) {
                language = 'en_US';
            }
        }
    }
    
    public static Map<String, String> countryToGBSCenterMap = new Map<String, String>();

    static {
        List<GBS_Country_to_Center__mdt> countriesToGBSCentersList = [SELECT Id, Country_Name__c, GBS_Center_Abbreviation__c, GBS_Center_Full_Name__c FROM GBS_Country_to_Center__mdt];
        for (GBS_Country_to_Center__mdt c2c : countriesToGBSCentersList) {
            countryToGBSCenterMap.put(c2c.Country_Name__c, c2c.GBS_Center_Full_Name__c);
            System.debug(c2c.Country_Name__c + ' --- > ' + c2c.GBS_Center_Full_Name__c);
        }
    }

    public Map<String, List<String>> requiredFields = new Map<String, List<String>> {
        'United States' => new List<String>{email, company, firstName, lastName, phone, streetAddress, postalCode, country, city, state, tinVatNumber},
        'Mexico'        => new List<String>{email, company, firstName, lastName, phone, streetAddress, postalCode, country, city, state},
        'Canada'        => new List<String>{email, company, firstName, lastName, phone, streetAddress, postalCode, country, city, state},
        'Default'       => new List<String>{email, company, firstName, lastName, phone, streetAddress, postalCode, country, city, state}
    };

    public List<String> mexicoStates = new List<String> {
        'Aguascalientes',
        'Baja California',
        'Baja California Sur',
        'Chihuahua',
        'Colima',
        'Campeche',
        'Coahuila',
        'Chiapas',
        'Federal District',
        'Durango',
        'Guerrero',
        'Guanajuato',
        'Hidalgo',
        'Jalisco',
        'México State',
        'Michoacán',
        'Morelos',
        'Nayarit',
        'Nuevo León',
        'Oaxaca',
        'Puebla',
        'Querétaro',
        'Quintana Roo',
        'Sinaloa',
        'San Luis Potosí',
        'Sonora',
        'Tabasco',
        'Tlaxcala',
        'Tamaulipas',
        'Veracruz',
        'Yucatán',
        'Zacatecas'
    };
    public List<SelectOption>getAvailableLanguages(){
    
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('en','English'));
        options.add(new selectOption('de','German'));
        options.add(new selectOption('es','Spanish'));
        options.add(new selectOption('fr','French'));
        options.add(new selectOption('es_MX','Spanish (Mexico) '));
        options.add(new selectOption('zh_CN','Chinese (Simplified)'));
        options.add(new selectOption('ko','Korean'));
        
        return options;
    
    }
    public List<selectOption> stateAbbreviations {
        get {
            String noneOption = '-N/A-';
            Country_State__c none = Country_State__c.getInstance(noneOption);
            List<selectOption> options = new List<selectOption>();
            List<selectOption> sortedOptions = new List<selectOption>();

            // if (String.isBlank(country)) {
            //     country = 'United States';
            // }
            if (country == 'Mexico') {
                for (String s : mexicoStates) {
                    sortedOptions.add(new SelectOption(s, s));
                }
            } else if (country == 'United States') {
                for (Country_State__c abbv : Country_State__c.getAll().values()) {
                    if (abbv.Name != noneOption) {
                        sortedOptions.add(new SelectOption(abbv.Abbreviations__c, abbv.Name));
                    }
                }
            } else if (country == 'Canada') {
                for (Country_Province__c abbv : Country_Province__c.getAll().values()) {
                    if (abbv.Name != noneOption) {
                        sortedOptions.add(new SelectOption(abbv.Abbreviations__c, abbv.Name));
                    }
                }
            }

            sortedOptions.sort();
            options.addAll(sortedOptions);
            options.add(new SelectOption(none.Abbreviations__c, none.Name));
            return options;
        }
        set;
    }

    public List<selectOption> countries {

        get {
            List<selectOption> options = new List<selectOption>();
            Schema.DescribeFieldResult fieldResult = Case.Employee_Location__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                options.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
            }
            return options;
        }
        set;
    }

    public List<selectOption> businesses {
        get {
            List<selectOption> options = new List<selectOption>();
            Schema.DescribeFieldResult fieldResult = Contact.Primary_Business__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                options.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
            }
            return options;
        }
        set;
    }


    public CommunitySelfRegController() {
        List<String> domains = new List<String>();
        List<SelfRegistrationEmailDomain__mdt> invalidDomainMetadata = [select Domain__c from SelfRegistrationEmailDomain__mdt];
        if (!invalidDomainMetadata.isEmpty()) {
            for (SelfRegistrationEmailDomain__mdt dom: invalidDomainMetadata) {
                domains.add(dom.Domain__c);
            }
        }
        this.invalidDomains = JSON.serialize(domains);
    }

    public PageReference registerUser() {
        Case newCase = new Case();
        String accountName = Label.SelfRegAccount;
        String contactRecordTypeName = Label.SelfRegContactRTName;
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Registration_Approval').getRecordTypeId();
        Id contactRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Registration_Approval').getRecordTypeId();

        // check for existing user
        if (doesUserExist(email)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SelfRegEmailError1));
            return null;
        }
        if (isPageValid()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SelfRegUserTypeError1));
            return null;
        }

        //String language = ApexPages.currentPage().getParameters().get('language');
        String language = selectedLang;
        if (String.isBlank(language)) {
            language = 'en_US';
        }

        Account acct = getDefaultAccount();
        Contact con = getContactByEmail(email);

        con.RecordTypeId = contactRTId;
        con.LastName = lastName;
        con.FirstName = firstName;
        con.AccountID = acct.Id;
        con.Email = email;
        con.Company__c = company;
        con.MailingStreet = streetAddress;
        con.MailingCity = city;
        con.MailingCountry = country;
        con.MailingPostalCode = postalCode;
        con.MailingState = state;
        con.OtherStreet = streetAddress;
        con.OtherCity = city;
        con.OtherCountry = country;
        con.OtherPostalCode = postalCode;
        con.OtherState = state;
        con.Vendor__c = true;
        con.Description = comments;
        con.Primary_Business__c = business;
        //Commented the  following line field mapping as part of SR_174229; 
        //con.Invoice_Number__c = invoiceNumber;
        con.TIN_VAT_Number__c = tinVatNumber;
        //Remove non-numeric values
        con.phone = phone.replaceAll('[^0-9]', '');

        //fix this
        if (!(con.Customer__c || con.Vendor__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SelfRegUserTypeError1));
            return null;
        } //else if(!state.equals('N/A') && String.isBlank(tinVatNumber)){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SelfRegTINVATError1));
        //}
        else {
            try {
                upsert con;

                //Proceed to insert case
                
                newCase.RecordTypeId = caseRTId;
                newCase.Origin = System.Label.SelfRegCaseOrigin;
                newCase.Case_Language__c = language;
                newCase.ContactId = con.Id;
                newCase.Description = con.Description;
                newCase.SuppliedEmail = con.Email;
                newCase.SuppliedName = con.FirstName + con.LastName;
                newCase.SuppliedCompany = con.Company__c;
                newCase.SuppliedPhone = con.Phone;
                
                if (business.equals('Suntory Beverage Food Europe') && countryToGBSCenterMap.get(country).equals('Madrid')) {
                    newCase.GBS_Center__c = 'SBFE';
                }
                else if (country != null) {
                    String gbsCenter = countryToGBSCenterMap.get(country);
                    if (gbsCenter != null) {
                        newCase.GBS_Center__c = gbsCenter;
                    }
                    else {
                        newCase.GBS_Center__c = 'US/Canada';
                    }
                }
                else {
                    newCase.GBS_Center__c = 'US/Canada';
                }

                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.AssignmentRuleHeader.useDefaultRule = true;
                newCase.setOptions(dmo);

                insert newCase;
            } catch (DMLException e) {
                CreateExceptionLog.insertErrorLog('CommunitySelfRegController', 'registerUser', String.valueOf(e), 'Fatal');
            }
        }

        if (newCase.Id != null && con.Id != null) {
            sendEmail(newCase, con.Id);
            PageReference page = System.Page.CommunitySelfRegConfirm;
            page.getParameters().put('language', language);
            page.setRedirect(true);
            return page;
        }
        return null;
    }

    private void sendEmail(Case newCase, Id contactId) {
        // every email template for each language should follow the same pattern
        // 'Vendor_Registration_Confirmation' + language locale key 
        // ex. Vendor_Registration_Confirmation_en_US
        String emailTemplateName = 'Vendor_Registration_Confirmation_' + newCase.Case_Language__c;
        EmailTemplate templateId = [Select Id from EmailTemplate where DeveloperName = :emailTemplateName];
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(templateId.Id);
        mail.setWhatId(newCase.Id);
        mail.setToAddresses(new List<String> {email});
        mail.setTargetObjectId(contactId);
        mail.setSaveAsActivity(false);
        messages.add(mail);
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        } catch (EmailException e) {
            CreateExceptionLog.insertErrorLog('CommunitySelfRegController', 'sendEmail', String.valueOf(e), 'Fatal');
        }
    }

    public static Contact getContactByEmail(String emailAddress) {
        Contact c = new Contact();

        List<Contact> contacts = [Select Id, Email, Customer__c, Vendor__c from Contact where email = :emailAddress];

        if (!contacts.isEmpty()) {
            if (contacts.size() > 1) {
                CreateExceptionLog.insertErrorLog('CommunitySelfRegController', 'getContactByEmail', 'Possible Duplicate Contacts ' + contacts, 'Fatal');
            }
            c = contacts[0];
        }
        return c;
    }

    public static Account getDefaultAccount() {
        Account defaultAccount = new Account();
        Id defaultAccountRecordTypdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();

        List<Account> accts = [select Id from Account where Name = :DEFAULT_ACCT_NAME AND RecordTypeId = :defaultAccountRecordTypdId limit 1];

        if (!accts.isEmpty()) {
            defaultAccount = accts[0];
        } else {
            defaultAccount.Name = DEFAULT_ACCT_NAME;
            defaultAccount.RecordTypeId = defaultAccountRecordTypdId;
            insert defaultAccount;
        }
        return defaultAccount;
    }

    public static Boolean doesUserExist(String userEmail) {
        Boolean isExistingUser = false;

        List<User> users = [select Id from User where Email = :userEmail AND isActive = true];

        if (!users.isEmpty()) {
            isExistingUser = true;
        }
        return isExistingUser;
    }

    public Boolean isPageValid() {
        List<String> requiredFieldsList = requiredFields.get(country); 
        if (requiredFieldsList == null) {
            requiredFieldsList = requiredFields.get('Default'); 
        }

        for (String requiredField : requiredFieldsList) {
            if (String.isBlank(requiredField)) {
                return false;
            }
        }
        return true;
    }
}