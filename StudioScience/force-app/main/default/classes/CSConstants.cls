public class CSConstants {
    
    /**************************************************************************************************************
Order Claim Constants
***************************************************************************************************************/
    
    public static final String DEFAULT_ACCOUNT_NAME = 'Beam Suntory';
    public static final Id DEFAULT_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Distributor').getRecordTypeId();
    
    
    public static final List <String> COUNTRIES_USING_US_BUSINESS_HOURS = new List <String> {
        'Argentina',
            'Belize',
            'Bolivia',
            'Brazil',
            'Canada',
            'Chile',
            'Colombia',
            'Costa Rica',
            'Uruguay',
            'Venezuela',
            'Honduras',
            'Ecuador',
            'El Salvador',
            'Suriname',
            'Guatemala',
            'Guyana',
            'Mexico',
            'Nicaragua',
            'Panama',
            'Paraguay',
            'Peru',
            'US'
            };
                
    // record types
    public static final Id Control_Collaboration_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Control_Collaboration').getRecordTypeId();
    public static final Id SGWS_Collaboration_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SGWS_Collaboration').getRecordTypeId();
    public static final Id Franchise_Collaboration_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Franchise_Collaboration').getRecordTypeId();
    public static final String ORDER_CLAIM_RECORDTYPE_DEVNAME = 'Order_Claim';
    public static final String ORDER_CLAIM_RECORDTYPE_LABEL = System.Label.Order_Claim;
    public static final Id ORDERS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Orders').getRecordTypeId();
    public static final Id ORDER_CLAIM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Claim').getRecordTypeId();
    public static final Id ORDER_CLAIM_SUBCASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Claim_Sub_Case').getRecordTypeId();
    
    public static final Set <Id> orderClaimRecordTypeIds = new Set <Id> {
        ORDER_CLAIM_RT_ID,
            ORDER_CLAIM_SUBCASE_RT_ID
            };
                
    public static final String ORDER_CLAIM_SUB_CASE_RECORDTYPE_DEVNAME = 'Order_Claim_Sub_Case';
    public static final String ORDER_CLAIM_SUB_CASE_RECORDTYPE_LABEL = System.Label.Order_Claim_Sub_Case;
    
    public static final String PRODUCTION_ORGANIZATION_ID = '00Do0000000cCkJEAU';
    public static final String SANDBOX_Esker_EMAIL_ADDRESS = 'beamsuntory.nobailment.us.sop.qa@process.esker.net';
    public static final String PROD_Esker_EMAIL_ADDRESS = 'orders.us.nobailment.beamsuntory@process.esker.net';
    public static final String SYSTEM_EMAIL_USER_ID = '005o00000034U8D';
    public static final String Orders_Case_Creation_for_Esker = 'Orders_Case_Creation_for_Esker';
    
    public static final String Esker_EmailAddress = UserInfo.getOrganizationId() == PRODUCTION_ORGANIZATION_ID ?
        PROD_Esker_EMAIL_ADDRESS :
    SANDBOX_Esker_EMAIL_ADDRESS;
    
    public static final String ORDERS = 'Orders';
    public static final String ORDERS_Bulk_Type = 'Bulk';
    public static final String ORDERS_Barrel_Type = 'Barrel';
    public static final String ORDERS_Standard_Type = 'Standard';
    public static final String ORDERS_Requisition_Type = 'Requisition';
    public static final String ORDER_CLAIM = 'Order Claim';
    public static final String QUALITY_CLAIM = 'Quality Claim';
    public static final String ESCALATED_FORM = 'Escalated Form';
    public static final String INQUIRY = 'Inquiry';
    public static final String CHANGES = 'Changes';
	public static final String SINGLE_BARREL_INQUIRY= 'Single Barrel Inquiry';
    
    //public static final Id ORDERS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Orders').getRecordTypeId();
    
    public static final String DISTRIBUTOR_RECORDTYPE_DEVNAME = 'Distributor';
    public static final String DISTRIBUTOR_RECORDTYPE_LABEL = 'Distributor';
    
    // country field value
    public static final String US_PRODUCT_DESTINATION_COUNTRY_VALUE = 'US';
    
    // Entitlement for accounts related to cases with Record type of order claim and order claim sub case
    public static final String ORDER_CLAIMS_ENTITLEMENT = 'Order Claim Entitlement';
    
    // Default Entitlement Processe for Record type order claim and order claim sub case
    public static final String ORDER_CLAIMS_ENTITLEMENT_PROCESS = 'CS Order Claims';
    
    // case statuses
    public static final String PENDING_SUB_CASE = 'Pending Sub-Case';
    public static final String CLOSED_APPROVED = 'Closed - Approved';
    public static final String CLOSED_REJECTED = 'Closed - Rejected';
    public static final String CLOSED = 'Closed';
    public static final String DUP_NO_ACTION = 'DUP - No Action';
    public static final String NEW_STATUS = 'New';
    public static final String OPEN = 'Open';

    // email to case values
    public static final String PROD_EMAIL_SERVICE_ADDRESS = 'customer.service@beamsuntory.com';
    public static final String SANDBOX_EMAIL_SERVICE_ADDRESS = 'customerservice.sandbox@beamsuntory.com';
    public static final String SANDBOX_EMAIL_SERVICE_ADDRESS_Modified = 'customer.service@1ihjfy4k4n28s0tbg296lw81qvg85zqmfmoae6sdwf988uu7pb.4b-yzuuae.cs51.case.sandbox.salesforce.com';
    public static final String EMAIL_SERVICE_ADDRESS = UserInfo.getOrganizationId() == PRODUCTION_ORGANIZATION_ID ?
        PROD_EMAIL_SERVICE_ADDRESS :
    SANDBOX_EMAIL_SERVICE_ADDRESS;
    
    // closed status variations for cases with Record type of order claim and order claim sub case
    public static final List <String> CLOSED_STATUS_VARIATIONS = new List <String> {
        CLOSED_REJECTED,
            CLOSED_APPROVED,
            CLOSED,
            DUP_NO_ACTION
            };
                
                // picklist field api names
                public static final String PRODUCT_DESTINATION_COUNTRY_APINAME = 'Product_Destination_Country__c';
    public static final String DISTRIBUTOR_CURRENCY_APINAME = 'Distibutor_Currency__c';
    public static final String SEAL_INTACT_APINAME = 'Seal_Intact__c';
    public static final String PRODUCT_SIZE_APINAME = 'Product_Size__c';
    public static final String FREIGHT_CLAIM_TYPE_APINAME = 'Freight_Claim_Type__c';
    public static final String QUANTITY_TYPE_APINAME = 'Quantity_Type__c';
    public static final String OVERAGE_DISPOSITION_APINAME = 'Overage__c';
    public static final String STATE_APINAME = 'State__c';
    public static final String PREMISE_APINAME = 'State__c';
    public static final String REGION_APINAME = 'State__c';
    public static final String MARKET_APINAME = 'State__c';
    public static final String REASON_FOR_DENIAL_APINAME = 'Reason_for_Denial__c';
    
    
    // default account name
    public static final String DEFAULT_BAILMENT_CLAIMS_ACCOUNT = 'Beam Suntory';
    
    public static final String DEFAULT_MARKET_READINESS = 'Market Readiness';
    
    public static final String UNKNOWN_PLANT = 'Unknown';
    
    // milestone names
    public static final String PREPARE_FOR_PLANT = 'Prepare for Plant';
    public static final String PREPARE_FOR_PLANT_EXPEDITED = 'Prepare for Plant - Expedited';
    public static final String PREPARE_FOR_PLANT_REOPEN = 'Prepare for Plant - ReOpened';
    
    public static final List <String> PREPARE_FOR_PLANT_MILESTONES = new List <String> {
        PREPARE_FOR_PLANT,
            PREPARE_FOR_PLANT_EXPEDITED,
            PREPARE_FOR_PLANT_REOPEN
            };
                
                
                
                /**************************************************************************************************************
Quality Claim Constants
QC = 'Quality Claim'
***************************************************************************************************************/
                
    public static final Id QC_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
    public static final Id QC_SUBCASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim_Sub_Case').getRecordTypeId();
    public static final Id LOGISTICS_REQUEST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Logistics_request').getRecordTypeId();
    public static final Id MARKET_READINESS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Market_Readiness_Inquiry').getRecordTypeId();
    public static final Id CUSTOMER_DATA_SUB_CASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Data_Sub_Case').getRecordTypeId();
    public static final Id CUSTOMER_DATA_CASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Data').getRecordTypeId();
    public static final Id BARREL_LAID_DOWN_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Laid_Down').getRecordTypeId();
    
    public static final String REVIEWING = 'Reviewing Details';
    
    
    public static final List <String> QC_CLOSED_STATUS_VARIATIONS = new List <String> {
        CLOSED_REJECTED,
            CLOSED_APPROVED,
            CLOSED,
            DUP_NO_ACTION
            };
                
                public static Set <Id> qualityClaimRecordTypeIds = new Set <Id> {
                    QC_RT_ID,
                        QC_SUBCASE_RT_ID
                        };
                            
                            
                            // milestone names
                            public static final String WORKING = 'Working';
    
    // Entitlement for accounts related to cases with Record type of quality claim sub case
    public static final String QUALITY_CLAIM_ENTITLEMENT = 'Quality Claim Entitlement';
    
    public static final String SLA_COMPLAINT_AND_INQUIRY_ENTITLEMENT = 'SLA Complaint and Inquiry Entitlement';
    public static final String SLA_COMPLAINT_AND_INQUIRY_PROCESS = 'SLA Complaint and Inquiry';
    // Default Entitlement Processe for Record type of quality claim sub case
    public static final String QUALITY_CLAIM_ENTITLEMENT_PROCESS = 'Quality Claim';
    
    // Entitlement for accounts related to cases with Record type of Logistics Request case
    public static final String LOGISTICS_REQUEST_ENTITLEMENT = 'Logistics Request Entitlement';
    
    // Default Entitlement Processe for Record type of Logistics Request case
    public static final String LOGISTICS_REQUEST_ENTITLEMENT_PROCESS = 'Logistics Request';
    
    // Entitlement for accounts related to cases with Record type of quality claim sub case
    public static final String QUALITY_CLAIM_SUB_CASE_ENTITLEMENT = 'Quality Claim Sub Case Entitlement';
    
    // Default Entitlement Processe for Record type of quality claim sub case
    public static final String QUALITY_CLAIM_SUB_CASE_ENTITLEMENT_PROCESS = 'Quality Claim Sub Case';
    
    public static final String QUALITY_CLAIM_PARENT_CASE_ENTITLEMENT = 'Quality Claim Parent Case Entitlement';
    public static final String QUALITY_CLAIM_PARENT_CASE_ENTITLEMENT_PROCESS = 'Quality Claim Parent Case';
    
    //Jai Kumar Garg
    public static final Id DUMMY_CASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dummy_Case').getRecordTypeId();
    public static final Id CONSUMER_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();
    public static final Id CONSUMER_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ConsumerAccount').getRecordTypeId();
    public static final String PRODUCT_PACKAGING_ISSUE = 'PRODUCT OR PACKAGING ISSUE';
    public static final String COMPLAINT = 'COMPLAINT';
    public static final String HIGH = 'HIGH';
    public static final String CRITICAL = 'CRITICAL';
    public static final String MEDIUM = 'MEDIUM';
    public static final String LOW = 'LOW';
    public static final String VISITING_THE_DISTILLERY = 'VISITING THE DISTILLERY';
    public static final String TODAY = 'TODAY';
    public static final String TOMORROW = 'TOMORROW';
    public static final String THIS_WEEK = 'THIS WEEK';
    public static final String EMAIL = 'EMAIL';
    public static final String CUSTOMER_PORTAL = 'CUSTOMER PORTAL';
    public static final String WEB = 'WEB';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String PENDING_WITH_QUALITY = 'Pending with Quality';
    public static final String DEFAULT_Consumer_ACCOUNT_NAME = 'Beam Suntory Consumer';
    public static final String CASE_IN_PROGRESS = 'In Progress';
    public static final String SINGLE_BARREL_STANDARD = 'Single Barrel - Standard';
    public static final String REGION = 'Region';
    public static final String DISTRIBUTOR ='Distributor';
    public static final String STATE = 'state';
    public static final String CANCELED= 'Canceled';
    public static final String CANCELLED_KIT_NOT_SELECTED = 'Cancelled - Kit Not Selected';
    public static final map<Integer, String> mapOfMonth = new Map<Integer, String> {1 => 'January', 2=> 'February', 3=> 'March', 4=> 'April', 
            5=> 'May', 6=> 'June', 7=> 'July', 8=> 'August', 9=> 'September', 10=> 'October', 11=> 'November' , 12=> 'December'};
    public static final map<String, String> mapOfMonthQuarter = new Map<String, String>{'January' => 'Quarter 1', 'February' => 'Quarter 1', 'March' => 'Quarter 1',
            'April' => 'Quarter 2', 'May' => 'Quarter 2', 'June' => 'Quarter 2', 'July' => 'Quarter 3', 'August' => 'Quarter 3', 'September' => 'Quarter 3',
            'October' => 'Quarter 4', 'November' => 'Quarter 4', 'December' => 'Quarter 4'};
    public static final String YEARLY = 'Yearly';
    public static final String MONTHLY = 'Monthly';
    public static final String QUARTERLY = 'Quarterly';
    public static final String SINGLE_BARREL_PROOF_SPECIFIC= 'Single Barrel - Proof Specific';
    public static final String PENDING_DOCUMENTATION= 'Pending Documentation';
    //Added for SAL-1329 on 29-Sep-21
    public static final String PENDING_SELECTION = 'Pending Selection';
    public static final String PREPARING_BARREL = 'Preparing Barrel';
    public static final String PENDING_PURCHASE_ORDER = 'Pending Purchase Order';
    public static final String PENDING_SHIP_DATE = 'Pending Ship Date';
    //End for SAL-1329 on 29-Sep-21
    
    public static final String DEFAULT_LANG = 'EN';
    
    //Picklist values for 'Laphroaig' brand 
    public static final String FRIENDS_OF_LAPHROAIG = 'Friends of Laphroaig';
    public static final String OUR_ONLINE_STORE = 'Our Online store';
    public static final String BRAND_NAME = 'Laphroaig';
    
    public static final String QUALITY_CLAIM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
    public static final String CSG_ORDER_CLAIM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CSG_Order_Claim').getRecordTypeId();
    public static final String CSG_BILLING_CLAIM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CSG_Billing_Claim').getRecordTypeId();
    public static final String CSG_QUALITY_CLAIM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CSG_Quality_Claim').getRecordTypeId();
    
    //DAL Support
    public static final String DAL_US_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DAL_US_Support').getRecordTypeId();
 
    public static Set<Id> CSG_RT_IDs = new Set<Id> {
        CSG_ORDER_CLAIM_RT_ID,
        CSG_BILLING_CLAIM_RT_ID,
        CSG_QUALITY_CLAIM_RT_ID
    };
        
    //Added for SAL-4617 by Vikash
    public static final String ET_BOTTLE_PLATE_LINE_1 = 'ET Bottle Plate Line 1';
    public static final String ET_BOTTLE_PLATE_LINE_2 = 'ET Bottle Plate Line 2';
    public static final String ET_BOTTLE_PLATE_LINE_3 = 'ET Bottle Plate Line 3';
    public static final List <String> TYPELIST = new List <String> {
        ET_BOTTLE_PLATE_LINE_1, ET_BOTTLE_PLATE_LINE_2, ET_BOTTLE_PLATE_LINE_3};
    Public static final String EL_TESORO_BOTTLE_TEXT_UPDATE_GROUP = 'El_Tesoro_Bottle_Text_Update';
    
	public static final String CSG_BILLING_CLAIM_ACKNOWLEDGMENT = 'CSG_Billing_Claim_Acknowledgment';
	public static final String CSG_ORDER_CLAIM_ACKNOWLEDGMENT = 'CSG_Order_Claim_Acknowledgment_Email';
	public static final String CSG_QUALITY_CLAIM_ACKNOWLEDGMENT = 'CSG_Quality_Claim_Acknowledgment';
    public static Map<Id, String> CSG_ACKNOWLEDGMENT = new Map<Id, String> {
        CSG_BILLING_CLAIM_RT_ID => CSG_BILLING_CLAIM_ACKNOWLEDGMENT,
        CSG_ORDER_CLAIM_RT_ID => CSG_ORDER_CLAIM_ACKNOWLEDGMENT,
        CSG_QUALITY_CLAIM_RT_ID => CSG_QUALITY_CLAIM_ACKNOWLEDGMENT
    };
    public static final Set<String> ORDER_TRIGGER_WORDS = new Set<String> {
        ' Order ', ' Delivery ', ' Auftrag and Lieferschein ', ' Verspätung ', ' verspätet '
    };
    public static final Set<String> BILLING_TRIGGER_WORDS = new Set<String> {
        ' Invoice ', ' Rechnung ', ' WKZ ', ' Belastungsanzeige ', ' Kreditor ', ' Abrechnung ', ' Abbuchung '
    };
    public static final Set<String> QUALITY_TRIGGER_WORDS = new Set<String> {
        ' Defekt ', ' defect ', ' Bruch ', ' Breakage ', ' kaput ', ' broken '
    };
    public static final Id Contact_Consumer_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
    public static final Id CS_Live_Chat_Support_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Live_Chat_Support').getRecordTypeId();

    //Added by Sangeet on 25-11-2022
    public static final String MARKET_READINESS_ENTITLEMENT_PROCESS = 'Market Readiness Inquiry';
    
    //Added by Akshat for conversion of Process builder to trigger code on 27/04/2023
    public static final String RESOLVED = 'Resolved';

    //Added by Vikash
    public static final String BRAND_CRUZAN = 'Cruzan';
    public static final String PRODUCT_TYPE_HALF_BARREL = 'Half Barrel';
    public static final String PRODUCT_TYPE_FULL_BARREL = 'Full Barrel';
    
    //Added by Deekshika on 20-6-2023 for Edrington queue
    public static final String EDRINGTON_QUEUE = 'Edrington Queue';
    public static final String EDRINGTON_Type = 'Edrington';

    //This status is used to capture case pick up time
    public static final Set <String> capturePickUpTimeStatus = new Set <String> {
        REVIEWING,
        WORKING,
        CLOSED_APPROVED,
        CLOSED_REJECTED,
        OPEN
    };
    //Added by Vikash 10-04-36
    public static final String ORDER_CLAIM_JAPAN_PUBLIC_GROUP = 'Order_Claims_Japan';  
    public static final String OC_JAPAN_NOTIFICATION_TEMPLATE = 'OrderClaimJapan_assignment_notification';
    
        
}