@isTest
public class GBS_CaseAssignedSendEmailTest {
    @testSetup
    static void setupData() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        Profile p = [SELECT Id FROM Profile WHERE Name='GBS Analyst']; 
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='TestingUser', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com', Country='Australia');
        
        Blob b2 = Crypto.GenerateAESKey(128);
        String h2 = EncodingUtil.ConvertTohex(b2);
        String uid2 = h2.SubString(0,8);
        User u2 = new User(Alias = uid2, Email= uid2 + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='OtherUser', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid2 + '@myorg.com', Country='Japan'); 
        
        List<User> users = new List<User>();
        users.add(u);
        users.add(u2);
        insert users;
        
        Case c1 = new Case();
        c1.RecordTypeId = GBS_Constants.RTR_RT_ID;
        c1.Type = 'Record to Report';
        c1.Primary_Category__c = 'Report Request';
        c1.Status = 'Logged';
        c1.OwnerId = u.Id;
        c1.SuppliedEmail = u.Id + 'test@myorg.com';
        
        Case c2 = new Case();
        c2.RecordTypeId = GBS_Constants.CLAIMS_RT_ID;
        c2.Type = 'Claims';
        c2.Primary_Category__c = 'Other claim requests';
        c2.Status = 'Logged';
        c2.OwnerId = u.Id;
        c2.SuppliedEmail = u.Id + 'test@myorg.com';
        
        List<Case> cases = new List<Case>();
        cases.add(c1);
        cases.add(c2);
        insert cases;
    }
    
    @isTest
    static void sendEmailConditionsMetTest() {
        Case c = [SELECT Id, Type, Status, OwnerId FROM Case WHERE Type = 'Record to Report'];
        User u = [SELECT Id, LastName FROM User WHERE LastName = 'OtherUser'];
        
        c.Status = 'In Progress';
        c.OwnerId = u.Id;
        
        Test.startTest();
        update c;
        Test.stopTest();
    }
    
    @isTest
    static void doNotSendEmailConditionsNotMetTest() {
        Case c = [SELECT Id, Type, Status, OwnerId FROM Case WHERE Type = 'Claims'];
        
        c.Status = 'In Progress';
        
        Test.startTest();
        //no ownership change, no email sent.
        update c;
        Test.stopTest();
    }
}