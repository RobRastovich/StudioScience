public class SLT_DTC_Account {
    /**
    *  @description : This method is use to fetch accounts by email.
    *  @args        : String email
    *  @return      : List<Account>
    **/
    public static List<Account> getAccountByEmail(String email){
        List<Account> existAccLst = new List<Account>();
        if(String.isNotBlank(email)){
            existAccLst = [SELECT Id 
                           FROM Account 
                           WHERE 
                           PersonEmail = :email LIMIT 1];  
        }
        return existAccLst;
    }

    /**
    *  @description : This method is use to fetch accounts by ids.
    *  @args        : Set<ID> ids
    *  @return      : List<Account>
    **/
    public static List<Account> getPersonAccountsByIDs(Set<ID> ids){
        return [SELECT Id, PersonContactId, PersonEmail, PersonMailingCountry, PersonMailingState,
                    PersonMailingCity, PersonMailingPostalCode, PersonMailingStreet, FirstName, Lastname
                    FROM Account 
                    WHERE Id IN :ids limit 1];
    }

    public static List<Account> getAccountByName(String accName){
        List<Account> existAccLst = new List<Account>();
        if(String.isNotBlank(accName)){
            existAccLst = [SELECT Id 
                          FROM Account 
                          WHERE Name = :accName LIMIT 1];  
        }
        return existAccLst;
    }
}