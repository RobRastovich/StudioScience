public class CRM_Constants {
    
    //Case Record Types
    public static final Id QUALITY_CLAIM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Quality_Claim').getRecordTypeId();
    public static final Id CONSUMER_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumer_Inquiry').getRecordTypeId();

    //Brand Names
    public static final String LARIOS_BRAND = 'Larios';
    
    //Assert Message
    public static final String CASE_ASSERT_MESSAGE = 'Case details not found.';
    public static final String ASSERT_MESSAGE_A = 'The field is still not replaced';
    public static final String Brand_cannot_be_blank = 'Brand cannot be blank';
    public static final String Product_cannot_be_blank = 'Product Type cannot be blank';
    
    public static final String ACKNOWLEDGEMENT = 'Acknowledgement';
    public static final String TOPIC_USER_GROUP = 'Topic_Users_Group';
    public static final String AGENT_CLOSED = 'Agent Closed';
    
    //Case Status
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_RESOLVED = 'Resolved';
    public static final String CASE_STATUS_ASSIGNED = 'Assigned';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    
    //Toast Messages
    public static final String RECORD_INSERTED = 'The Topic is succesfully inserted.';
    public static final String CONTACT_ADMIN_MESSAGE = 'Please contact Administration.';
    
    //Toast Message type
    public static final String SUCCESS_TYPE = 'success';
    public static final String ERROR_TYPE = 'error';
    public static final List<String> RECORD_TYPE_LIST= new List<String>{'Consumer Inquiry', 'Quality Claim'};
    public static final String CASE_PREFIX = '500';
    
    public static final String Contact_Us_Community_Site_Guest_User = 'Contact Us Community Site Guest User';
    public static final String SFDC_Integration = 'SFDC Integration';
    
    public static final Set<String> Product_Type_Mandatory_Brands = new Set<String>{'Alberta Distillers', 'Alberta Rye', 'Ardmore'
        , 'Ardray', 'Auchentoshan', 'Baker\'s'
        , 'Basil Hayden\'s', 'Beam Suntory Corporate','Suntory Global Spirits Corporate', 'Booker\'s', 'Bowmore'
        , 'Calico Jack', 'Canadian Club', 'Connemara', 'Courvoisier', 'Cruzan', 'DeKuyper', 'EFFEN'
        , 'El Tesoro', 'Glen Garioch', 'Hornitos', 'House of Suntory', 'Jim Beam'
        , 'Kilbeggan', 'Knob Creek', 'Larios', 'Laphroaig', 'Legent', 'Little Book', 'Maker\'s Mark'
        , 'Midori', 'On The Rocks', 'Pinnacle', 'Sauza', 'Sipsmith', 'Skinnygirl'
        , 'Suntory ALL FREE', 'Teacher\'s', 'Tres Generaciones', 'Tyrconnell'};
            
    public static final Set<String> Consumer_Response_Brand_Emails = new Set<String>{'info@makersmark.com', 'info@sipsmith.com', 'info@laphroaig.com','consumerinquiries@beamsuntory.com'};
}