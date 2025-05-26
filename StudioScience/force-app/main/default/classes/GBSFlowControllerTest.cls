@isTest 
public class GBSFlowControllerTest {
    
    enum PortalType { CSPLiteUser, PowerCustomerSuccess, PowerPartner, CustomerSuccess }
    
    static testmethod void usertest() {
        
        GBSFlowController gsf = new GBSFlowController();
        
        User pu = getPortalUser(PortalType.PowerCustomerSuccess, null, true);
        
        System.assert([select isPortalEnabled 
                         from user 
                        where id = :pu.id].isPortalEnabled,
                      'User was not flagged as portal enabled.');       
          
        System.RunAs(pu) {
            System.assert([select isPortalEnabled 
                             from user 
                            where id = :UserInfo.getUserId()].isPortalEnabled, 
                          'User wasnt portal enabled within the runas block. ');
          
          gsf.getUserProfile();
          gsf.getuserAccessGroup();
          gsf.getCustomerPriority();
          gsf.addMore();
          gsf.save();
          gsf.getFeedList();
        }
    }
     
        
    public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {
    
        System.debug('portalType is::::::::'+portalType);
        /* Make sure the running user has a role otherwise an exception 
           will be thrown. */
        if(userWithRole == null) {   
            
            if(UserInfo.getUserRoleId() == null) {

                UserRole ur= new UserRole(name = 'TEST ROLE');
                Database.insert(ur);
                
                Profile p2 = [SELECT Id  FROM Profile WHERE Name='Company Employee'];
               
        userWithRole = new User(firstname = 'user1', lastname = 'one', profileid = p2.Id ,userroleid = ur.id, Customer_priority__c = 'VIP', Military__c = 'Military', Username = 'use1@test.com.dev' ,
           Email = 'use1@test.com', Alias = 'useuse1' , Access_Group__c ='EXTERNAL', CommunityNickname = 'nickname1' , TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', 
           EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US' );        
        
        

         } else {
             UserRole ur= new UserRole(name = 'TEST ROLE');
                Database.insert(ur);
                
                Profile p2 = [SELECT Id  FROM Profile WHERE Name='CS Coordinator'];
               
        userWithRole = new User(firstname = 'user1', lastname = 'one', profileid = p2.Id ,userroleid = ur.id, Customer_priority__c = 'VIP', Military__c = '', Username = 'use1@test.com.dev' ,
           Email = 'use1@test.com', Alias = 'useuse1' , Access_Group__c ='EXTERNAL', CommunityNickname = 'nickname1' , TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', 
           EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US' );
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            
            
        }
        
        Account a;
        Contact c;
        System.runAs(userWithRole) {

            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);
            
            c = new Contact(AccountId = a.id, lastname = 'lastname');
            Database.insert(c);
            
            RecordType r = [select name,id from Recordtype where name = 'Orders' limit 1];
            GBSFlowController test1 = new GBSFlowController ();
        
            Case case1 = new Case(recordTypeId = r.id);
            insert case1;

        //test1.flowID = CSFlowController.flowID;
        test1.flowID = case1.Id;
        test1.addMore();
        List<Attachment> newAtt = test1.newAttachments;
        
        newAtt[0].Name='Unit Test 1';
        newAtt[0].Body=Blob.valueOf('Unit Test 1');

        newAtt[2].Name='Unit Test 2';
        newAtt[2].Body=Blob.valueOf('Unit Test 2');

         
        test1.save();
        }
             
        //all military are vip, not all vip are military
        
        /* Get any profile for the given type.*/
        Profile p = [select id from profile where usertype = :portalType.name() limit 1];   
        
        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname',contactId = c.id);
        
        
        
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
        
        
       

    }
    
    
    public static testMethod void TestProfileType2(){
            
        GBSFlowController gsf1 = new GBSFlowController ();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Company Employee'];
        
        //System.debug('Profile name is:::'+p.Name);
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testUser@test.com' + System.currentTimeMillis());
        insert u1;
        
        // now insert your test data

       System.runAs(u1){
            gsf1.getCustomerPriority();
        }
        
    }
    
    
}