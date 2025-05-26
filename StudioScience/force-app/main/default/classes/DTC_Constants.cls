public class DTC_Constants {
    public static final String API = 'API';
    public static final String BRAND_JIM_BEAM = 'Jim Beam';
    public static final String BRAND_MAKERS_MARK = 'Makers Mark';
    public static final String NEW_STATUS = 'New';
    public static final String VALIDATION_FAILS = 'Validation Fails';
    public static final String REQUIRED_FIELD_MISSING = 'Required field missing';
    public static final String SUCCESS = 'Success';
    public static final String FAILURE = 'Failure';
    public static final String INCORRECT_STATUS_MESSAGE = 'The case status is not in correct order.';
    public static final String RECORD_CREATED_SUCCESSFULLY = 'Record created successfully.';
    public static final String RECORD_UPDATED_SUCCESSFULLY = 'Record updated successfully.';
    public static final String INVALID_REQUEST = 'Invalid request';
    public static final String MISSING_CASENUMBER_VALUE = 'The value of Case Number cannot be empty.';
    public static final String MISSING_ORDERID = 'The value of Order ID cannot be empty.';
    public static final String MISSING_TRACKING_NUMBER = 'The value of Tracking Number cannot be empty.';
    public static final String MALFORMED_JSON = 'Malformed JSON! Supplied JSON is of incorrect format or '
    +'missing required attributes.';
    public static final String MEMBERSHIP_CANCELLATION = 'Membership Cancellation';
    public static final String REQUIRED_ATTRIBUTES_ARE_MISSING = 'Missing required attributes from supplied JSON. '
    +'Casedetails, Type and MagentoID are mandatory.';
    public static final  Set<String> CASE_REQUIRED_FIELDS = new Set<String>{'First_name__c', 'Last_name__c', 'Email_Address__c', 
    'Cancelation_Reason__c', 'Notes__c', 'Brand__c', 'Program_Subscription__c'};
    public static final  Set<String> ACCOUNT_REQUIRED_FIELDS = new Set<String>{'PersonEmail'};
    public static final  Set<String> CASE_REQUIRED_FIELDS_UPDATE = new Set<String>{'CaseNumber'};
    public static final  Set<String> CASE_REQUIRED_FIELDS_UPDATE_TRACKING_NUMBER = new Set<String>{'orderId', 'trackingNumber'};
    public static final  Set<String> CONTACT_REQUIRED_FIELDS = new Set<String>{'MagentoID__c'};
    public static final String REQUIRED_FIELD_IS_MISSING = 'Required field is missing : ';
    public static final String REQUIRED_FIELDS_ARE_MISSING = 'Required fields are missing : ';
    public static final Id CASE_DTC_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().
    get('DTC').getRecordTypeId();
    public static final Id CASE_CONSUMER_INQ_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().
    get('Consumer_Inquiry').getRecordTypeId(); // Vikash kumar 29/11/2022
    public static final Id ACCOUNT_CONSUMER_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().
    get('ConsumerAccount').getRecordTypeId();
    public static final String DATE_PARSING_ERROR = 'Cannot deserialize instance of date from VALUE_STRING value';
    public static final String DATE_PARSING_ERROR_MESSAGE = 'Date has incorrect Format. Use correct format or pass null.';
    //Case Status Value
    public static final String REFUND_STATUS = 'Refund';
    public static final String CANCEL_SHIPMENT = 'Cancel shipment';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String COMMUNICATE_WITH_DHL = 'Communicate with DHL';
    public static final String CLOSED_STATUS = 'Closed';
    public static final String INITIATED_SUB_STATUS = 'Initiated';
    public static final  Set<String> STATUS_PICKLIST_BRAND_SET = new Set<String>{'Closed', 'Payment Decline'};
    public static final  Set<String> CASE_PICKLIST_BRAND_SET = new Set<String>{'Jim Beam', 'Maker'+'\''+'s Mark'};
    public static final  Set<String> CASE_PICKLIST_CANCELLATION_REASON_SET = new Set<String>{'Program Cost', 
    'Product/Bottle Offering', 'Frequency of Shipments', 'Shipping/Delivery Issues', 'No Longer Interested', 'Other'};
    public static final  String CASE_PICKLIST_BRAND = '1. Jim Beam, 2. Maker'+'\''+'s Mark. ';
    public static final  String CASE_PICKLIST_CANCELLATION_REASON = '1. Program Cost, 2. Product/Bottle Offering, '
    +'3. Frequency of Shipments, 4. Shipping/Delivery Issues, 5. No Longer Interested, 6. Other. ';
    public static final String BAD_VALUE_FOR_RESTRICTED_PICKLIST = 'Bad value for restricted picklist field ';
    public static final String RECORD_NOT_FOUND_AGAINST_ORDERID = 'Either the order id is incorrect or case status is not valid.';
    public static final String REFER_USER_GUIDE = 'Please refer user guide for correct options.';
    public static final String CREATE_API = 'Create';
    public static final String UPDATE_API = 'Update';
    //Avatax Status, Braintree Status, SAP Status
    public static final String AVATAX_UNCOMMITED = 'Uncommited';
    public static final String BRAINTREE_SETTLED = 'Settled';
    public static final String SAP_RETURN_ORDER = 'YREU - Return Order';
    public static final String QUEUE_DTC_DHL = 'DTC_DHL';
    public static final String DHL_PORTAL = 'DHL Portal';
    public static final String ASSIGNED_TO_ME = 'Assigned to me';
    
    public static final String RETURN_TO_WAREHOUSE_UNSUCCESSFULL_DELIVERY = 'Returned to warehouse'
    +'(Unsuccessful Delivery Attempts)';
    public static final String RETURN_TO_WAREHOUSE_DAMAGE = 'Returned to warehouse(Damage)';
    public static final String RETURN_TO_WAREHOUSE_LOST = 'Returned to warehouse(Lost)';
    public static final String SHIPPED_AT_WAREHOUSE = 'Shipment at warehouse';
    public static final String COMMUNITY_CONSOLE ='Community Console';
    public static final String RETURN_AND_RESHIP ='Return And Reship';
    public static final String RESHIP_CONFIRMED ='Reship confirmed';
    public static final String RESHIPMENT_INITIATED ='Reshipment initiated';
    public static final Map<string, String> MAP_SUBSCRIPTION_TO_BRAND = 
        new Map<string, String>{'Barreled & Boxed' => 'Jim Beam', 'Whisky Drop' => 'Maker'+'\''+'s Mark'};
    public static final String DTC_DHL_ACCOUNT = 'DTC DHL Account';
    public static final  Set<String> DHL_CASE_REQUIRED_FIELDS = new Set<String>{'First_name__c', 'Last_name__c', 
        'Email_Address__c',
        'Program_Subscription__c', 'Consumer_Street__c', 'Consumer_City__c', 'Consumer_State__c',
        'Consumer_Postal_Code__c','Consumer_Country__c','UPS_Tracking_Number__c','UPS_Reason_For_Return__c','DHL_Status__c',
        'Customer_Phone_Number__c'};
    public static final String SUB_STATUS_CONFIRMATION_EMAIL_SENT = 'Confirmation email sent';
    public static final String REOPEN_STATUS = 'Reopen';
    public static final String QUEUE_BARRELED_BOXED = 'Barreled_Boxed_Membership_Program';
    public static final String QUEUE_DTC = 'Direct_To_Customer';
    public static final String BRAND_MAKERS_MARK_APPOS = 'Maker'+'\''+'s Mark';
    public static final String DTC_CUSTOM_NOTIFICATION = 'DTC_Custom_Notification'; //By Nishant Khandal on 15/3/2022
    public static final String CASE_OBJECT = 'Case'; //By Nishant Khandal on 15/3/2022
    public static final String AVATAX_COMMITED = 'Commited'; //By Nishant Khandal on 16/3/2022
    public static final String CASE_ORIGIN_MAGENTO = 'Magento';
    public static final String PAYMENT_DECLINE = 'Payment Decline'; //By Nishant Khandal on 22/3/2022
    public static final String CASE_TYPE_NOT_PAYMENT_DECLINE = 'The status you send is Payment decline but the type of case is '
    +'not Payment decline. '; //By Nishant Khandal on 22/3/2022
    public static final String CASE_ALREADY_CLOSED = 'The case is already closed. '; //By Nishant Khandal on 22/3/2022  
    public static final String RETURN_ADDINFORMATION = 'Return'; //By Nishant Khandal on 24/3/2022
    public static final String RETURN_AND_CREDIT = 'Return And Credit'; //By Nishant Khandal on 24/3/2022
    public static final Set<String> CASE_REQUIRED_FIELDS_SET_2 = new Set<String>{'OrderID__c','ProductID__c','Batch_Billing__c'};
    public static final String FIELD_CUSTOM_VALIDATION_EXCEPTION = 'Insert failed. First exception on row 0; first error: '
    +'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    public static final String SUB_STATUS_DO_NOT_CANCEL_SHIPMENT = 'Do not cancel shipment';

    public static final String BARRELED_BOXED_MEMBERSHIP_PROGRAMM = 'Barreled_Boxed_Membership_Program'; //By Nishant Khandal 
    public static final String DIRECT_TO_CUSTOMER = 'Direct_To_Customer'; //By Nishant Khandal on 24/3/2022
    public static final String INVALID_VALUE_PROVIDED = 'Invalid value provided';
    public static final String ONLY_TRUE_FALSE_IS_EXPECTED = 'The expected value is either True or False';
    public static final Set<String> CASE_BOOLEAN_FIELDS = new Set<String>{'Cancel_Confirmed__c','Shipment_Required__c'};
    public static final Map<string, String> MAP_CASE_BOOLEAN_FIELDS_API_NAMES = 
        new Map<string, String>{'isCancelConfirmed' => 'Cancel_Confirmed__c', 'isShipmentRequired' => 'Shipment_Required__c'};
    public static final String CANCELCONFIRMED_REQUIRED_FOR_MC_CASE = 'IsCancelConfirmed is required for membership cancellation '
    +'case.';
    public static final String INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST ='INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST';
    public static final String INCORRECT_VALUE_FOR_DATE = 'Incorrect value for Date.';
    public static final String DUPLICATE_VALUES_NOT_ALLOWED = 'Duplicate values are not allowed.';
    public static final String PLEASE_CONTACT_ADMINISTRATOR = 'Please contact administrator';
    public static final String DHL_STATUS_CANNOTBENULL = 'The Status Cannot be update as null.';
    public static final String NOTIFICATION_BODY = 'There is a reply from customer on Case Number: ';
    public static final Id DTC_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DTC').getRecordTypeId(); 
    public static final String CUSTOMER_PORTAL = 'Customer Portal';
    public static final String SHIPPING_AND_DELIVERY_QUESTIONS = 'Shipping/Delivery Questions';
    public static final String REPLACEMENT_CONFIRMED_SUB_STATUS = 'Replacement confirmed';
    public static final String REPLACEMENT_INITIATED_SUB_STATUS = 'Replacement initiated'; 
    public static final  Set<String> CASE_REQUIRED_FIELDS_GET_CASE_DETAILS = new Set<String>{'email', 'brand'};
    public static final String ORDER_ID = 'orderid';
    public static final String EMAIL = 'email';
    public static final String BRAND = 'brand';
    public static final String INCORRECT_EMAIL_FORMAT = 'The format of email is incorrect.';
    public static final String RECORD_NOT_FOUND_CASE_DETAILS = 'Either the record does not exist or case is closed';
    public static final String MISSING_EMAIL = 'The value of Email cannot be empty.';
    public static final String RETURN_CASE_SUCCESSFULLY = 'Here is your case';
    public static final String MISSING_BRAND = 'The value of Brand cannot be empty its either Barreled & Boxed or Whisky Drop.';
    public static final String REPLACEMENT = 'Replacement';
    public static final  Set<String> DHL_REPLACEMENT_CASE_REQUIRED_FIELDS = new Set<String>{'First_name__c', 'Last_name__c', 
        'Email_Address__c',
        'Program_Subscription__c', 'Consumer_Street__c', 'Consumer_City__c', 'Consumer_State__c',
        'Consumer_Postal_Code__c','Consumer_Country__c','UPS_Tracking_Number__c','UPS_Reason_For_Return__c','Damage_Issue__c',
        'Customer_Phone_Number__c'};
    public static final String DHL_STATUS_LOST = 'Lost';
    public static final String DHL_STATUS_DAMAGE = 'Damage';
    public static final String DHL_STATUS_NOT_YET_SHIPPED = 'Not Yet Shipped';
    public static final String ADD_INFO_DISPUTE = 'Dispute';
    public static final String OPEN_STATUS = 'Open';
    public static final String WHISKY_DROP = 'Whisky Drop – Membership Program';
    public static final  Set<String> DISPUTE_CASE_REQUIRED_FIELDS = new Set<String>{'OrderID__c','DisputeID__c','TransactionID__c',
        'Transaction_Amount__c','Received_Date__c','Response_Deadline__c'};
    public static final String ONE_ADDRESS_FIELD_VALUE = 'Please provide customer address.';
    public static final String PLEASE_REVISIT = 'There is no update on Valid/Invalid case from last 5 days. Please revisit.';
    public static final String BRAIN_TREE_STATUS_WON = 'Won';
    public static final String BRAIN_TREE_STATUS_LOST = 'Lost';
    public static final String SUB_STATUS_SETTLED = 'Settled';
    public static final String SUB_STATUS_INVALID = 'Invalid';
    public static final String SUB_STATUS_BRAINTREE_RESPONSE = 'Waiting for braintree response';
    public static final String PLEASE_REVISIT_BRAINTREE = 'There is no update on Valid/Invalid case from last 10 days. Please revisit.';
    public static final String CASE_CLOSED_ERROR = 'Case cannot be marked as closed if Braintree status is not Won or Lost';
    public static final String LABEL_CANCELATION_REASON = 'Cancelation Reason';
    public static final String SUB_STATUS_FOLLOWUP_EMAIL_SENT = 'Follow up email sent';
    public static final String SUB_STATUS_VALID = 'Valid';
    public static final Set<String> COMPANY_MAIL_SET = new Set<String> {'dtc.mail@beamsuntory.com',
                                                       'thewhiskydrop@beamsuntory.com', 
                                                       'barreledandboxed@beamsuntory.com',
                                                       'barreled.boxed2@beamsuntory.com',
                                                       'barreledandboxed@beamdistilling.com',
                                                       'thewhiskydrop@makersmark.com'};
    public static final Integer FIVE_DAYS = 5;
    public static final Integer TEN_DAYS = 10;
    public static final String EMAIL_WHISKY_DROP = 'thewhiskydrop@beamsuntory.com';
    public static final String EMAIL_BARRELED_AND_BOXED = 'barreledandboxed@beamsuntory.com';
    public static final String UPDATE_REQD_ON_CASE_NO = 'Update Required on Case Number: ';
    public static final String NO_UPDATE_FROM_CUSTOMER = 'There is no update from Customer on Case Number: ';
    public static final String PLEASE_MARK_AS_REFUND_INITIATED = ' Please mark it as Refund-Initiated. ';
    public static final Id ACCOUNT_VENDOR_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().
    get('Vendor').getRecordTypeId();
    public static final String DTC_ET_DISPUTEVALID  = 'DTC_ET_DisputeValid';
    public static final String DTC_EMAIL_BEAMSUNTORY  = 'DTC';
    public static final String GBS_EMAILS  = 'GBS Emails';
    public static final Set<String> WHISKY_DROP_BARRELED_AND_BOX_SET = new Set<String> {'Whisky Drop – Membership Program',
        																				'Barreled & Boxed – Membership Program'};
                                                                                     // Vikash 30/11/2022
    public static final String LIMITED_ONLINE_RELEASES = 'Limited Online Releases'; // Nishant Khandal CRM-1991
    public static final String QUEUE_MAKER_S_MARK_LIMITED_ONLINE_RELEASES = 'Maker_s_Mark_Limited_Online_Releases'; // Nishant Khandal CRM-1991
    public static final Map<string, String> MAP_HOLD_HOW_CAN_WE_HELP_WITH_QUEUE = 
        new Map<string, String>{WHISKY_DROP => QUEUE_DTC, 
                                LIMITED_ONLINE_RELEASES => QUEUE_MAKER_S_MARK_LIMITED_ONLINE_RELEASES,
                                System.Label.Barreled_Boxed_Membership_Program => QUEUE_BARRELED_BOXED};
    public static final String WHISKYDROP_MM  = 'thewhiskydrop@makersmark.com';
    public static final String BARREDANDBOXED_BD  = 'barreledandboxed@beamdistilling.com';
    public static final String ADDITIONAL_INFORMATION_OTHER = 'Other';
    public static final String BARRELED_BOXED = 'Barreled & Boxed – Membership Program';
}