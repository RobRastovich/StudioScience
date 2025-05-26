Public class ExportCampaignController { 
  //Object details, object fields
  public List<Campaign__c> campaignlst {get; set;}
  String marketingID = ApexPages.currentPage().getParameters().get('mPlanId');
  public String integrationType {get;set;}
  Public ExportCampaignController()
  {
    //SOQL Query for get related records for Marketing plans 
    integrationType = ApexPages.currentPage().getParameters().get('integrationType');
    if(integrationType.equals('IO')){
      campaignlst = new List<Campaign__c>();
      for (Campaign__c c : [Select id, IOCode__c,Name,CampaignBrand__c,PlannedCampaignSpend__c,CampaignBalance__c,ActualCampaignSpend__c,CommittedCampaignSpend__c,Comments__c,InitialStartDate__c,InitialEndDate__c,CampaignType__c,GLAccountType__c,GLDescription__c,GLCode__c,Prioirty_JTBD__c,Program__c,Description__c from Campaign__c where ParentMarketingPlan__c =: marketingID ])
      { 
        campaignlst.add(c);
      }
    } else if(integrationType.equals('WBS')){
      campaignlst = new List<Campaign__c>();
      for (Campaign__c c : [Select Id, WBSCode__c,Name,PlannedCampaignSpend__c,CampaignBalance__c, ActualCampaignSpend__c, CommittedCampaignSpend__c, Comments__c, InitialStartDate__c, InitialEndDate__c, CampaignType__c, GLAccountType__c, GLDescription__c, GLCode__c, Related_Priority__c, NationalAccount__c, FBS_RTD__c, Description__c from Campaign__c where ParentMarketingPlan__c =: marketingID ])
      { 
        campaignlst.add(c);
      }
    }
  }
}