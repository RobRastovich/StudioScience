@isTest
private class ControllerFormattedDatetimeTest {
    
    static testMethod void getFormattedDatetimeTest2() {
        Controller_Formatted_Datetime controllerFormattedDatetime = new Controller_Formatted_Datetime();
        controllerFormattedDatetime.getFormattedDatetime();
    }
    
    static testMethod void getFormattedDatetimeTest1() {
        DateTime date_time = date.today();
        String defined_format= 'MM/dd/yyyy kk:mm a';
        Controller_Formatted_Datetime controllerFormattedDatetime = new Controller_Formatted_Datetime(date_time,defined_format);
        controllerFormattedDatetime.getFormattedDatetime();
    }
    
    
 }