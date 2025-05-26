global class SpainJITRegHandler implements Auth.SamlJitHandler {
    global Set<String> spain = new Set<String>{'Valverde', 'Palazuelos', 'Jerez', 'Segovia','Madrid','Spain Remote', 'New York  - Global Headquarters', 'United States Remote'};
    
    // Custom exception class for JIT errors
    private class JitException extends Exception {}

    /**
     * Handles the user portion of the JIT provisioning.
     * If 'create' is true, then creates a new user; otherwise updates the user.
     
    private void handleUser(boolean create, User u, Map<String, String> attributes,
                            String federationIdentifier, boolean isStandard) {

        
        // Set alias if creating a new user
        if (create) {
            u.Username=attributes.get('name');
            u.FederationIdentifier = federationIdentifier;
            String alias = '';
            if (u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if (alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        
        // Inherit locale settings from the current user
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey
                            FROM User WHERE Id = :currentUserId];
        u.LocaleSidKey = currentUser.LocaleSidKey;
        u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        u.EmailEncodingKey = currentUser.EmailEncodingKey;
        
        // Set the user's profile
        if (attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile WHERE Id = :profileId];
            u.ProfileId = p.Id;
        } else {
            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'eCommerce' LIMIT 1];
            if (!profiles.isEmpty()) {
                u.ProfileId = profiles[0].Id;
            }
        }
        
        // Set the user's role if provided in the attributes
        if (attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id = :userRole];
            u.UserRoleId = r.Id;
        }
        
        // Create the new user record if needed
        if (create) {
            insert u;
        }
    }
        */

    /**
     * Handles the contact provisioning for a portal or community user.
     * It either locates an existing contact without a user or creates a new one.
     
    private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
        Contact c;
        Boolean newContact = false;
        // Retrieve the record type for Portal contacts
        RecordType contactRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Portal_User' LIMIT 1];
        
        if (create) {
            // Query contacts 
            Map<Id, Contact> contacts = new Map<Id, Contact>([
                SELECT Id, AccountId 
                FROM Contact 
                WHERE email = :attributes.get('name') 
            ]);
            if (!contacts.isEmpty()) {
                c = contacts.values()[0];
            }
            
            // If no existing contact is found, create a new one
            if (c == null) {
                //TODO Need to create an Account
                c = new Contact();
                c.RecordTypeId=contactRT.Id;
                newContact = true;
            }
        } else {
            // For updates, retrieve the existing contact record
            String contactId = u.ContactId;
            c = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
        }
    }
        */

    /**
     * Retrieves the account associated with the incoming SAML attributes.
     * Throws an exception if the account cannot be found.
     
    private String handleAccount(boolean create, User u, Map<String, String> attributes) {
        Account vAccount;
        String accountIdentifier = attributes.get('email');
        try {
            Id RecordTypeId = [SELECT Id, DeveloperName FROM RecordType where DeveloperName='Consumer' Limit 1].Id;
            List<Account> vAccountList = [SELECT Id FROM Account WHERE PersonEmail  = :accountIdentifier];
            if(vAccountList.size()>0){
                vAccount=vAccountList.get(0);
            } 
            
            If(create && vAccount==null){
               vAccount = new Account(PersonEmail=attributes.get('email'), FirstName=attributes.get('givenname'), LastName=attributes.get('surname'));
            }
        } catch (Exception ex) {
            throw new JitException('Could not find account');
        }
        return vAccount.Id;
    }
        */

    /**
     * Main method to process JIT provisioning.
     * Routes processing for community/portal users versus standard users.
     
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        // If this is a portal or community user, handle account and contact provisioning
        if (communityId != null || portalId != null) {
            String accountId = handleAccount(false, u, attributes);
            handleContact(create, accountId, u, attributes);
            handleUser(create, u, attributes, federationIdentifier, false);
        } else {
            // Otherwise, simply process the user
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }
        */
    /**
     * Upserts a portal user based on the provided attributes and federation identifier.
     * If allowCreate is true, a new user will be created if one does not already exist.
     */
    private User upsertPortalUser(
        Map<String, String> attributes,
        String federationIdentifier,
        Boolean allowCreate
    ) {
        String email      = attributes.get('email');
        String firstName  = attributes.get('givenname');
        String lastName   = attributes.get('surname');
        String alias      = (firstName != null && lastName != null) ? (firstName.substring(0,1) + lastName) : 'userx';
        alias             = alias.length() > 8 ? alias.substring(0,8) : alias;
    
        // Check for existing portal user
        List<User> portalUsers = [
            SELECT Id, Username, FirstName, LastName, Email, ContactId, ProfileId, Alias
            FROM User
            WHERE UserType = 'CustomerPortal'
            AND Email = :email
            LIMIT 1
        ];
    
        if (!portalUsers.isEmpty()) {
            User existingUser = portalUsers[0];
            existingUser.FirstName = firstName;
            existingUser.LastName = lastName;
            existingUser.Alias = alias;
            existingUser.FederationIdentifier = federationIdentifier;
            update existingUser;
            return existingUser;
        }
    
        // If creation is not allowed, return null
        if (!allowCreate) {
            return null;
        }
    
        // Look up Person Account record type
        RecordType acctRt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'Consumer'
            LIMIT 1
        ];
    
        // Create Person Account
        Account personAcct = new Account(
            RecordTypeId = acctRt.Id,
            FirstName = firstName,
            LastName = lastName,
            PersonEmail = email
        );
        insert personAcct;
    
        // Lookup Contact
        Contact contact = [
            SELECT Id FROM Contact
            WHERE AccountId = :personAcct.Id
            LIMIT 1
        ];
    
        // Look up portal profile
        Profile portalProfile = [
            SELECT Id FROM Profile
            WHERE Name = 'Spain Employee Shop Shopper Profile'
            LIMIT 1
        ];
    
        // Create Portal User
        User newUser = new User(
            Username = email + '.portal',
            Email = email,
            FirstName = firstName,
            LastName = lastName,
            Alias = alias,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = portalProfile.Id,
            ContactId = contact.Id,
            FederationIdentifier = federationIdentifier,
            CommunityNickname = firstName + '.' + lastName + Math.mod(Crypto.getRandomInteger(), 10000)
        );
        insert newUser;
        return newUser;
    }
    





    global Map<String,String> cleanAttributes(Map<String,String> samlAttributes){
        Map<String,String> vAttributes = new Map<String,String>();
        for(String vString: samlAttributes.keySet()){
            String vKey = vString.replace('http://schemas.microsoft.com/Identity/claims/','');
            vKey=vKey.replace('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/', '');
            vKey=vKey.replace('http://schemas.microsoft.com/claims/', '');
            vKey=vKey.replace('http://schemas.microsoft.com/identity/claims/','');
            vAttributes.put(vKey,samlAttributes.get(vString)); 
            System.debug('Update User: '+vKey+' -> '+samlAttributes.get(vString));
         }
        return vAttributes;
    }

    /**
     * Implementation of Auth.SamlJitHandler.createUser.
     * Creates and returns a new User record based on SAML JIT provisioning.
     */
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        try {
            Map<String, String> vAttributes = cleanAttributes(attributes);
            return upsertPortalUser(vAttributes, federationIdentifier, true);
        } catch (Exception ex) {
            System.debug('createUser error: ' + ex.getMessage());
            return null;
        }
    }
    

    /**
     * Implementation of Auth.SamlJitHandler.updateUser.
     * Updates an existing user based on SAML JIT provisioning.
     */
    global void updateUser(
        Id userId,
        Id samlSsoProviderId,
        Id communityId,
        Id portalId,
        String federationIdentifier,
        Map<String, String> attributes,
        String assertion
    ) {
    try {
        Map<String, String> vAttributes = cleanAttributes(attributes);
        upsertPortalUser(vAttributes, federationIdentifier, false);
    } catch (Exception ex) {
        System.debug('updateUser error: ' + ex.getMessage());
    }
}

    
    

}