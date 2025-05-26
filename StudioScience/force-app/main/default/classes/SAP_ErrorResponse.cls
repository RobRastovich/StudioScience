public class SAP_ErrorResponse{
	public cls_error error;
	public class cls_error {
		public String code;	///IWFND/CM_BEC/029
		public cls_message message;
		public cls_innererror innererror;
	}
	public class cls_message {
		public String lang;	//en
		public String value;	//RFC Error: Runtime error occurred in backend system
	}
	public class cls_innererror {
		public cls_application application;
		public String transactionid;	//5773F43355B10030E005FA4E3B46EEC3
		public String timestamp;	//20201216083610.5944970
		public cls_Error_Resolution Error_Resolution;
		public cls_errordetails[] errordetails;
	}
	public class cls_application {
		public String component_id;	//SD-SLS
		public String service_namespace;	///SAP/
		public String service_id;	//SRA017_SALESORDER_CREATE_SRV
		public String service_version;	//0001
	}
	public class cls_Error_Resolution {
		public String SAP_Transaction;	//For backend administrators: use ADT feed reader "SAP Gateway Error Log" or run transaction /IWFND/ERROR_LOG on SAP Gateway hub system and search for entries with the timestamp above for more details
		public String SAP_Note;	//See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)
	}
	public class cls_errordetails {
	}
	public static SAP_ErrorResponse parse(String json){
		return (SAP_ErrorResponse) System.JSON.deserialize(json, SAP_ErrorResponse.class);
	}

}