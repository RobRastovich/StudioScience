public class SBP_Constants {

    // Entitlement for accounts related to cases with Record type of order claim and order claim sub case
    public static final String SINGLE_BARREL_ENTITLEMENT = 'Single Barrel Entitlement';

    // Default Entitlement Processe for Record type order claim and order claim sub case
    public static final String SINGLE_BARREL_ENTITLEMENT_PROCESS = 'Single Barrel - Standard';

    // Default Entitlement Processe for Record type order claim and order claim sub case
    public static final String REGISTER_EMAIL_TEMPLATE_NAME = 'Register_Barrel';
    public static final String BARREL_FINAL_DETAILS_EMAIL_TEMPLATE_NAME = 'Barrel_Final_Details';
    public static final String ACCOUNT_APPLICATION_APPROVED_EMAIL_TEMPLATE_NAME = 'Account_Application_Approved';
    public static final String SAP_NUMBER_ENTERED_EMAIL_TEMPLATE_NAME = 'SAP_has_been_Entered';
    public static final String Baker_s_Application_Approval_Email= 'Baker_s_Application_Approval_Email';
    public static final String BAKER_S_APPLICATION_APPROVAL_GROUP = 'Baker\'s Application Approval Group';
    public static final String BARREL_QUANTITY_PROOF_ADDED = 'Quantity_and_Proof_is_Added';
    public static final String LOW_QUANTITY_TEMPLATE = 'Low_Yield_Template_Draft';

	//Organization-Wide address 'Single.Barrels@beamsuntory.com'
	public static final OrgWideEmailAddress singleBarrelOWEA = [select Id from OrgWideEmailAddress where Address = 'single.barrels@beamsuntory.com' Limit 1];
    
    // standard barrel order case statuses
    public static final String NEW_STATUS = 'New';
    public static final String PENDING_DOCUMENTATION = 'Pending Documentation';
    public static final String PREPARING_BARREL = 'Preparing Barrel';
    public static final String PENDING_FINAL_DETAILS = 'Pending Final Details';
    public static final String ORDER_SHIPPED = 'Order Shipped';
    public static final String CLOSED = 'Closed';

    // proof specific barrel order case statuses
    public static final String PENDING_SELECTION = 'Pending Selection';
    public static final String PENDING_PURCHASE_ORDER = 'Pending Purchase Order';
    public static final String PENDING_SHIP_DATE = 'Pending Ship Date';


    // email to case values
    public static final String PRODUCTION_ORGANIZATION_ID = '00Do0000000cCkJEAU';
    public static final String PROD_EMAIL_SERVICE_ADDRESS = 'customer.service@beamsuntory.com';
    public static final String PROD_COMPLIANCE_EMAIL_SERVICE_ADDRESS = 'compliance@beamsuntory.com';

    public static final String SANDBOX_EMAIL_SERVICE_ADDRESS = 'customerservice.sandbox@beamsuntory.com';
    public static final String EMAIL_SERVICE_ADDRESS = UserInfo.getOrganizationId() == PRODUCTION_ORGANIZATION_ID ?
            PROD_EMAIL_SERVICE_ADDRESS :
            SANDBOX_EMAIL_SERVICE_ADDRESS;

    public static final String COMPLIANCE_EMAIL_SERVICE_ADDRESS = UserInfo.getOrganizationId() == PRODUCTION_ORGANIZATION_ID ?
            PROD_COMPLIANCE_EMAIL_SERVICE_ADDRESS :
            '';
    public static final String SANDBOX_singleBarrelOWEA_EMAIL_ADDRESS = 'single.barrels@beamsuntory.com.invalid';
    public static final String PROD_singleBarrelOWEA_EMAIL_ADDRESS = 'single.barrels@beamsuntory.com';
    public static final String singleBarrelOWEA_SERVICE_ADDRESS = UserInfo.getOrganizationId() == PRODUCTION_ORGANIZATION_ID ?
            PROD_singleBarrelOWEA_EMAIL_ADDRESS :
            SANDBOX_singleBarrelOWEA_EMAIL_ADDRESS;

    public static final List<String> STATUSES_AFTER_PENDING_DOCUMENTATION = new List<String> {
        PREPARING_BARREL,
        PENDING_FINAL_DETAILS,
        ORDER_SHIPPED,
        CLOSED
    };

    public static final String SAMPLE_KIT = 'Sample Kit';
    public static final String TRIP_AND_TOUR = 'Trip and Tour';
    public static final String DISTILLER_CHOICE = 'Distiller\'s Choice';
    public static final String REMOTE_SELECTION = 'Remote Selection';
    public static final String SPLIT_BARREL = 'Split Barrel';

    // picklist field api names
    public static final String STATE_APINAME = 'State__c';
    public static final String PREMISE_APINAME = 'PremiseType__c';
    public static final String REGION_APINAME = 'Region__c';
    public static final String MARKET_APINAME = 'Market__c';


    // milestone names
    public static final String POS_ITEM_MILESTONE = 'Select POS Items';
    public static final String SELECT_BARREL_MILESTONE = 'Select Barrel';
    public static final String SELECT_SAMPLE_MILESTONE = 'Select Sample';
    public static final String UPLOAD_PO_MILESTONE = 'Upload Purchase Order';
    public static final String ENTER_BOTTLE_TEXT_MILESTONE = 'Enter Bottle Text';
    public static final String ENTER_SAP_NUMBER_MILESTONE = 'Enter SAP Number';
    public static final String ENTER_BARREL_DETAIL_MILESTONE = 'Enter Barrel Detail';
    public static final String SELECT_SAMPLE_DETAIL_MILESTONE = 'Select Sample';
    public static final String SCHEDULE_TRIP_MILESTONE = 'Schedule Trip';
    public static final String STO_CREATED_MILESTONE = 'Create STO';



    // Email templates
    public static final String FINAL_DETAILS_TEMPLATE = 'Final_Information_has_been_Entered';
    public static final String SAP_NUMBER_ENTERED_TEMPLATE = 'SAP_has_been_Entered';

    // Record Type Names

    // case
    public static final Id SINGLE_BARREL_STANDARD_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Standard').getRecordTypeId();
    public static final Id SINGLE_BARREL_PROOF_SPECIFIC_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Proof_Specific').getRecordTypeId();
    public static final Id SINGLE_BARREL_SPLIT_BARREL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Single_Barrel_Split_Barrel').getRecordTypeId();
    public static final Id BARREL_READY_TO_ENTER_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Ready_to_Enter').getRecordTypeId(); //added by ajeeta
	public static final Id SINGLE_BARREL_LAPHROAIG_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask').getRecordTypeId(); //added by abhishek sharma
    
    // barrel
    public static final Id KNOB_CREEK_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Full_Barrel').getRecordTypeId();
    public static final Id KNOB_CREEK_SPLIT_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Split_Barrel').getRecordTypeId();
    public static final Id KNOB_CREEK_SAMPLE_KIT_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek_Sample_Kit').getRecordTypeId();

    public static final Id MAKERS_MARK_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark_Full_Barrel').getRecordTypeId();
    public static final Id BAKERS_SAMPLE_KIT_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Baker_s_Sample_Kit').getRecordTypeId();
	public static final Id ETLC_SAMPLE_KIT_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro_Laphroaig_Cask_Sample_Kit').getRecordTypeId();
    
    //Added by Nishant Khandal for Barrel Laphroaig Single cask
    public static final Id LAPHROAIG_SINGLE_CASK_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask_Full_Barrel').getRecordTypeId();
    public static final Id LAPHROAIG_SINGLE_CASK_SAMPLE_KIT_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Laphroaig_Single_Cask_Sample_Kit').getRecordTypeId();
    
    public static final Id JIM_BEAM_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Full_Barrel').getRecordTypeId();
    public static final Id JIM_BEAM_SAMPLE_KIT_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Jim_Beam_Sample_Kit').getRecordTypeId();

    public static final Id CRUZAN_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Cruzan_Full_Barrel').getRecordTypeId();
    public static final Id CRUZAN_SAMPLE_KIT_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Cruzan_Sample_Kit').getRecordTypeId();

    public static final Id EL_TESORO_FULL_BARREL_RT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro_Full_Barrel').getRecordTypeId();
	public static final Id BAKER_SAMPLE_KIT_ID = Schema.SObjectType.Barrel__c.getRecordTypeInfosByDeveloperName().get('Baker_s_Sample_Kit').getRecordTypeId();
    // Plant
    public static final Id KNOB_CREEK_EVENT_RT_ID = Schema.SObjectType.Plant_Event__c.getRecordTypeInfosByDeveloperName().get('Knob_Creek').getRecordTypeId();
    public static final Id MAKERS_MARK_EVENT_RT_ID = Schema.SObjectType.Plant_Event__c.getRecordTypeInfosByDeveloperName().get('Makers_Mark').getRecordTypeId();
    public static final Id EL_TESORO_EVENT_RT_ID = Schema.SObjectType.Plant_Event__c.getRecordTypeInfosByDeveloperName().get('El_Tesoro').getRecordTypeId();
    public static final Id LAPHROAIG_SINGLE_CASK_EVENT_RT_ID = Schema.SObjectType.Plant_Event__c.getRecordTypeInfosByDeveloperName().
                                                               get('Laphroaig_Single_Cask').getRecordTypeId(); //Added By Nishant Khandal LSB-20

    // POS Customizations
    public static final Id POS_FULL_BARREL_RT_ID = Schema.SObjectType.POS_Customization__c.getRecordTypeInfosByDeveloperName().get('Full_Barrel').getRecordTypeId();
    public static final Id POS_SPLIT_BARREL_RT_ID = Schema.SObjectType.POS_Customization__c.getRecordTypeInfosByDeveloperName().get('Split_Barrel').getRecordTypeId();

    // full barrel recordtype map by brand name
    public static Map<String, Id> fullBarrelBrandRTIdMap = new Map<String, Id> {
        'Knob Creek'        		=> KNOB_CREEK_FULL_BARREL_RT_ID,
        'Makers Mark'       		=> MAKERS_MARK_FULL_BARREL_RT_ID,
        'Jim Beam'          		=> JIM_BEAM_FULL_BARREL_RT_ID,
        'Cruzan'            		=> CRUZAN_FULL_BARREL_RT_ID,
        'El Tesoro'         		=> EL_TESORO_FULL_BARREL_RT_ID,
        'Baker\'s'					=> BAKERS_SAMPLE_KIT_RT_ID,
        //'El Tesoro Laphroaig Cask'  => ETLC_SAMPLE_KIT_RT_ID
        'El Tesoro Laphroaig Cask'  => ETLC_SAMPLE_KIT_RT_ID,
        'Laphroaig Single Cask'     => LAPHROAIG_SINGLE_CASK_FULL_BARREL_RT_ID // Added by Nishant khanadal for LSB-7
         
    };

    public static Map<String, Id> splitBarrelBrandRTIdMap = new Map<String, Id> {
        'Knob Creek'        => KNOB_CREEK_SPLIT_BARREL_RT_ID
    };

    public static Map<String, Id> sampleKitBrandRTIdMap = new Map<String, Id> {
        'Knob Creek'        => KNOB_CREEK_SAMPLE_KIT_RT_ID,
        'Jim Beam'          => JIM_BEAM_SAMPLE_KIT_BARREL_RT_ID,
        'Cruzan'            => CRUZAN_SAMPLE_KIT_RT_ID
    };

    public static Map<String, Id> plantEventRtIdMap = new Map<String, Id> {
        'Knob Creek'        => KNOB_CREEK_EVENT_RT_ID,
        'Makers Mark'       => MAKERS_MARK_EVENT_RT_ID,
        'El Tesoro'         => EL_TESORO_EVENT_RT_ID,
        'Laphroaig Single Cask' => LAPHROAIG_SINGLE_CASK_EVENT_RT_ID // Added by Nishant Khandal LSB-20
    };

    public static Map<String, String> brandToPlant = new Map<String, String> {
        'Knob Creek'        => 'Clermont',
        'Makers Mark'       => 'Loretto',
        'El Tesoro'         => 'La Alteña Distillery',
        'Laphroaig Single Cask' => 'Laphroaig Distillery' // Added by Nishant Khandal LSB-21/20
    };

    public static Map<String, Id> caseBrandsRTIdMap = new Map<String, Id> {
        'Makers Mark'       		=> SINGLE_BARREL_PROOF_SPECIFIC_RT_ID,
        'El Tesoro'         		=> SINGLE_BARREL_PROOF_SPECIFIC_RT_ID,
        'Knob Creek'        		=> SINGLE_BARREL_STANDARD_RT_ID,
        'Jim Beam'          		=> SINGLE_BARREL_STANDARD_RT_ID,
        'Cruzan'           			=> SINGLE_BARREL_STANDARD_RT_ID,
        'Baker\'s'					=> SINGLE_BARREL_STANDARD_RT_ID,
        'El Tesoro Laphroaig Cask'  => SINGLE_BARREL_PROOF_SPECIFIC_RT_ID,
        'Laphroaig Single Cask'     => SINGLE_BARREL_LAPHROAIG_RT_ID    // Added by abhishek sharma
    };

    public static Set<Id> caseSingleBarrelRtIds = new Set<Id> {
        SINGLE_BARREL_STANDARD_RT_ID,
        SINGLE_BARREL_PROOF_SPECIFIC_RT_ID,
        SINGLE_BARREL_LAPHROAIG_RT_ID                      //Added By Nishant Khandal LSB-81
    };


    public static Set<Id> caseSingleBarrelMissingItemsRtIds = new Set<Id> {
        SINGLE_BARREL_STANDARD_RT_ID,
        SINGLE_BARREL_PROOF_SPECIFIC_RT_ID,
        SINGLE_BARREL_SPLIT_BARREL_RT_ID
    };

    public static Set<Id> fullBarrelRtIds = new Set<Id> {
        KNOB_CREEK_FULL_BARREL_RT_ID,
        MAKERS_MARK_FULL_BARREL_RT_ID,
        JIM_BEAM_FULL_BARREL_RT_ID,
        CRUZAN_FULL_BARREL_RT_ID,
        EL_TESORO_FULL_BARREL_RT_ID,
        LAPHROAIG_SINGLE_CASK_FULL_BARREL_RT_ID 
    };

    public static Set<Id> splitBarrelRtIds = new Set<Id> {
        KNOB_CREEK_SPLIT_BARREL_RT_ID
    };

    public static Set<Id> clermontBarrelRtIds = new Set<Id> {
        KNOB_CREEK_FULL_BARREL_RT_ID,
        JIM_BEAM_FULL_BARREL_RT_ID,
        CRUZAN_FULL_BARREL_RT_ID

    };

    public static Set<Id> standardBarrelRTIds = new Set<Id> {
        KNOB_CREEK_FULL_BARREL_RT_ID,
        JIM_BEAM_FULL_BARREL_RT_ID,
        CRUZAN_FULL_BARREL_RT_ID
    };

    public static Set<Id> proofSpecificBarrelRTIds = new Set<Id> {
        MAKERS_MARK_FULL_BARREL_RT_ID,
        EL_TESORO_FULL_BARREL_RT_ID,
        BAKERS_SAMPLE_KIT_RT_ID,
        ETLC_SAMPLE_KIT_RT_ID    
    };

    public static Map<String, String> stateMap = new Map<String, String> {
        'AL' => 'Alabama',
        'AK' => 'Alaska',
        'AZ' => 'Arizona',
        'AR' => 'Arkansas',
        'CA' => 'California',
        'CO' => 'Colorado',
        'CT' => 'Connecticut',
        'DE' => 'Delaware',
        'FL' => 'Florida',
        'GA' => 'Georgia',
        'HI' => 'Hawaii',
        'ID' => 'Idaho',
        'IL' => 'Illinois',
        'IN' => 'Indiana',
        'IA' => 'Iowa',
        'KS' => 'Kansas',
        'KY' => 'Kentucky',
        'LA' => 'Louisiana',
        'ME' => 'Maine',
        'MD' => 'Maryland',
        'MA' => 'Massachusetts',
        'MI' => 'Michigan',
        'MN' => 'Minnesota',
        'MS' => 'Mississippi',
        'MO' => 'Missouri',
        'MT' => 'Montana',
        'NE' => 'Nebraska',
        'NV' => 'Nevada',
        'NH' => 'New Hampshire',
        'NJ' => 'New Jersey',
        'NM' => 'New Mexico',
        'NY' => 'New York',
        'NC' => 'North Carolina',
        'ND' => 'North Dakota',
        'OH' => 'Ohio',
        'OK' => 'Oklahoma',
        'OR' => 'Oregon',
        'PA' => 'Pennsylvania',
        'RI' => 'Rhode Island',
        'SC' => 'South Carolina',
        'SD' => 'South Dakota',
        'TN' => 'Tennessee',
        'TX' => 'Texas',
        'UT' => 'Utah',
        'VT' => 'Vermont',
        'VA' => 'Virginia',
        'WA' => 'Washington',
        'DC' => 'Washington DC',
        'WV' => 'West Virginia',
        'WI' => 'Wisconsin',
        'WY' => 'Wyoming',
        'OR' => 'Oregon',
        'N1' => 'North Carolina',
        'U1' => 'Utah'
    };

    //Added for SR_193730
    public static final String REGISTERING_CASE_WITH_COMPLIANCE_EMAIL_TEMPLATE = 'Registering_Case_with_Compliance';
    public static final Map<String, Id> BRAND_TO_SAMPLE_BARREL_RT_ID = new Map<String, Id>{
        'Knob Creek' => KNOB_CREEK_SAMPLE_KIT_RT_ID,
        'El Tesoro' => EL_TESORO_FULL_BARREL_RT_ID,
        'Baker\'s' => BAKER_SAMPLE_KIT_ID,
        'El Tesoro Laphroaig Cask'=> ETLC_SAMPLE_KIT_RT_ID,
        'Laphroaig Single Cask'=> LAPHROAIG_SINGLE_CASK_SAMPLE_KIT_RT_ID        //Added for LSB-143
    };
        
        // Added for PlantEventTrigger
    public static final String USER_TYPE_PLANT_TEAM_MEMBER = 'Plant Team Member';
    public static final String USER_TYPE_DIPLOMAT= 'Diplomat';
    public static final String USER_TYPE_HERITAGE_MANAGER = 'Heritage Manager';
    public static final String USER_TYPE_SUPER_HERITAGE_MANAGER = 'Super Heritage Manager';
    public static final String BRAND_MAKERS_MARK = 'Makers Mark';

    public static final String SAMPLE_KIT_APINAME = 'Sample_Kit__c';
    public static final String SAMPLE_KIT_FEDEXCARRIERNAME = 'FedEx';
    public static final String SAMPLE_KIT_TRACKING_NUMBER_UNMATCHED_CODE = '9040';
    
    
    //Added For Laphroaig Single Cask
    public static final String ACCOUNT_APPLICATION_STATUS_APPROVED = 'Approved';
    public static final String ACCOUNT_APPLICATION_STATUS_PENDING = 'Pending Approval';
    public static final String LAPHROAIG_SINGLE_CASK = System.Label.LAPHROAIG_SINGLE_CASK;
    public static final String LAPHROAIG_SINGLE_CASK_QUESTION_SET = System.Label.LAPHROAIG_SINGLE_CASK_QUESTION_SET;
    public static final String LAPHROAIG_SINGLE_CASK_ACC_APPLICATION_APPROVED_TEMPLATE ='Laphroaig_Account_Applicaiton_Approved';
    public static final String SINGLE_BARREL_INT_ACCOUNT = 'Single Barrel International Account';
    public static final String OPERATION_SUCCESS = 'Operation should return successfully';
    public static final String CASE_STRING = 'Case';
    public static final String CUSTOMER_SERVICE_EMAIL_ID = 'cs@beamsuntory.com';//By Nishant Khandal LSB-69
    public static final String CUSTOMER_SERVICE_EMAIL_DISPLAY_NAME = 'Beam Suntory Customer Service';//By Nishant Khandal LSB-69
    public static final String LAPHROAIG_TRIP_AND_TOUR_TIMER_EXPIRED_TEMPLATE = 'Laphroaig_Trip_and_Tour_Timer_Expired';//added by Nishant Khandal for LSB-69
    public static final String REMOTE_EXPERIENCE_PENDING_SELECTION = 'Remote Experience Pending Selection';// ADDED FOR LSB-153
    public static final String BOTTLING = 'Bottling';// ADDED FOR LSB-153
    public static final String PREPARING_STO = 'Preparing STO';// ADDED FOR LSB-153
    public static final String AWAITING_DISTRIBUTOR_PO = 'Awaiting Distributor PO';// ADDED FOR LSB-216

    //Added For TForce Integration
    public static final String barrelObject = 'Barrel__c';
    public static final String carrierName = 'TForce';
    public static final String noTrackingDetails = 'Tracking Details not Found';

    //Added by Sangeet on 12-04-23
    public static final String BRAND_KNOB_CREEK = 'Knob Creek';
    public static final String BRAND_BAKERS = 'Baker\'s';
    
    //Added by Vikash on 15-01-2024
    public static final String PRODUCT_TYPE_RYE = 'Rye';
}