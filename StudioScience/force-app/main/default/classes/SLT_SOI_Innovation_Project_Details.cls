public class SLT_SOI_Innovation_Project_Details {
    public static List<Innovation_Project_Details__c> getInnovationProjectDetails(Id innovationSampleRequestId) {
        List<Innovation_Project_Details__c> projectList = new List<Innovation_Project_Details__c>();
        if(String.isNotBlank(innovationSampleRequestId)) {
            projectList = [SELECT Id, AddressId__r.Name, AddressId__r.State__c, AddressId__r.Street__c, AddressId__r.City__c,
                              AddressId__r.Zip_Code__c, Phone__c, Quantity__c, Attention_To__c, Recipient_Email__c
                              FROM Innovation_Project_Details__c
                              WHERE InnovationId__c =: innovationSampleRequestId];
        }
        return projectList;
    }
}