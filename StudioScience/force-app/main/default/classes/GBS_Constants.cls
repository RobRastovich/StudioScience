public class GBS_Constants {

    public static final String CLOSED = 'Closed';
    public static final String CLOSED_ABANDONED = 'Closed - Abandoned';
    public static final String CLOSED_APPROVED = 'Closed - Approved';
    public static final String CLOSED_REJECTED = 'Closed - Rejected';

    public static final String DEFAULT_ACCOUNT_NAME = 'Beam Suntory GBS';
    public static Id vendorAccountRecordTypdId {
        get {
            return [SELECT  Id, 
                            Name, 
                            DeveloperName, 
                            NamespacePrefix 
                            FROM RecordType 
                            WHERE DeveloperName = 'Vendor' AND NamespacePrefix != 'gvp' LIMIT 1].Id;
        }
        set;
    }
    //public static Id vendorAccountRecordTypdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();

    public static final Set<String> CLOSED_STATUS_VARIATIONS = new Set<String> {
        CLOSED,
        CLOSED_ABANDONED,
        CLOSED_APPROVED,
        CLOSED_REJECTED
    };

    // Entitlement for accounts related to GBS Cases
    public static final String STANDARD_ENTITLEMENT = 'GBS Entitlement - Standard';
    public static final String GBS_OUTLOOK_ORIGIN = 'Outlook';

    // Default Entitlement Processe GBS Cases
    public static final String STANDARD_ENTITLEMENT_PROCESS = 'GBS - Standard';

    // milestone names
    public static final String IN_PROGRESS_MILESTONE = 'In Progress';
    public static final String LOGGED_MILESTONE = 'Logged';
    public static final String WAITING_MILESTONE = 'Waiting';

    // status names
    public static final String IN_PROGRESS = 'In Progress';
    public static final String LOGGED = 'Logged';
    public static final String WAITING = 'Waiting on 3rd Party';

    public static final Map<String, String> statusToMilestone = new Map<String, String> {
        LOGGED         => LOGGED_MILESTONE,
        IN_PROGRESS    => IN_PROGRESS_MILESTONE,
        WAITING        => WAITING_MILESTONE
    };

    public static final List<String> STANDARD_MILESTONES = new List<String> {
        LOGGED,
        IN_PROGRESS,
        WAITING
    };

    public static final String GBS_MADRID_PAYROLL_GROUP_NAME = 'GBS: Madrid Payroll';
    public static final String GBS_MADRID_NON_PAYROLL_GROUP_NAME = 'GBS: Madrid Non-Payroll';
    public static final String GBS_SINGAPORE_NON_PAYROLL_GROUP_NAME = 'GBS: Singapore Non-Payroll';
    public static final String GBS_SINGAPORE_PAYROLL_GROUP_NAME = 'GBS: Singapore Payroll';
    public static final String GBS_INDIA_NON_PAYROLL_GROUP_NAME = 'GBS: India Non-Payroll';
    public static final String GBS_SINGAPORE_INDIA_SHARED_NON_PAYROLL_GROUP_NAME = 'GBS: India/Singapore Shared Non-Payroll';

    // gbs recordTypes
    public static final Id CLAIMS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claims').getRecordTypeId();
    public static final Id GBS_OUTLOOK_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GBS_Outlook').getRecordTypeId();
    public static final Id GMDM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM').getRecordTypeId();
    public static final Id GMDM_CENTER_CHANGE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Center_Change').getRecordTypeId();
    public static final Id GMDM_CENTER_ACCOUNT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Center_Account_Create').getRecordTypeId();
    public static final Id GMDM_CUSTOMER_HIERARCHY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Customer_Hierarchy').getRecordTypeId();
    public static final Id GMDM_CUSTOMER_MAINTENANCERT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Customer_Maintenance').getRecordTypeId();
    public static final Id GMDM_EDW_MAPPING_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_EDW_Mapping').getRecordTypeId();
    public static final Id GMDM_ACCOUNT_CHANGE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Account_Change_Extend').getRecordTypeId();
    public static final Id GMDM_MATERIALS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Materials').getRecordTypeId();
    public static final Id GMDM_REBATES_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Rebates').getRecordTypeId();
    public static final Id GMDM_SIMPLE_REQUEST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Simple_Request').getRecordTypeId();
    public static final Id GMDM_VENDOR_MAINTENANCE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GMDM_Vendor_Maintenance').getRecordTypeId();
    public static final Id HR_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HR').getRecordTypeId();
    public static final Id OTC_BAILMENT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Bailment').getRecordTypeId();
    public static final Id OTC_BAILMENT_ERROR_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Bailment_Error').getRecordTypeId();
    public static final Id OTC_CANCELLATION_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Cancellation').getRecordTypeId();
    public static final Id OTC_COMMISIONS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Commissions').getRecordTypeId();
    public static final Id OTC_CORRECT_INVOICE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Correct_Invoice').getRecordTypeId();
    public static final Id OTC_CREDIT_APPROVAL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Credit_Approval').getRecordTypeId();
    public static final Id OTC_D2D_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_D2D_Xfer').getRecordTypeId();
    public static final Id OTC_FI_REQUEST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_FI_Request').getRecordTypeId();
    public static final Id OTC_INVOICE_NUMBER_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Invoice_Number').getRecordTypeId();
    public static final Id OTC_INVOICE_REQUEST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Invoice_Request').getRecordTypeId();
    public static final Id OTC_MANUAL_INVOICE_REQUEST_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Manual_Invoice_Request').getRecordTypeId();
    public static final Id OTC_RESEND_AUTO_INVOICE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Resend_Auto_Invoice').getRecordTypeId();
    public static final Id OTC_TPM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_TPM').getRecordTypeId();
    public static final Id OTC_BILLING_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OTC_Billing').getRecordTypeId();
    public static final Id PAYROLL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Payroll').getRecordTypeId();
    public static final Id PTP_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PTP_AP').getRecordTypeId();
    public static final Id PTP_PR_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PTP_AP_PR_PO').getRecordTypeId();
    public static final Id RTR_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RTR').getRecordTypeId();
    public static final Id TAX_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Tax').getRecordTypeId();
    public static final Id TE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('T_E').getRecordTypeId();

    public static Set<Id> gbsRecordTypeIds = new Set<Id> {
        CLAIMS_RT_ID,
        GBS_OUTLOOK_RT_ID,
        GMDM_RT_ID,
        GMDM_CENTER_CHANGE_RT_ID,
        GMDM_CENTER_ACCOUNT_RT_ID,
        GMDM_CUSTOMER_HIERARCHY_RT_ID,
        GMDM_CUSTOMER_MAINTENANCERT_ID,
        GMDM_EDW_MAPPING_RT_ID,
        GMDM_ACCOUNT_CHANGE_RT_ID,
        GMDM_MATERIALS_RT_ID,
        GMDM_REBATES_RT_ID,
        GMDM_SIMPLE_REQUEST_RT_ID,
        GMDM_VENDOR_MAINTENANCE_RT_ID,
        HR_RT_ID,
        OTC_BAILMENT_RT_ID,
        OTC_BAILMENT_ERROR_RT_ID,
        OTC_CANCELLATION_RT_ID,
        OTC_COMMISIONS_RT_ID,
        OTC_CORRECT_INVOICE_RT_ID,
        OTC_CREDIT_APPROVAL_RT_ID,
        OTC_D2D_RT_ID,
        OTC_FI_REQUEST_RT_ID,
        OTC_INVOICE_NUMBER_RT_ID,
        OTC_INVOICE_REQUEST_RT_ID,
        OTC_MANUAL_INVOICE_REQUEST_RT_ID,
        OTC_RESEND_AUTO_INVOICE_RT_ID,
        OTC_TPM_RT_ID,
        OTC_BILLING_RT_ID,
        PAYROLL_RT_ID,
        PTP_RT_ID,
        PTP_PR_RT_ID,
        RTR_RT_ID,
        TAX_RT_ID,
        TE_RT_ID
    };



}