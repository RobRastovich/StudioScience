public class ComplianceConstants {
    //Case Record Type IDS
    public static final String RECORDTYPE_BRAND_REGISTRATION_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Brand Registration').getRecordTypeId();
    public static final String RECORDTYPE_STATE_LICENSE_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('State License').getRecordTypeId();
    
    //Case Record Type Names
    public static final String RECORDTYPE_BRAND_REGISTRATION = 'Brand Registration';
    public static final String RECORDTYPE_STATE_LICENSE = 'State License';
    public static final String RECORDTYPE_SUB_CASE = 'Compliance Sub Case';
    public static final String RECORDTYPE_QUOTE_REQUEST = 'Quote Request';
    public static final String RECORDTYPE_PRICE_POSTING = 'Price Posting';
    public static final String RECORDTYPE_PRICE_FILING = 'Price Filing';
    public static final String RECORDTYPE_DISCOUNT = 'Discount';
    public static final String RECORDTYPE_COMPLIANCE_INQUIRY = 'Compliance Inquiry';
    public static final String RECORDTYPE_CUSTOMER_DATA = 'Customer Data';
    public static final String RECORDTYPE_INQUIRY = 'Inquiry';
    public static final String RECORDTYPE_BARREL_LAID_DOWN = 'Barrel Laid Down';
    public static final String RECORDTYPE_SINGLE_BARREL_PROOF_SPECIFIC = 'Single Barrel - Proof Specific';
    public static final String RECORDTYPE_SINGLE_BARREL_SPLIT_BARREL = 'Single Barrel - Split Barrel';
    public static final String RECORDTYPE_SINGLE_BARREL_STANDARD = 'Single Barrel - Standard';
    public static final String RECORDTYPE_Laphroaig_SINGLE_CASK = 'Laphroaig Single Cask';


    //Compliance Profile Names
    public static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static final String BRAND_REG_COMPLIANCE_COORDINATOR_PROFILE = 'System Administrator';
    public static final String QUOTE_REQUEST_COMPLIANCE_COORDINATOR_PROFILE = 'Compliance Coordinator';
    public static final String COMMUNITY_STATE_CONTACT_PROFILE = 'Compliance State Contact';
    public static final String COMMUNITY_STATE_MANAGER_PROFILE = 'Operations, Admins and Reps';
    public static final String COMMUNITY_STATE_MANAGER_PROFILE_EDGE = 'EDGE Sales Manager';

    //Compliance Queue Names
    public static final String BRAND_REG_QUEUE_API_NAME = 'Brand_Registration';
    public static final String QUOTE_REQUEST_QUEUE_API_NAME = 'Quote_Requests';
    public static final String GROUP_COMPLIANCE_TEAM_API_NAME = 'Compliance_Team';

    //Case Type Values
    public static final String SUB_CASE_TYPE_BRAND_REGISTRATION = 'Brand Registration';
    public static final String QUOTE_REQUEST_TYPE_STATE_CONTACT = 'State Contact';
    public static final String QUOTE_REQUEST_TYPE_STATE_MANAGER = 'State Manager';
    public static final string SUB_CASE_TYPE_TRAY_PACK_AUDIT ='Traypack Audit';
    public static final string SUB_CASE_TYPE_VAP_LTO_ALLOCATION ='VAP/LTO Allocation';
    public static final string SUB_CASE_TYPE_GIFTSHOP_PRICING ='Giftshop Pricing';

    //Compliance Flagset Values
    public static final String FLAG_NO_APPROVAL_REQUIRED = 'No_Approval_Required';
    public static final String FLAG_BRAND_REG_KICKED_OFF = 'Brand_Registration__Kicked_Off';
    public static final String FLAG_BRAND_REG_ALL_SUB_CASES_CLOSED = 'Brand_Registration__All_Sub_Cases_Closed';
    public static final String FLAG_QUOTE_REQUEST_AVAILABILITY_SET = 'Quote_Request__Availability_Set';
    public static final String FLAG_QUOTE_REQUEST_PRICING_SET = 'Quote_Request__Pricing_Set';   
    public static final String FLAG_PRICE_POSTING_SUBMISSION_CONFIRMATION = 'Price_Posting__Submission_Confirmation';
    public static final String FLAG_PRICE_POSTING_STATE_MANAGER_APPROVAL = 'Price_Posting__State_Manager_Approval';
    public static final String FLAG_PRICE_FILING_HAS_BLANK_WORKBOOK = 'Price_Filing__Has_Blank_Workbook';
    public static final String FLAG_PRICE_FILING_HAS_FINALIZED_WORKBOOK = 'Price_Filing__Has_Finalized_Workbook';
    public static final String FLAG_DISCOUNT_HAS_DISCOUNT_DOCUMENT = 'Discount__Has_Discount_Document';
    public static final String FLAG_GENERAL_ATTACHMENT = 'General__Has_Attachment';

    //Case Status Values
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_WORKING = 'Working';
    public static final String CASE_STATUS_NOT_SUBMITTED = 'Not Submitted';
    public static final String CASE_STATUS_WAITING_FOR_KICKOFF = 'Waiting for Kickoff';
    public static final String CASE_STATUS_WAITING_FOR_SUBMISSION = 'Waiting for Submission';
    public static final String CASE_STATUS_WAITING_FOR_APPROVAL = 'Waiting for Approval';
    public static final String CASE_STATUS_WAITING_FOR_POSTING = 'Waiting for Posting';
    public static final String CASE_STATUS_WAITING_FOR_STATE_MANAGER = 'Waiting for State Manager';
    public static final String CASE_STATUS_REJECTED_WAITING_FOR_RESUBMISSION = 'Rejected / Waiting for Resubmission';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_CLOSE_PENDING = 'Close Pending';
    public static final String CASE_STATUS_CLOSED_NO_ACTION = 'Closed - No Action';
    public static final String CASE_STATUS_SUBMITTED_WAITING_FOR_LICENSE_COPY = 'Submitted/Waiting for License Copy';


    //Field API Names
    public static final String USER_REPRESENTED_STATES_FIELD_API_NAME = 'Represented_States__c';
    public static final String CASE_TYPE_FIELD_API_NAME = 'Type';
    public static final String CONTENT_VERSION_DOCUMENT_TYPE_FIELD_API_NAME = 'Document_Type__c';
    public static final String QUOTE_REQUEST_ITEM_SIZE_FIELD_API_NAME = 'Item_Size__c'; 
    public static final String QUOTE_REQUEST_QUOTE_TYPE_FIELD_API_NAME = 'Quote_Type__c'; 
    public static final String QUOTE_REQUEST_UNAVAILABILITY_REASON_FIELD_API_NAME = 'Unavailability_Reason__c';

    public static final String COMPLIANCE_COMMUNITY_NAME = 'Beam Suntory Compliance Community';

    //EmailTemplate API Names
    public static final String BRAND_REG_DUE_DATE_CHANGED_TEMPLATE_API_NAME = 'Brand_Registration_Due_Date_Changed';
    public static final String BRAND_REG_IN_FIELD_DATE_CHANGED_TEMPLATE_API_NAME = 'Brand_Registration_In_Field_Date_Changed';
    public static final String BRAND_REG_KICK_OFF_TEMPLATE_API_NAME = 'Brand_Registration_Kick_Off';
    public static final String BRAND_REG_PAST_DUE_TEMPLATE_API_NAME = 'Brand_Registration_Sub_Cases_Past_Due';
    public static final String BRAND_REG_SUB_CASE_1_DAY_REMINDER = 'Case_Due_1_Day_Reminder';
    public static final String QUOTE_REQUEST_ITEM_AVAILABILITY = 'Quote_Request_Item_Availability';
    public static final String QUOTE_REQUEST_NEW_QUOTE_AVAILABLE = 'Quote_Request_New_Quote_Request_Available';
    public static final String QUOTE_REQUEST_PRICE_NEEDED_FROM_FINANCE = 'Quote_Request_Price_Needed_From_Commercial_Finance';
    public static final String QUOTE_REQUEST_APPROVED_BY_FINANCE = 'Quote_Request_Approved_by_Commercial_Finance';
    public static final String PRICE_POSTING_1_DAY_REMINDER = 'Case_Posting_1_Day_Reminder';
    public static final String PRICE_FILING_BLANK_WORKBOOK_UPLOADED = 'Compliance_Price_Filing_Blank_Workbook_Uploaded';
    public static final String PRICE_FILING_FINALIZED_WORKBOOK_UPLOADED = 'Compliance_Price_Filing_Finalized_Workbook_Uploaded';
    public static final String PRICE_FILING_WORKBOOK_APPROVED = 'Price_Filing_Approved_by_Commercial_Finance';
    public static final String PRICE_FILING_WORKBOOK_REJECTED = 'Price_Filing_Rejected_by_Commercial_Finance';
    public static final String DISCOUNTS_DOCUMENT_NEEDS_APPROVAL = 'Discounts_New_Discount_Document_Needs_Approval';
    public static final String DISCOUNTS_DOCUMENT_APPROVED = 'Discounts_Document_Approved';
    public static final String DISCOUNTS_DOCUMENT_REJECTED = 'Discounts_Document_Rejected';
    public static final String INQUIRY_NEW_CASE_SUBMITTED = 'Compliance_Inquiry_New_Case_Submitted';

    //Miscellaneous Values
    public static final String SYSTEM_EMAIL_USER_ID = '005o00000034U8D';
    public static final String PRODUCTION_ORGANIZATION_ID = '00Do0000000cCkJEAU';
    public static final String BRAND_REG_PROJ_NUMBER_DEFAULT = 'N/A';
    public static final String APPROVED = 'Approved';
    public static final String REJECTED = 'Rejected';
    public static final String COMPLIANCE_ACCOUNT_NAME = 'Compliance Account';

    //Email Values
    public static final String PROD_EMAIL_SERVICE_ADDRESS = 'customer.service@beamsuntory.com';
    //public static final String SANDBOX_EMAIL_SERVICE_ADDRESS = 'customerservice.sandbox@beamsuntory.com';
    public static final String SANDBOX_EMAIL_SERVICE_ADDRESS = 'customer.service@1cp78u8h195yanjo1r94nglc7c09b8lvfw7499km1ozemppckl.2a-uwjea2.cs47.case.sandbox.salesforce.com';
    public static final String EMAIL_SERVICE_ADDRESS = UserInfo.getOrganizationId()==PRODUCTION_ORGANIZATION_ID ? 
                                                                                        PROD_EMAIL_SERVICE_ADDRESS :
                                                                                        SANDBOX_EMAIL_SERVICE_ADDRESS;
    
    public static final String PRODUCTION_COMMERCIAL_FINANCE_ADDRESS = 'CommercialFinance_BeamSuntory@BeamSuntory.com'; 
    public static final String SANDBOX_COMMERCIAL_FINANCE_ADDRESS = 'commercialfinance.sandbox@beamsuntory.com'; 
    public static final String COMMERCIAL_FINANCE_ADDRESS = UserInfo.getOrganizationId()==PRODUCTION_ORGANIZATION_ID ? 
                                                                                        PRODUCTION_COMMERCIAL_FINANCE_ADDRESS :
                                                                                        SANDBOX_COMMERCIAL_FINANCE_ADDRESS;
    
    public static final String PROD_COMPLIANCE_ADDRESS = 'MarketReadiness@BeamSuntory.com';
    public static final String SANDBOX_COMPLIANCE_ADDRESS = 'MarketReadiness.sandbox@beamsuntory.com';
    public static final String COMPLIANCE_ADDRESS = UserInfo.getOrganizationId()==PRODUCTION_ORGANIZATION_ID ? 
                                                                                        PROD_COMPLIANCE_ADDRESS :
                                                                                        SANDBOX_COMPLIANCE_ADDRESS;
    //Badri-changes SAL-1973-start
    public static final String PROD_CUSTOMER_DATA_ADDRESS = 'customerdata@beamsuntory.com';
    public static final String SANDBOX_CUSTOMER_DATA_ADDRESS = 'customerdata@k-1dxgeq6ik30kc847ds1licv7esq5ss5to60sxjl2iebi76i350.3c-5ckpuae.cs60.case.sandbox.salesforce.com';
    public static final String CUSTOMER_DATA_ADDRESS = UserInfo.getOrganizationId()==PRODUCTION_ORGANIZATION_ID ? 
                                                                                        PROD_CUSTOMER_DATA_ADDRESS :
                                                                                        SANDBOX_CUSTOMER_DATA_ADDRESS;
    //end
    //Milestone Values
    public static final String ENTITLEMENT_QUOTE_REQUEST = 'Quote Request';

    //Document Type Values
    public static final String DOCUMENT_TYPE_KICKOFF =                  'Kickoff';
    public static final String DOCUMENT_TYPE_SUBMISSION =               'Submission';
    public static final String DOCUMENT_TYPE_APPROVAL =                 'Approval';
    public static final String DOCUMENT_TYPE_QUOTE =                    'Quote';
    public static final String DOCUMENT_TYPE_BLANK_WORKBOOK =           'Blank Workbook';
    public static final String DOCUMENT_TYPE_FINALIZED_WORKBOOK =       'Finalized Workbook';
    public static final String DOCUMENT_TYPE_DISCOUNTS_DOCUMENT =       'Discounts Document';
    public static final String DOCUMENT_TYPE_OTHER =                    'Other';
    public static final String DOCUMENT_TYPE_SUBMISSION_CONFIRMATION =  'Submission Confirmation';
    public static final String DOCUMENT_TYPE_STATE_MANAGER_APPROVAL =   'State Manager Approval';

    //Document Type Allowed Value Sets
    //Brand Registration
    public static final List<String> BR_DOC_TYPE_LIST = new List<String>{
        DOCUMENT_TYPE_KICKOFF,
        DOCUMENT_TYPE_OTHER
    };

    //Brand Registration Sub Case
    public static final List<String> BR_SUBCASE_DOC_TYPE_LIST = new List<String>{
        DOCUMENT_TYPE_SUBMISSION,
        DOCUMENT_TYPE_APPROVAL,
        DOCUMENT_TYPE_OTHER
    };

    //Quote Request
    public static final List<String> QR_DOC_TYPE_LIST = new List<String>{
        DOCUMENT_TYPE_QUOTE,
        DOCUMENT_TYPE_OTHER
    };

    //Price Posting
    public static final List<String> PP_DOC_TYPE_LIST = new List<String>{
        DOCUMENT_TYPE_SUBMISSION,
        DOCUMENT_TYPE_SUBMISSION_CONFIRMATION,
        DOCUMENT_TYPE_STATE_MANAGER_APPROVAL,
        DOCUMENT_TYPE_OTHER
    };

    //Price Filing
    public static final List<String> PF_DOC_TYPE_LIST = new List<String>{
        DOCUMENT_TYPE_BLANK_WORKBOOK,
        DOCUMENT_TYPE_FINALIZED_WORKBOOK,
        DOCUMENT_TYPE_SUBMISSION,
        DOCUMENT_TYPE_OTHER
    };

    //Discounts
    public static final List<String> DISC_DOC_TYPE_LIST = new List<String>{
        DOCUMENT_TYPE_DISCOUNTS_DOCUMENT,
        DOCUMENT_TYPE_OTHER
    };

    //Compliance Inquiry Types
    public static final List<String> COMPLIANCE_INQUIRY_TYPE_LIST = new List<String>{
        'Item Availability / Allocation',
        'UPC, Bottle Shot, Label, Etc.',
        'Pricing Question',
        'Miscellaneous Posting Information',
        'Brand Registration',
        'State / NABCA Codes',
        'Report Request',
        'Other'
    };
    
    //Added by Akshat Jain on 12/4/2023
    public static final String BRAND_REGISTRATIONS_TYPE = 'Brand registrations';
    public static final String LICENSING_TYPE           = 'Licensing';
    public static final String SPECS_TYPE               = 'Specs';
    public static final String NEWSLETTERS_TYPE         = 'Newsletters';
    public static final String MISSING_PRICING_TYPE     = 'Missing Pricing';
    public static final String MEDIUM_PRIORITY          = 'Medium';
    public static final String HIGH_PRIORITY            = 'High';
}