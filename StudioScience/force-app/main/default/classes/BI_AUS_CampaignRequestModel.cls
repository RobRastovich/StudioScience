public class BI_AUS_CampaignRequestModel{
	public d d;
	public class d {
		public String WbsElement;	//AU21BHYYFBRWF001_TEST
		public String Description;	//WBS Element Test
		public String CompanyCode;	//AU60
		public String ControllingArea;	//6000
		public String Currency_bi;	//AUD
		public String CurrencyIso;	//AUD
		public String WbsUp;	//AU21BSDN
		public String SystemStatus;	//REL
		public String ProjectDefinition;	//BIAU2021_TEST
		public boolean WbsPlanningElement;
		public boolean WbsAccountAssignmentElement;
		public boolean WbsBillingElement;
		public String UserFieldChar201;	//AU01
		public String UserFieldChar202;	//900
		public String UserFieldChar101;	//BYGBBXX01
		public String UserFieldQuan1;	//0.000
		public String UserFieldQuan2;	//0.000
		public String UserFieldCurr1;	//0.000
		public String UserFieldCurr2;	//0.000
		public boolean UserFieldFlag1;
		public boolean UserFieldFlag2;
		public boolean WbsSummarization;
		public boolean Statistical;
		public String Evgew;	//0
		public boolean Planintegrated;
		public String WbsBasicDuration;	//0.0
		public String WbsForecastDuration;	//0.0
		public String WbsActualDuration;	//0.0
		public String WbsActualDurUnit;
		public String NetworkAssignment;	//0
		public WBSElementToExtension WBSElementToExtension;
		public WBSElementToProject WBSElementToProject;
	}
	public class WBSElementToExtension {
		public List<Results> results;
	}
	public class Results {
		public String WBSElement;	//AU21BHYYFBRWF001_TEST
		public String Structure;	//BAPI_TE_WBS_ELEMENT
		public String FieldName;	//WBS_ELEMENT
		public String Value;	//AU21BHYYFBRWF001_TEST
	}
	public class WBSElementToProject {
		public String ProjectDefinition;	//BIAU2021_TEST
		public String Description;	//Brand Investment Australia 2021
		public String CompCode;	//AU60
		public String ControllingArea;	//6000
		public String ProjectProfile;	//ZAU0001
		public boolean ProjectStock;
		public boolean Statistical;
	}
	public static BI_AUS_CampaignRequestModel parse(String json){
		return (BI_AUS_CampaignRequestModel) System.JSON.deserialize(json, BI_AUS_CampaignRequestModel.class);
	}
}