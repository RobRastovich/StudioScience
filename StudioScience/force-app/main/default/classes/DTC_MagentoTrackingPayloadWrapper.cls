public class DTC_MagentoTrackingPayloadWrapper {
	public class Entity {
		public String order_id;
		public String parent_id;
		public String carrier_code;
		public String track_number;
		public String title;
	}

	public Entity entity;

	
	public static DTC_MagentoTrackingPayloadWrapper parse(String json) {
		return (DTC_MagentoTrackingPayloadWrapper) System.JSON.deserialize(json, DTC_MagentoTrackingPayloadWrapper.class);
	}
}