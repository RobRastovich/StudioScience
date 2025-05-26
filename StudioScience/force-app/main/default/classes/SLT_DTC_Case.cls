public class SLT_DTC_Case {
    
    /**
    *  @description : This method is use to fetch case by id.
    *  @args        : ID 
    *  @return      : Case
    **/
    public static Case getCaseByID(ID id){
        Case createdCase = [SELECT Id, CaseNumber, Brand__c 
                                FROM Case 
                                WHERE Id  =: id];
        return createdCase;
    }

    /**
    *  @description : This method is use to fetch cases based on Case Number.
    *  @args        : String CaseNUmber
    *  @return      : Case 
    **/
    
    public static Case getCaseRecordByCaseNumber(String CaseNumber){
        
        List<Case> getCaseRecords;
        if(String.isNotBlank(CaseNumber)){
            getCaseRecords = [SELECT id, Status, Sub_Status__c, Name__c, Date_of_Transaction__c, 
                                Transaction_Amount__c, SAP_Order_Number__c, 
                                Tax_Amount__c, Consumer_State__c, 
                                Origin, Braintree_Status__c, Avatax_Status__c, 
                                SAP_Status__c, How_can_we_help__c, AdditionalInformation__c, Follow_Up_Count__c 
                                FROM Case 
                                WHERE CaseNumber =: CaseNumber];
        }
        Case recordCase = new Case();
        recordCase = getCaseRecords.size()>0  ? getCaseRecords[0] : null;
        return recordCase;
    }

    public static List<Case> getCasesList(Integer pagenumber, Integer pageSize, String searchString, Set<Id> recordTypeIds, String addInfo,
        String sortOrder){
        String query = 'select id, CaseNumber, CreatedDate, DHL_Status__c, First_name__c, Last_name__c, '
        +'AdditionalInformation__c FROM Case ';  
        if (String.isBlank(addInfo)) {
            addInfo = DTC_Constants.ASSIGNED_TO_ME;
        }
        query = getDTCQuery(searchString, addInfo, query, recordTypeIds) ;
        if (String.isNotBlank(sortOrder) && sortOrder == 'ASC') {
            query += ' ORDER BY CaseNumber ASC NULLS LAST LIMIT ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1)); 
        } else {
            query += ' ORDER BY CaseNumber DESC NULLS LAST LIMIT ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1)); 
        }
        return Database.query(query);
    }

    public static Integer getCasesCount(String searchString, Set<Id> recordTypeIds, String addInfo){
        String subStatus = DTC_Constants.COMMUNICATE_WITH_DHL;
        String query = 'select count() FROM Case ';  
        if (String.isBlank(addInfo)) {
            addInfo = DTC_Constants.ASSIGNED_TO_ME;
        }
        query = getDTCQuery(searchString, addInfo, query, recordTypeIds);  
        return Database.countQuery(query);
    }

    @testVisible
    private static String getDTCQuery(String searchString, String addInfo, String query, Set<Id> recordTypeIds){
        if (addInfo == DTC_Constants.DHL_PORTAL) {
            if (String.isNotBlank(searchString)) {
                query += ' WHERE (Origin like \'%' + addInfo + '%\' '
                    + ' AND CaseNumber like \'%' + searchString + '%\') '; 
            } else {
                query += ' WHERE Origin like \'%' + addInfo + '%\' ';
            }
            query += ' AND Status != \'Closed\' AND RecordTypeId IN : recordTypeIds'; 
        }else if (addInfo.toLowerCase() == 'closed') {
            if (String.isNotBlank(searchString)) {
                query += ' WHERE (Status != null AND Status != \'\' AND Status like \'%' + addInfo + '%\''
                    + ' AND CaseNumber like \'%' + searchString + '%\') '; 
            } else {
                query += ' WHERE Status != null AND Status != \'\' AND Status like \'%' + addInfo + '%\' ';
            }
            query += ' AND RecordTypeId IN : recordTypeIds AND ClosedDate = LAST_N_DAYS:60'; 
        }  else {
            if (String.isNotBlank(searchString)) {
                query += ' WHERE ((Sub_Status__c = \'Communicate with DHL\''
                    + ' AND CaseNumber like \'%' + searchString + '%\' AND Status = \'In Progress\') OR ((CaseNumber like \'%' + searchString + '%\' AND'; 
            } else {
                query += ' WHERE ((Sub_Status__c = \'Communicate with DHL\' AND Status = \'In Progress\') OR ((';
            }
            query += ' Origin=\'Console\') AND AdditionalInformation__c=\'' + DTC_Constants.REPLACEMENT + '\')) AND Status != \'Closed\' AND RecordTypeId IN : recordTypeIds';
        }
        return query;
    }

    public static Case getDhlCaseByID(ID id){
        Case createdCase = [SELECT Id, CaseNumber, Origin, Email_Address__c, 
                                First_name__c, Last_name__c, OrderID__c,
                                Program_Subscription__c, Consumer_Country__c, 
                                Consumer_State__c, Consumer_City__c, Consumer_Postal_Code__c,
                                Consumer_Street__c, OwnerID, UPS_Tracking_Number__c, 
                                UPS_Reason_For_Return__c,ContactId, AccountId,
                                DHL_Status__c, How_can_we_help__c, AdditionalInformation__c, 
                                Brand__c, Customer_Phone_Number__c, Damage_Issue__c,
                                ContactPhone, ContactEmail, Status
                                FROM Case 
                                WHERE Id  =: id];
        return createdCase;
    }
    
    /**
    *  @description : This method is use to fetch case by given Order Id.
    *  @args        : Order ID 
    *  @return      : Case
    **/
    public static Case getCaseRecordByOrderID(String orderid){
        List<Case> getCaseRecords;
        if(String.isNotBlank(orderid)){
            getCaseRecords = [SELECT Id, OrderID__c, Status, Sub_Status__c, UPS_Tracking_Number__c, AdditionalInformation__c 
                                FROM Case 
                                WHERE (OrderID__c  =: orderid 
                                AND
                                ((Status =: DTC_Constants.IN_PROGRESS AND Sub_Status__c =: DTC_Constants.RESHIP_CONFIRMED) 
                                OR 
                                (Status =: DTC_Constants.IN_PROGRESS AND Sub_Status__c =: 
                                DTC_Constants.RESHIPMENT_INITIATED)
                                OR
                                (Status =: DTC_Constants.IN_PROGRESS AND Sub_Status__c =: 
                                 DTC_Constants.REPLACEMENT_INITIATED_SUB_STATUS))) LIMIT 1];
        }
        Case recordCase = new Case();
        recordCase = getCaseRecords.size()>0  ? getCaseRecords[0] : null;
        return recordCase;
    }

    public static Case getCaseDetailByID(Id id){
        Case caseRecord = [SELECT Id, CaseNumber, Status, Sub_Status__C, AdditionalInformation__c,
                           How_can_we_help__c
                           FROM Case 
                           WHERE Id  =: id];
        return caseRecord;
    }

    public static Map<String, Case> getMapOfCasesToOrderID(Set<String> orderIds, Set<String> recordTypeIds){
        Map<String, Case> orderIdToCaseMap = new Map<String, Case>();
        List<Case> casesList;
        String query = 'SELECT Id, OrderID__c, RecordTypeId FROM CASE WHERE RecordTypeId IN  : recordTypeIds'
            + ' AND OrderID__c IN : orderIds';
        casesList = Database.query(query);
        if (casesList != null) {
            for (Case caseObj : casesList) {
                if (caseObj.OrderID__c != null && caseObj.OrderID__c != '') {
                    orderIdToCaseMap.put(caseObj.OrderID__c, caseObj);
                }
            }
        }
        return orderIdToCaseMap;
    }

    public static List<Case> getCaseRecordsToEmailAndBrand(String orderId, String email, String brand){
        List<Case> getCaseRecords;
        if(String.isNotBlank(orderId)){
            getCaseRecords = [SELECT ID, OrderID__c, Status, Sub_Status__c, CaseNumber, Program_Subscription__C,
                                Email_Address__c, Brand__c
                                FROM Case 
                                WHERE (RecordTypeId =: DTC_Constants.CASE_DTC_RECORDTYPEID
                                AND
                                OrderID__c  =: orderid 
                                AND
                                Brand__c =: brand
                                AND
                                Email_Address__c =: email
                                AND
                                Status !=: DTC_Constants.CLOSED_STATUS)];
        }
        else{
            getCaseRecords = [SELECT ID, OrderID__c, Status, Sub_Status__c, CaseNumber, Program_Subscription__c,
                                Email_Address__c, Brand__c
                                FROM Case 
                                WHERE 
                                (RecordTypeId =: DTC_Constants.CASE_DTC_RECORDTYPEID
                                AND    
                                Brand__c =: brand
                                AND
                                Email_Address__c =: email
                                AND
                                Status !=: DTC_Constants.CLOSED_STATUS)];
        }
        List<Case> returnCaseRecords;
        returnCaseRecords = getCaseRecords.size()>0  ? getCaseRecords : new List<Case>();
        return returnCaseRecords;
    }

    public static Map<String, Case> getMapOfCasesToEmailID(Set<String> emailIds, Set<String> recordTypeIds){
        Map<String, Case> emailIdToCaseMap = new Map<String, Case>();
        List<Case> casesList;
        String query = 'SELECT Id, Email_Address__c, RecordTypeId, Brand__c FROM CASE WHERE RecordTypeId IN  : recordTypeIds'
            + ' AND Email_Address__c IN : emailIds';
        casesList = Database.query(query);
        if (casesList != null) {
            for (Case caseObj : casesList) {
                if (caseObj.Email_Address__c != null && caseObj.Email_Address__c != '') {
                    emailIdToCaseMap.put(caseObj.Email_Address__c, caseObj);
                }
            }
        }
        return emailIdToCaseMap;
    }
}