public class SRV_CustomSettings {
    /**
    *  @description : This method is use to create instance of Custom Seeting(Topic_Added_For_User__c) CRM.
    *  @args        : String, Integer 
    *  @return      : Topic_Added_For_User__c
    **/
    public static Topic_Added_For_User__c createInstanceTopic(String topicName, Integer countOfTopic){
        Topic_Added_For_User__c insertSetting = new Topic_Added_For_User__c();
        if(String.isNotBlank(topicName)){
            insertSetting.Topic_Name__c = topicName;
            insertSetting.Name = String.valueof(countOfTopic); 
        }
        return insertSetting;
    }
}