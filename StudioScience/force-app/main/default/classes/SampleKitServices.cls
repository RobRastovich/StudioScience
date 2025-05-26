public class SampleKitServices {
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	Once the Tracking information is entered on a sample kit then the related cases will be updated
and start a milestone on the case giving the sales rep 30 days to make a sample selection in the
customer community
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateRelatedCaseWhenSampleKitIsShipped(List<Sample_Kit__c> samples, Map<Id, Sample_Kit__c> oldMap) {
        Set<Id> barrelGroupIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        
        for (Sample_Kit__c sk : samples) {
            Sample_Kit__c oldSampleKit = oldMap.get(sk.Id);
            if (String.isBlank(oldSampleKit.Tracking_Number__c) && String.isNotBlank(sk.Tracking_Number__c)) {
                barrelGroupIds.add(sk.Barrel_Order_Group__c);
            }
        }
        
        for (Case c : [select id, Sample_Kit_Shipped__c from Case where Barrel_Order_Group__c IN : barrelGroupIds]) {
            c.Sample_Kit_Shipped__c = true;
            casesToUpdate.put(c.Id, c);
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
        }
    }
    
    /**************************************************************************************************************
Author:        Craig Austgen
Company:       Slalom, LLC
Description:	pulls in the Submitter from the barrel order to set the recipient for the email alert that goes out
once the tracking number is entered
History
<Date>      <Authors Name>     <Brief Description of Change>
7/2018     	Craig Austgen       Initial Creation

***************************************************************************************************************/
    public static void updateSubmitter(List<Sample_Kit__c> samples) {
        Set<Id> barrelGroupIds = new Set<Id>();
        Map<Id, Id> barrelOrderGroupToSubmitter = new Map<Id, Id>();
        
        for (Sample_Kit__c sk : samples) {
            if (sk.Submitter__c == null) {
                barrelGroupIds.add(sk.Barrel_Order_Group__c);
            }
        }
        
        for (Case c : [select id, Barrel_Order_Group__c, Submitter__c from Case where Barrel_Order_Group__c IN : barrelGroupIds]) {
            barrelOrderGroupToSubmitter.put(c.Barrel_Order_Group__c, c.Submitter__c );
        }
        
        for (Sample_Kit__c sk : samples) {
            if (barrelOrderGroupToSubmitter.containsKey(sk.Barrel_Order_Group__c)) {
                sk.Submitter__c = barrelOrderGroupToSubmitter.get(sk.Barrel_Order_Group__c);
            }
        }
    }
    
    /**************************************************************************************************************
Author:        MaheshBabu
Company:       Tata Consultancy Services
Description:	This method will capture the date when Tracking_Number__c gets populated
History
<Date>      <Authors Name>     <Brief Description of Change>
10/2019     MaheshBabu       Initial Creation

***************************************************************************************************************/
    public static void setTrackingNumberCreationDateOnUpdate(List<Sample_Kit__c> newSamples, Map<Id,Sample_Kit__c> oldSamples) {   
        
        List<Id> Samplekitids = new List<Id>();
        for (Sample_Kit__c sk : newSamples) {
            if (sk.Tracking_Number__c != null && oldSamples.get(sk.Id).Delivery_Status__c!='Delivered' && sk.Delivery_Status__c=='Delivered') {
                sk.Tracking_Number_Creation_Date__c = System.now();
            }
            
        }
    }
    
    /**************************************************************************************************************
Author:        MaheshBabu
Company:       Tata Consultancy Services
Description:	This method will capture the date when Tracking_Number__c gets populated
History
<Date>      <Authors Name>     <Brief Description of Change>
10/2019     MaheshBabu       Initial Creation

***************************************************************************************************************/
    public static void setTrackingNumberCreationDateOnInsert(List<Sample_Kit__c> newSamples) {
        for (Sample_Kit__c sk : newSamples) {
            if (sk.Tracking_Number__c != null && sk.Delivery_Status__c=='Delivered') {
                sk.Tracking_Number_Creation_Date__c = System.now();
                
            }
        }
    }
    
    /**************************************************************************************************************
Author:        Priyankar Saha
Company:       Tata Consultancy Services
Description:	This method will automatically pull the Case Number from the Barrel Order Group at the time of Insertion of Sample Kit
History
<Date>      <Authors Name>     <Brief Description of Change>
11/2019     Priyankar Saha       Initial Creation

*****************************************************************************************************************/
    public static void setCasetoSampleKitOnInsert(List<Sample_Kit__c> newSamples){
        Set<Id> barrelOrderGroupIds = new Set<Id>();
        for(Sample_Kit__c sk : newSamples){
            if(sk.Barrel_Order_Group__c != null){
                barrelOrderGroupIds.add(sk.Barrel_Order_Group__c);
            }
        }
        Map<Id, Id> barrelIdToCaseIdMap = new Map<Id, Id>();
        for(Barrel_Order_Group__c br : [Select Id,(Select Id from Cases__r Limit 1) from Barrel_Order_Group__c Where Id IN : barrelOrderGroupIds]){
            if(!br.Cases__r.isEmpty()){
                barrelIdToCaseIdMap.put(br.Id, br.Cases__r[0].Id);
            }
        }
        System.debug('Barrel To Case Map:::'+barrelIdToCaseIdMap);
        for(Sample_Kit__c sk : newSamples){
            if(barrelIdToCaseIdMap.containsKey(sk.Barrel_Order_Group__c) && sk.Case__c == null){
                sk.Case__c = barrelIdToCaseIdMap.get(sk.Barrel_Order_Group__c);
            }
        }
    }
    
    
    /**************************************************************************************************************
    Author:        MaheshBabu
    Company:       Tata Consultancy Services
    Description:	This method will update the case status to Cancelled - Kit Not Selected if Final Email Sent? is true
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    07/2020     MaheshBabu       Initial Creation
    
    ***************************************************************************************************************/
    public static void updateCaseStatus(List<Sample_Kit__c> newSamples, Map<Id,Sample_Kit__c> oldSamples) {
       
        Set<Id> barrelGroupIds = new Set<Id>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        
        for (Sample_Kit__c sk : newSamples) {
            if (oldSamples.get(sk.Id).Final_Email_Sent__c == false && sk.Final_Email_Sent__c == true) {
                barrelGroupIds.add(sk.Barrel_Order_Group__c);
            }
        }
        
        for (Case c : [select id, Status from Case where Barrel_Order_Group__c IN : barrelGroupIds]) {
            c.Status = 'Cancelled - Kit Not Selected';
            casesToUpdate.put(c.Id, c);
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate.values();
        }
        
    }
    
        /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method will update the Delivery Status to Awaiting Shipment whenever a tracking number is entered in a sample kit
History
<Date>      <Authors Name>     <Brief Description of Change>
09/2021     Yash Jain       Initial Creation

***************************************************************************************************************/
    public static void setDeliveryStatusOnUpdate(List<Sample_Kit__c> newSamples, Map<Id,Sample_Kit__c> oldSamples) 
    {   
        List<Sample_Kit__c> sampleKits = new List<Sample_Kit__c>();
        for (Sample_Kit__c sk : newSamples) {
            if (sk.Tracking_Number__c != null && oldSamples.get(sk.Id).Tracking_Number__c == null) {
                Sample_Kit__c sampleKit  = new Sample_Kit__c(Id = sk.Id);
                sampleKit.Delivery_Status__c = 'Awaiting Shipment';
                sampleKits.add(sampleKit);
            }
            else if(sk.Fedex_Api_Status__c != oldSamples.get(sk.Id).Fedex_Api_Status__c)
            {
                Sample_Kit__c sampleKitStatusChange  = new Sample_Kit__c(Id = sk.Id);
                sampleKitStatusChange.FedEx_Last_Modified_DateTime__c = DateTime.now();
                sampleKits.add(sampleKitStatusChange);
            }          
        }
        update sampleKits;
    }
    
            /**************************************************************************************************************
Author:        Yash Jain
Company:       Metacube
Description:	This method will update the Delivery Status to Awaiting Shipment whenever a tracking number is entered in a sample kit
History
<Date>      <Authors Name>     <Brief Description of Change>
09/2021     Yash Jain       Initial Creation

***************************************************************************************************************/
    public static void setDeliveryStatusOnInsert(List<Sample_Kit__c> newSamples) 
    {   
        List<Sample_Kit__c> sampleKits = new List<Sample_Kit__c>();
        for (Sample_Kit__c sk : newSamples) {
            if (sk.Tracking_Number__c != null) {
                Sample_Kit__c sampleKit  = new Sample_Kit__c(Id = sk.Id);
                sampleKit.Delivery_Status__c = 'Awaiting Shipment';
                sampleKits.add(sampleKit);
            }            
        }
        update sampleKits;
    }
    
}