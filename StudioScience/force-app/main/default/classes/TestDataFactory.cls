@isTest
public class TestDataFactory {
    
    //TOTAL MARKETING PLANS = 31
    //2018 - $10M
    //  2018 US - $7M
    //    2018 US JBW $1M
    //      2018 US JBW American $100K
    //        2018 US JBW American AMR SDP Heritage $30K
    //          2018 US JBW American AMR SDP Heritage Arkansas $5K
    //          2018 US JBW American AMR SDP Heritage Kansas $5K
    //          2018 US JBW American AMR SDP Heritage Louisana $15K
    //        2018 US JBW American AMR SDP Legacy $50K
    //          2018 US JBW American AMR SDP Legacy Massachusetts $20K
    //          2018 US JBW American AMR SDP Legacy Missouri $20K
    //          2018 US JBW American AMR SDP Legacy New Jersey $8K
    //      2018 US JBW Southern $200K
    //        2018 US JBW Southern SOU Central $60K
    //          2018 US JBW Southern SOU Central Illinois $20K
    //          2018 US JBW Southern SOU Central Kentucky $10K
    //          2018 US JBW Southern SOU Central Minnesota $20K
    //        2018 US JBW Southern SOU Eastern $60K
    //          2018 US JBW Southern SOU Eastern Delaware $20K
    //          2018 US JBW Southern SOU Eastern New York Upstate $20K
    //          2018 US JBW Southern SOU Eastern New York Metro $20K
    //        2018 US JBW Southern SOU Western $70K
    //          2018 US JBW Southern SOU Western Alaska $30K
    //          2018 US JBW Southern SOU Western Arizona $20K
    //          2018 US JBW Southern SOU Western Nevada $20K
    //      2018 US JBW National Accounts $200K
    //          2018 US JBW National Accounts On-Premise $100K
    //          2018 US JBW National Accounts Off-Premise $80K
    //      2018 US JBW National Marketing $400K
    //  2018 Mexico - $2M
    //    2018 Mexico JBW $100K
    
    public static Map<String, ID> GetTagsMap() {
        //Retrieve the Tags into a Map using their Name as the key, and ID as value.
        Map<String, ID> mapTags = new Map<String, ID>();        
        List<Tags__c> testTags = [SELECT Id, Name FROM Tags__c];        
        for (Tags__c t : testTags) {
            mapTags.put(t.Name, t.Id);          
        } 
        return mapTags;
    }
    
    public static void createMarketingPlanHierarchy() {
        
        //First create the Tags (Brands and Territories) needed by Marketing Plans. Create a map.
        createTags();       
        Map<String, ID> mapTags = GetTagsMap();
                
        //Get the MP Record Types
        Map<String, ID> mpTypes = BI_UtilityLogic.getRecordTypeNamesByIds( 
            BI_Constants.OBJECT_MARKETINGPLAN, new List<String> {  
                BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED,
                BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED });       
        
        //Create all the Marketing Plans, in top-down order. As they are created, add them to Map using Name as Key, and ID as Value.
        Map<String, ID> plans = new Map<String, ID>();
                
        //Need to create the hierarchy by level, so that parent lookups get set correctly.
        List<MarketingPlan__c> plansToCreate = new List<MarketingPlan__c>();        
        
        //Level 1 - Year
        string currentYear = string.valueof(System.Today().year());
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2018 $10M',currentYear,null,null,null,mapTags.get('null'),mapTags.get('null'),plans.get('null'),10000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 2 - Country
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2018 US $7M',currentYear,'US',null,null,mapTags.get('null'),mapTags.get('null'),plans.get('2018 $10M'),7000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 Mexico $2M',currentYear,'MEX','Mexico','Mexico',mapTags.get('Mexico'),mapTags.get('null'),plans.get('2018 $10M'),2000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 3 - Brand
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2018 Mexico JBW $100K',currentYear,'MEX','Mexico','Mexico',mapTags.get('Mexico'),mapTags.get('Jim Beam White'),plans.get('2018 Mexico $2M'),100000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW $1M',currentYear,'US',null,null,mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US $7M'),1000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 4 - Brand Region
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2018 US JBW American $100K',currentYear,'US','American',null,mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW $1M'),100000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern $200K',currentYear,'US','Southern',null,mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW $1M'),200000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW National Accounts $200K',currentYear,'US','National Accounts',null,mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW $1M'),200000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW National Marketing $400K',currentYear,'US','National Marketing','National Marketing',mapTags.get('National Marketing'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW $1M'),400000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 5 - Brand Division
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Heritage $30K',currentYear,'US','American','AMR SDP Heritage Division',mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American $100K'),30000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Legacy $50K',currentYear,'US','American','AMR SDP Legacy Division',mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American $100K'),50000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Central $60K',currentYear,'US','Southern','SOU Central',mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern $200K'),60000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Eastern $60K',currentYear,'US','Southern','SOU Eastern',mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern $200K'),60000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Western $70K',currentYear,'US','Southern','SOU Western',mapTags.get('null'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern $200K'),70000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW National Accounts On-Premise $100K',currentYear,'US','National Accounts','On-Premise',mapTags.get('On-Premise'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW National Accounts $200K'),100000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW National Accounts Off-Premise $80K',currentYear,'US','National Accounts','Off-Premise',mapTags.get('Off-Premise'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW National Accounts $200K'),80000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 6 - Brand Territory
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Heritage Arkansas $5K',currentYear,'US','American','AMR SDP Heritage Division',mapTags.get('Arkansas'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American AMR SDP Heritage $30K'),5000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Heritage Kansas $5K',currentYear,'US','American','AMR SDP Heritage Division',mapTags.get('Kansas'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American AMR SDP Heritage $30K'),5000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Heritage Louisana $15K',currentYear,'US','American','AMR SDP Heritage Division',mapTags.get('Louisiana'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American AMR SDP Heritage $30K'),15000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Legacy Massachusetts $20K',currentYear,'US','American','AMR SDP Legacy Division',mapTags.get('Massachusetts'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American AMR SDP Legacy $50K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Legacy Missouri $20K',currentYear,'US','American','AMR SDP Legacy Division',mapTags.get('Missouri'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American AMR SDP Legacy $50K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW American AMR SDP Legacy New Jersey $8K',currentYear,'US','American','AMR SDP Legacy Division',mapTags.get('New Jersey'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW American AMR SDP Legacy $50K'),8000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Central Illinois $20K',currentYear,'US','Southern','SOU Central',mapTags.get('Illinois'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Central $60K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Central Kentucky $10K',currentYear,'US','Southern','SOU Central',mapTags.get('Kentucky'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Central $60K'),10000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Central Minnesota $20K',currentYear,'US','Southern','SOU Central',mapTags.get('Minnesota'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Central $60K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Eastern Delaware $20K',currentYear,'US','Southern','SOU Eastern',mapTags.get('Delaware'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Eastern $60K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Eastern New York Upstate $20K',currentYear,'US','Southern','SOU Eastern',mapTags.get('New York Upstate'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Eastern $60K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Eastern New York Metro $20K',currentYear,'US','Southern','SOU Eastern',mapTags.get('New York Metro'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Eastern $60K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Western Alaska $30K',currentYear,'US','Southern','SOU Western',mapTags.get('Alaska'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Western $70K'),30000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Western Arizona $20K',currentYear,'US','Southern','SOU Western',mapTags.get('Arizona'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Western $70K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        plansToCreate.add(MapMarketingPlan('2018 US JBW Southern SOU Western Nevada $20K',currentYear,'US','Southern','SOU Western',mapTags.get('Nevada'),mapTags.get('Jim Beam White'),plans.get('2018 US JBW Southern SOU Western $70K'),20000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED)));
        InsertPlansAndAddToMap(plans, plansToCreate);
    }
    
    public static void InsertPlansAndAddToMap(Map<String, ID> mapPlans, List<MarketingPlan__c> newPlans) {
            
        insert newPlans;
        
        if (mapPlans != null) {
            for (MarketingPlan__c p : newPlans) {
                mapPlans.put(p.Name, p.Id); 
            }                   
        }   
    }
    
    public static MarketingPlan__c MapMarketingPlan(String name, String year, String country, String region, String division1, ID territoryId, ID brandQuality, ID parentPlan, decimal budget, ID recordType) {
        MarketingPlan__c newPlan = new MarketingPlan__c();
        newPlan.Name = name;
        newPlan.ParentMarketingPlan__c = parentPlan;
        newPlan.Year__c = year;
        newPlan.Brand__c = brandQuality;
        newPlan.Country__c = country;
        newPlan.Region__c = region;
        newPlan.Division__c = division1;
        newPlan.Territory__c = territoryId;
        newPlan.Budget__c = budget;
        newPlan.RecordTypeId = recordType;
        return newPlan;
    }
    
    public static Campaign__c MapCampaign(Id parentMarketingPlanId, decimal budget, Date startDate, Date endDate, String currencyCode, ID brandQualityId) {
        System.debug('parentMarketingPlanId is ' + parentMarketingPlanId);
        System.debug('budget is ' + budget);
        System.debug('startDate is '+ startDate);
        System.debug('endDate is '+ endDate);
        System.debug('currencyCode is '+ currencyCode);
        System.debug('brandQualityId is '+ brandQualityId);
        
        Campaign__c c = new Campaign__c();
        c.ParentMarketingPlan__c = parentMarketingPlanId;
        c.InitialStartDate__c = startDate;
        c.InitialEndDate__c = endDate;
        c.PlannedCampaignSpend__c = budget;
        c.CurrencyIsoCode = currencyCode;
        c.Brand_Quality__c = brandQualityId;
        c.Name = 'testcampaign';
        c.CampaignType__c = 'Brand Investment';
        c.GLAccountType__c = 'Agency Fees';
        c.GLDescription__c = 'Agency Fee & Travel – Media';
        c.GLCode__c = '15611';
        return c;    
    }

    public static Campaign_Spend__c MapCampaignSpendPlanning(Id parentCampaignId, String currencyCode, String SpendType) {
        Campaign_Spend__c cs = new Campaign_Spend__c();
        cs.ParentCampaign__c= parentCampaignId;
        cs.CurrencyIsoCode= currencyCode;
        cs.Spend_Type__c= SpendType;
        cs.Notes__c= 'Test Notes'; 
        cs.Customer__c= 'Test Customer'; 
        cs.Vendor__c= 'Test Vendor'; 
        cs.Quantity__c= 1;
        cs.Unit_Cost__c= 2.0; 
        cs.Jan_Budget__c= 10.0;
        cs.Feb_Budget__c= 10.0; 
        cs.Mar_Budget__c= 10.0; 
        cs.Apr_Budget__c= 10.0;
        cs.May_Budget__c= 10.0;
        cs.Jun_Budget__c= 10.0;
        cs.Jul_Budget__c= 10.0;
        cs.Aug_Budget__c= 10.0;
        cs.Sep_Budget__c= 10.0;
        cs.Oct_Budget__c= 10.0;
        cs.Nov_Budget__c= 10.0;
        cs.Dec_Budget__c= 10.0;
        return cs;    
    }
    
    public static MarketingPlanAdjustments__c MapTransferRequest(String comments, Id fromMP, Id toMP, String requestStatus, Decimal amount)
    {
        MarketingPlanAdjustments__c t = new MarketingPlanAdjustments__c();
        t.ReasonforRequest__c = comments;
        t.ReceivingMarketingPlan__c = toMP;
        t.TransferringMarketingPlan__c = fromMP;
        t.Request_Status__c = requestStatus;
        t.Amount__c = amount;
        return t;
    }
    
    public static void createTags() {
                
        //Get RecordTypes
        Id territoryId = BI_UtilityLogic.getRecordTypeId('Tags__c','Territory');
        Id brandId = BI_UtilityLogic.getRecordTypeId('Tags__c','Brand'); 
        Id brandQualityId = BI_UtilityLogic.getRecordTypeId('Tags__c','BrandQuality'); 
        Id pl4BrandId = BI_UtilityLogic.getRecordTypeId('Tags__c','PL4Brand'); 
        
        //Total Tags = 58 + 46 + 46 = 150
        List<Tags__c> tags = new List<Tags__c>();
        
        //Territories - 58. 
        //Need name, segment, and recordtype.
        tags.add(new Tags__c(Name='Alabama',IOCodeSegment__c='01',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Alaska',IOCodeSegment__c='02',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Arizona',IOCodeSegment__c='03',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Arkansas',IOCodeSegment__c='04',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Colorado',IOCodeSegment__c='05',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Connecticut',IOCodeSegment__c='06',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Delaware',IOCodeSegment__c='07',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Florida',IOCodeSegment__c='08',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Georgia',IOCodeSegment__c='09',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Hawaii',IOCodeSegment__c='10',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Idaho',IOCodeSegment__c='11',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Illinois',IOCodeSegment__c='12',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Indiana',IOCodeSegment__c='13',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Iowa',IOCodeSegment__c='14',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Kansas',IOCodeSegment__c='15',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Kentucky',IOCodeSegment__c='16',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Louisiana',IOCodeSegment__c='17',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Maine',IOCodeSegment__c='18',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Maryland',IOCodeSegment__c='19',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Massachusetts',IOCodeSegment__c='20',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Mexico',IOCodeSegment__c='21',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Michigan',IOCodeSegment__c='22',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Minnesota',IOCodeSegment__c='23',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Mississippi',IOCodeSegment__c='24',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Missouri',IOCodeSegment__c='25',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Montana',IOCodeSegment__c='26',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='National Marketing',IOCodeSegment__c='27',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Nebraska',IOCodeSegment__c='28',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Nevada',IOCodeSegment__c='29',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='New Hampshire',IOCodeSegment__c='30',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='New Jersey',IOCodeSegment__c='31',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='New Mexico',IOCodeSegment__c='32',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='New York Metro',IOCodeSegment__c='33',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='New York Upstate',IOCodeSegment__c='34',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='North Carolina',IOCodeSegment__c='35',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='North Dakota',IOCodeSegment__c='36',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Northern California',IOCodeSegment__c='37',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Off-Premise',IOCodeSegment__c='38',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Ohio',IOCodeSegment__c='39',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Ohio LP',IOCodeSegment__c='40',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Oklahoma',IOCodeSegment__c='41',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='On-Premise',IOCodeSegment__c='42',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Oregon',IOCodeSegment__c='43',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Pennsylvania',IOCodeSegment__c='44',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Rhode Island',IOCodeSegment__c='45',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='South Carolina',IOCodeSegment__c='46',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='South Dakota',IOCodeSegment__c='47',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Southern California',IOCodeSegment__c='48',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Tennessee',IOCodeSegment__c='49',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Texas',IOCodeSegment__c='50',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Utah',IOCodeSegment__c='51',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Vermont',IOCodeSegment__c='52',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Virginia',IOCodeSegment__c='53',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Washington',IOCodeSegment__c='54',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Washington D.C.',IOCodeSegment__c='55',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='West Virginia',IOCodeSegment__c='56',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Wisconsin',IOCodeSegment__c='57',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='Wyoming',IOCodeSegment__c='58',RecordTypeId=territoryId));
        
        //Brands -46
        //Need Name, campaignBrand picklist, and recordtype
        tags.add(new Tags__c(Name='2 Gingers',CampaignBrand__c='2 Gingers',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='AO',CampaignBrand__c='AO',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Auchentoshan',CampaignBrand__c='Auchentoshan',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Basil Hayden',CampaignBrand__c='Basil Hayden',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Bowmore',CampaignBrand__c='Bowmore',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Calico Jack',CampaignBrand__c='Calico Jack',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Canadian Club',CampaignBrand__c='Canadian Club',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Cien Anos',CampaignBrand__c='Cien Anos',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Courvoisier',CampaignBrand__c='Courvoisier',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Cruzan',CampaignBrand__c='Cruzan',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='DeKuyper',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Effen',CampaignBrand__c='DeKuyper',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='El Tesoro',CampaignBrand__c='El Tesoro',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Glen Garioch',CampaignBrand__c='Glen Garioch',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Hakushu',CampaignBrand__c='Hakushu',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Hibiki',CampaignBrand__c='Hibiki',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Hornitos',CampaignBrand__c='Hornitos',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Black',CampaignBrand__c='Jim Beam Black',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Devils Cut',CampaignBrand__c='Jim Beam Devils Cut',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Fire',CampaignBrand__c='Jim Beam Fire',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Ghost',CampaignBrand__c='Jim Beam Ghost',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Honey',CampaignBrand__c='Jim Beam Honey',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Maple',CampaignBrand__c='Jim Beam Maple',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam Red Stag',CampaignBrand__c='Jim Beam Red Stag',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Jim Beam White',CampaignBrand__c='Jim Beam White',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Kamora',CampaignBrand__c='Kamora',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Kessler Blend',CampaignBrand__c='Kessler Blend',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Kilbeggan',CampaignBrand__c='Kilbeggan',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Knob Creek',CampaignBrand__c='Knob Creek',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Laphroaig',CampaignBrand__c='Laphroaig',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Maker\'s 46',CampaignBrand__c='Maker\'s 46',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Maker\'s Mark',CampaignBrand__c='Maker\'s Mark',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='McClellands',CampaignBrand__c='McClellands',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Midori',CampaignBrand__c='Midori',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Mozart',CampaignBrand__c='Mozart',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Multibrand',CampaignBrand__c='Multibrand',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Old Grandad',CampaignBrand__c='Old Grandad',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Old Overholt',CampaignBrand__c='Old Overholt',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Pavan',CampaignBrand__c='Pavan',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Pinnacle Vodka',CampaignBrand__c='Pinnacle Vodka',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Sauza',CampaignBrand__c='Sauza',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Sauza 901',CampaignBrand__c='Sauza 901',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Skinnygirl',CampaignBrand__c='Skinnygirl',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Tres Gen',CampaignBrand__c='Tres Gen',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Windsor Canadian',CampaignBrand__c='Windsor Canadian',RecordTypeId=brandId));
        tags.add(new Tags__c(Name='Yamazaki',CampaignBrand__c='Yamazaki',RecordTypeId=brandId));

        insert tags;
        
        tags.clear();
        
        Tags__c testPL4Data = new Tags__c(Name='testPL4Brand',RecordTypeId=pl4BrandId); // test data created for Clone_Campaign_To_Program_Test, pl4brand added for below brand qualities
        insert testPL4Data;
        
        //Retrieve the Brand tags so we can use them to create BrandQuality tags.
        List<Tags__c> brandList = [SELECT Id, Name FROM Tags__c WHERE RecordTypeId = :brandId];
        Map<String, Id> brandMap = new Map<String, ID>();
        for (Tags__c t : brandList) {
            brandMap.put(t.Name, t.Id);         
        }
        
        //Create the Brand Qualities. For simplicity, just create 1 BQ per B, with the exact same naming.
        //46 Brand Quailities
        //Need Name, Brand lookup, segment, and recordtype
        tags.add(new Tags__c(Name='BQ_2 Gingers',Brand__c=brandMap.get('2 Gingers'),IOCodeSegment__c='AAAAA',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_AO',Brand__c=brandMap.get('AO'),IOCodeSegment__c='BBBBB',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Auchentoshan',Brand__c=brandMap.get('Auchentoshan'),IOCodeSegment__c='CCCCC',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Basil Hayden',Brand__c=brandMap.get('Basil Hayden'),IOCodeSegment__c='DDDDD',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Bowmore',Brand__c=brandMap.get('Bowmore'),IOCodeSegment__c='EEEEE',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Calico Jack',Brand__c=brandMap.get('Calico Jack'),IOCodeSegment__c='FFFFF',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Canadian Club',Brand__c=brandMap.get('Canadian Club'),IOCodeSegment__c='GGGGG',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Cien Anos',Brand__c=brandMap.get('Cien Anos'),IOCodeSegment__c='HHHHH',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Courvoisier',Brand__c=brandMap.get('Courvoisier'),IOCodeSegment__c='IIIII',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Cruzan',Brand__c=brandMap.get('Cruzan'),IOCodeSegment__c='JJJJJ',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_DeKuyper',Brand__c=brandMap.get('DeKuyper'),IOCodeSegment__c='KKKKK',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Effen',Brand__c=brandMap.get('Effen'),IOCodeSegment__c='LLLLL',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_El Tesoro',Brand__c=brandMap.get('El Tesoro'),IOCodeSegment__c='MMMMM',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Glen Garioch',Brand__c=brandMap.get('Glen Garioch'),IOCodeSegment__c='NNNNN',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Hakushu',Brand__c=brandMap.get('Hakushu'),IOCodeSegment__c='OOOOO',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Hibiki',Brand__c=brandMap.get('Hibiki'),IOCodeSegment__c='PPPPP',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Hornitos',Brand__c=brandMap.get('Hornitos'),IOCodeSegment__c='QQQQQ',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Black',Brand__c=brandMap.get('Jim Beam Black'),IOCodeSegment__c='RRRRR',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Devils Cut',Brand__c=brandMap.get('Jim Beam Devils Cut'),IOCodeSegment__c='SSSSS',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Fire',Brand__c=brandMap.get('Jim Beam Fire'),IOCodeSegment__c='TTTTT',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Ghost',Brand__c=brandMap.get('Jim Beam Ghost'),IOCodeSegment__c='UUUUU',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Honey',Brand__c=brandMap.get('Jim Beam Honey'),IOCodeSegment__c='VVVVV',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Maple',Brand__c=brandMap.get('Jim Beam Maple'),IOCodeSegment__c='WWWWW',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam Red Stag',Brand__c=brandMap.get('Jim Beam Red Stag'),IOCodeSegment__c='XXXXX',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Jim Beam White',Brand__c=brandMap.get('Jim Beam White'),IOCodeSegment__c='YYYYY',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Kamora',Brand__c=brandMap.get('Kamora'),IOCodeSegment__c='ZZZZZ',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Kessler Blend',Brand__c=brandMap.get('Kessler Blend'),IOCodeSegment__c='AAAAA',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Kilbeggan',Brand__c=brandMap.get('Kilbeggan'),IOCodeSegment__c='AAAA1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Knob Creek',Brand__c=brandMap.get('Knob Creek'),IOCodeSegment__c='BBBB1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Laphroaig',Brand__c=brandMap.get('Laphroaig'),IOCodeSegment__c='CCCC1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Maker\'s 46',Brand__c=brandMap.get('Maker\'s 46'),IOCodeSegment__c='DDDD1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Maker\'s Mark',Brand__c=brandMap.get('Maker\'s Mark'),IOCodeSegment__c='EEEE1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_McClellands',Brand__c=brandMap.get('McClellands'),IOCodeSegment__c='FFFF1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Midori',Brand__c=brandMap.get('Midori'),IOCodeSegment__c='GGGG1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Mozart',Brand__c=brandMap.get('Mozart'),IOCodeSegment__c='HHHH1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Multibrand',Brand__c=brandMap.get('Multibrand'),IOCodeSegment__c='IIII1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Old Grandad',Brand__c=brandMap.get('Old Grandad'),IOCodeSegment__c='JJJJ1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Old Overholt',Brand__c=brandMap.get('Old Overholt'),IOCodeSegment__c='KKKK1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Pavan',Brand__c=brandMap.get('Pavan'),IOCodeSegment__c='LLLL1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Pinnacle Vodka',Brand__c=brandMap.get('Pinnacle Vodka'),IOCodeSegment__c='MMMM1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Sauza',Brand__c=brandMap.get('Sauza'),IOCodeSegment__c='NNNN1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Sauza 901',Brand__c=brandMap.get('Sauza 901'),IOCodeSegment__c='OOOO1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Skinnygirl',Brand__c=brandMap.get('Skinnygirl'),IOCodeSegment__c='PPPP1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Tres Gen',Brand__c=brandMap.get('Tres Gen'),IOCodeSegment__c='QQQQ1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Windsor Canadian',Brand__c=brandMap.get('Windsor Canadian'),IOCodeSegment__c='RRRR1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
        tags.add(new Tags__c(Name='BQ_Yamazaki',Brand__c=brandMap.get('Yamazaki'),IOCodeSegment__c='SSSS1',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
            
        insert tags;        
    }
    
    
    public static void createProgramTranspose() {   // method created for test data of Clone_Campaign_To_Program_Test
        
        List<CampaignToProgramTranspose__c> transposes = new List<CampaignToProgramTranspose__c>();
        //Transposes Campaign to Program.
        transposes.add(new CampaignToProgramTranspose__c(Name='settings1',ChannelType__c='Non-Premise',GL_Description__c='Advanced TV Paid Advertising',ProgramFocus__c='Other',ProgrammingType__c='Other'));
        transposes.add(new CampaignToProgramTranspose__c(Name='settings2',ChannelType__c='Non-Premise',GL_Description__c='Cinema Paid Advertising',ProgramFocus__c='Other',ProgrammingType__c='Other'));
        insert transposes;
    }
    
        //Retrieves plans by name.
    public static Map<String, MarketingPlan__c> retrieveMarketingPlansByName(List<String> names) {
        List<MarketingPlan__c> plans = [SELECT Name, Id, ParentMarketingPlan__c, Year__c, Brand__c, Country__c, Region__c, Division__c, Territory__c, Budget__c, AllocatedBudget__c, Next_IO_Sequence__c  
            FROM MarketingPlan__c 
            WHERE Name IN :names];  
            
        Map<String, MarketingPlan__c> plansByName = new Map<String, MarketingPlan__c>();
        
        for (MarketingPlan__c plan : plans) {
            plansByName.put(plan.Name, plan);
        }
            
        return plansByName;
    }
    
    public static List<Audit_Log__c> retrieveAuditLogs() {
        List<Audit_Log__c> logs = [SELECT Id, Name, Amount_of_Adjustment__c, Marketing_Plan_Transfer__c, New_Total_Value__c, Old_Total_Value__c, Reason_for_Adjustment__c, Related_Campaign_Record__c, Related_Marketing_Plan__c
            FROM Audit_Log__c];
            return logs;
    }

    public static User createBIRunningUserWithCurrencyCode(String currencyCode, String profileName){
        Profile sysAdmin = [SELECT Id, Name FROM Profile WHERE Name=:profileName LIMIT 1];
        User BI_User = new User(firstname = 'BI', lastname = 'User', profileid = sysAdmin.Id, Customer_priority__c = 'VIP', Username = 'BI_TestUser@test.com',
           Email = 'BI_TestUser@test.com', Alias = 'BIUser' , Access_Group__c ='EXTERNAL', TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', 
           EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US', CurrencyIsoCode=currencyCode);
        insert BI_User;
        return BI_User;
    }

    public static void createWBSAUSTags() {
                
        //Get RecordTypes
        Id territoryId = BI_UtilityLogic.getRecordTypeId('Tags__c','Territory');
        Id brandId = BI_UtilityLogic.getRecordTypeId('Tags__c','Brand'); 
        Id brandQualityId = BI_UtilityLogic.getRecordTypeId('Tags__c','BrandQuality'); 
        Id pl4BrandId = BI_UtilityLogic.getRecordTypeId('Tags__c','PL4Brand'); 
        
        //Total Tags = 58 + 46 + 46 = 150
        List<Tags__c> tags = new List<Tags__c>();
        
        //Territories - 58. 
        //Need name, segment, and recordtype.
        tags.add(new Tags__c(Name='NSW',WBSCodeSegment__c='AUSNSW',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='QLD',WBSCodeSegment__c='AUSQLD',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='SA',WBSCodeSegment__c='AUSTSA',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='TAS',WBSCodeSegment__c='AUSTAS',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='VIC',WBSCodeSegment__c='AUSVIC',RecordTypeId=territoryId));
        tags.add(new Tags__c(Name='WA',WBSCodeSegment__c='AUSTWA',RecordTypeId=territoryId));
        
        //Brands -46
        //Need Name, campaignBrand picklist, and recordtype
        tags.add(new Tags__c(Name='Canadian Club',CampaignBrand__c='Canadian Club',WBSCodeSegment__c='CCLB',RecordTypeId=brandId));

        insert tags;
        
        tags.clear();
        
        Tags__c testPL4Data = new Tags__c(Name='testPL4Brand',RecordTypeId=pl4BrandId); // test data created for Clone_Campaign_To_Program_Test, pl4brand added for below brand qualities
        insert testPL4Data;
        
        //Retrieve the Brand tags so we can use them to create BrandQuality tags.
        List<Tags__c> brandList = [SELECT Id, Name FROM Tags__c WHERE RecordTypeId = :brandId];
        Map<String, Id> brandMap = new Map<String, ID>();
        for (Tags__c t : brandList) {
            brandMap.put(t.Name, t.Id);         
        }
        
        //Create the Brand Qualities. For simplicity, just create 1 BQ per B, with the exact same naming.
        //46 Brand Quailities
        //Need Name, Brand lookup, segment, and recordtype
        tags.add(new Tags__c(Name='BQ_Canadian Club',Brand__c=brandMap.get('Canadian Club'),WBSCodeSegment__c='CCL',RecordTypeId=brandQualityId,PL4_Brand__c=testPL4Data.ID));
            
        insert tags;        
    }

    public static void createWBSAUSMarketingPlanHierarchy() {
        
        //First create the Tags (Brands and Territories) needed by Marketing Plans. Create a map.
        createWBSAUSTags();       
        Map<String, ID> mapTags = GetTagsMap();
                
        //Get the MP Record Types
        Map<String, ID> mpTypes = BI_UtilityLogic.getRecordTypeNamesByIds( 
            BI_Constants.OBJECT_MARKETINGPLAN, new List<String> {  
                BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS,
                BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS});       
        
        //Create all the Marketing Plans, in top-down order. As they are created, add them to Map using Name as Key, and ID as Value.
        Map<String, ID> plans = new Map<String, ID>();
                
        //Need to create the hierarchy by level, so that parent lookups get set correctly.
        List<MarketingPlan__c> plansToCreate = new List<MarketingPlan__c>();        
        
        //public static MarketingPlan__c MapMarketingPlan(String name, String year, String country, String region, String division1, ID territoryId, ID brandQuality, ID parentPlan, decimal budget, ID recordType) {


        //Level 1 - Year
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2017 $10M AUD','2017',null,null,null,mapTags.get('null'),mapTags.get('null'),plans.get('null'),10000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 2 - Country
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2017 AUS $7M AUD','2017','AUS',null,null,mapTags.get('null'),mapTags.get('null'),plans.get('2017 $10M AUD'),7000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        //***//
        
        //Level 3 - Brand
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2017 AUS CCL $1M','2017','AUS',null,null,mapTags.get('null'),mapTags.get('Canadian Club'),plans.get('2017 AUS $7M AUD'),1000000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        
        //Level 4 - Brand Region
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2017 AUS CCL Australian $500K','2017','AUS','Australian',null,mapTags.get('null'),mapTags.get('Canadian Club'),plans.get('2017 AUS CCL $1M'),500000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 5 - Brand Division
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2017 AUS CCL Australian CCL BTL $30K','2017','AUS','Australian','CCL BTL Division',mapTags.get('null'),mapTags.get('Canadian Club'),plans.get('2017 AUS CCL Australian $500K'),30000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNPROHIBITED_AUS_WBS)));
        InsertPlansAndAddToMap(plans, plansToCreate);
        
        //Level 6 - Brand Territory
        plansToCreate.clear();
        plansToCreate.add(MapMarketingPlan('2017 AUS CCL Australian CCL BTL NSW $5K','2017','AUS','Australian','CCL BTL Division',mapTags.get('NSW'),mapTags.get('Canadian Club'),plans.get('2017 AUS CCL Australian CCL BTL $30K'),5000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS)));
        plansToCreate.add(MapMarketingPlan('2017 AUS CCL Australian CCL BTL VIC $10K','2017','AUS','Australian','CCL BTL Division',mapTags.get('VIC'),mapTags.get('Canadian Club'),plans.get('2017 AUS CCL Australian CCL BTL $30K'),10000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS)));
        plansToCreate.add(MapMarketingPlan('2017 AUS CCL Australian CCL BTL QLD $15K','2017','AUS','Australian','CCL BTL Division',mapTags.get('QLD'),mapTags.get('Canadian Club'),plans.get('2017 AUS CCL Australian CCL BTL $30K'),15000, mpTypes.get(BI_Constants.RECORDTYPE_MP_CAMPAIGNALLOWED_AUS_WBS)));
        InsertPlansAndAddToMap(plans, plansToCreate);
    }

    static Integer idCounter = 1;
    public static String getFakeId(Schema.SObjectType sot)
    {
        String result = String.valueOf(idCounter);
        idCounter ++;
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }
}