public class SCR_CaseUpdationScripts {
    
    public static void updateCaseClosedType(List<Case> cases) {
        for(Case c : cases) {
            if(c.CaseClosedType__c == NULL) {
                if(c.Status == 'Resolved') {
                    c.CaseClosedType__c = 'Agent Closed';
                } else {
                    c.CaseClosedType__c = 'Auto Closed';
                }
            }
            if(c.Actual_Closed_Date__c == NULL) {
                if(c.ClosedDate != NULL) {
                    c.Actual_Closed_Date__c = c.ClosedDate;
                } else if(c.ClosedDate == null && c.Status == 'Resolved'){
                    c.Actual_Closed_Date__c = c.LastModifiedDate;
                }
            }
            if(c.AgentResponseOnCase__c == NULL || c.ConsumerResponseOnCase__c == NULL) {
                Integer consumerResponseCount = 0;
                Integer agentResponseCount = 0;
                for(EmailMessage em : c.EmailMessages) {
                    if(em.Incoming && em.FromAddress != 'consumerinquiries@beamsuntory.com') {
                        consumerResponseCount++;
                    } else if(em.Incoming == false && em.CreatedBy.Name != 'Beam Suntory CS' && em.FromAddress == 'consumerinquiries@beamsuntory.com') {
                        agentResponseCount++;
                    }
                }
                c.ConsumerResponseOnCase__c = consumerResponseCount;
                c.AgentResponseOnCase__c = agentResponseCount;
            }
        }
        try {
            update cases;
        } catch (Exception e) {
            System.debug('Exception is ' + e.getMessage());
        }
    }
    
    public static void updateCaseStatusToDuplicate(List<Case> cases) {
        for(Case c : cases) {
            c.Status = 'Duplicate';
        }
        try {
            update cases;
        } catch (Exception e) {
            System.debug('Exception is ' + e.getMessage());
        }
    }
    
    public static void updateCaseStatusToAssigned(List<Case> cases) {
        for(Case c : cases) {
            String ownerId = c.ownerId;
            if(ownerId.startsWith('005')) {
                c.Status = 'Assigned';
            }
        }
        try {
            update cases;
        } catch (Exception e) {
            System.debug('Exception is ' + e.getMessage());
        }
    }
    
    public static void updateCaseResponse(List<Case> cases) {
        for(Case c : cases) {
            Integer consumerResponseCount = 0;
            Integer agentResponseCount = 0;
            for(EmailMessage em : c.EmailMessages) {
                if(em.Incoming && em.FromAddress != 'consumerinquiries@beamsuntory.com') {
                    consumerResponseCount++;
                } else if(em.Incoming == false && em.CreatedBy.Name != 'Beam Suntory CS' && em.FromAddress == 'consumerinquiries@beamsuntory.com') {
                    agentResponseCount++;
                }
            }
            c.ConsumerResponseOnCase__c = consumerResponseCount;
            c.AgentResponseOnCase__c = agentResponseCount;
        }
        
        try {
            update cases;
        } catch (Exception e) {
            System.debug('Exception is ' + e.getMessage());
        }
    }

    public static void updateCaseBrandFamily(List<Case> cases){
        List<Brand_Family_Brand_Mapping__mdt> brandFamilyList = [Select Brand__c, Brand_Family__c FROM Brand_Family_Brand_Mapping__mdt];
        Map<String, String> brandFamilyMap = new Map<String,String>();

        for(Brand_Family_Brand_Mapping__mdt brandFamily : brandFamilyList)
            brandFamilyMap.put( brandFamily.Brand__c, brandFamily.Brand_Family__c );

        for(Case cse : cases){
            if(cse.Brand__c != null){
                if(brandFamilyMap.get(cse.Brand__c) != null)
                    cse.Brand_Family__c = brandFamilyMap.get(cse.Brand__c);
                else
                    cse.Brand_Family__c = cse.Brand__c;
            }
        }

        try {
            update cases;
        } catch (Exception e) {
            System.debug('Exception is ' + e.getMessage());
        }
    }
}