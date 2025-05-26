public class GBSFlowController {


    public Flow.Interview.GBS_Case_Submission_Start myFlow {get;set;} 
    public List<Attachment> newAttachments {get; set; }
    public ID returnId;
    public String recordTypeName {get;set;}
    public String AccessGroup {get;set;}
    public String priorityOfCustomer {get;set;}
    public Boolean recordCreated {get;set;}
    private final Integer NUM_OF_ATTACHMENTS = 10; 
    public ID flowID {get;set;}
    public List<FeedItem> lfi {get;set;}

    public GBSFlowController() {

        System.debug('Inside constructor:::');

        newAttachments=new List<Attachment>(); 
          for (Integer i=0; i<NUM_OF_ATTACHMENTS; i++) {
                newAttachments.add(new Attachment());
          }
    }

    public String getUserProfile() {
        Profile p =[select Name from Profile where Id = :userinfo.getProfileId() Limit 1];

            System.debug('profile ' + p.Name);
            recordTypeName = p.Name;
            return recordTypeName;
     

    }
    
     public String getuserAccessGroup() {
     System.debug('Inside getuserAccessGroup:::');
        User u =[select Access_Group__c from User where Id = :userinfo.getUserId() Limit 1];

            System.debug('User Access Group: ' + u.Access_Group__c);
            AccessGroup = u.Access_Group__c;
            return AccessGroup;
     

    }
            
    public String getCustomerPriority() {
    System.debug('Inside getCustomerPriority:::');
        User p1 = [select name,profileId, Profile.Name,GBS_VIP_User__c from User where Id = :userinfo.getUserId()];
        System.debug(p1.Profile.Name);
            priorityOfCustomer = p1.GBS_VIP_User__c;
            if(p1.GBS_VIP_User__c == null){
                priorityOfCustomer = 'null';
            }
            System.debug('The profile is: ' + priorityOfCustomer);
            return priorityOfCustomer;
        
       }

     public List<Attachment> getAtts() {

     System.debug('Inside getAtts:::');
        if(myFlow != null) {
            List<Attachment> currentAttachments = [select Name, BodyLength from Attachment where parentId = :myFlow.CaseRecord.Id];
            if(currentAttachments.size() > 0) {
                return currentAttachments;
            }

        }
        return null;
    } 

    public Map<String,String> getFeedList() {
        
            Map<String,String> MapOfFiles=new Map<String,String>();
            if(myFlow != null) {
               lfi = [select parentId,Type, ContentSize, ContentFileName,Title from FeedItem where parentId = :myFlow.CaseRecord.Id AND Type = 'ContentPost'];
               if(lfi.size() > 0) {
                   system.debug('Feedlist to render ==>'+lfi);
                   for(FeedItem FI:lfi)
                   {
                       String fsize=String.valueOf(FI.ContentSize);
                       String fname=String.valueOf(FI.ContentFileName);
                       MapOfFiles.put(fname,fsize);
                    }   
                   return MapOfFiles;
                }
            }
            return null;
        }
        

    public void addMore() {
    System.debug('Inside addMore:::');
        newAttachments=new List<Attachment>();
        for (Integer i=0; i<NUM_OF_ATTACHMENTS; i++) {
            newAttachments.add(new Attachment());
        }
    }

    public void save() {
    System.debug('Inside save::');
        if(myFlow != null) {
        flowID = myFlow.CaseRecord.Id;
        }
        List<Attachment> toInsert=new List<Attachment>();
        for (Attachment newAtt : newAttachments) {
            if (newAtt.Body!=null) {
                newAtt.parentId=flowID;
                toInsert.add(newAtt);
            }
        }
        if(toInsert.size() > 0){
            recordCreated = true;
            insert toInsert;
            newAttachments.clear();
            addMore();   
        }
    }
}