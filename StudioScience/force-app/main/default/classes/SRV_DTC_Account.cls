public class SRV_DTC_Account {

    public static Account insertPersonAccountUsingUserDetail(case objUserDetail, Account accountDetail) {
        Account newPersonAccount = new Account();
        try {
            newPersonAccount.FirstName = objUserDetail.First_name__c;
            newPersonAccount.LastName = objUserDetail.Last_name__c;
            newPersonAccount.RecordTypeId = DTC_Constants.ACCOUNT_CONSUMER_RECORDTYPEID;
            newPersonAccount.PersonEmail = String.isNotBlank(accountDetail.PersonEmail) ? accountDetail.PersonEmail : 
            objUserDetail.Email_Address__c;
            newPersonAccount.PersonMailingCountry = String.isNotBlank(accountDetail.PersonMailingCountry) ? 
            accountDetail.PersonMailingCountry : newPersonAccount.PersonMailingCountry;
            newPersonAccount.PersonMailingState = String.isNotBlank(accountDetail.PersonMailingState) ? 
            accountDetail.PersonMailingState : newPersonAccount.PersonMailingState;
            newPersonAccount.PersonMailingCity = String.isNotBlank(accountDetail.PersonMailingCity) ? 
            accountDetail.PersonMailingCity : newPersonAccount.PersonMailingCity;
            newPersonAccount.PersonMailingPostalCode = String.isNotBlank(accountDetail.PersonMailingPostalCode) ? 
            accountDetail.PersonMailingPostalCode : newPersonAccount.PersonMailingPostalCode;
            newPersonAccount.PersonMailingStreet = String.isNotBlank(accountDetail.PersonMailingStreet) ? 
            accountDetail.PersonMailingStreet : newPersonAccount.PersonMailingStreet;
            insert newPersonAccount;
            if (newPersonAccount != null) {
                newPersonAccount = SLT_DTC_Account.getPersonAccountsByIDs(new Set<ID>{newPersonAccount.Id})[0];
            }
        } catch (Exception ex) {
        }
        return newPersonAccount;  
    }

    public static Account updateAccount(Account accountToUpdate, Account accountDetails) {
        accountToUpdate.PersonMailingCountry = String.isNotBlank(accountDetails.PersonMailingCountry) ? 
        accountDetails.PersonMailingCountry : accountToUpdate.PersonMailingCountry;
        accountToUpdate.PersonMailingState = String.isNotBlank(accountDetails.PersonMailingState) ? 
        accountDetails.PersonMailingState : accountToUpdate.PersonMailingState;
        accountToUpdate.PersonMailingCity = String.isNotBlank(accountDetails.PersonMailingCity) ? 
        accountDetails.PersonMailingCity : accountToUpdate.PersonMailingCity;
        accountToUpdate.PersonMailingPostalCode = String.isNotBlank(accountDetails.PersonMailingPostalCode) ? 
        accountDetails.PersonMailingPostalCode : accountToUpdate.PersonMailingPostalCode;
        accountToUpdate.PersonMailingStreet = String.isNotBlank(accountDetails.PersonMailingStreet) ? 
        accountDetails.PersonMailingStreet : accountToUpdate.PersonMailingStreet;
        update accountToUpdate;
        return accountToUpdate;
    }

    public static Account updateDhlAccount(Account accountToUpdate, Case caseDetails) {
        accountToUpdate.PersonMailingCountry = String.isNotBlank(caseDetails.Consumer_Country__c) ? 
        caseDetails.Consumer_Country__c : accountToUpdate.PersonMailingCountry;
        accountToUpdate.PersonMailingState = String.isNotBlank(caseDetails.Consumer_State__c) ? 
        caseDetails.Consumer_State__c : accountToUpdate.PersonMailingState;
        accountToUpdate.PersonMailingCity = String.isNotBlank(caseDetails.Consumer_City__c) ? 
        caseDetails.Consumer_City__c : accountToUpdate.PersonMailingCity;
        accountToUpdate.PersonMailingPostalCode = String.isNotBlank(caseDetails.Consumer_Postal_Code__c) ? 
        caseDetails.Consumer_Postal_Code__c : accountToUpdate.PersonMailingPostalCode;
        accountToUpdate.PersonMailingStreet = String.isNotBlank(caseDetails.Consumer_Street__c) ? 
        caseDetails.Consumer_Street__c : accountToUpdate.PersonMailingStreet;
        update accountToUpdate;
        return accountToUpdate;
    }

    public static Id getExistingAccountId(String email) {
        List<Account> existAccLst = SLT_DTC_Account.getAccountByEmail(email);
        return existAccLst.isEmpty() ? null : existAccLst[0].Id;
    }
}