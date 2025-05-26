@isTest
public class PRHeaderRecordRedirectControllerTest {
    
    @isTest static void testgetDomainURL(){
        string URL = PRHeaderRecordRedirectController.getDomainURL();
        System.assert(!String.isEmpty(URL),'URL is not null');
    }

}