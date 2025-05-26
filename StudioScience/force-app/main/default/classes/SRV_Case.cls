/**
    @company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 17/02/2020
    @description This is service class for case object.
*/
public class SRV_Case {
    
    /**
    *  @description : This method is use to fetch data for all the picklist values required by contact us component.
    *  @args        : String Brand
    *  @return      : Map<String,Object>
    **/
    public static Map<String,Object> getPickListValues(String brand){
        if(String.isEmpty(brand)) {
            throw new CS_CustomException('Brand cannot be empty.');
        }
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, List<String>> categoryHelpMap = new Map<String, List<String>>();
        Map<String, Object> productVisibiltyMap = new Map<String, Object>();
        List<Brand_Category_Help_Mapping__mdt> brandCategoryHelpList = SLT_CustomMetadata.getBrandCategoryHelpListByBrand(brand);
        for(Brand_Category_Help_Mapping__mdt categoryHelp : brandCategoryHelpList) {
            //Data preparation for how can we help you and additional information
            if(categoryHelpMap.containsKey(categoryHelp.How_Can_We_Help_You__c)) {
                List<String> lstAdditionalInfo = categoryHelpMap.get(categoryHelp.How_Can_We_Help_You__c);
                lstAdditionalInfo.add(categoryHelp.AdditionalInformation__c);
                categoryHelpMap.put(categoryHelp.How_Can_We_Help_You__c, lstAdditionalInfo);
            } else {
                categoryHelpMap.put(categoryHelp.How_Can_We_Help_You__c, new List<String> {categoryHelp.AdditionalInformation__c});
            }
            
            //keys for setting up product visibility
            String key = String.isNotEmpty(categoryHelp.AdditionalInformation__c) ? 
                categoryHelp.How_Can_We_Help_You__c + ' - ' + categoryHelp.AdditionalInformation__c : 
            categoryHelp.How_Can_We_Help_You__c;
            productVisibiltyMap.put(key, categoryHelp.Is_Product_Visible__c);
        }
        if(!productVisibiltyMap.isEmpty())
            responseMap.put('isProductVisible', productVisibiltyMap);
        
        List<Brand_Product_Mapping__mdt> brandProductsMDT = SLT_CustomMetadata.getBrandProductMappingByBrand(brand);
        if(brandProductsMDT.size() > 0)
            responseMap.put(brand, brandProductsMDT);
        List<Issue_Type__mdt> issueLstMDT = SLT_CustomMetadata.getIssuetypeList();
        if(issueLstMDT.size() > 0)
            responseMap.put('Issue__c', issueLstMDT);
        List<Brand_Lot_Code_Setting__mdt> lotCodeResourceMDT = SLT_CustomMetadata.getLotCodeResourceByBrand(brand);
        responseMap.put('lotCodeResource', lotCodeResourceMDT.isEmpty() ? 'jimBeamLotCode' : lotCodeResourceMDT[0].Static_Resource_Name__c);
        //responseMap.put('lotCodeResource', lotCodeResourceMDT);
        responseMap.put('BrandCategoryHelpMapping__c', new List<Object>{ categoryHelpMap });
        responseMap.put('Country_of_Interest__c', getPicklistData('Country_of_Interest__c'));
        responseMap.put('Product_Size__c', getPicklistData('Product_Size__c'));
        responseMap.put('Do_you_still_have_the_product__c', getPicklistData('Do_you_still_have_the_product__c'));
        responseMap.put('productPackagingIssue', SLT_CustomMetadata.getTranslatedProductPackaging());
        responseMap.put('Damage_Issue__c', getPicklistData('Damage_Issue__c'));
        return responseMap;
    }
    
    public static Map<String,Object> getPickListValuesForLwc(String brand){
        if(String.isEmpty(brand)) {
            throw new CS_CustomException('Brand cannot be empty.');
        }
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, List<String>> categoryHelpMap = new Map<String, List<String>>();
        Map<String, Object> productVisibiltyMap = new Map<String, Object>();
        List<Brand_Category_Help_Mapping__mdt> brandCategoryHelpList = SLT_CustomMetadata.getBrandCategoryHelpListByBrand(brand);
        for(Brand_Category_Help_Mapping__mdt categoryHelp : brandCategoryHelpList) {
            //Data preparation for how can we help you and additional information
            if(categoryHelpMap.containsKey(categoryHelp.How_Can_We_Help_You__c)) {
                List<String> lstAdditionalInfo = categoryHelpMap.get(categoryHelp.How_Can_We_Help_You__c);
                lstAdditionalInfo.add(categoryHelp.AdditionalInformation__c);
                categoryHelpMap.put(categoryHelp.How_Can_We_Help_You__c, lstAdditionalInfo);
            } else {
                categoryHelpMap.put(categoryHelp.How_Can_We_Help_You__c, new List<String> {categoryHelp.AdditionalInformation__c});
            }
            
            //keys for setting up product visibility
            String key = String.isNotEmpty(categoryHelp.AdditionalInformation__c) ? 
                categoryHelp.How_Can_We_Help_You__c + ' - ' + categoryHelp.AdditionalInformation__c : 
            categoryHelp.How_Can_We_Help_You__c;
            productVisibiltyMap.put(key, categoryHelp.Is_Product_Visible__c);
        }
        if(!productVisibiltyMap.isEmpty())
            responseMap.put('isProductVisible', productVisibiltyMap);
        
        List<Brand_Product_Mapping__mdt> brandProductsMDT = SLT_CustomMetadata.getBrandProductMappingByBrand(brand);
        if(brandProductsMDT.size() > 0)
            responseMap.put(brand, brandProductsMDT);
        List<Issue_Type__mdt> issueLstMDT = SLT_CustomMetadata.getIssuetypeList();
        if(issueLstMDT.size() > 0)
            responseMap.put('Issue__c', issueLstMDT);
        List<Brand_Lot_Code_Setting__mdt> lotCodeResourceMDT = SLT_CustomMetadata.getLotCodeResourceByBrand(brand);
        //responseMap.put('lotCodeResource', lotCodeResourceMDT.isEmpty() ? 'jimBeamLotCode' : lotCodeResourceMDT[0].Static_Resource_Name__c);
        responseMap.put('lotCodeResource', lotCodeResourceMDT);
        responseMap.put('BrandCategoryHelpMapping__c', new List<Object>{ categoryHelpMap });
        responseMap.put('Country_of_Interest__c', getPicklistData('Country_of_Interest__c'));
        responseMap.put('Product_Size__c', getPicklistData('Product_Size__c'));
        responseMap.put('Do_you_still_have_the_product__c', getPicklistData('Do_you_still_have_the_product__c'));
        responseMap.put('productPackagingIssue', SLT_CustomMetadata.getTranslatedProductPackaging());
        responseMap.put('Damage_Issue__c', getPicklistData('Damage_Issue__c'));
        return responseMap;
    }

    /**
    *  @description : This method is use to create case.
    *  @args        : Case caseObj, String caseId, Boolean isComplaint, String reCaptchaResponse, Account accountObj, String accountId
    *  @return      : Map<String, Object>
    **/
    public static Map<String, Object> createCase(Case caseObj, String caseId, Boolean isComplaint, String reCaptchaResponse, Account accountObj, String accountId, List<String> documentId) {
        Map<String, Object> responseMap;
        //Added For CRM-299
        List<ContentDocumentLink> insertDocuments = new List<ContentDocumentLink>();
        if(String.isBlank(reCaptchaResponse)){
            return null;
        }
        responseMap = verifyRecaptcha(reCaptchaResponse);
        if(responseMap != null && responseMap.get('success') == false){
            return responseMap;
        }
        responseMap = new Map<String, Object>();
        if(String.isBlank(caseId)){
            //Changes for story DTCS-9
            //Check that brand is either Jim Beam or Makers Mark
            if((caseObj.Brand__c == System.label.Makers_Mark_DTC && 
                (caseObj.How_can_we_help__c == DTC_Constants.WHISKY_DROP || 
                caseObj.How_can_we_help__c == DTC_Constants.LIMITED_ONLINE_RELEASES)) || 
                (caseObj.Brand__c == System.label.Jim_Beam_Brand && 
                caseObj.How_can_we_help__c == System.Label.Barreled_Boxed_Membership_Program)){
                if (caseObj.AdditionalInformation__c == System.Label.Membership_Cancellation
                    || caseObj.AdditionalInformation__c == DTC_Constants.SHIPPING_AND_DELIVERY_QUESTIONS 
                    || caseObj.How_can_we_help__c == DTC_Constants.LIMITED_ONLINE_RELEASES) {
                    caseObj.OwnerID = SLT_DTC_Group.getQueueByName(caseObj.How_can_we_help__c).Id; 
                    if (caseObj.AdditionalInformation__c == System.Label.Membership_Cancellation) {
                        caseObj.Status = DTC_Constants.CLOSED_STATUS;
                    } else if (caseObj.AdditionalInformation__c == DTC_Constants.SHIPPING_AND_DELIVERY_QUESTIONS 
                              || caseObj.How_can_we_help__c == DTC_Constants.LIMITED_ONLINE_RELEASES) {
                        caseObj.Status = DTC_Constants.NEW_STATUS;
                    }
                    caseObj.RecordTypeId = DTC_Constants.DTC_RT_ID;
                    caseObj.Origin = DTC_Constants.CUSTOMER_PORTAL;
                    if(caseObj.Brand__c == System.label.Makers_Mark_DTC && 
                       caseObj.How_can_we_help__c != DTC_Constants.LIMITED_ONLINE_RELEASES){
                    	caseObj.Automated_Notification_Email__c = DTC_Constants.EMAIL_WHISKY_DROP;
                    }
                    else if(caseObj.Brand__c == System.label.Jim_Beam_Brand) {
                        caseObj.Automated_Notification_Email__c = DTC_Constants.EMAIL_BARRELED_AND_BOXED;  
                    }
                    caseObj.Email_Address__c = accountObj.PersonEmail;
                    caseObj.First_name__c = accountObj.FirstName;
                    caseObj.Last_name__c = accountObj.LastName;
                    caseObj.Consumer_Country__c = accountObj.PersonMailingCountry;
                }    
            }
            else{
                caseObj.RecordTypeId = isComplaint ? CSConstants.QC_RT_ID : CSConstants.CONSUMER_INQUIRY_RT_ID;
            }  
            //Till Here
        } else {
            caseObj.Id = caseId;
        }
        Id existingAccId = getExistingAccountId(accountObj.PersonEmail);
        if(existingAccId != null) {
            accountObj.Id = existingAccId;
        }
        
        if(caseObj != null) {
            upsert accountObj;
            Set<ID> ids = new Set<ID>();
            ids.add(accountObj.id);
            List<Account> lstAccInfo = SLT_Account.getAccountsByIDs(ids);
            if(lstAccInfo.size() > 0){
                caseObj.ContactId = lstAccInfo[0].PersonContactId;    
            }
            updateCaseFields(caseObj);
            upsert caseObj;
        }
        //Added For CRM-299 start here
        if(documentId != null && documentId.size() > 0){
            for(String docId : documentId){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = docId;
                cdl.LinkedEntityId = caseObj.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                insertDocuments.add(cdl);
            }
        }
        //Added For CRM-299 till here
        if(insertDocuments.size() > 0){
            insert insertDocuments;
        }
        responseMap.put('caseId', caseObj.Id);
        responseMap.put('accountId', accountObj.Id);
        return responseMap;
    }
    
    /**
    *  @description : This method is use to update the case.
    *  @args        : Case caseObj, String caseId, Account accountObj, String accountId, String address2
    *  @return      : Map<String, Object>
    **/
    public static Map<String, Object> updateCase(Case caseObj, String caseId, Account accountObj, String accountId, String address2) {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        caseObj.Id = caseId;
        List<ID> ids = new List<ID>();
        ids.add(caseId);
        List<Case> caseLstInfo = SLT_Case.getCaseByIDs(ids);
        if(caseLstInfo.size() > 0) {
            caseObj.Subject = caseLstInfo[0].CaseNumber + ' : '  + 'Quality Claim';    
        }
        
        accountObj.Id = accountId;
        accountObj.PersonMailingStreet = String.isNotEmpty(address2) ? accountObj.PersonMailingStreet + ', ' + address2 : accountObj.PersonMailingStreet;
        update accountObj;
        updateCaseFields(caseObj);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        caseObj.RecordTypeId = CSConstants.QC_RT_ID;
        caseObj.setOptions(dmo);
        
        List<Case> caseLst = new List<Case>();
        caseLst.add(caseObj);
        caseServices.setCasePriority(caseLst);
        update caseLst;
        
        responseMap.put('success', true);
        responseMap.put('caseId', caseObj.Id);
        return responseMap;
    }
    
    /**
    *  @description : This method is use to verify reCaptcha response.
    *  @args        : String reCaptchaResponse
    *  @return      : Map<String, Object>
    **/
    private static Map<String, Object> verifyRecaptcha(String reCaptchaResponse){
        Map<String, Object> responseMap;
        ContactUs_Setting__c mc = ContactUs_Setting__c.getValues('Default');
        String endPoint = mc.ReCaptchaEndPoint__c;
        String requestBody = 'secret=' + mc.ReCaptchaSecretKey__c + '&response=' + reCaptchaResponse;
        responseMap = UTL_Http.makeHttpRequest(endPoint, 'POST', requestBody);
        return responseMap;
    }
    
    /**
    *  @description : Helper method is use to fetch the existing account.
    *  @args        : String email
    *  @return      : Id
    **/
    private static Id getExistingAccountId(String email) {
        List<Account> existAccLst = SLT_Account.getAccountByEmail(email);
        return existAccLst.isEmpty() ? null : existAccLst[0].Id;
    }
    
    /**
    *  @description : Helper method use to get piclist data of case for given api.
    *  @args        : String apiName
    *  @return      : List<PicklistValue>
    **/
    private static List<PicklistValue> getPicklistData(String apiName) {
        return wrapPicklistEntries(Schema.getGlobalDescribe().get('case').getDescribe().fields.getMap().get(apiName).getDescribe().getPicklistValues());
    }
    
    /**
    *  @description : Helper method is use to wrap List<Schema.PicklistEntry> into PicklistValue class
    *  @args        : List<Schema.PicklistEntry> lstPicklistEntry
    *  @return      : List<PicklistValue>
	**/
    private static List<PicklistValue> wrapPicklistEntries(List<Schema.PicklistEntry> lstPicklistEntry) {
        return (List<PicklistValue>) JSON.deserialize(JSON.serialize(lstPicklistEntry), List<PicklistValue>.class);
    }
    
    /**
    *  @description : Helper method use to update case fields value for translated text.
    *  @args        : Case caseObj
    *  @return      : void
    **/
	private static void updateCaseFields(Case caseObj) {
        List<Brand_Category_Help_Mapping__mdt> lstHelpMdt = SLT_CustomMetadata.getBrandCategoryHelpMapping(
            caseObj.How_can_we_help__c, caseObj.AdditionalInformation__c);
        if(!lstHelpMdt.isEmpty()) {
            caseObj.How_can_we_help__c = lstHelpMdt[0].How_Can_We_Help_You__c;
            caseObj.AdditionalInformation__c = lstHelpMdt[0].AdditionalInformation__c;
        }
    }
    
    /* Class structure to wrap picklist values */
    private class PicklistValue {
        @AuraEnabled public String value;
        @AuraEnabled public String active;
        @AuraEnabled public String label;
    }
    
}