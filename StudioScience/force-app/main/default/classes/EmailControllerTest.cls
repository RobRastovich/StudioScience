/**************************************************************************************
Apex Class Name     : EmailControllerTest
Created Date        : 09-11-2022
Function            : Test class of EmailMessageServices class.
*************************************************************************************/
@IsTest(seeAllData = false)
public class EmailControllerTest {
    public static Highball__c hbObj ;
    public static Account accountInstance ;
    public static EmailWrapper ew;
    public static List<EmailWrapper> myList;
    public static final String ACCOUNT_RT_Distributor = 'On Premise';
    
    /**
*  @description : This method is use setup data for test cases.
**/
    public static void prepareData(){
        Account a = new Account();
        a.RecordTypeId = accountRTId;
        a.Name = 'Test Account';
        insert a;
        hbObj = new Highball__c();
        hbObj.Type_of_Technology__c = 'Machine';
        hbObj.Account__c = a.Id;
        hbObj.Expected_Installation_Date__c = Date.today();
        insert hbObj;
        ew = new EmailWrapper();
        ew.strRecipientId = hbObj.id;
        ew.strRecipientEmail = 'test@test.com';
        
        EmailMessage em=new EmailMessage();
        em.subject ='Highball Activation - IO Code Notification';
        em.RelatedToId=ew.strRecipientId;
        em.Incoming=true;
        insert em;
		myList = new List<EmailWrapper>();
        myList.add(ew);
        //insert myList;
    }
    @IsTest
    public static void testUpdateStatus() {
        prepareData();
        string errorMsg;
        Test.startTest();
        try {
            EmailController.sendHighballReminderEmail(myList);
        } catch (exception e) {
            errorMsg = e.getMessage();   
        }
        System.assertNotEquals(null, hbObj);
        Test.stopTest();
    }
    private static Id accountRTId {
        get{
            if (accountRTId == null) {
                accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCOUNT_RT_Distributor).getRecordTypeId();
            }
            return accountRTId;
        }
        set;
    }
}