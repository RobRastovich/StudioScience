public class SLT_Consumer_Response {
    /**
    *  @description : This method is use to fetch Consumer Response (CRM).
    *  @args        : Case 
    *  @return      : Consumer_Response__c
    **/
    public static Consumer_Response__c getConsumerResponseRecord(Case caseRecord){
        List<Consumer_Response__c> consumerResponses = new List<Consumer_Response__c>();
        Consumer_Response__c recordConsumerResponse = new Consumer_Response__c();
        if(caseRecord.trigger_word__c == false){
            if(String.isNotBlank(caseRecord.ParentId)){
                consumerResponses = [SELECT Brand__c, Additional_Information__c, AutoResponse_Acknowledgement__c, 
                                 How_can_we_help_you__c, Email_Content__c, RoutingQueue__c, Country__c
                                 FROM Consumer_Response__c 
                                 WHERE Brand__c =: caseRecord.Brand__c
                                 AND Additional_Information__c =: null 
                                 AND How_can_we_help_you__c =: null
                                 AND RoutingQueue__c != null];
            }else{
            consumerResponses = [SELECT Brand__c, Additional_Information__c, AutoResponse_Acknowledgement__c, 
                                 How_can_we_help_you__c, Email_Content__c, RoutingQueue__c, Country__c
                                 FROM Consumer_Response__c 
                                 WHERE Brand__c =: caseRecord.Brand__c
                                 AND Additional_Information__c =: caseRecord.AdditionalInformation__c 
                                 AND How_can_we_help_you__c =: caseRecord.How_can_we_help__c
                                 AND RoutingQueue__c =: caseRecord.Owner.Name
                                 AND (Country__c =: caseRecord.Consumer_Country__c
                                 OR Country__c = null)
                                 ORDER BY Country__c NULLS LAST];
            }
            if(consumerResponses.size() > 0){
                recordConsumerResponse = consumerResponses[0];
                for(Consumer_Response__c consumerResponse : consumerResponses){
                    if(caseRecord.Consumer_Country__c == consumerResponse.Country__c){
                        recordConsumerResponse = consumerResponse;
                        break;
                    }
                }
            }
        }
        else{
            recordConsumerResponse = [SELECT Brand__c, Additional_Information__c, AutoResponse_Acknowledgement__c, 
                                         How_can_we_help_you__c, Email_Content__c, RoutingQueue__c, Country__c
                                         FROM Consumer_Response__c 
                                         WHERE Brand__c =: caseRecord.Brand__c
                                         AND Trigger_Word__c = True];
        }
        recordConsumerResponse = recordConsumerResponse != null  ? recordConsumerResponse : null;
        return recordConsumerResponse;
    }
}