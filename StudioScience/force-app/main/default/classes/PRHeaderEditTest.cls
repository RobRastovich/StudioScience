@isTest
public class PRHeaderEditTest {
    
    @testSetup static void setup(){
    	List<Profile> pf= [Select Id, Name from Profile where Name IN ('Commercial Services Management','System Administrator')];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        List<User> userListToInsert = new List<User>();
        for(Profile p : pf){
            if(p.Name == 'System Administrator'){
                User u1=new User(firstname = 'Test SYSTEM ADMIN1', lastName = 'XYZ1', email = 'abcSystem1' + '@test1' + orgId + '.org', 
                         Username = 'testSystem1@test1.com', EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = p.Id);
                userListToInsert.add(u1);
                
            }else{
                User u2=new User(firstname = 'Test2', lastName = 'XYZ2', email = 'abcSystem2' + '@test2' + orgId + '.org', 
                         Username = 'abcCommercial@test.com', EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = p.Id); 
                userListToInsert.add(u2);
            }        
        }

        insert userListToInsert;
    }
    
    public static testmethod void editMethodNoAccess(){
        
        User commercialUser = [Select Id From User Where Username = 'abcCommercial@test.com'];
        System.runAs(commercialUser){
            PR_Header__c ph = new PR_Header__c(Status__c = 'New');
        	insert ph;            
            PageReference pageRef = Page.PRHeaderEditAccessPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ph);
            ApexPages.currentPage().getParameters().put('Id',ph.id);
            PRHeaderEdit phe = new PRHeaderEdit(sc);
            test.startTest();
            PageReference testPage = phe.redirectEdit();
            test.stopTest();
        }        
    }
    
    public static testmethod void editMethodWithAccess(){      
        User systemAdminUser = [Select Id From User Where Username = 'testSystem1@test1.com'];
        System.runAs(systemAdminUser){
            PR_Header__c ph = new PR_Header__c(Status__c = 'New');
        	insert ph;            
            PageReference pageRef = Page.PRHeaderEditAccessPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ph);
            ApexPages.currentPage().getParameters().put('Id',ph.id);
            PRHeaderEdit phe = new PRHeaderEdit(sc);
            test.startTest();
            PageReference testPage = phe.redirectEdit();
            test.stopTest();

        }       
    }
}