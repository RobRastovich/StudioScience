@isTest
public class OC_JapanQueueAssignmentNotificationTest {

    @testSetup static void setup() {
        Case c = new Case();
        c.RecordTypeId = CSConstants.ORDER_CLAIM_RT_ID;
        c.Brand__c = 'Knob Creek';
        c.Type = 'Damage Claim';
        c.Product_Destination_Country__c = 'Japan';
        
        insert c;
    }
	
    public static Case getCaseByBrand(String brand) {
        return [select id, Barrel_Selected__c, Status from Case where Brand__c = :brand limit 1];
    }
    public static testMethod void sendEmailToQueueMembersTest(){
        Case cs = getCaseByBrand('Knob Creek');
        
        Test.startTest();
        OC_JapanQueueAssignmentNotification.InputVariable param = new OC_JapanQueueAssignmentNotification.InputVariable();
        param.c = cs;
        
        List<OC_JapanQueueAssignmentNotification.InputVariable> params = new List<OC_JapanQueueAssignmentNotification.InputVariable>{param};
        OC_JapanQueueAssignmentNotification.sendEmailToQueueMembers(params);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(1, invocations, 'One email should be sent');
        
            
    }    
}