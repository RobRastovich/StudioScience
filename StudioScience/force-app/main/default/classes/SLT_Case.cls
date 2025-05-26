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
    @description This selector class is created to fetch case details.
*/
public class SLT_Case {
	
    /**
    *  @description : This method is use to fetch cases by list of id.
    *  @args        : List<ID> listOfIDs
    *  @return      : List<Case>
    **/
    public static List<Case> getCaseByIDs(List<ID> listOfIDs){
        List<Case> listOfCases = [SELECT Subject, CaseNumber,CreatedDate, Brand__c, Type, Single_Barrel_State__c,
                				      Single_Barrel_Region__c, Single_Barrel_Country__c,Product_Type__c, National_Account_Flag__c,
                                  	  Retail_Account__r.Name, Retail_Account__r.PremiseType__c, Retail_Account__r.BillingCountry, 
                                  	  Account.BillingCountry, Plant_Event__C,Change_Reason__c, Type_selection__c, Other_Reason_Description__c,
                                  	  Delivery_Number__c, process_regulation_number__c, Billing_Number__c, Article_Number__c, Product_Name__c,
                              		  Product_Size__c, Quantity__c, Quantity_Type__c, Amount__c, Customer_Name__c, Customer_Number__c,
                              		  Customer_Phone_Number__c, Customer_Email_Address__c, Category__c, Sub_Category__c
                                  FROM Case 
                                  WHERE Id IN : listOfIDs];
        return listOfCases;
    }
    
    /**
    *  @description : This method is use to fetch cases that were created by user in specific duration which is 90 days or 365 days.
    *  @args        : Integer numberOfDays, Id caseId, String email, String country, String state, String city, String postalCode, String street, Datetime createdDate, Integer limitOfData
    *  @return      : List<Case>
    **/
    public static List<Case> getCasesInLastDaysForParticularUser(Integer numberOfDays, Id caseId, String email, String country, String state, String city, String postalCode, String street, Datetime createdDate, Integer limitOfData){
        List<Case> lstCaseInfoInDays = [SELECT Id 
                                         FROM Case 
                                         WHERE Id != :caseId 
                                         AND RecordType.Id = :CSConstants.QC_RT_ID 
                                         AND CreatedDate <= :createdDate 
                                         AND CreatedDate >= :createdDate - numberOfDays
                                         AND (Contact.Email = :email
                                              OR (Contact.MailingCountry = :country 
                                                  AND Contact.MailingStreet = :street 
                                                  AND Contact.MailingPostalCode = :postalCode 
                                                  AND Contact.MailingCity = :city AND Contact.MailingState = :state)) 
                                         LIMIT :limitOfData];
        return lstCaseInfoInDays;
    }
    
    /**
    *  @description : This method is use to fetch cases based on current case's contact email address or mailing address.
    *  @args        : Id caseId, String email, String country, String state, String city, String postalCode, String street
    *  @return      : List<Case>
    **/
    public static List<Case> getCaseByEmailOrAddress(Id caseId, String email, String country, String state, String city, String postalCode, String street){
        return [SELECT CaseNumber, Status, Brand__c 
                FROM Case 
                Where Id != :caseId 
                AND RecordType.Id =: CSConstants.QC_RT_ID 
                AND (Contact.Email = :email OR 
                     (Contact.MailingCountry = :country 
                      AND Contact.MailingStreet = :street 
                      AND Contact.MailingPostalCode = :postalCode 
                      AND Contact.MailingCity = :city AND Contact.MailingState = :state)) 
                ORDER BY CaseNumber DESC];
    }
    
    /**
    *  @description : This method is use to fetch quality claim cases based on contact country and 4 initial characters
    * 				  of lot code and for current year.
    *  @args        : Id caseId, String country, String lotCode
    *  @return      : List<Case>
    **/
    public static List<Case> getCasesByCountryAndLotcode(Id caseId, String country, String lotCode) {
        lotCode += '%'; 
        return [SELECT 
                    Id, CaseNumber, Account.Name, Lot_code__c 
                FROM 
                    Case 
                WHERE 
                    Id != :caseId
                AND
                	CreatedDate = THIS_YEAR
                AND 
                    RecordTypeId = :CSConstants.QUALITY_CLAIM_RT_ID
                AND 
                    Contact.MailingCountry = :country 
                AND 
                    Lot_Code__c LIKE :lotCode];
    }

    /**
    *  @description : This method is use to fetch case by id.
    *  @args        : ID 
    *  @return      : Case
    **/
    public static Case getCaseByID(ID id){
        List<Case> cases = new List<Case>();
        cases = [SELECT Id, CaseNumber, Brand__c, Retail_Account__c
                    FROM Case 
                    WHERE Id  =: id 
                    LIMIT 1];
        Case recordCase = new Case();
        recordCase = cases.size()>0  ? cases[0] : null;
        return recordCase;
    }
    
    public static Case getCaseDetailByID(Id id){
        List<Case> cases = new List<Case>();
        Case recordCase = new Case();
        cases = [SELECT Id, CaseNumber, Status, Sub_Status__c
                    FROM Case 
                    WHERE Id  =: id 
                    LIMIT 1];
        recordCase = cases.size()>0  ? cases[0] : null;
        return recordCase;                   
    }
    
    /**
    *  @description : This method is use to fetch case by id.
    *  @args        : String 
    *  @return      : Case
    **/
    public static Case getCaseAccountDetailsByID(String caseId){
        List<Case> cases = new List<Case>();
        cases = [SELECT Retail_Account__c, National_Account_Flag__c, Retail_Account__r.Name, AccountId, Account.Name,
                    Account.Attention__c, Account.State__c, Account.TDL_Match_Code__c,
                    Account.PremiseType__c, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, 
                    Account.Phone, Account.BillingStreet, Retail_Account__r.PremiseType__c, Retail_Account__r.State__c,
                    Retail_Account__r.BillingCity, Retail_Account__r.BillingState, Retail_Account__r.BillingPostalCode, 
                    Retail_Account__r.Phone, Retail_Account__r.BillingStreet,
                    ContactId, Contact.LastName, Plant_Event__r.Time_Interval__r.Date_Range_Label__c
                    FROM case 
                    WHERE Id =: caseId];
        Case recordCase = new Case();
        recordCase = cases.size()>0  ? cases[0] : null;
        return recordCase;
    }

    public static List<Case> getCasesListById(Set<Id> caseIds) {
        List<Case> cases = new List<Case>();
        cases = [SELECT Id, Status, Sub_Status__c
                    FROM Case 
                    WHERE Id  
                    IN :caseIds ];
        return cases;  
    }
}