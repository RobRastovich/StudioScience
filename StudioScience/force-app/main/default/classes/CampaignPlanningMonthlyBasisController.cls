public class CampaignPlanningMonthlyBasisController {
    
    Id parentCampaignId;
    Id campaignPlanningRecordTypeId;
    Id monthlyPlanRecordTypeId;
    public boolean DisplayPopup {get; set;}
    public Campaign_Spend__c objCampaignSpend {get;set;}    
    public boolean MonthList {get; set;}
    public List<Campaign_Spend__c> campaignPlanningMonthList {get; set;}
    public boolean IsUpdate {get; set;}
    Decimal amount;
    public boolean IsUpdateBudget {get; set;}
    public boolean IsInsertBudget {get; set;}
    
    public CampaignPlanningMonthlyBasisController(ApexPages.StandardController controller) {
        DisplayPopup = false;
        parentCampaignId = ApexPages.CurrentPage().getparameters().get('id');
        campaignPlanningRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Campaign Planning & Forecasting').getRecordTypeId();
        monthlyPlanRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Monthly_Plan_AUS').getRecordTypeId();
        objCampaignSpend = new Campaign_Spend__c();
        campaignPlanningMonthList = new List<Campaign_Spend__c>();
        IsUpdate = false;
        MonthList = false;
        IsUpdateBudget = false;
        IsInsertBudget = false;
    }
    
    public List<Campaign_Spend__c> campaignPlanning{
        get
        {
            return [SELECT Id,Name,Spend_Type__c,Notes__c,Customer__c,Vendor__c,Unit_Cost__c,Quantity__c,Total_Estimate__c,Total_Planning_Amount__c,
                    (SELECT Id,Name,Monthly_Planning__c,Forecast_Month__c,Amount__c,Planning_Month__c FROM MonthlyPlanning__r 
                     WHERE ParentCampaign__c =:parentCampaignId AND RecordTypeId =:monthlyPlanRecordTypeId Order By Planning_Month__c ASC) 
                    FROM Campaign_Spend__c Where ParentCampaign__c =:parentCampaignId AND RecordTypeId =:campaignPlanningRecordTypeId Order By CreatedDate DESC];
        }
    }
    
    
    public void ShowPopup() {
        DisplayPopup = true;
        campaignPlanningMonthList = new List<Campaign_Spend__c>();
    }
    public PageReference Cancel() {       
        DisplayPopup = false;
        campaignPlanningMonthList = new List<Campaign_Spend__c>();
        objCampaignSpend = new Campaign_Spend__c();
        IsUpdate = false;
        MonthList = false;
        IsUpdateBudget = false;
        IsInsertBudget = false;
        return null;
    }
    
    
    public PageReference saveCampaignSpend(){
        System.debug('Id of selected:::'+objCampaignSpend.Id);
        if(objCampaignSpend.Id == null){
            objCampaignSpend.ParentCampaign__c = parentCampaignId;
        }
        /*for(Campaign_Spend__c planningMonthRec:campaignPlanningMonthList){
            System.debug('planningMonthRec is:::'+planningMonthRec);
            amount = planningMonthRec.Amount__c;
            System.debug('Amount value is:::'+amount);
            if(amount < 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Amount value cannot be -ve'));
                DisplayPopup = true;
                return null;
            }else{
                objCampaignSpend.CurrencyIsoCode='AUD';
            }
        }*/
        
        objCampaignSpend.CurrencyIsoCode='AUD';
        upsert objCampaignSpend;
        update campaignPlanningMonthList;
        objCampaignSpend = new Campaign_Spend__c();
        campaignPlanningMonthList = new List<Campaign_Spend__c>();
        IsUpdate = false;
        DisplayPopup = false;
        MonthList = false;
        return null;
    }
    
    
    
    public PageReference editCampaignPlanningRecord(){
        objCampaignSpend = new Campaign_Spend__c();
        Id campaignPlanningEditRecordId = ApexPages.currentPage().getParameters().get('selectedCampaignPlanningEditRecord');
        objCampaignSpend = [select id, ParentCampaign__c, name, Spend_Type__c, Notes__c, Customer__c, Vendor__c, Unit_Cost__c, Quantity__c, Total_Estimate__c from Campaign_Spend__c where Id=:campaignPlanningEditRecordId];
        campaignPlanningMonthList = [select id, ParentCampaign__c, Planning_Month__c, Amount__c from Campaign_Spend__c where Monthly_Planning__c=:campaignPlanningEditRecordId];
        System.debug('campaignPlanningMonthList size is::::'+campaignPlanningMonthList);
        if(campaignPlanningMonthList.size()>0){
            MonthList = true;
        }
        DisplayPopup = true;
        IsUpdate = true;
        return null;
    }
    
    public PageReference viewCampaignPlanningRecord(){
        Id campaignPlanningId = ApexPages.currentPage().getParameters().get('selectedCampaignPlanningId');
        System.debug('id is::'+campaignPlanningId);
        PageReference requestPage = new PageReference('/'+campaignPlanningId);
        requestPage.setRedirect(true);
        return requestPage;
    }
    
    public PageReference deleteCampaignPlanningRecord(){
        Id campaignPlanningRecordId = ApexPages.currentPage().getParameters().get('selectedCampaignPlanningRecord');
        Campaign_Spend__c campaignRecord = [select id, name from Campaign_Spend__c where Id=:campaignPlanningRecordId];
        delete campaignRecord;    
        return null;
    }
        
}