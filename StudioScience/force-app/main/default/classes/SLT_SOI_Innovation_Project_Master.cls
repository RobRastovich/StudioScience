public class SLT_SOI_Innovation_Project_Master {
    public static List<Innovation_Project_Master__c> getInnovationSampleRecords() {
        List<Innovation_Project_Master__c> sampleList = new List<Innovation_Project_Master__c>();
        sampleList = [SELECT Id, Name, Start_Date__c, End_Date__c, Status__c FROM Innovation_Project_Master__c
                         WHERE Start_Date__c <=: Date.today()
                         AND Status__c =: SOI_Constants.STATUS_ACTIVE
                         AND End_Date__c >=: Date.today()];
        return sampleList;
    }
    
    public static String getProjectName(Id projectId) {
        Innovation_Project_Master__c innovationProject = new Innovation_Project_Master__c();
        if(String.isNotBlank(projectId)) {
            innovationProject = [SELECT Name FROM Innovation_Project_Master__c
                                    WHERE Id =: projectId];
        }
        return innovationProject.Name;
    }
}