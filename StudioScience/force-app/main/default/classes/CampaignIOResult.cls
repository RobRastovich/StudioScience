public class CampaignIOResult {
	public Boolean IsSuccess {get; set;}
	public String Message {get; set;}
	public Campaign__c Campaign {get; set;}
	
	/*
	public CampaignIOResult() {
		IsSuccess = null;
		Message = null;
		Campaign = null;
	}	
	*/
	public CampaignIOResult(Campaign__c c) {
		IsSuccess = null;
		Message = null;
		Campaign = c;
	}	
}