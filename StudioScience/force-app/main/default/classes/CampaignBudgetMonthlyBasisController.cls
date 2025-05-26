public class CampaignBudgetMonthlyBasisController {
    
    Id parentCampaignId;
    Id monthlyBudgetRecordTypeId;
    ID AUSCampaignRecordTypeId;
    public boolean DisplayMonthlyBudgetPopup {get; set;}
    public Campaign_Spend__c objCampaignSpend {get;set;}   
    Decimal amount;
    public List<Campaign_Spend__c> campaignBudgetMonthList {get; set;}
    public boolean IsUpdateBudget {get; set;}
    public boolean IsInsertBudget {get; set;}
    public Boolean isMemberOfGroup { set; }
    
    public Boolean getIsMemberOfGroup()
    {
        Id profileId=UserInfo.getProfileId();
        Set<String> profileRestricted= new Set<String>();
        for(Profile profile: [Select Id,Name from Profile where Id=:profileId AND Name in ('AUS Marketing - Platform', 'AUS Finance - Platform') ]){
            profileRestricted.add(profile.Name);
            system.debug('ProfileName'+profile.Name);
        }
        
        if(!profileRestricted.isEmpty())
            return false;
        
        return true;
    }
    
    public CampaignBudgetMonthlyBasisController(ApexPages.StandardController controller) {
        parentCampaignId = ApexPages.CurrentPage().getparameters().get('id');
        monthlyBudgetRecordTypeId = Schema.SObjectType.Campaign_Spend__c.getRecordTypeInfosByName().get('Monthly_Budget_AUS').getRecordTypeId();
        AUSCampaignRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Australia Campaign (WBS)').getRecordTypeId();
        objCampaignSpend = new Campaign_Spend__c();
        campaignBudgetMonthList = new List<Campaign_Spend__c>();
        IsUpdateBudget = false;
        IsInsertBudget = false;
    }
    
    public List<Campaign__c> campaignBudget{
        get
        {
            return [Select id,name,Total_Budget_New__c,RecordTypeId,
                    (Select Id, Name, Budget_Month__c, Amount__c FROM Campaign_Spend__r 
                     Where ParentCampaign__c =:parentCampaignId AND RecordTypeId =:monthlyBudgetRecordTypeId Order By Budget_Month__c ASC) 
                    from Campaign__c Where Id =:parentCampaignId AND RecordTypeId =:AUSCampaignRecordTypeId Order By CreatedDate DESC];
        }
    }
    
    
    public void ShowPopup() {
        DisplayMonthlyBudgetPopup = true;        
        campaignBudgetMonthList = new List<Campaign_Spend__c>();
    }
    
    public PageReference Cancel() {       
        DisplayMonthlyBudgetPopup = false;
        objCampaignSpend = new Campaign_Spend__c();
        campaignBudgetMonthList = new List<Campaign_Spend__c>();
        IsUpdateBudget = false;
        IsInsertBudget = false;
        return null;
    }
    
    public PageReference saveMonthlyBudgetCampaignSpend(){
        System.debug('Id of selected:::'+objCampaignSpend);
        System.debug('List is:::'+campaignBudgetMonthList.size());
        
        for(Campaign_Spend__c BudgetMonthRec:campaignBudgetMonthList){
            System.debug('BudgetMonthRec is:::'+BudgetMonthRec);
            amount = BudgetMonthRec.Amount__c;
            System.debug('Amount value is:::'+amount);
            if(amount < 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Amount value cannot be -ve'));
                DisplayMonthlyBudgetPopup = true;
                return null;
            }
        }
        
        update campaignBudgetMonthList;
        campaignBudgetMonthList = new List<Campaign_Spend__c>();
        DisplayMonthlyBudgetPopup = false;
        IsInsertBudget = false;
        IsUpdateBudget = false;
        
        return null;
    }
    
    public PageReference editCampaignBudgetMonthlyRecord(){
        campaignBudgetMonthList = new List<Campaign_Spend__c>();
        Id campaignMonthlyBudgetEditRecordId = ApexPages.currentPage().getParameters().get('selectedMonthlyBudgetCampaignPlanningEditRecord');
        System.debug('inside edit:::'+campaignMonthlyBudgetEditRecordId);
        campaignBudgetMonthList = [select id, ParentCampaign__c, Budget_Month__c, Amount__c from Campaign_Spend__c where ParentCampaign__c=:campaignMonthlyBudgetEditRecordId AND RecordTypeId =:monthlyBudgetRecordTypeId ];
        if(campaignBudgetMonthList.size()>0){
            IsUpdateBudget = true;
        }else{
            IsInsertBudget = true;
        }
        DisplayMonthlyBudgetPopup = true;
        return null;
    }
}