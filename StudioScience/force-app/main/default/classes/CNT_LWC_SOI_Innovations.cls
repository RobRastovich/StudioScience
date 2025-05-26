public class CNT_LWC_SOI_Innovations {
    @AuraEnabled(cacheable = true)
    public static List<Innovation_Project_Master__c> getInnovationSampleRecords() {
        return SLT_SOI_Innovation_Project_Master.getInnovationSampleRecords();
    }
    
    @AuraEnabled
    public static Boolean saveInnovationRecords(String jsonFormString) {
        try {
            InnovationRequestsWrapper requestsWrapper = new InnovationRequestsWrapper();
            if(String.isNotEmpty(jsonFormString)) {
                requestsWrapper = (InnovationRequestsWrapper)System.JSON.deserialize(jsonFormString,
                                     InnovationRequestsWrapper.class);
            }
            List<InnovationDetailsWrapper> projectWrapperList = new List<InnovationDetailsWrapper>();
            List<Innovation_Project_Details__c> projectDetailsList = new List<Innovation_Project_Details__c>();
            if(requestsWrapper != null && String.isNotEmpty(requestsWrapper.innovationSampleId) &&
                String.isNotEmpty(requestsWrapper.submittedBy) && String.isNotEmpty(requestsWrapper.email) &&
                String.isNotEmpty(requestsWrapper.soldTo) && String.isNotEmpty(requestsWrapper.region) &&
                String.isNotEmpty(requestsWrapper.projectList) && String.isNotEmpty(requestsWrapper.notes)) {
                Innovation_Sample_Requests__c innovationRequest = setValuesToSampleRequest(requestsWrapper);
                if(String.isNotEmpty(requestsWrapper.costCenter) || String.isNotEmpty(requestsWrapper.wbsElement)) {
                    if(String.isNotEmpty(requestsWrapper.costCenter)) {
                        innovationRequest.Cost_Center__c = requestsWrapper.costCenter;
                    } else {
                        innovationRequest.WBS_Element__c = requestsWrapper.wbsElement;
                    }
                    System.Savepoint sp = Database.setSavepoint();
                    insert innovationRequest;
                
                    if(innovationRequest.Id != null && String.isNotEmpty(innovationRequest.Id)) {
                        projectWrapperList = (List<InnovationDetailsWrapper>)System.JSON.deserialize(requestsWrapper.projectList,
                                                List<InnovationDetailsWrapper>.class);
                        for(InnovationDetailsWrapper project : projectWrapperList) {
                            if(project != null && String.isNotEmpty(project.addressId) &&
                                String.isNotEmpty(project.recipientEmail) && project.quantity >= 0 &&
                                String.isNotEmpty(project.attentionTo) && String.isNotEmpty(project.phone)) {
                                Innovation_Project_Details__c projectDetail =
                                    setValuesToProjectDetail(project, innovationRequest);
                                projectDetailsList.add(projectDetail);
                            } else {
                                Database.rollback(sp);
                                return false;
                            }
                        }
                        if(projectDetailsList.size() > 0) {
                            Database.SaveResult[] srList = database.insert(projectDetailsList, false);
                            for(Database.SaveResult sr : srList) {
                                if(sr.isSuccess() == false) {
                                    Database.rollback(sp);
                                    return false;
                                }
                            }
                            innovationRequest.Send_Email__c = true;
                            update innovationRequest;
                            return true;
                        }
                    } else {
                        Database.rollback(sp);
                        return false;
                    }
                } else {
                    return false;
                }
            } else {
                return false;
            }
        } catch(Exception e) {
            String errorMessage = 'Error while saving records ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('CNT_LWC_SOI_Innovation', 'saveInnovationRecords', String.valueOf(errorMessage),
                'Fatal');
            return false;
        }
        return true;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<List<String>> getSoldToPicklistValues() {
        List<List<String>> pickListValuesList = new List<List<String>>();
        Schema.DescribeFieldResult fieldResult = Innovation_Sample_Requests__c.Sold_to__c.getDescribe();
        List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListValue : pickList) {
            pickListValuesList.add(new List<String>{pickListValue.getLabel(), pickListValue.getValue()});
        }
        return pickListValuesList;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<List<String>> getRegionOptions() {
        List<List<String>> pickListValuesList = new List<List<String>>();
        Schema.DescribeFieldResult fieldResult = Innovation_Sample_Requests__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListValue : pickList) {
            pickListValuesList.add(new List<String>{pickListValue.getLabel(), pickListValue.getValue()});
        }
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static Map<String, Map<String, Id>> getSampleKitShipAddressMap(String country) {
        Map<String, Map<String, Id>> sampleKitShipAddressMap = new Map<String, Map<String, Id>>();
        List<Sample_Kit_Shipping_Address__c> sampleKitShipAddressList = new List<Sample_Kit_Shipping_Address__c>();
        if(String.isNotBlank(country)) {
            sampleKitShipAddressList = SLT_SOI_Sample_Kit_Shipping_Address.getShipAddressRecords(country);
        }
        for(Sample_Kit_Shipping_Address__c sampleKitShipAddress : sampleKitShipAddressList) {
            if(sampleKitShipAddressMap.containsKey(sampleKitShipAddress.State__c)) {
                sampleKitShipAddressMap.get(sampleKitShipAddress.State__c).put(sampleKitShipAddress.Name,
                    sampleKitShipAddress.Id);
            }
            else {
                sampleKitShipAddressMap.put(sampleKitShipAddress.State__c,
                    new Map<String, Id>{sampleKitShipAddress.Name => sampleKitShipAddress.Id});
            }
        }
        return sampleKitShipAddressMap;
    }
    
    @AuraEnabled
    public static Map<String, String> filterOfficeValueByStateMap(String country, String stateVal) {
        List<Sample_Kit_Shipping_Address__c> addressList = new List<Sample_Kit_Shipping_Address__c>();
        if(String.isNotBlank(country) && String.isNotBlank(stateVal)) {
            addressList = SLT_SOI_Sample_Kit_Shipping_Address.filterOfficeValueByStateList(country, stateVal);
        }
        Set<String> nameSet = new Set<String>();
        Map<String, String> addressNameMap = new Map<String, String>();
        for(Sample_Kit_Shipping_Address__c sk : addressList) {
            if(!nameSet.contains(sk.Name)) {
                String address = '';
                if(String.isNotBlank(sk.Street__c)) {
                    address = sk.Street__c + ', ';
                }
                if(String.isNotBlank(sk.City__c)) {
                    address = address + sk.City__c + ', ';
                }
                if(String.isNotBlank(sk.State__c)) {
                    address = address + sk.State__c + ', ';
                }
                if(String.isNotBlank(sk.Zip_Code__c)) {
                    address = address + sk.Zip_Code__c;
                }
                if(address.right(1) == ', ') {
                    address = address.substring(0, address.length() - 2);
                }
                nameSet.add(sk.Name);
                addressNameMap.put(sk.Name, address);
            }
        }
        return addressNameMap;
    }
    
    private static Innovation_Sample_Requests__c setValuesToSampleRequest(InnovationRequestsWrapper requestsWrapper) {
        Innovation_Sample_Requests__c innovationRequest = new Innovation_Sample_Requests__c();
        innovationRequest.Innovation_Samples__c = requestsWrapper.innovationSampleId;
        innovationRequest.Submitted_By__c = requestsWrapper.submittedBy;
        innovationRequest.Email__c = requestsWrapper.email;
        innovationRequest.Sold_to__c = requestsWrapper.soldTo;
        innovationRequest.Region__c = requestsWrapper.region;
        innovationRequest.Notes__c = requestsWrapper.notes;
        innovationRequest.Resubmission__c = requestsWrapper.resubmission;
        return innovationRequest;
    }
    
    private static Innovation_Project_Details__c setValuesToProjectDetail(InnovationDetailsWrapper project,
        Innovation_Sample_Requests__c innovationRequest) {
        Innovation_Project_Details__c projectDetail = new Innovation_Project_Details__c();
        projectDetail.AddressId__c = project.addressId;
        projectDetail.Recipient_Email__c = project.recipientEmail;
        projectDetail.Quantity__c = project.quantity;
        projectDetail.Attention_To__c = project.attentionTo;
        projectDetail.Phone__c = project.phone;
        projectDetail.InnovationId__c = innovationRequest.Id;
        return projectDetail;
    }
    
    public class InnovationRequestsWrapper {
        @AuraEnabled
        public Id innovationSampleId{get;set;}
        @AuraEnabled
        public String submittedBy{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String soldTo{get;set;}
        @AuraEnabled
        public String costCenter{get;set;}
        @AuraEnabled
        public String wbsElement{get;set;}
        @AuraEnabled
        public String projectList{get;set;}
        @AuraEnabled
        public String region{get;set;}
        @AuraEnabled
        public String notes{get;set;}
        @AuraEnabled
        public Boolean resubmission{get;set;}
    }
    
    public class InnovationDetailsWrapper {
        @AuraEnabled
        public Id addressId{get;set;}
        @AuraEnabled
        public String recipientEmail{get;set;}
        @AuraEnabled
        public Decimal quantity{get;set;}
        @AuraEnabled
        public String attentionTo{get;set;}
        @AuraEnabled
        public String phone{get;set;}
        @AuraEnabled
        public String legalShipPoint{get;set;}
    }
}