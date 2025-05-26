public class SOI_OrderInformationTableController {
    public Id innovationSampleRequestId{get;set;}
    public String state{get;set;}

    public List<Innovation_Project_Details__c> getInnovationProjectDetails() {
        List<Innovation_Project_Details__c> listOfProjectDetails = new List<Innovation_Project_Details__c>();
        if(innovationSampleRequestId != null){
            listOfProjectDetails = SLT_SOI_Innovation_Project_Details.getInnovationProjectDetails(innovationSampleRequestId);
        }
        for(Innovation_Project_Details__c projectDetails : listOfProjectDetails) {
            state = projectDetails.AddressId__r.State__c;
            break;
        }
        return listOfProjectDetails;
    }  
}