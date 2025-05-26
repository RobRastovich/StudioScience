@isTest
public class PosBottleTextChangeTest {
    @testSetup static void setup() {
            Barrel_Order_Group__c bg = new Barrel_Order_Group__c();
            bg.Type__c = 'Distiller\'s Choice';            
            insert bg;
            
            Case c2 = new Case();
            c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
            c2.Type = 'Distiller\'s Choice';
            c2.Barrel_Order_Group__c = bg.Id;
            c2.Brand__c = 'El Tesoro';
            c2.ccEmail__c = 'test@test.com';
            insert c2;
            
            Barrel__c elTesoro = new Barrel__c();
            elTesoro.Brand__c = 'El Tesoro';
            elTesoro.Barrel_Number__c = 'B-98986';
            elTesoro.Ship_Date__c = null;
            elTesoro.Case__c = c2.Id;
            elTesoro.RecordTypeId = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro_Full_Barrel').getRecordTypeId();
            insert elTesoro;
            
            List<POS_Customization__c> posItems = new List<POS_Customization__c>();
            posItems.add(new POS_Customization__c(Type__c = 'ET Bottle Plate Line 1', Insert_Text__c = 'Test1', Barrel__c = elTesoro.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
            posItems.add(new POS_Customization__c(Type__c = 'ET Bottle Plate Line 2', Insert_Text__c = 'Test2', Barrel__c = elTesoro.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
            posItems.add(new POS_Customization__c(Type__c = 'ET Bottle Plate Line 3', Insert_Text__c = 'Test3', Barrel__c = elTesoro.Id, RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID));
            POSCustomizationServices.runTrigger=true;
            insert posItems;
                    
    } 
    
    public static Barrel__c getBarrelByBrand(String brand) {
        return [select Id from Barrel__c where Brand__c = :brand limit 1];
        
    }
    
    public static List<POS_Customization__c> getPOSCustomizationsByBarrel(Id barrelId) {
        return [select Id, Insert_Text__c from POS_Customization__c where Barrel__c = :barrelId];
    }
    
    public static testMethod void bottleTextUpdateNotificationTest(){
        Barrel__c barrel = getBarrelByBrand('El Tesoro');
        
        Test.startTest();
        List<POS_Customization__c> posItems = [Select Id, Type__c, Insert_Text__c From POS_Customization__c Where Barrel__c =:barrel.Id];
        POSCustomizationServices.runTrigger=true;
        posItems[0].Insert_Text__c = 'TestTest';
        update posItems;
        
        PosBottleTextChange.PosLabelTextParam param = new PosBottleTextChange.PosLabelTextParam();
        param.barrelId = barrel.Id;
        param.labelType = posItems[0].Type__c;
        param.newText = posItems[0].Insert_Text__c;
        param.oldText = 'Test1';
        
        List<PosBottleTextChange.PosLabelTextParam> posParams = new List<PosBottleTextChange.PosLabelTextParam>{param};
            
            PosBottleTextChange.bottleTextUpdateNotification(posParams);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        //system.assertEquals(2, invocations, 'Two email should be sent');
        List<POS_Customization__c> posList = getPOSCustomizationsByBarrel(barrel.Id);
        //system.assertEquals('TestTest', posList[0].Insert_Text__c , 'Text should be updated for ET Bottle Plate Line 1');
    }
    
    public static testMethod void bottleTextUpdateNotificationForSecondLabelTest(){
        Barrel__c barrel = getBarrelByBrand('El Tesoro');
        
        Test.startTest();
        List<POS_Customization__c> posItems = [Select Id, Type__c, Insert_Text__c From POS_Customization__c Where Barrel__c =:barrel.Id];
        POSCustomizationServices.runTrigger=true;
        posItems[1].Insert_Text__c = 'TestXyz';
        update posItems;
        
        PosBottleTextChange.PosLabelTextParam param1 = new PosBottleTextChange.PosLabelTextParam();
        param1.barrelId = barrel.Id;
        param1.labelType = posItems[1].Type__c;
        param1.newText = posItems[1].Insert_Text__c;
        param1.oldText = 'Test2';
        
        List<PosBottleTextChange.PosLabelTextParam> posParams1 = new List<PosBottleTextChange.PosLabelTextParam>{param1};
            
            PosBottleTextChange.bottleTextUpdateNotification(posParams1);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        //system.assertEquals(2, invocations, 'Two email should be sent');
        List<POS_Customization__c> posList = getPOSCustomizationsByBarrel(barrel.Id);
        //system.assertEquals('TestXyz', posList[1].Insert_Text__c , 'Text should be updated for ET Bottle Plate Line 2');
    }
}