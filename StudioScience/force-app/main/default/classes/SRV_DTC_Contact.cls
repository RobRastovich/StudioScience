public class SRV_DTC_Contact {

    public static void createContact(Contact contactDetail, String personEmail) {
        Contact newContact  = new Contact();
        newContact.LastName = contactDetail.LastName;
        newContact.Email = personEmail;
        newContact.MagentoID__c = contactDetail.MagentoID__c;
        Insert newContact;
    }

    public static void updateContact(Contact existContact, String personEmail, String MagentoID) {
        existContact.Email = personEmail;
        existContact.MagentoID__c = MagentoID;
        Update existContact;
    }

    public static void createOrUpdateContact(Contact contactDetail, String personEmail) {
        Id existingContactId = SLT_DTC_Contact.getExistingContactId(personEmail);
        if(existingContactId != null) {
            contactDetail.Id = existingContactId;
            List<Contact> lstContactInfo = SLT_DTC_Contact.getContactsByIDs(new Set<ID>{contactDetail.Id});
            if(lstContactInfo.size() > 0){
                updateContact(lstContactInfo[0], personEmail, contactDetail.MagentoID__c);
            }
        }else {
            createContact(contactDetail, personEmail);
        }
    }
}