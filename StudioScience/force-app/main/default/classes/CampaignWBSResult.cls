public class CampaignWBSResult {
	public Boolean isSuccess {get; set;}
	public String message {get; set;}
	public Campaign__c campaign {get; set;}
	
	public CampaignWBSResult(Campaign__c c) {
		isSuccess = null;
		message = null;
		campaign = c;
	}	
}