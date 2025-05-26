@isTest
public class SettingsControllerTest{

static testmethod void testSettingsControllet(){

GBS_Custom_Message__c setting = new GBS_Custom_Message__c();
    setting.Name = 'Test Setting';
    setting.Message__c = 'This is test';
    insert setting;

    SettingsController sett=new SettingsController();
    sett.msg=setting;

    System.assertEquals(sett.save(),null);

        }
    
}