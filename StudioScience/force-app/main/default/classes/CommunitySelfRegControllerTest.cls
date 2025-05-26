@isTest
private class CommunitySelfRegControllerTest {
    @testSetup static void testSetupMethod(){
        Account a = new Account();
        a.name = 'Customer';
        insert a;
        List<Country_State__c> states = new List<Country_State__c>();
        states.add(new Country_State__c(Abbreviations__c='IL',Name='Illinois'));
        states.add(new Country_State__c(Abbreviations__c='N/A',Name='-N/A-'));
        insert states;
    }

    @isTest static void testRegisterContact() {
        CommunitySelfRegController cont = new CommunitySelfRegController();
        cont.email = 'test@mail.com';
        cont.company = 'Company';
        cont.firstName = 'First';
        cont.lastName = 'Last';
        cont.streetAddress = '123 Street';
        cont.city = 'Chicago';
        cont.postalCode = '60610';
        cont.country = 'United States';
        cont.vendor = true;
        cont.comments = 'Comments';
        cont.invoiceNumber = 'P1232';
        cont.state = 'IL';
        cont.phone = '5550123456';
        cont.tinVatNumber = 'TV-01';
        cont.business = 'Suntory Beverage Food Europe';
        List<selectOption> lst = cont.stateAbbreviations; 
        System.assert(cont.registerUser() != null);
        System.assert(lst.size() > 0);

        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }
    
    @isTest static void testRegisterContactMadridSBFE() {
        CommunitySelfRegController cont = new CommunitySelfRegController();
        cont.email = 'test@mail.com';
        cont.company = 'Company';
        cont.firstName = 'First';
        cont.lastName = 'Last';
        cont.streetAddress = '123 Street';
        cont.city = 'Madrid';
        cont.postalCode = '11111';
        cont.country = 'Spain';
        cont.vendor = true;
        cont.comments = 'Comments';
        cont.invoiceNumber = 'P1232';
        cont.state = 'N/A';
        cont.phone = '5550123456';
        cont.tinVatNumber = 'TV-01';
        cont.business = 'Suntory Beverage Food Europe';
        List<selectOption> lst = cont.stateAbbreviations; 
        System.assert(cont.registerUser() != null);
        System.assert(lst.size() > 0);

        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }
    
    @isTest static void testRegisterContactCountryNoGBSCenter() {
        CommunitySelfRegController cont = new CommunitySelfRegController();
        cont.email = 'test@mail.com';
        cont.company = 'Company';
        cont.firstName = 'First';
        cont.lastName = 'Last';
        cont.streetAddress = '123 Street';
        cont.city = 'Madrid';
        cont.postalCode = '11111';
        cont.country = 'Bostwana';
        cont.vendor = true;
        cont.comments = 'Comments';
        cont.invoiceNumber = 'P1232';
        cont.state = 'N/A';
        cont.phone = '5550123456';
        cont.tinVatNumber = 'TV-01';
        cont.business = 'Beam Suntory';
        List<selectOption> lst = cont.stateAbbreviations; 
        System.assert(cont.registerUser() != null);
        System.assert(lst.size() > 0);

        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }
    
        @isTest static void testRegisterContactCountryIsNull() {
        CommunitySelfRegController cont = new CommunitySelfRegController();
        cont.email = 'test@mail.com';
        cont.company = 'Company';
        cont.firstName = 'First';
        cont.lastName = 'Last';
        cont.streetAddress = '123 Street';
        cont.city = 'Madrid';
        cont.postalCode = '11111';
        cont.country = null;
        cont.vendor = true;
        cont.comments = 'Comments';
        cont.invoiceNumber = 'P1232';
        cont.state = 'N/A';
        cont.phone = '5550123456';
        cont.tinVatNumber = 'TV-01';
        cont.business = 'Beam Suntory';
        List<selectOption> lst = cont.stateAbbreviations; 
        System.assert(cont.registerUser() != null);
        System.assert(lst.size() > 0);

        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }


    @isTest static void testRegisterContactWithNoUserType(){
        CommunitySelfRegController cont = new CommunitySelfRegController();
        cont.email = 'test@mail.com';
        cont.company = 'Company';
        cont.firstName = 'First';
        cont.lastName = 'Last';
        cont.streetAddress = '123 Street';
        cont.city = 'Chicago';
        cont.postalCode = '60610';
        cont.country = 'United States';
        cont.vendor = false;
        cont.comments = 'Comments';
        cont.invoiceNumber = 'P1232';
        cont.state = 'Illinois';
        cont.phone = '5550123456';
        cont.business = 'Suntory Beverage Food Europe';
        List<selectOption> lst = cont.stateAbbreviations; 
        System.assert(cont.registerUser() != null);
        System.assert(lst.size() > 0);
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest static void testRegisterContactEmailInUse(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile sysAdminProfile = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner = new User(
            UserRoleId = portalRole.Id,
            ProfileId = sysAdminProfile.Id,
            Username = System.now().millisecond() + 'test@admin.com',
            Alias = 'admin',
            Email='test@admin.com',
            EmailEncodingKey='UTF-8',
            Firstname='Test',
            Lastname='Admin',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert portalAccountOwner;

        System.runAs(portalAccountOwner){
            Account portalAccount = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner.Id
            );
            insert portalAccount;
            Contact portalContact = new Contact(
                FirstName = 'Test',
                Lastname = 'Contact',
                AccountId = portalAccount.Id,
                Email = System.now().millisecond() + 'test@admin.com'
            );
            insert portalContact;

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name=:System.Label.SelfRegProfile Limit 1];
            User portalUser = new User(
                Username = System.now().millisecond() + 'test-user@mail.com',
                ContactId = portalContact.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test',
                Email = 'test@mail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test-nickname',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            insert portalUser;
        }

        CommunitySelfRegController cont = new CommunitySelfRegController();
        cont.getAvailableLanguages();
        cont.email = 'test@mail.com';
        cont.company = 'Company';
        cont.firstName = 'First';
        cont.lastName = 'Last';
        cont.streetAddress = '123 Street';
        cont.city = 'Chicago';
        cont.postalCode = '60610';
        cont.country = 'United States';
        cont.vendor = true;
        cont.comments = 'Comments';
        cont.invoiceNumber = 'P1232';
        cont.state = '-N/A-';
        cont.phone = '5550123456';
        cont.business = 'Suntory Beverage Food Europe';
        List<selectOption> lst = cont.stateAbbreviations; 
        System.assert(cont.registerUser() == null);
        System.assert(lst.size() > 0);
    }
}