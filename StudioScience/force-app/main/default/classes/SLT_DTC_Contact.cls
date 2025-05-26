public class SLT_DTC_Contact {
    
    public static Id getExistingContactId(String email) {
        List<Contact> existContactLst = getContactByEmail(email);
        return existContactLst.isEmpty() ? null : existContactLst[0].Id;
    }

    public static List<Contact> getContactByEmail(String email){
        List<Contact> existContactLst = new List<Contact>();
        if(String.isNotBlank(email)){
            existContactLst = [SELECT Id 
                                  FROM Contact 
                                  WHERE Email = :email
                                  AND Account.RecordType.DeveloperName = 'ConsumerAccount'
                                  LIMIT 1];
        }
        return existContactLst;
    }

    public static List<Contact> getContactsByIDs(Set<ID> ids){
        return [SELECT Id, Name, Email, MagentoID__c 
                    FROM Contact 
                    WHERE Id IN :ids limit 1];
    }
}