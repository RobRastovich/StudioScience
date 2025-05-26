Public class ExportCampaignSpendController { 
  //Object details, object fields
  public List<Campaign_Spend__c> campaignSpendlst {get; set;}
  String campaignID = ApexPages.currentPage().getParameters().get('campId');
  //public String integrationType {get;set;}
  Public List<RecordType> CampSpendRecType = [Select Id,name From RecordType where sobjecttype = 'Campaign_Spend__c' and Name = 'Forecast'];
  Public ExportCampaignSpendController()
  {
    //SOQL Query for get related records for Campaign Spend records     
      campaignSpendlst= new List<Campaign_Spend__c>();    
      for (Campaign_Spend__c c : [Select id, RecordTypeId,Amount__c,Committed_Type__c,Vendor__c,Document_Number__c,Line_Item_Number__c,Document_Text__c,Line_Item_Text__c,Document_Date__c,Posting_Date__c,Debit_Date__c,GLAccount__c,GLDescription__c,IOCode__c from Campaign_Spend__c where ParentCampaign__c =: campaignID AND recordtypeid in (Select Id From RecordType where sobjecttype = 'Campaign_Spend__c' and name in ('Actual', 'Committed'))])
      { 
        campaignSpendlst.add(c);
      }
    
  } 
  
 }