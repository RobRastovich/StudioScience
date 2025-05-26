@isTest
private class CalendarControllerTest {
    static testMethod void PopulateProgramCalendarTest() {
        List<Tags__c> lstInsertTag= new List<Tags__c>();
        List<Program__c> lstInsertProgram= new List<Program__c>();
        List<Tags__c> lstTerritory= new List<Tags__c>();
        List<Tags__c> lstBrandFamily= new List<Tags__c>();
        List<Tags__c> lstBrand= new List<Tags__c>();
        
        integer currentYear = System.today().year(); 
        TestDataProgramCalendar testData= new TestDataProgramCalendar();
        testData.createCalendarSetting();
        testData.createCalendarValues();
        testData.createDistributorValues();
        lstInsertTag=testData.createTerritory();
        lstInsertTag.addall(TestDataProgramCalendar.createBrand());
        //lstInsertTag.addall(CalendarNControllerTest.createBrand());
        
        insert lstInsertTag;
        lstTerritory=[select id from Tags__c where recordType.Name='Territory'];
        lstBrand=[select id from Tags__c where recordType.Name='PL4 Brand'];
        lstInsertProgram.add(testData.createPrograms(Date.newInstance(currentYear , 01, 01),Date.newInstance(currentYear , 08, 30),lstTerritory[0].id,lstBrand[0].id,'Non-Premise','Program','Promotion','BI'));
        lstInsertProgram.add(testData.createPrograms(Date.newInstance(currentYear+1 , 01, 01),Date.newInstance(currentYear+1 , 08, 30),lstTerritory[0].id,lstBrand[0].id,'Non-Premise','Program','Promotion','BI'));
        lstInsertProgram.add(testData.createPrograms(Date.newInstance(currentYear-1 , 01, 01),Date.newInstance(currentYear-1 , 08, 30),lstTerritory[0].id,lstBrand[0].id,'Non-Premise','Program','Promotion','BI'));
        lstInsertProgram.add(testData.createPrograms(Date.newInstance(currentYear , 10, 01),Date.newInstance(currentYear , 12, 31),lstTerritory[0].id,lstBrand[0].id,'Non-Premise','Program','Other','BI'));
        lstInsertProgram.add(testData.createPrograms(Date.newInstance(currentYear+1 , 8, 01),Date.newInstance(currentYear+1 , 12, 31),lstTerritory[0].id,lstBrand[0].id,'Off Premise','Core Priority','Other','EG'));
        lstInsertProgram.add(testData.createPrograms(Date.newInstance(currentYear-1 , 4, 01),Date.newInstance(currentYear-1 , 08, 30),lstTerritory[0].id,lstBrand[0].id,'Off Premise','Core Priority','Other','EG'));
        insert lstInsertProgram;
        
        
     
        User userRecord=[select id, firstName, LastName from User where id=:userinfo.getUserid()];
        Calendar_View__c savedView= new Calendar_View__c();
        savedView.Calendar_Setting__c='{"Territory":false,"TerritoryAlaska":false,"AlaskaNoDistributor":false,"AlaskaSOUTHERNWINESPIRITSOFAK":false,"TerritoryArizona":false,"ArizonaNoDistributor":false}';
        savedView.Filter_Query__c='AND TerritoryName__c IN (\'\',\'Minnesota\',\'Alaska\',\'Arizona\',\'Alabama\') AND BrandFamilyName__c IN (\'\',\'Test BrandFamily1\') AND  BrandName__c IN (\'\',\'Test Brand1\') AND Channel__c IN (\'\',\'Non-Premise\') AND ProgrammingType__c IN (\'\',\'Other\') AND FocusType__c IN (\'\',\'Program\') AND Funds__c IN (\'\',\'BI\')';
        savedView.Type__c='User';
        savedView.User__c=userinfo.getuserid();
        savedView.Name = userRecord.firstName+' '+userRecord.lastName +'- Default View';
        savedView.Is_Default__c=true;
        insert savedView;
        
       
            Test.startTest();
            PageReference VfPage = Page.calendar;
            Test.setCurrentPage(VfPage);
            
            CalendarController clr= new CalendarController();
            clr.userJson='{"Territory":false,"TerritoryAlaska":true,"AlaskaNoDistributor":true,"AlaskaSOUTHERNWINESPIRITSOFAK":false,"TerritoryArizona":false,"ArizonaNoDistributor":false}';
            clr.filterString='AND TerritoryName__c IN (\'\',\'Minnesota\',\'Alaska\',\'Arizona\',\'Alabama\') AND BrandFamilyName__c IN (\'\',\'Test BrandFamily1\') AND BrandName__c IN (\'\',\'Test Brand1\') AND Channel__c IN (\'\',\'Non-Premise\')  AND ProgrammingType__c IN (\'\',\'Other\') AND FocusType__c IN (\'\',\'Program\') AND Funds__c IN (\'\',\'BI\',\'EG\')';
            clr.delViewId=string.valueOf(savedView.id);
            clr.getItems();
            clr.errLabel='ReportURLError';
            //clr.getSortItems();
            //clr.getquarterStart();
            //clr.getquarterEnd();
            clr.getperiod();
            clr.nextView();
            clr.previousView();
            clr.saveview();
            clr.getSavedViewForUser();
            clr.reportDateUpdate();
            
            clr.viewVal='2';
            clr.getquarterStart();
            clr.getquarterEnd();
            clr.getperiod();
            clr.nextView();
            clr.previousView();
            clr.reportDateUpdate();
            
            clr.viewVal='3';
            clr.getquarterStart();
            clr.getquarterEnd();
            clr.getperiod();
            clr.nextView();
            clr.previousView();
            clr.reportDateUpdate();
            
            clr.errorMessage();
            clr.getColorMap();
            clr.delCalendarView();
            lstBrandFamily=[select id from Tags__c where recordType.Name='Brand Family' limit 1];
            delete lstBrandFamily; 
            delete lstInsertProgram;
            delete lstInsertTag;       
            Test.stoptest();
            
       
    }
    
   
    


}