public class SLT_Contact {
    /**
    *  @description : This method is use to fetch contact by id.
    *  @args        : String 
    *  @return      : Contact
    **/
    public static Contact getContactByID(String contactId){
        List<Contact> contacts = new List<Contact>();
        contacts = [SELECT Id, Name, LastName 
                       FROM Contact 
                       WHERE Id =: contactId];
        Contact recordContact = new Contact();
        recordContact = contacts.size()>0  ? contacts[0] : null;
        return recordContact;
    }
}