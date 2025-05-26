public with sharing class ContactQuery {
    @AuraEnabled( cacheable = true )
    public static List<Contact> getContactList(String acctId){ 
        List<AccountContactRelation> accountContactRelations = [SELECT ContactId FROM AccountContactRelation WHERE AccountId =:acctId];
        Set<Id> contactRelationsIds = new Set<Id>();
        for (AccountContactRelation relation : accountContactRelations) {
            contactRelationsIds.add(relation.ContactId);
        }
        List<Contact> directAndIndirectContacts = [SELECT Id, Name FROM Contact WHERE Id IN :contactRelationsIds order by Name];
        return directAndIndirectContacts;
    }
}