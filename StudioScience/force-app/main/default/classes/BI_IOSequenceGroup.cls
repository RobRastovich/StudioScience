public class BI_IOSequenceGroup {
	public Id MarketingPlanId {get; set; }
	public Integer Sequence {get; set; }
	public List<CampaignIOResult> CampaignResults {get; set; }
	
	public BI_IOSequenceGroup() {
		CampaignResults = new List<CampaignIOResult>();    	
	}
}