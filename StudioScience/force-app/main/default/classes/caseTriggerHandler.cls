/**************************************************************************************
Apex Class Name     : caseTriggerHandler
Created Date        : 1/2016
Function            : Handles events from the caseTrigger trigger
*************************************************************************************/

public class caseTriggerHandler {
    
    /**************************************************************************************************************
    Method name:    handleAfterInsert
    Object:         Case
    Event:          after insert
    Date:           1/2016
    Details and Notes: Handles all after insert triggers
    ***************************************************************************************************************/
    public static void handleBeforeInsert(List<Case> cases) {
        
        // Code added by Nishant Khandal start
        List<Case> caseDTCRecords = new List<Case>();
        
        //Added List, String and Id by Sangeet and Akshat on 04-11-2022
        List<Case> caseBrandRegistrationRecords = new List<Case>();
        List<Case> caseDiscountAndPriceFillingRecords = new List<Case>();
        List<Case> caseOrderClaimAndOCsubcaseRecords = new List<Case>();
        List<Case> caseLogisticRequestRecords = new List<Case>();
        List<Case> caseCSGQualityBillingOrderClaimRecords = new List<Case>();
        List<Case> casSingleBarrelRTIdsRecords = new List<Case>();
        List<Case> caseGbsRecordTypeIdsRecords = new List<Case>();
        List<Case> caseQualityClaimRecords = new List<Case>();
        List<Case> caseQualityClaimSubCaseRecords = new List<Case>();
        List<Case> caseConsumerInquiryRecords = new List<Case>();
        List<Case> caseMarketReadinessRecords = new List<Case>();
        List<Case> caseSubCaseRecords = new List<Case>();
        List<Case> caseConsumerInquiryAndQualityClaimRecords = new List<Case>();
        List<Case> caseSGWS_Control_FranchiseCollaborationRecords = new List<Case>();
        List<Case> caseOrderClaimRecords = new List<Case>();
        //Added by Deekshika 27/06/2023 - update Type Edrington
        List<Case> caseOrdersRecords = new List<Case>();
        
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        String discountRTName = ComplianceConstants.RECORDTYPE_DISCOUNT;
        Id discountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(discountRTName).getRecordTypeId();
        String priceFilingRTName = ComplianceConstants.RECORDTYPE_PRICE_FILING;
        Id priceFilingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(priceFilingRTName).getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ComplianceConstants.RECORDTYPE_SUB_CASE).getRecordTypeId();

        for(Case cse : cases){
            if(cse.recordTypeId == DTC_Constants.CASE_DTC_RECORDTYPEID) {
                caseDTCRecords.add(cse);
            }
            //Added else if by Sangeet on 04-11-2022
            else if(cse.recordTypeId == brandRegistrationRecordTypeId){
                caseBrandRegistrationRecords.add(cse);
            }
            else if(CSConstants.LOGISTICS_REQUEST_RT_ID.equals(cse.RecordTypeId)){
                caseLogisticRequestRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.QC_RT_ID){
                caseQualityClaimRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.QC_SUBCASE_RT_ID){
                caseQualityClaimSubCaseRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID){
                caseConsumerInquiryRecords.add(cse);
            }
            else if(CSConstants.MARKET_READINESS_RT_ID.equals(cse.RecordTypeId)){
                caseMarketReadinessRecords.add(cse);
            }
            else if(cse.RecordTypeId == complianceSubCaseRecordTypeId) {
                caseSubCaseRecords.add(cse);
            }
            
            if(cse.recordTypeId == CSConstants.CSG_QUALITY_CLAIM_RT_ID || cse.recordTypeId == CSConstants.CSG_BILLING_CLAIM_RT_ID || cse.recordTypeId == CSConstants.CSG_ORDER_CLAIM_RT_ID){
                caseCSGQualityBillingOrderClaimRecords.add(cse);
            }
            
            if(cse.recordTypeId == discountRecordTypeId || cse.recordTypeId == priceFilingRecordTypeId){
                caseDiscountAndPriceFillingRecords.add(cse);
            }
            if(CSConstants.orderClaimRecordTypeIds.contains(cse.RecordTypeId)){
                caseOrderClaimAndOCsubcaseRecords.add(cse);
            }
            if(SBP_Constants.caseSingleBarrelRtIds.contains(cse.RecordTypeId)){
                casSingleBarrelRTIdsRecords.add(cse);
            }
            if(GBS_Constants.gbsRecordTypeIds.contains(cse.RecordTypeId)){
                caseGbsRecordTypeIdsRecords.add(cse);
            }
            if(cse.RecordTypeId == CSConstants.Franchise_Collaboration_RT_ID ||
                     cse.RecordTypeId == CSConstants.SGWS_Collaboration_RT_ID ||
                     cse.RecordTypeId == CSConstants.Control_Collaboration_RT_ID) {
                         
                        caseSGWS_Control_FranchiseCollaborationRecords.add(cse);
            }
            if(cse.recordTypeId == CSConstants.ORDER_CLAIM_RT_ID){
                caseOrderClaimRecords.add(cse);
            }
            //Added by Deekshika 27/06/2023 - update Type Edrington
            if(cse.recordTypeId == CSConstants.ORDERS_RT_ID){
                caseOrdersRecords.add(cse);
            }
        }
        
        if(CaseDTCRecords.size() > 0){
            DTC_CaseServices.checkDuplicateOrderId(CaseDTCRecords, null);
            DTC_CaseServices.checkDuplicateOpenReplacementCases(CaseDTCRecords, null);
            DTC_CaseServices.updateCaseOwnerOnTheBasisOFBrand(CaseDTCRecords, null);
            DTC_CaseServices.updateRetailAccount(CaseDTCRecords);
            CaseServices.setDefaultAccountForCSConsumer(CaseDTCRecords);
           	return;
        }
        // Code added by Nishant Khandal End
        
        caseServices.setCaseValues(cases);
        //calling record specific methods
        if(caseBrandRegistrationRecords.size() > 0){
            CaseComplianceUtility.doBrandRegistrationBeforeInsert(caseBrandRegistrationRecords);
        }
        
        if(caseDiscountAndPriceFillingRecords.size() > 0){
            CaseComplianceUtility.setStateManagerEmailOnInsert(caseDiscountAndPriceFillingRecords);
        }
        
        if(caseOrderClaimAndOCsubcaseRecords.size() > 0){
            caseServices.setDefaultAccountForCSClaims(caseOrderClaimAndOCsubcaseRecords);
            caseServices.addEntitlementToCaseDynamic(caseOrderClaimAndOCsubcaseRecords, CSConstants.ORDER_CLAIM_RT_ID);
            caseServices.assignBusinessHoursToCases(caseOrderClaimAndOCsubcaseRecords);
        }
        if(caseOrderClaimRecords.size()>0){
            caseServices.setOrderClaimTriggerWordChecked(caseOrderClaimRecords);
        }
        if(caseLogisticRequestRecords.size() > 0){
           caseServices.addEntitlementToCaseDynamic(caseLogisticRequestRecords, CSConstants.LOGISTICS_REQUEST_RT_ID);
        }
        
        if(caseCSGQualityBillingOrderClaimRecords.size() > 0){
            caseServices.addEntitlementProcessForConsole(caseCSGQualityBillingOrderClaimRecords);
            caseServices.updateRecordTypeOfCSGCases(caseCSGQualityBillingOrderClaimRecords);
        }
        
        if(casSingleBarrelRTIdsRecords.size()>0){
            caseServices.addEntitlementToCaseDynamic(casSingleBarrelRTIdsRecords, SBP_Constants.SINGLE_BARREL_PROOF_SPECIFIC_RT_ID);
            caseServices.updateCaseSubmitterForSingleBarrelCases(casSingleBarrelRTIdsRecords);
            caseServices.updateRegionalDiplomat(casSingleBarrelRTIdsRecords);
            caseServices.updateTimeStampsForSingleBarrelTracker(casSingleBarrelRTIdsRecords, null);
        }
        
        if(caseGbsRecordTypeIdsRecords.size()>0){
            //below method is added in beforeInsert by Sangeet on 14-02-2023
            caseServices.assignAccountToGbsCase(caseGbsRecordTypeIdsRecords, null);
            caseServices.addEntitlementToCaseDynamic(caseGbsRecordTypeIdsRecords, GBS_Constants.GBS_OUTLOOK_RT_ID);
            caseServices.assignGBSBusinessHoursToCase(caseGbsRecordTypeIdsRecords, null);
        }
        
        if(caseQualityClaimRecords.size()>0){
            caseServices.addEntitlementToQualityClaimCase(caseQualityClaimRecords);
            caseServices.setDefaultAccountForCSConsumer(caseQualityClaimRecords);
            caseServices.setDefaultAccountAddressForCSConsumer(caseQualityClaimRecords);
            caseServices.AddingLotCode(caseQualityClaimRecords);
            caseServices.setCasePriority(caseQualityClaimRecords);
        }
        
        if(caseQualityClaimSubCaseRecords.size()>0){
            caseServices.addEntitlementToQualityClaimCase(caseQualityClaimSubCaseRecords);
            caseServices.setDefaultAccountForCSConsumer(caseQualityClaimSubCaseRecords);
            caseServices.setDefaultAccountAddressForCSConsumer(caseQualityClaimSubCaseRecords);
            caseServices.assignBusinessHoursToCases(caseQualityClaimSubCaseRecords);
        }
        
        if(caseConsumerInquiryRecords.size()>0){
            caseServices.addEntitlementToQualityClaimCase(caseConsumerInquiryRecords);
            caseServices.setDefaultAccountForCSConsumer(caseConsumerInquiryRecords);
            caseServices.setDefaultAccountAddressForCSConsumer(caseConsumerInquiryRecords);
            caseServices.setCasePriority(caseConsumerInquiryRecords);
        }
        
        if(caseMarketReadinessRecords.size()>0){
            caseServices.setDefaultAccountForMarketReadiness(caseMarketReadinessRecords);
            caseServices.addEntitlementToCaseDynamic(caseMarketReadinessRecords, CSConstants.MARKET_READINESS_RT_ID);
            caseServices.updatePriorityBasedOnTheTypeFieldValue(caseMarketReadinessRecords);
        }
        
        if(caseSubCaseRecords.size() > 0) {
            CaseComplianceUtility.setComplianceSubCaseStateType(caseSubCaseRecords);
        }
        
        if(caseSGWS_Control_FranchiseCollaborationRecords.size()>0){
            caseServices.updateCaseTypePicklist(caseSGWS_Control_FranchiseCollaborationRecords);
        }
        //Added by Deekshika 27/06/2023 - update Type Edrington
        if(caseOrdersRecords.size() > 0) {
            caseServices.updateCaseType(caseOrdersRecords);
        }

       	caseServices.calculateBusinessHoursAgesOnInsert(cases);
        //method added by Sangeet for convert process builder to trigger on 10-01-23
        caseServices.updateCaseStatus(cases);
    }
        
    
    public static void handleBeforeUpdate(List<Case> cases, Map<Id, Case> oldCases) {
        
		//Added List, String and Id by Sangeet and Akshat on 04-11-2022
        Id registrationApprovalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Registration Approval').getRecordTypeId();
        String brandRegistrationRTName = ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION;
        Id brandRegistrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(brandRegistrationRTName).getRecordTypeId();
        String subCaseRTName = ComplianceConstants.RECORDTYPE_SUB_CASE;
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(subCaseRTName).getRecordTypeId();
        String quoteRequestRTName = ComplianceConstants.RECORDTYPE_QUOTE_REQUEST;
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(quoteRequestRTName).getRecordTypeId();
        String discountRTName = ComplianceConstants.RECORDTYPE_DISCOUNT;
        Id discountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(discountRTName).getRecordTypeId();
        String barrelLaidDownRTName = ComplianceConstants.RECORDTYPE_BARREL_LAID_DOWN;
        Id barrelLaidDownId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(barrelLaidDownRTName).getRecordTypeId();
        
        LIst<Case> caseBarrelLaidDownRecords = new List<Case>();
        List<Case> caseOrderClaimRecords = new List<Case>();
        List<Case> caseOrderClaimSubcaseRecords = new List<Case>();
        List<Case> caseConsumerInquiryRecord = new List<Case>();
        List<Case> caseQualityClaimRecords = new List<Case>();
        List<Case> caseQualityClaimSubcaseRecords = new List<Case>();
        List<Case> caseSingleBarrelStandardRecords = new List<Case>();
        List<Case> caseSingleBarrelProofSpecificRecords = new List<Case>();
        List<Case> caseGbsRecordTypeIdsRecords = new List<Case>();
        List<Case> caseLogisticRequestRecords = new List<Case>();
        List<Case> caseRegistrationApprovalRecords = new List<Case>();
        List<Case> caseBrandRegistrationRecords = new List<Case>();
        List<Case> caseComplianceSubCaseRecords = new List<Case>();
        List<Case> caseEDIorders_Orders_Inquiry_Changes_EscalatedFormRecords = new List<Case>();
        List<Case> caseQuoteRequestRecords = new List<Case>();
        List<Case> caseDiscountRecords = new List<Case>();
        List<Case> caseMarketReadinessRecords = new List<Case>();
        
        //DTCS - 22 Code added by Nishant Khandal start
        List<Case> caseDTCRecords = new List<Case>();
        Set<Case> DHLStatusChangedRecords = new Set<Case>();
        List<Case> caseLaphroaigRecords = new List<Case>();  //Added by Nishant for LSB-166
        for(Case cse : cases){
            
            String recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(cse.recordtypeid).getname();
            
            if(cse.recordTypeId == DTC_Constants.CASE_DTC_RECORDTYPEID) {
                caseDTCRecords.add(cse);
                if(cse.DHL_Status__c != oldCases.get(cse.Id).DHL_Status__c) {
                    DHLStatusChangedRecords.add(cse);
                }
            }
            else if(cse.recordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID){
                caseOrderClaimSubcaseRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.ORDER_CLAIM_RT_ID){
                caseOrderClaimRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID){
                caseConsumerInquiryRecord.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.QC_RT_ID){
                caseQualityClaimRecords.add(cse);
            }

            else if(cse.recordTypeId == CSConstants.BARREL_LAID_DOWN_RT_ID){
                caseBarrelLaidDownRecords.add(cse);
            }
            
            else if(cse.recordTypeId == CSConstants.QC_SUBCASE_RT_ID){
                caseQualityClaimSubcaseRecords.add(cse);
            }
            else if(cse.Case_Record_Type__c == CSConstants.SINGLE_BARREL_STANDARD){
                caseSingleBarrelStandardRecords.add(cse);
            }
            else if(cse.Case_Record_Type__c == CSConstants.SINGLE_BARREL_PROOF_SPECIFIC){
                caseSingleBarrelProofSpecificRecords.add(cse);
            }
            else if(CSConstants.LOGISTICS_REQUEST_RT_ID.equals(cse.RecordTypeId)){
                caseLogisticRequestRecords.add(cse);
            }
            else if(cse.RecordTypeId == registrationApprovalCaseRecordTypeId){
                caseRegistrationApprovalRecords.add(cse);
            }
            else if(cse.RecordTypeId == brandRegistrationRecordTypeId){
                caseBrandRegistrationRecords.add(cse);
            }
            else if(cse.RecordTypeId == complianceSubCaseRecordTypeId){
                caseComplianceSubCaseRecords.add(cse);
            }
            else if(cse.RecordTypeId == quoteRequestRecordTypeId){
                caseQuoteRequestRecords.add(cse);
            }
            else if(cse.RecordTypeId == discountRecordTypeId){
                caseDiscountRecords.add(cse);
            }
            else if(cse.recordTypeId == SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID){  //Added by Nishant for LSB-166 
                caseLaphroaigRecords.add(cse);
            }
            else if(CSConstants.MARKET_READINESS_RT_ID.equals(cse.RecordTypeId)){
                caseMarketReadinessRecords.add(cse);
            }
            
            if(GBS_Constants.gbsRecordTypeIds.contains(cse.RecordTypeId)){
                caseGbsRecordTypeIdsRecords.add(cse);
            }
            if((recordtypename == 'EDI Order') || (recordtypename == 'Orders') || (recordtypename == 'Inquiry') || (recordtypename == 'Changes') || (recordtypename == 'Escalated Form')){
                caseEDIorders_Orders_Inquiry_Changes_EscalatedFormRecords.add(cse);
            }
        }
        
        if(caseLaphroaigRecords.size() > 0){
            SBP_LaphroaigCaseServices.updateSTOCreationDate(caseLaphroaigRecords, (Map<Id, Case>) oldCases); //Added by Nishant for LSB-166
            SBP_LaphroaigCaseServices.updateCaseStatusAndSubStatus(caseLaphroaigRecords, (Map<Id, Case>) oldCases); //For LSB-153
            SBP_LaphroaigCaseServices.updateCaseSubject(caseLaphroaigRecords, (Map<Id, Case>) oldCases);
            caseServices.addEntitlementToCaseDynamic(caseLaphroaigRecords, SBP_Constants.SINGLE_BARREL_LAPHROAIG_RT_ID);
            caseServices.markSingleBarrelMilestonesAsComplete(caseLaphroaigRecords, oldCases);
            caseServices.updateBarrelExpectedShipDate(caseLaphroaigRecords, oldCases);
            caseServices.tripHasBeenScheduled(caseLaphroaigRecords, oldCases);
            caseServices.updateTimeStampsForSingleBarrelTracker(caseLaphroaigRecords, oldCases);
        }
        
        if(CaseDTCRecords.size() > 0){
            DTC_CaseServices.updateCaseStatusShipmentAtWarehouse(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateCaseStatusClosed(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateCaseStatusCommunicateWithDHL(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.checkDuplicateOrderId(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateCaseAdditionalInformation(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.checkDuplicateOpenReplacementCases(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateCaseOwnerOnTheBasisOFBrand(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateNextNotificationDate(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.sendBellNotification(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateStatusAndSubStatus(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.validationOnCaseStatusIsClose(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.updateValidCaseList(caseDTCRecords);
            DTC_CaseServices.sendBellNotificationOnDHLStatusUpdate(DHLStatusChangedRecords);
            DTC_CaseServices.updateSubStatusToBlank(CaseDTCRecords, (Map<Id, Case>) oldCases);
            DTC_CaseServices.sendBellNotificationPhysicalReturnDHL(CaseDTCRecords);
            DTC_CaseServices.checkStatusFlowOfCaseStatusDTC(CaseDTCRecords, (Map<Id, Case>) oldCases); 
            return;
        }
        //DTCS - 22 Code added by Nishant Khandal End
        
        if(caseQualityClaimRecords.size()>0){
            CRM_CaseServices.captureCasePickupTime(caseQualityClaimRecords, oldCases);
        }

        if (caseServices.runTrigger) {  
            
            caseServices.calculateBusinessHoursAgesOnUpdate(cases, oldCases);
            caseServices.updateNumTimesIn3rdParty(cases, oldCases);
            caseServices.updateFlagsOnStatusChange(cases, oldCases);
            //method addded by Sangeet for convert process builder to trigger on 10-01-23
            caseServices.updateCaseStatus(cases);

            if(caseOrderClaimRecords.size()>0){
                caseServices.updateClonedCaseMilestoneOnCaseClosed(caseOrderClaimRecords, oldCases);
                caseServices.addEntitlementToCaseDynamic(caseOrderClaimRecords, CSConstants.ORDER_CLAIM_RT_ID);
                caseServices.assignBusinessHoursToCases(caseOrderClaimRecords);
                caseServices.caseSetStatusChangeWithSLA(caseOrderClaimRecords, oldCases); 
                caseServices.pauseUnpauseMilestoneOnStatusChange(caseOrderClaimRecords,oldCases);
            }
            if(caseBarrelLaidDownRecords.size()>0){
                // from here we will call our service class methor that will update date on subcase
                CaseServices.updateBarrelLaidDownDates(caseBarrelLaidDownRecords, oldCases);
            }
            
            if(caseOrderClaimSubcaseRecords.size()>0){
                caseServices.updateClonedCaseMilestoneOnCaseClosed(caseOrderClaimSubcaseRecords, oldCases);
                caseServices.addEntitlementToCaseDynamic(caseOrderClaimSubcaseRecords, CSConstants.ORDER_CLAIM_SUBCASE_RT_ID);
                caseServices.assignBusinessHoursToCases(caseOrderClaimSubcaseRecords);
                caseServices.emailNonTechnicalResponseToParentCaseOwner(caseOrderClaimSubcaseRecords, oldCases);
            }
            
            if(caseConsumerInquiryRecord.size()>0){
                caseServices.setDefaultAccountAddressForCSConsumer(caseConsumerInquiryRecord);
                caseServices.addEntitlementToQualityClaimCase(caseConsumerInquiryRecord);
                caseServices.updateFlagsOnCICaseChange(caseConsumerInquiryRecord, oldCases);
                //Added by Akshat Jain on 27/04/2023
                caseServices.updateSubStatusOnCase(caseConsumerInquiryRecord, oldCases);
            }
            
            if(caseQualityClaimRecords.size()>0){
                caseServices.setDefaultAccountAddressForCSConsumer(caseQualityClaimRecords);
                caseServices.caseSetStatusChangeWithSLA(caseQualityClaimRecords, oldCases); 
                caseServices.addEntitlementToQualityClaimCase(caseQualityClaimRecords);
                //Added by Akshat Jain on 27/04/2023
                caseServices.updateSubStatusOnCase(caseQualityClaimRecords, oldCases);
                caseServices.updateCaseClosedFieldsOnStatusChanged(caseQualityClaimRecords, oldCases);
                CRM_CaseServices.mandatoryFieldNotBlank(caseQualityClaimRecords, oldCases);
                CRM_CaseServices.updateDateTimeAssignedOnCase(caseQualityClaimRecords, oldCases);
            }
            
            if(caseQualityClaimSubcaseRecords.size()>0){
                caseServices.setDefaultAccountAddressForCSConsumer(caseQualityClaimSubcaseRecords);
                caseServices.emailNonTechnicalResponseToParentCaseOwner(caseQualityClaimSubcaseRecords, oldCases);
                caseServices.emailQualityRecommendationToParentCaseOwner(caseQualityClaimSubcaseRecords, oldCases);
                caseServices.addEntitlementToQualityClaimCase(caseQualityClaimSubcaseRecords);
                caseServices.setQualityClaimTimeStamp(caseQualityClaimSubcaseRecords, oldCases);
                CRM_CaseServices.captureCasePickupTime(caseQualityClaimSubcaseRecords, oldCases);
            }
            
            if(caseSingleBarrelStandardRecords.size()>0){
                caseServices.updateBrandAllocationForSingleBarrel(caseSingleBarrelStandardRecords, oldCases);
                caseServices.addEntitlementToCaseDynamic(caseSingleBarrelStandardRecords, SBP_Constants.SINGLE_BARREL_STANDARD_RT_ID);
                caseServices.moveSingleBarrelCaseStatus(caseSingleBarrelStandardRecords);
                caseServices.markSingleBarrelMilestonesAsComplete(caseSingleBarrelStandardRecords, oldCases);
                caseServices.updateRegionalDiplomat(caseSingleBarrelStandardRecords);
                caseServices.updateBarrelExpectedShipDate(caseSingleBarrelStandardRecords, oldCases);
                caseServices.tripHasBeenScheduled(caseSingleBarrelStandardRecords, oldCases);
                caseServices.updateTimeStampsForSingleBarrelTracker(caseSingleBarrelStandardRecords, oldCases);
            }
            
            if(caseSingleBarrelProofSpecificRecords.size()>0){
                caseServices.updateBrandAllocationForSingleBarrel(caseSingleBarrelProofSpecificRecords, oldCases);
                caseServices.addEntitlementToCaseDynamic(caseSingleBarrelProofSpecificRecords, SBP_Constants.SINGLE_BARREL_PROOF_SPECIFIC_RT_ID);
                caseServices.markSingleBarrelMilestonesAsComplete(caseSingleBarrelProofSpecificRecords, oldCases);
                caseServices.updateRegionalDiplomat(caseSingleBarrelProofSpecificRecords);
                caseServices.updateBarrelExpectedShipDate(caseSingleBarrelProofSpecificRecords, oldCases);
                caseServices.tripHasBeenScheduled(caseSingleBarrelProofSpecificRecords, oldCases);
                caseServices.singleBarrelPurchaseOrderUploaded(caseSingleBarrelProofSpecificRecords, oldCases);
                caseServices.updateTimeStampsForSingleBarrelTracker(caseSingleBarrelProofSpecificRecords, oldCases);
            }
            
            if(caseGbsRecordTypeIdsRecords.size()>0){
                caseServices.updateGBSStatusOnOwnerChange(caseGbsRecordTypeIdsRecords, oldCases);
                caseServices.completeGBSMilestones(caseGbsRecordTypeIdsRecords, oldCases);
                caseServices.assignAccountToGbsCase(caseGbsRecordTypeIdsRecords, oldCases);
                caseServices.addEntitlementToCaseDynamic(caseGbsRecordTypeIdsRecords, GBS_Constants.GBS_OUTLOOK_RT_ID);
                caseServices.checkForReOpenedGBSCase(caseGbsRecordTypeIdsRecords, oldCases);
                caseServices.assignGBSBusinessHoursToCase(caseGbsRecordTypeIdsRecords, oldCases);
            }
            
            if(caseLogisticRequestRecords.size() > 0){
                caseServices.addEntitlementToCaseDynamic(caseLogisticRequestRecords, CSConstants.LOGISTICS_REQUEST_RT_ID);
            }
            
            if(caseRegistrationApprovalRecords.size()>0){
                caseServices.syncSelfRegistrationOwnership(caseRegistrationApprovalRecords, oldCases);
            }
            
            if(caseEDIorders_Orders_Inquiry_Changes_EscalatedFormRecords.size()>0){
                caseServices.caseSetStatusChangeWithSLA(caseEDIorders_Orders_Inquiry_Changes_EscalatedFormRecords, oldCases);
            }
            if(caseMarketReadinessRecords.size()>0){
                caseServices.updatePriorityBasedOnTheTypeFieldValue(caseMarketReadinessRecords);
            }
            
            //caseServices.emailInitialSAPNumberEntered(cases, oldCases); commented by ajeeta to test for barrel ready to enter
            //caseServices.emailEskerPDFs(cases);
        }
        
        if(caseConsumerInquiryRecord.size() > 0){
        caseServices.updateCaseClosedFieldsOnStatusChanged(caseConsumerInquiryRecord, oldCases);
            CRM_CaseServices.mandatoryFieldNotBlank(caseConsumerInquiryRecord, oldCases);
            CRM_CaseServices.updateDateTimeAssignedOnCase(caseConsumerInquiryRecord, oldCases);
        }
        if (CaseComplianceUtility.runCaseComplianceTriggerLogic) {
            
            if(caseBrandRegistrationRecords.size() > 0){
                CaseComplianceUtility.setFlagOnBrandRegistrationBeforeUpdate(caseBrandRegistrationRecords, oldCases);
                CaseComplianceUtility.calculateNumberOfRegistrationsOnSubmission(caseBrandRegistrationRecords, oldCases);
            }
            
            if(caseComplianceSubCaseRecords.size()>0){
                CaseComplianceUtility.closePostingStateWithPostingDate(caseComplianceSubCaseRecords, oldCases);
                CaseComplianceUtility.moveStatustoWaitingForPosting(caseComplianceSubCaseRecords, oldCases);
            }
            
            if(caseQuoteRequestRecords.size()>0){
                CaseComplianceUtility.sendEmailsOnQuoteRequestApproval(caseQuoteRequestRecords, oldCases);
            }
            
            if(caseDiscountRecords.size()>0){
                CaseComplianceUtility.evaluateDiscountApprovalNeeded(caseDiscountRecords, oldCases);
            }
        }
    }
    
    public static void handleAfterInsert(List<Case> cases, Map<Id, Case> newMap) { 
        
        List<Case> caseBarrelReadyToEnterRecords = new List<Case>();
        Id BarrelReadyRId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Barrel_Ready_to_Enter').getRecordTypeId();
        
        for(Case cse: cases){
            if(cse.RecordTypeId == BarrelReadyRId){
                caseBarrelReadyToEnterRecords.add(cse);
            }
        }
        
        caseServices.sendEmailToCollaborators(cases, null);
        
        if(caseBarrelReadyToEnterRecords.size()>0){
            caseServices.updateSingleBarrelParentCaseWithSubcase(caseBarrelReadyToEnterRecords);
        }
        
    }
    
    public static void handleAfterUpdate(List<Case> cases, Map<Id, Case> oldCases) {
        
        String barrelLaidDownRTName = ComplianceConstants.RECORDTYPE_BARREL_LAID_DOWN;
        String singleBarrelProofSpecificRTName = ComplianceConstants.RECORDTYPE_SINGLE_BARREL_PROOF_SPECIFIC;
        String singleBarrelSplitBarrelRTName   = ComplianceConstants.RECORDTYPE_SINGLE_BARREL_SPLIT_BARREL;
        String singleBarrelStandard            = ComplianceConstants.RECORDTYPE_SINGLE_BARREL_STANDARD;
        String laphroaigSingleCaskRTName       = ComplianceConstants.RECORDTYPE_Laphroaig_SINGLE_CASK;
        
        List<Case> caseBrandRegRecords = new List<Case>();
        List<Case> caseStateLicenseRecords = new List<Case>();
        
        //Added by Deekshika 11-11-2022 - Case Trigger Optimization
        List<Case> caseBarrelReadyToEnterRecords = new List<Case>();
        List<Case> caseQualityClaimRecords = new List<Case>();
        List<Case> caseSingleBarrelRecordTypeIds = new List<Case>();
        List<Case> caseComplianceSubCaseRecords = new List<Case>();
        List<Case> caseOrderClaimSubcaseRecords = new List<Case>();
        List<Case> caseOrderClaimRecords = new List<Case>();
        List<Case> caseQualityClaimSubCaseRecords = new List<Case>();
        List<Case> caseCustomerDataSubCaseRecords = new List<Case>();
        List<Case> caseCustomerDataCaseRecords = new List<Case>();
        List<Case> caseLogisticRequestsRecords = new List<Case>();
        List<Case> caseQuoteRequestRecords = new List<Case>();
        List<Case> caseGBSRecords = new List<Case>();
        List<Case> caseParseEmailRecords = new List<Case>();
        List<Case> caseCompleteMilestoneOnCaseCloseRecords = new List<Case>();
        List<Case> caseConsumerInquiryRecords = new List<Case>();
        LIst<Case> caseBarrelLaidDownRecords = new List<Case>();
        List<Case> caseSingleBarrelaAndLaphroaigCaskRecords = new List<Case>();

        Id BarrelReadyRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Barrel Ready to Enter').getRecordTypeId();
        Id complianceSubCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ComplianceConstants.RECORDTYPE_SUB_CASE).getRecordTypeId();
        Id quoteRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ComplianceConstants.RECORDTYPE_QUOTE_REQUEST).getRecordTypeId();
        Id barrelLaidDownId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(barrelLaidDownRTName).getRecordTypeId();
        Id singleBarrelProofSpecificId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(singleBarrelProofSpecificRTName).getRecordTypeId();
        Id singleBarrelSplitBarrelId   = Schema.SObjectType.Case.getRecordTypeInfosByName().get(singleBarrelSplitBarrelRTName).getRecordTypeId();
        Id singleBarrelStandardId      = Schema.SObjectType.Case.getRecordTypeInfosByName().get(singleBarrelStandard).getRecordTypeId();
        Id laphroaigSingleCaskId       = Schema.SObjectType.Case.getRecordTypeInfosByName().get(laphroaigSingleCaskRTName).getRecordTypeId();
        
        for(Case cse : cases){
            
            if(cse.recordTypeId == ComplianceConstants.RECORDTYPE_BRAND_REGISTRATION_ID) {
                caseBrandRegRecords.add(cse);
            }
            else if(cse.recordTypeId == ComplianceConstants.RECORDTYPE_STATE_LICENSE_ID) {
                caseStateLicenseRecords.add(cse);
            }
            else if(cse.RecordTypeId == BarrelReadyRId){
                caseBarrelReadyToEnterRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.QC_RT_ID){
                caseQualityClaimRecords.add(cse);
            }
            else if(cse.recordTypeId == complianceSubCaseRecordTypeId) {
                caseComplianceSubCaseRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.ORDER_CLAIM_SUBCASE_RT_ID){
                caseOrderClaimSubcaseRecords.add(cse);
            }
            else if(cse.RecordTypeId == CSConstants.ORDER_CLAIM_RT_ID){
                caseOrderClaimRecords.add(cse);
            }
            else if(cse.RecordTypeId == CSConstants.LOGISTICS_REQUEST_RT_ID){
                caseLogisticRequestsRecords.add(cse);
            }
            else if(cse.RecordTypeId == CSConstants.QC_SUBCASE_RT_ID){
                caseQualityClaimSubCaseRecords.add(cse);
            }
            else if(cse.RecordTypeId == CSConstants.CUSTOMER_DATA_SUB_CASE_RT_ID){
                caseCustomerDataSubCaseRecords.add(cse);
            }
            else if(cse.RecordTypeId == CSConstants.CUSTOMER_DATA_CASE_RT_ID){
                caseCustomerDataCaseRecords.add(cse);
            }
            else if(cse.RecordTypeId == quoteRequestRecordTypeId){
                caseQuoteRequestRecords.add(cse);
            }
            else if(cse.recordTypeId == CSConstants.BARREL_LAID_DOWN_RT_ID){
                caseBarrelLaidDownRecords.add(cse);
            }
            else if(cse.RecordTypeId == CSConstants.CONSUMER_INQUIRY_RT_ID){
                if(oldCases.get(cse.Id).Status != cse.Status && cse.Status == CRM_Constants.CASE_STATUS_CLOSED 
                   && cse.CaseClosedType__c == CRM_Constants.AGENT_CLOSED && cse.Actual_Closed_Date__c != null){
                       caseConsumerInquiryRecords.add(cse);
                }   
            }
            if (SBP_Constants.caseSingleBarrelRtIds.contains(cse.RecordTypeId)) {
                caseSingleBarrelRecordTypeIds.add(cse);
            }
            if(GBS_Constants.gbsRecordTypeIds.contains(cse.RecordTypeId)){
                caseGBSRecords.add(cse);
            }
            if(cse.RecordTypeId == GBS_Constants.CLAIMS_RT_ID || cse.RecordTypeId == GBS_Constants.TAX_RT_ID ||
                cse.RecordTypeId == GBS_Constants.OTC_BILLING_RT_ID || cse.RecordTypeId == GBS_Constants.TE_RT_ID ||
                cse.RecordTypeId == GBS_Constants.PAYROLL_RT_ID || cse.RecordTypeId == GBS_Constants.PTP_RT_ID ||
                cse.RecordTypeId == GBS_Constants.RTR_RT_ID || cse.RecordTypeId == GBS_Constants.GBS_OUTLOOK_RT_ID){
                    
                caseParseEmailRecords.add(cse);
            }
            if(cse.RecordTypeId == quoteRequestRecordTypeId 
               	|| (CSConstants.orderClaimRecordTypeIds.contains(cse.RecordTypeId)) || (GBS_Constants.gbsRecordTypeIds.contains(cse.RecordTypeId)) 
            	|| (CSConstants.qualityClaimRecordTypeIds.contains(cse.RecordTypeId))){
                caseCompleteMilestoneOnCaseCloseRecords.add(cse);
            }

            if((cse.RecordTypeId == singleBarrelProofSpecificId || cse.RecordTypeId == singleBarrelSplitBarrelId || cse.RecordTypeId == singleBarrelStandardId 
            || cse.RecordTypeId == laphroaigSingleCaskId)) 
            {
               caseSingleBarrelaAndLaphroaigCaskRecords.add(cse);
            }


        }
        
        if (caseServices.runTrigger) {
            caseServices.runTrigger = false;
            
            caseServices.updateCaseTypeAndReassign(cases, oldCases);
            caseServices.removeAbandonedCases(cases, oldCases);
            caseServices.sendEmailToCollaborators(cases, oldCases);
            caseServices.handleBookingUpdate(cases, oldCases);
            caseServices.deletePlantEventsFromCase(cases, oldCases);
            
            
            if(caseSingleBarrelRecordTypeIds.size()>0){
                caseServices.emailInitialSAPNumberEntered(caseSingleBarrelRecordTypeIds, oldCases);
                caseServices.updateSKUAndQuantityOnRelatedBarrels(caseSingleBarrelRecordTypeIds, oldCases);   
            }
            
            if(caseBarrelReadyToEnterRecords.size()>0){
                caseServices.updateSingleBarrelParentCaseWithSubcase(caseBarrelReadyToEnterRecords);
            }
            
            if(caseQualityClaimRecords.size()>0){
                caseServices.createQualityClaimSubCase(caseQualityClaimRecords, oldCases);
                caseServices.updateQualityClaimSubCase(caseQualityClaimRecords, oldCases);
            }
            
            //caseServices.updateBrandAllocationForSingleBarrel(cases, oldCases);
            
            if(caseOrderClaimSubcaseRecords.size() > 0) {
                caseServices.checkRequiredFieldsOnChildForClosingParentCase(caseOrderClaimSubcaseRecords, oldCases);
                caseServices.updateParentCase(caseOrderClaimSubcaseRecords, oldCases);
                caseServices.checkIfCaseWasReopened(caseOrderClaimSubcaseRecords, oldCases);
                caseServices.removeSLAFromCase(caseOrderClaimSubcaseRecords, oldCases);
            }
            
            if(caseOrderClaimRecords.size()>0){
                caseServices.setChildCasesToBePickedUpByAssignmentRules(caseOrderClaimRecords, oldCases);
                caseServices.setChildCaseToExpeditedOrderClaim(caseOrderClaimRecords, oldCases);
                caseServices.checkIfCaseWasReopened(caseOrderClaimRecords, oldCases);
                caseServices.markPreparePlantMilestoneAsCompleted(caseOrderClaimRecords, oldCases);
                caseServices.removeSLAFromCase(caseOrderClaimRecords, oldCases);
            }
            
            if(caseCustomerDataSubCaseRecords.size()>0){
                caseServices.updateParentCase(caseCustomerDataSubCaseRecords, oldCases);
            }
            
            if(caseCustomerDataCaseRecords.size()>0){
                caseServices.updateCustomerDataSubCase(caseCustomerDataCaseRecords, oldCases);
            }
            
            if(caseQualityClaimSubCaseRecords.size()>0){
                caseServices.updateParentCase(caseQualityClaimSubCaseRecords, oldCases);
            }
            if(caseLogisticRequestsRecords.size()>0){
                caseServices.updateParentCase(caseLogisticRequestsRecords, oldCases);
            }
            
			if(caseBarrelLaidDownRecords.size()>0){
                // from here we will call our service class method that will update date on parent case
                CaseServices.updateBarrelLaidDownDatesOnParent(caseBarrelLaidDownRecords, oldCases);
            }
            if(caseGBSRecords.size()>0){
                caseServices.updateReOpenedMilestones(caseGBSRecords, oldCases);
            }
            if(caseParseEmailRecords.size()>0){
                GBS_CaseAssignedSendEmail.parseEmails(caseParseEmailRecords, oldCases);
            }
            if(caseStateLicenseRecords.size() > 0){
                CaseComplianceUtility.stateLicenseStatusChange(json.serialize(cases));
            }
        }
        if(caseBrandRegRecords.size() > 0){
            CaseComplianceUtility.closeComplianceSubcases(json.serialize(cases));
        }
        
        if (CaseComplianceUtility.runCaseComplianceTriggerLogic) {
            CaseComplianceUtility.runCaseComplianceTriggerLogic = false;
            if(caseBrandRegRecords.size() > 0){
                CaseComplianceUtility.doComplianceKickoff(caseBrandRegRecords, oldCases);
                CaseComplianceUtility.kickoffCustomerdata(caseBrandRegRecords, oldCases);
                CaseComplianceUtility.sendEmailOnInFieldChanged(caseBrandRegRecords, oldCases);
                CaseComplianceUtility.isDueDateChanged(caseBrandRegRecords, oldCases);
               
            }
            //CaseComplianceUtility.sendEmailsOnQuoteRequestSubmission(cases, oldCases);
            
            //if(caseComplianceSubCaseRecords.size() > 0) {
                CaseComplianceUtility.doAllChildCasesClosed(caseComplianceSubCaseRecords, oldCases);
            //}
            
        }
        //added If by akshat jain on 18-11-2022
        if(caseConsumerInquiryRecords.size()>0){
            caseServices.sendSurveyEmail(caseConsumerInquiryRecords, oldCases);
        }
        
        if(caseSingleBarrelaAndLaphroaigCaskRecords.size()>0){
            caseServices.updateSampleKitRelatedToCase(caseSingleBarrelaAndLaphroaigCaskRecords, oldCases);
        }

        if(caseCompleteMilestoneOnCaseCloseRecords.size()>0){
            EntitlementsServices.completeMilestoneOnCaseClose(caseCompleteMilestoneOnCaseCloseRecords, oldCases);
        }
    }
}