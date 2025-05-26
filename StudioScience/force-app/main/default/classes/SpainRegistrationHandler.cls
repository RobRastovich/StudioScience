/**
Author: Rob Rastovich
Date: 2025
**/
global class SpainRegistrationHandler implements Auth.RegistrationHandler{
    global Set<String> vSpainLocation = new Set<String>{'Valverde', 'Palazuelos', 'Jerez', 'Segovia','Madrid','Spain Remote', 'New York  - Global Headquarters', 'United States Remote'};

    private static final String ORG_SUFFIX = '.sso.badge.org';
    public static final String DEFAULT_ACCOUNTNAME = 'Acme';
    
    /**
     * Let anyone register as long as the required fields are supplied
     * 
     * We require email, lastName, firstName
     * 
     * @data - the user's info from the Auth Provider
     **/ 
    global boolean canCreateUser(Auth.UserData data) {
        System.debug('canCreateUser was called for ' + (data != null ? data.email : 'null'));
        Map<String, Object> rootMap = (Map<String, Object>) JSON.deserializeUntyped(data.idTokenJSONString);
        Boolean retVal = (data != null 
                && data.email != null
                && data.lastName != null
                && data.firstName != null
                && vSpainLocation.contains((String) rootMap.get('Office'))
                && (String) rootMap.get('EmployeeType')=='External_USER');
        
        System.debug('data.username='+data.username);
        System.debug('data.email='+data.email);
        System.debug('data.lastName='+data.lastName);
        System.debug('data.firstName='+data.firstName);
        System.debug('EmployeeType='+(String) rootMap.get('EmployeeType'));
        System.debug('Office='+(String) rootMap.get('Office'));

        
        return retVal;
    }
    
    /**
     * Create the User - A required method to implement the Handler Interface
     * 
     * @param portalId  - Id of the Community
     * @param data - Auth Provider user data describing the User to create
     * 
     * @return User that has been initialized
    **/ 
    global User createUser(Id portalId, Auth.UserData data){

        if(!canCreateUser(data)) {
            // Returning null signals the auth framework we can't create the user
            return null;
        }

        System.debug('data: '+data.idTokenJSONString);
        Map<String, Object> rootMap = (Map<String, Object>) JSON.deserializeUntyped(data.idTokenJSONString);
        System.debug('Office='+(String) rootMap.get('Office'));
        String vLocation=(String) rootMap.get('Office');

        System.debug('vLocation='+vLocation);
        if(!vSpainLocation.contains(vLocation)) {
            return null;
        } 
        
        
        // Is this a Community Context?
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            System.debug('Registering Community user: ' + data.email);
            
            // To keep things modular, we're creating the PersonAccount in a separate method
            Account vAccount = createPersonAccountContact(data);
            Id contactId = vAccount.PersonContactId;

            
            // You'd likely use other logic to assign the Profile
            Profile vProfile = [SELECT Id FROM profile WHERE name='Spain Employee Shop Shopper Profile'];
    
            // Keeping it modular, we initialize the user in another method
            User u = createUser(data,vProfile, contactId);
            
            u.contactId = contactId;


            //Assign Permission Set Group to the user
            assignPermissionSetGroupToUser(u.Id, 'Commerce_Shopper');

            //Assign Permission Set Licenses to the user
            assignPermissionSetLicensesToUser(u.Id);

            //Assign buyer groups to the user
            addUserToBuyerGroups(u.Id, vAccount.Id);


            return u;
        } else {
            return null;
        }
        
    }

    /**
     * Create a PersonAccount for the contact
     * 
     * @param data - Facebook provided context for this User
     **/ 
    private Account createPersonAccountContact(Auth.UserData data) {

        List<Account> vAccountList = [Select PersonContactId, Id From Account Where personEmail = :data.email];

        if(vAccountList.size()==1) {
            System.debug('Person Account already exists for ' + data.email + ' id=' + vAccountList[0].Id);
            return vAccountList[0];
        }

        Account person = new Account();
        person.LastName = data.lastName;
        person.FirstName = data.FirstName;
        person.personEmail = data.email;
        person.RecordTypeId = [Select Id From RecordType 
                                Where SobjectType='Account' 
                                  AND isPersonType=true LIMIT 1].id;
        
        insert person;
        
        System.debug('Person Account created for ' + data.email + ' id=' + person.id);
        
        /**
         * This next step is necessary to get a valid contact Id,
         * it won't exist until the PersonAcct is saved
         **/         
        Account vAccount = [Select PersonContactId From Account Where Id = :person.Id];
        
        return vAccount; 

    }
    
    /**
     * Create and initialize the User but don't save it yet
     * 
     * @param data - the provided User context from FaceBook
     * @param p - the Profile we are going to assign to this user
     * 
     * @return User that has been initialized but not Saved
     **/ 
    private User createUser(Auth.UserData data, Profile p, Id contactId) {
        System.debug('Update User called for: ' + data);
        //make sure user does not already exist
        List<User> UserList = [SELECT Id FROM User WHERE username = :data.email + ORG_SUFFIX ];
        if(UserList.size() > 0) {
            System.debug('User already exists for ' + data.email);
            return UserList[0]; // User already exists, return null
        }

        User u = new User();
        u.username = data.email + ORG_SUFFIX;
        u.contactId = contactId;
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.firstName + data.lastName;
        
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        insert u;
        return u;
        
    }

        /**
     * Update the user
     * @param portalId  - Id of the Community
     * @param data - Auth Provider user data describing the User to create
     **/     
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        System.debug('Update User called for: ' + data);
        // Is this a Community Context?
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            System.debug('Updating Community user: ' + data.email);
            
            // To keep things modular, we're creating the PersonAccount in a separate method
            Account vAccount = createPersonAccountContact(data);

            //Assign Permission Set Group to the user
            assignPermissionSetGroupToUser(userId, 'Commerce_Shopper');

            //Assign Permission Set Licenses to the user
            assignPermissionSetLicensesToUser(userId);

            //Assign buyer groups to the user
            addUserToBuyerGroups(userId, vAccount.Id);


        } 


    }

    public static Boolean assignPermissionSetGroupToUser(Id userId, String psgName) {
        // 1) Verify User exists
        User u = [SELECT Id 
                    FROM User 
                   WHERE Id = :userId 
                   LIMIT 1];
        if (u == null) {
            return false;
        }
        
        // 2) Verify Permission Set Group exists
        PermissionSetGroup psg = [SELECT Id 
                                    FROM PermissionSetGroup 
                                   WHERE DeveloperName = :psgName 
                                   LIMIT 1];
        if (psg == null) {
            return false;
        }
        
        // 3) Create the assignment
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId      = u.Id,
            PermissionSetGroupId = psg.Id
        );
        
        // 4) Insert and let exceptions bubble if they occur
        insert psa;
        return true;
    }

    public static Boolean assignPermissionSetLicensesToUser(Id userId) {
        if (userId == null) {
            return false;
        }
        
        // 1) Lookup the two desired PSLs by MasterLabel
        List<PermissionSetLicense> pslList = [
            SELECT Id 
              FROM PermissionSetLicense
             WHERE MasterLabel IN :new List<String>{'Commerce User', 'Salesforce Payments External'}
        ];
        if (pslList.isEmpty()) {
            return false;
        }
        
        // 2) Build assignment records
        List<PermissionSetLicenseAssign> assigns = new List<PermissionSetLicenseAssign>();
        for (PermissionSetLicense psl : pslList) {
            assigns.add(new PermissionSetLicenseAssign(
                AssigneeId              = userId,
                PermissionSetLicenseId  = psl.Id
            ));
        }
        
        // 3) Bulk insert and handle errors
        try {
            insert assigns;
            return true;
        } catch (DmlException ex) {
            // Log or rethrow as needed
            System.debug('Permission Set License assignment failed: ' + ex.getMessage());
            throw ex;
        }
    }

    public static Boolean addUserToBuyerGroups(Id userId, Id accountId) {
        if (userId == null || accountId == null) {
            return false;
        }
        
        //Lookup the two BuyerGroup records by Name
        List<BuyerGroup> groups = [
            SELECT Id, Name
              FROM BuyerGroup
             WHERE Name IN :new List<String>{'Spain Shop: Madrid','Spain Shop: Segovia'}
        ];
        if (groups.isEmpty()) {
            return false;
        }
        
        // Construct BuyerGroupMember records
        List<BuyerGroupMember> members = new List<BuyerGroupMember>();
        for (BuyerGroup bg : groups) {
            members.add(new BuyerGroupMember(
                buyerId       = accountId,
                BuyerGroupId  = bg.Id
            ));
        }
        
        // 4) Bulk insert within try/catch to handle duplicates or perms
        try {
            insert members;
            return true;
        } catch (DmlException ex) {
            // Log exception or rethrow as needed
            System.debug('Failed to assign BuyerGroupMember: ' + ex.getMessage());
            throw ex;
        }
    }
    
    
}