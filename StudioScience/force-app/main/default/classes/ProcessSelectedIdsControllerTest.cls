@isTest
private class ProcessSelectedIdsControllerTest{
   static testMethod void testMethod1() 
    {

      List <Case> lstCases = new List<Case>();
     recordType rt = [SELECT ID,Name from RecordType where name='Single Barrel - Proof Specific'];
     Case caserec = new Case();
     caserec.Type='Trip and Tour';
     caserec.status ='New';
     Caserec.RecordTypeId = rt.id;
     
     lstCases.add(caserec);
     Case Caserec1 = new Case();
     caserec1.Type='Trip and Tour';
     caserec1.status ='New';
     Caserec.RecordTypeId = rt.id;
     lstCases.add(caserec1);
    
     insert  lstCases;
     
     Barrel__c Barrelrec = new Barrel__c();
     Barrelrec.Brand__c ='Knob Creek';
     Barrelrec.SKU__c='34rty';
     Barrelrec.Case__c =caserec.id;
     
     insert Barrelrec;
     Barrel__c Barrelrec1 = new Barrel__c();
     Barrelrec.Brand__c ='Knob Creek';
     Barrelrec.SKU__c='34rty4';
     Barrelrec1.Case__c =caserec1.id;
     insert Barrelrec1;
     List<String>BarrelIds = new List<String>();
     
     BarrelIds.add(Barrelrec.id);
     BarrelIds.add(Barrelrec1.id);
     
      String customIdsStr = JSON.serialize(BarrelIds);
     
      Test.startTest();
      //Test.setCurrentPage(Page.YOUR_PAGE);
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCases);
      stdSetController.setSelected(lstCases);
      ProcessSelectedIdsController process= new ProcessSelectedIdsController(stdSetController);
      String ShipDate = '2020-05-20';
      
  ProcessSelectedIdsController.updateShipDate(ShipDate,BarrelIds);
     Test.stopTest();
 
  }
  static testMethod void testupdateShipDate(){
      String ShipDate = '5/1/2020';
     // ProcessSelectedIdsController.updateShipDate(ShipDate,BarrelIds);

  }
  
}