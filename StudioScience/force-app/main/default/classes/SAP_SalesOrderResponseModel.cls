public class SAP_SalesOrderResponseModel {

	public d d;

	public class d {
		public String ShipToPartnerName;
		public Boolean SalesOrderSimulation;
		public Boolean SingleShipment;
		public Integer OrderItemCount;
		public String ShipToCity;
		public String SalesOrderNumber;
		public String PO;
		public String ShipToPartnerID;
		public String ShipToContact;
		public String ShippingCarrier;
		public String ShippingIncoTerms;
		public String Currency_so;
		public String ShipToPostalCode;
		public String FormattedAddress1;
		public String ShipToRegion;
		public String ShipmentInstruction;
		public String RequestedDate;
		public String PaymentTerms;
		public String Status;
		public String PromotionCode;
		public String CustomerID;
		public String CustomerName;
		public String FormattedAddress9;
		public String Tax;
		public String Freight;
		public String FormattedAddress8;
		public String GrandTotal;
		public String ShipToAddressLine1;
		public String ShipToCountry;
		public String FormattedAddress7;
		public String TotalAmount;
		public String FormattedAddress2;
		public String FormattedAddress3;
		public String FormattedAddress6;
		public String FormattedAddress4;
		public String FormattedAddress5;
		public String NotesToReceiver;
		public String SalesOrganization;
		public String DistributionChannel;
		public String Division;
		public String OrderDate;
		public String ShipToAddressLine2;
		public OrderItemSet OrderItemSet;
	}

	public class Results {
	}

	public class OrderItemSet {
		public List<Results> results;
	}

	
	public static SAP_SalesOrderResponseModel parse(String json) {
		return (SAP_SalesOrderResponseModel) System.JSON.deserialize(json, SAP_SalesOrderResponseModel.class);
	}
}