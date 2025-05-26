public without sharing class BI_CampaignIntegrationLogic {
	public static String FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    public static List<CampaignIOResult> generateIOCodes(set<Id> campaignIds) {        
        System.debug(LoggingLevel.INFO,'Entered BI_CampaignIntegrationLogic.generateIOCodes');
        System.debug(LoggingLevel.INFO,'# Campaigns passed in: ' + campaignIds.size());
        
        //Retrieve all the Campaigns grouped by parent Marketing Plan. Assure all other info
        //needed to generate IO codes is retrieved.
        Map<Id, BI_IOSequenceGroup> groups = GetIOGroupings(campaignIds);
        List<CampaignIOResult> results = new List<CampaignIOResult>();
        List<Campaign__c> updateCampaigns = new List<Campaign__c>();     
        List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c>();             
        
        //Foreach grouping, generate the IO codes, update the Campaigns, and update the parent Marketing Plan with next sequence number.
        for (BI_IOSequenceGroup gr : groups.values()) {
            Integer mpNextAvailableSequence = gr.Sequence;
            Integer countSuccessful = 0;
            
            for (CampaignIOResult cr : gr.CampaignResults) {				
                String ioCodeWithoutSegment = GenerateIOCodeOrError(cr);
                
                System.debug('io code is '+(ioCodeWithoutSegment + padSequenceNumber(mpNextAvailableSequence)));
                if (!String.isBlank(ioCodeWithoutSegment) && (cr.Campaign.RequestStatus__c != EXT_BI_CampaignHelper.STATUS_IO_REJECTED) && (cr.Campaign.RequestStatus__c != EXT_BI_CampaignHelper.STATUS_IO_CREATED)) {
                    cr.Campaign.IOCode__c = ioCodeWithoutSegment + padSequenceNumber(mpNextAvailableSequence);
                    cr.Campaign.RequestStatus__c = EXT_BI_CampaignHelper.STATUS_IO_PENDING;
                    updateCampaigns.add(cr.Campaign);
                    if(ioCodeWithoutSegment != null){
                        mpNextAvailableSequence++;
                    }
                    countSuccessful++;
                }
                if (String.isBlank(ioCodeWithoutSegment) && (cr.Campaign.RequestStatus__c == EXT_BI_CampaignHelper.STATUS_IO_REJECTED)){
                    cr.Campaign.RequestStatus__c = EXT_BI_CampaignHelper.STATUS_IO_PENDING;
                    cr.Campaign.Request_Status_Message__c = '';
                    updateCampaigns.add(cr.Campaign);
                } 
                results.add(cr);		
            }
            
            if (countSuccessful > 0) {
                MarketingPlan__c planToUpdate = new MarketingPlan__c();
                planToUpdate.Id = gr.MarketingPlanId;
                planToUpdate.Next_IO_Sequence__c = gr.Sequence + countSuccessful;
                updatePlans.add(planToUpdate);		
            }	
        }
        
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {  			
            
            //TODO: maybe handle partial transactions?
            //Try to update all the Campaigns with their new IO Codes and IO Pending status.
            update updateCampaigns; 			
            
            //TODO: maybe handle partial transactions?
            //Try to update all the Marketing Plans with Next Available Sequence number.
            update updatePlans;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO,'Exception caught trying to update Campaigns and Marketing Plans: ' + e.getMessage());
            
            //Rollback to the savepoint.
            Database.rollback(sp); 				
            
            //Simply add errors on all the Results
            //TODO: maybe handle partial transactions?
            for (CampaignIOResult cior : results) {
                cior.IsSuccess = false;  				
                cior.Message = getFriendlyErrorIO(e.getMessage());  
            }		
        }
        
        return results;		 		
    }

	public static List<CampaignWBSResult> generateWBSCodes(set<Id> campaignIds) {        
        System.debug(LoggingLevel.INFO,'Entered BI_CampaignIntegrationLogic.generateWBSCodes');
        System.debug(LoggingLevel.INFO,'# Campaigns passed in: ' + campaignIds.size());
  		
  		//Retrieve all the Campaigns grouped by parent Marketing Plan. Assure all other info
  		//needed to generate IO codes is retrieved.
  		Map<Id, BI_WBSSequenceGroup> groups = GetWBSGroupings(campaignIds);
  		List<CampaignWBSResult> results = new List<CampaignWBSResult>();
  		List<Campaign__c> updateCampaigns = new List<Campaign__c>();     
  		List<MarketingPlan__c> updatePlans = new List<MarketingPlan__c>();             
  		                                 		 		
  		//Foreach grouping, generate the IO codes, update the Campaigns, and update the parent Marketing Plan with next sequence number.
  		for (BI_WBSSequenceGroup gr : groups.values()) {
  			Integer mpNextAvailableSequence = gr.Sequence;
  			Integer countSuccessful = 0;
  			
  			for (CampaignWBSResult cr : gr.CampaignResults) {
  				
  				String wbsCodeWithoutSegment = GenerateWBSCodeOrError(cr);                
                
                System.debug('wbs code is '+(wbsCodeWithoutSegment + padSequenceNumber(mpNextAvailableSequence)));
                if (!String.isBlank(wbsCodeWithoutSegment) && (cr.Campaign.RequestStatus__c != EXT_BI_CampaignHelper.STATUS_WBS_REJECTED) &&(cr.Campaign.RequestStatus__c != EXT_BI_CampaignHelper.STATUS_WBS_CREATED)) {
                    cr.Campaign.WBSCode__c = wbsCodeWithoutSegment + padSequenceNumber(mpNextAvailableSequence);
                    cr.Campaign.RequestStatus__c = EXT_BI_CampaignHelper.STATUS_WBS_PENDING;
                    updateCampaigns.add(cr.Campaign);
                    if(wbsCodeWithoutSegment != null){
                        mpNextAvailableSequence++;
                    }
                    countSuccessful++;
                }
                if (String.isBlank(wbsCodeWithoutSegment) && (cr.Campaign.RequestStatus__c == EXT_BI_CampaignHelper.STATUS_WBS_REJECTED)){
                    cr.Campaign.RequestStatus__c = EXT_BI_CampaignHelper.STATUS_WBS_PENDING;
                    cr.Campaign.Request_Status_Message__c = '';
                    updateCampaigns.add(cr.Campaign);
                } 
                results.add(cr);		
  			}
  			
  			if (countSuccessful > 0) {
  				MarketingPlan__c planToUpdate = new MarketingPlan__c();
  				planToUpdate.Id = gr.MarketingPlanId;
  				planToUpdate.Next_IO_Sequence__c = gr.Sequence + countSuccessful;
  				updatePlans.add(planToUpdate);		
  			}	
  		}
  		
  		// Create a savepoint
  		Savepoint sp;
  		if(!Test.isRunningTest()){
			sp = Database.setSavepoint();
  		}
  		try {  			
			
			//TODO: maybe handle partial transactions?
  			//Try to update all the Campaigns with their new IO Codes and IO Pending status.
  			update updateCampaigns;		
  			
  			//TODO: maybe handle partial transactions?
  			//Try to update all the Marketing Plans with Next Available Sequence number.
  			update updatePlans;

  			//
  			if(!Test.isRunningTest()){
				//BI_WBSCalloutUtility.makeCallout(campaignIds);
  			}
  		} catch (Exception e) {
  			System.debug(LoggingLevel.INFO,'Exception caught trying to update Campaigns and Marketing Plans: ' + e.getMessage());
  			
  			//Rollback to the savepoint.
			if(!Test.isRunningTest()){
	  			Database.rollback(sp); 				
  			}

  			//Simply add errors on all the Results
  			//TODO: maybe handle partial transactions?
  			for (CampaignWBSResult cwbsr : results) {
  				cwbsr.IsSuccess = false;  				
  				cwbsr.Message = getFriendlyErrorWBS(e.getMessage());  
  			}		
  		}
  		return results;		 		
	}
	
	private static String getFriendlyErrorIO(String msg) {
		String defaultMsg = 'A problem occurred while attempting to update Campaign\'s IO Code or update master Marketing Plan\'s Next Available Sequence. All transactions have been reverted.';	
		if (msg == null) { return defaultMsg; }
		
		//Inspect the Exception to determine if a Duplicate IO Code was created.
		if (msg.contains('DUPLICATE_VALUE') == true) { return BI_Constants.IO_DUPLICATE; }
		if (msg.contains(FIELD_CUSTOM_VALIDATION_EXCEPTION)) { return FIELD_CUSTOM_VALIDATION_EXCEPTION +':'+ msg.substringAfter(FIELD_CUSTOM_VALIDATION_EXCEPTION+','); }
		
		return defaultMsg + '<br/><br/> Exception: ' + msg;
	}

	private static String getFriendlyErrorWBS(String msg) {
		String defaultMsg = 'A problem occurred while attempting to update Campaign\'s WBS Code or update master Marketing Plan\'s Next Available Sequence. All transactions have been reverted.';	
		if (msg == null) { return defaultMsg; }
		
		//Inspect the Exception to determine if a Duplicate IO Code was created.
		if (msg.contains('DUPLICATE_VALUE') == true) { return BI_Constants.WBS_DUPLICATE; }
		if (msg.contains(FIELD_CUSTOM_VALIDATION_EXCEPTION)) { return FIELD_CUSTOM_VALIDATION_EXCEPTION +':'+ msg.substringAfter(FIELD_CUSTOM_VALIDATION_EXCEPTION+','); }
		
		return defaultMsg + '<br/><br/> Exception: ' + msg;
	}	
	
	private static String GenerateIOCodeOrError(CampaignIOResult cr) {
		if (!IsCampaignValidForIOGeneration(cr)) {
			return null;	
		}		
		
        	cr.IsSuccess = true;
		String ioCode = String.format('{0}{1}{2}', new List<String>{
			cr.Campaign.Brand_Quality__r.IOCodeSegment__c,
			cr.Campaign.Year__c.right(2),			
			cr.Campaign.ParentMarketingPlan__r.Territory__r.IOCodeSegment__c });	
					
		return ioCode;
	}

	private static String GenerateWBSCodeOrError(CampaignWBSResult cr) {
		
		if (!IsCampaignValidForWBSGeneration(cr)) {
			return null;	
		}		

		WBS_Country_Codes__c currCountryCode = WBS_Country_Codes__c.getInstance(cr.Campaign.Country__c);
		String countryCode = currCountryCode != null && currCountryCode.Country_Code__c != null ? currCountryCode.Country_Code__c : cr.Campaign.Country__c.left(2);
		
		String wbsCode = String.format('{0}{1}{2}{3}', new List<String>{
			countryCode,
			cr.Campaign.Year__c.right(2),
			cr.Campaign.Brand_Quality__r.WBSCodeSegment__c,
			cr.Campaign.ParentMarketingPlan__r.Territory__r.WBSCodeSegment__c });	
					
		return wbsCode;
	}
	
	private static Boolean IsCampaignValidForIOGeneration(CampaignIOResult cr) {
		
		//Validate CR not null
		if (cr == null) { return false; }
		
		
		//validate campaign not null
		if (cr.Campaign == null) {
			cr.IsSuccess = false;
			cr.Message = 'Trouble retrieving Campaign information. Please try again.';
			return false;
		}
		
        //As per new functionality we don't validate IO Code, we just generate new IO Code if it is not generated else we proceed with existing IO Code
		//Validate IO code doesn't already exist.
		/*if (!String.isBlank(cr.Campaign.IOCode__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_ALREADYHASIO; 
			return false;
		}*/
		
		//Validate Year is populated.
		if (cr.Campaign.Year__c == null) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_YEAR_MISSING; 
			return false;
		}
		
		//Validate SAP Controlling Area is populated.
		if (String.isBlank(cr.Campaign.SAP_Controlling_Area__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_SAP_CONTROLLINGAREA; 
			return false;
		}
		
		//Validate SAP Company Code is populated.
		if (String.isBlank(cr.Campaign.SAP_Company_Code__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_SAP_COMPANYCODE;
			return false;
		}
		
		//Validate SAP Cost Center is populated.
		if (String.isBlank(cr.Campaign.SAP_Cost_Center__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_SAP_COSTCENTER; 
			return false;
		}
		
		//Validate Brand Quality is populated.
		if (cr.Campaign.Brand_Quality__r == null || 
			String.isBlank(cr.Campaign.Brand_Quality__r.IOCodeSegment__c) ||
			cr.Campaign.Brand_Quality__r.IOCodeSegment__c.length() != 5) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_BRANDQUALITY; 
			return false;
		}

		//Validate Territory is populated on parent marketing plan.
		if (cr.Campaign.ParentMarketingPlan__r == null ||
			cr.Campaign.ParentMarketingPlan__r.Territory__r == null || 
			String.isBlank(cr.Campaign.ParentMarketingPlan__r.Territory__r.IOCodeSegment__c) ||
			cr.Campaign.ParentMarketingPlan__r.Territory__r.IOCodeSegment__c.length() != 2) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.IO_TERRITORY; 
			return false;	
		}
		
		//TODO: validate we have all fields.
		cr.IsSuccess = true;
		return true;
	}	

	private static Boolean IsCampaignValidForWBSGeneration(CampaignWBSResult cr) {
		
		//Validate CR not null
		if (cr == null) { return false; }
		
		
		//validate campaign not null
		if (cr.Campaign == null) {
			cr.IsSuccess = false;
			cr.Message = 'Trouble retrieving Campaign information. Please try again.';
			return false;
		}
		
        //As per new functionality we don't validate WBS Code, we just generate new WBS Code if it is not generated else we proceed with existing WBS Code		
		//Validate WBS code doesn't already exist.
		/*if (!String.isBlank(cr.Campaign.WBSCode__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_ALREADYHASWBS; 
			return false;
		}*/
		
		//Validate Year is populated.
		if (cr.Campaign.Year__c == null) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_YEAR_MISSING; 
			return false;
		}
		
		//Validate SAP Controlling Area is populated.
		if (String.isBlank(cr.Campaign.SAP_Controlling_Area__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_SAP_CONTROLLINGAREA; 
			return false;
		}
		
		//Validate SAP Company Code is populated.
		if (String.isBlank(cr.Campaign.SAP_Company_Code__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_SAP_COMPANYCODE;
			return false;
		}
		
		//Validate SAP Cost Center is populated.
		if (String.isBlank(cr.Campaign.SAP_Cost_Center__c)) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_SAP_COSTCENTER; 
			return false;
		}

		//Validate Brand Quality is populated.
		if (cr.Campaign.Brand_Quality__r == null || 
			String.isBlank(cr.Campaign.Brand_Quality__r.WBSCodeSegment__c) ||
			cr.Campaign.Brand_Quality__r.WBSCodeSegment__c.length() != 3) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_BRANDQUALITY; 
			return false;
		}

		//Validate Brand is populated.
		if (cr.Campaign.ParentMarketingPlan__r.Brand__r == null || 
			String.isBlank(cr.Campaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c) ||
			cr.Campaign.ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c.length() != 4) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_BRAND; 
			return false;
		}
		
		//Validate Territory is populated on parent marketing plan.
		if (cr.Campaign.ParentMarketingPlan__r == null ||
			cr.Campaign.ParentMarketingPlan__r.Territory__r == null || 
			String.isBlank(cr.Campaign.ParentMarketingPlan__r.Territory__r.WBSCodeSegment__c) ||
			cr.Campaign.ParentMarketingPlan__r.Territory__r.WBSCodeSegment__c.length() != 6) {
			cr.IsSuccess = false;
			cr.Message = BI_Constants.WBS_TERRITORY; 
			return false;	
		}
		
		//TODO: validate we have all fields.
		cr.IsSuccess = true;
		return true;
	}
	
	private static Map<Id, BI_IOSequenceGroup> GetIOGroupings(set<Id> campaignIds) {
		
		List<Campaign__c> camps  = [SELECT Id, Name, Year__c, IOCode__c, RequestStatus__c,
			Brand_Quality__r.IOCodeSegment__c,
			SAP_Controlling_Area__c,
			SAP_Company_Code__c,
			SAP_Cost_Center__c,
			ParentMarketingPlan__c,			 
			ParentMarketingPlan__r.Territory__r.IOCodeSegment__c,  
			ParentMarketingPlan__r.Next_IO_Sequence__c 
			FROM Campaign__c
			WHERE Id IN :campaignIds];
			
		//Temp storage for unique MPs.		
		Map<Id, BI_IOSequenceGroup> groupings = new Map<Id, BI_IOSequenceGroup>();
		
		for (Campaign__c c : camps) {
			
			BI_IOSequenceGroup temp = groupings.get(c.ParentMarketingPlan__c);
								
			if (temp == null) {	
				
				//If we dont already have a MarketingPlanSequence for the parent Plan, create one.				
				temp = new BI_IOSequenceGroup();
				temp.MarketingPlanId = c.ParentMarketingPlan__c;
				temp.Sequence = getSequenceSafely(c.ParentMarketingPlan__r.Next_IO_Sequence__c);
				temp.CampaignResults.add(new CampaignIOResult(c));
				groupings.put(c.ParentMarketingPlan__c, temp);
				
			} else {
				
				//We already have one, simply add the Campaign to the list.
				temp.CampaignResults.add(new CampaignIOResult(c));
			}			 
		} 					
		
		return groupings;
	}

	private static Map<Id, BI_WBSSequenceGroup> GetWBSGroupings(Set<Id> campaignIds) {
		
		List<Campaign__c> camps  = [SELECT Id, Name, Year__c, WBSCode__c, RequestStatus__c,
			Brand_Quality__r.WBSCodeSegment__c, Country__c,
			SAP_Controlling_Area__c,
			SAP_Company_Code__c,
			SAP_Cost_Center__c,
			ParentMarketingPlan__c,			 
			ParentMarketingPlan__r.Territory__r.WBSCodeSegment__c,  
			ParentMarketingPlan__r.Next_IO_Sequence__c,
			ParentMarketingPlan__r.Brand__r.WBSCodeSegment__c 
			FROM Campaign__c
			WHERE Id IN :campaignIds];
			
		//Temp storage for unique MPs.		
		Map<Id, BI_WBSSequenceGroup> groupings = new Map<Id, BI_WBSSequenceGroup>();
		
		for (Campaign__c c : camps) {
			
			BI_WBSSequenceGroup temp = groupings.get(c.ParentMarketingPlan__c);
								
			if (temp == null) {	
				
				//If we dont already have a MarketingPlanSequence for the parent Plan, create one.				
				temp = new BI_WBSSequenceGroup();
				temp.MarketingPlanId = c.ParentMarketingPlan__c;
				temp.Sequence = getSequenceSafely(c.ParentMarketingPlan__r.Next_IO_Sequence__c);
				temp.CampaignResults.add(new CampaignWBSResult(c));
				groupings.put(c.ParentMarketingPlan__c, temp);
				
			} else {
				
				//We already have one, simply add the Campaign to the list.
				temp.CampaignResults.add(new CampaignWBSResult(c));
			}			 
		} 					
		
		return groupings;
	}
	
	private static Integer getSequenceSafely(Decimal sequence) {
		if (sequence == null || sequence <= 0) { 
			return 1; 
		} else {
			return sequence.intValue(); 
		}			
	}	
	
	private static String padSequenceNumber(Integer sequence) {		
		if (sequence == null) {
			 return '001';	
		} else {
			return String.valueOf(sequence).leftPad(3).replaceAll(' ','0');			
		}	
	}
}