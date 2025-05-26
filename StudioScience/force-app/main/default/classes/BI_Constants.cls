public without sharing class BI_Constants {
    //Error Messages

    public static final String DUPLICATE_PLAN = 'This Marketing Plan is a duplicate. Please correct the issue and try again.';
    public static final String PLAN_ALLOCATEDBUDGET_VIOLATION = 'This change would cause the parent Marketing Plan\'s Allocated Budget to exceed Budget. Please correct the issue and try again.';
    public static final String TRANSFERREQUEST_MULTIPLEAPPROVALS = 'Error: Multiple Marketing Plan Transfers got approved at the same time which is unsupported. Please try your approval again shortly.';
    public static final String TRANSFERREQUEST_CAMPAIGNSLUSH_TOOLOW = 'The Sender Marketing Plan (From) does not have enough Campaign Unallocated Budget available to complete the transfer. Please contact your administrator.';
    public static final String TRANSFERREQUEST_PLANSLUSH_TOOLOW = 'The Sender Marketing Plan (From) does not have enough MP Unallocated Budget available to complete the transfer. Please contact your administrator.';
    public static final String TRANSFERREQUEST_UNKNOWN = 'We were unable to automate the Transfer Request. Please send the following error to your administrator: ';
    public static final String IO_ALREADYHASIO = 'This Campaign already has an IO Code generated.';
    public static final String IO_YEAR_MISSING = 'This Campaign is missing Year which is required to generate an IO Code.';
    public static final String IO_SAP_CONTROLLINGAREA = 'This Campaign is missing SAP Controlling Area which is required to generate an IO Code.';
    public static final String IO_SAP_COMPANYCODE = 'This Campaign is missing SAP Company Code which is required to generate an IO Code.';
    public static final String IO_SAP_COSTCENTER = 'This Campaign is missing SAP Cost Center which is required to generate an IO Code.';
    public static final String IO_BRANDQUALITY = 'This Campaign is either missing a Brand Quality, the Brand Quality is missing an IO Code Segment, or the IO Code Segment is not 5 characters long.';
    public static final String IO_TERRITORY = 'This Campaign\'s parent Marketing Plan is either missing a Territory, the Territory is missing an IO Code Segment, or the IO Code Segment is not 2 characters long.';
    public static final String IO_DUPLICATE = 'A duplicate IO Code was found on another Campaign. Please contact your administrator.';
    public static final String WBS_ALREADYHASWBS = 'This Campaign already has a WBS Code generated.';
    public static final String WBS_YEAR_MISSING = 'This Campaign is missing Year which is required to generate a WBS Code.';
    public static final String WBS_SAP_CONTROLLINGAREA = 'This Campaign is missing SAP Controlling Area which is required to generate a WBS Code.';
    public static final String WBS_SAP_COMPANYCODE = 'This Campaign is missing SAP Company Code which is required to generate a WBS Code.';
    public static final String WBS_SAP_COSTCENTER = 'This Campaign is missing SAP Cost Center which is required to generate a WBS Code.';
    public static final String WBS_BRANDQUALITY = 'This Campaign is either missing a Brand Quality, the Brand Quality is missing a WBS Code Segment, or the WBS Code Segment is not 3 characters long.';
    public static final String WBS_BRAND = 'This Campaign\'s Marketing Plan is either missing a Brand, the Brand is missing a WBS Code Segment, or the WBS Code Segment is not 4 characters long.';
    public static final String WBS_TERRITORY = 'This Campaign\'s parent Marketing Plan is either missing a Territory, the Territory is missing a WBS Code Segment, or the WBS Code Segment is not 6 characters long.';
    public static final String WBS_DUPLICATE = 'A duplicate WBS Code was found on another Campaign. Please contact your administrator.';    
    public static final String MISSING_CONVERSION_RATE = 'There is no conversion rate available for the specified date. Please contact your administrator to check the configuration of the currency conversion rates.';
    public static final String INCORRECT_DATE_FORMAT = 'The date field used for conversion was not formatted properly. Please have your administrator inspect the following field: ';
    public static final String UNEXPECTED_ERROR = 'An unexpected error occurred. Please contact an administrator to confirm that the conversion rates are configured properly.';
    //Record Types
    public static final String RECORDTYPE_CAMPAIGN_IO_2018 = 'parent_campaign';
    public static final String RECORDTYPE_CAMPAIGN_CHILD = 'Child Campaign';
    public static final String RECORDTYPE_CAMPAIGNSPEND_FORECAST = 'Forecast';
    public static final String RECORDTYPE_CAMPAIGNSPEND_Campaign_Planning_Forecasting = 'Campaign Planning & Forecasting';
    public static final String RECORDTYPE_CAMPAIGNSPEND_ACTUAL = 'Actual';
    public static final String RECORDTYPE_CAMPAIGNSPEND_COMMITTED = 'Committed';
    public static final String RECORDTYPE_CAMPAIGNSPEND_Monthly_Plan_AUS = 'Monthly_Plan_AUS';//Added for AUS BI Campaign planning restructure project
    public static final String RECORDTYPE_CAMPAIGNSPEND_Monthly_Budget_AUS = 'Monthly_Budget_AUS';//Added for AUS BI Campaign planning restructure project
    
    public static final String National_POS_RT = 'POS_Finance_Only';
    public static final String National_POS_CampaignType = 'National POS (Finance Only)';
    public static final String National_POS_COGS_CampaignType = 'National POS-COGS (Finance Only)';
    
    //DEPRECATED public static final String RECORDTYPE_MP_CAMPAIGNALLOWED_EDIT = 'Campaigns_Allowed_Editable';
    public static final String RECORDTYPE_MP_CAMPAIGNALLOWED = 'Campaigns_Allowed_Not_Editable';
    //public static final String RECORDTYPE_MP_CAMPAIGNPROHIBITED_EDIT = 'Campaigns_Prohibited_Editable';
    public static final String RECORDTYPE_MP_CAMPAIGNPROHIBITED = 'Campaigns_Prohibited_Not_Editable';

    public static final String RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS = 'Campaigns_Allowed_Not_Editable_AUS_WBS';
    public static final String RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS = 'Campaigns_Prohibited_Not_Editable_AUS_WBS';
    public static final Set<String> MP_WBS_RECORDTYPES = new Set<String>{
        RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS,
        RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS
    };

    public static final String RECORDTYPE_CAMPAIGN_AUSTRALIA_WBS = 'Australia Campaign (WBS)';
    public static final Set<String> CAMPAIGN_WBS_RECORDTYPES = new Set<String>{
        RECORDTYPE_CAMPAIGN_AUSTRALIA_WBS
    };
    //Object Names
    public static final String OBJECT_CAMPAIGNSPEND = 'Campaign_Spend__c';
    public static final String OBJECT_MARKETINGPLAN = 'MarketingPlan__c';
    
    //MISC
    public static final String TRANSFERREQUEST_STATUS_APPROVED = 'Approved';
    public static final String NEXT_IO_SEQUENCE = 'Next IO Sequence';
    public static final String NEXT_WBS_SEQUENCE = 'Next WBS Sequence';
    public static final Integer TOTAL_MONTHS_IN_YEAR = 12;
    public static final Integer MAX_NUMBER_OF_CHARACTERS_IN_NAME_FIELD = 80;

    public static Boolean isWBSMarketingPlan(String mpRecordTypeName){
        return MP_WBS_RECORDTYPES.contains(mpRecordTypeName);
    }

    public static Boolean isWBSCampaign(String campaignRecordTypeName){
        return CAMPAIGN_WBS_RECORDTYPES.contains(campaignRecordTypeName);
    }

}