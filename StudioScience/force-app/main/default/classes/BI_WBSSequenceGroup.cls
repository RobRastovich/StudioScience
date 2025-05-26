public class BI_WBSSequenceGroup {
	public Id MarketingPlanId {get; set; }
	public Integer Sequence {get; set; }
	public List<CampaignWBSResult> CampaignResults {get; set; }
	
	public BI_WBSSequenceGroup() {
		CampaignResults = new List<CampaignWBSResult>();    	
	}
}