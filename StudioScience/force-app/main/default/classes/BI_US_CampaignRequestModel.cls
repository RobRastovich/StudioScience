public class BI_US_CampaignRequestModel {

	public class Extension {
		public List<Results> results;
	}

	public d d;

	public class d {
		public String Order;
		public String OrderType;
		public String OrderName;
		public String CoArea;
		public String CompCode;
		public String Respcctr;
		public String Currency_bi;
		public Extension Extension;
	}

	public class Results {
		public String Order;
		public String Structure;
		public String FieldName;
		public String Value;
	}

	
	public static BI_US_CampaignRequestModel parse(String json) {
		return (BI_US_CampaignRequestModel) System.JSON.deserialize(json, BI_US_CampaignRequestModel.class);
	}
}