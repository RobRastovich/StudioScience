public class AttachmentHandler{

  Public static void AttachmentToFeed(list<Attachment> newList)
  {
      list<FeedItem> listOfFeedFiles = new List<FeedItem>(); 
      List<Attachment> toDelete =new list<Attachment>();
      List<Id> listtoDelete=new list<Id>();
      List<Id> emailMsgIds=new List<Id>();
      Map<Id,Id> emailMsgIdMap=new Map<Id,Id>();
      String CurrentUser=UserInfo.getUserId();
      Boolean IsPortalUser=[Select IsPortalEnabled from User u where id = :CurrentUser].IsPortalEnabled ;
      Id attParentId;
      String sObjName;
    System.debug('Attachment Added - Trigger Fired **********************'); 
    for(Attachment attachment : newList){
              System.debug('Att list==>'+newList);
              sObjName = 'null';
              attParentId=attachment.ParentId;         //Store the Attachment Parent Id
              sObjName = attParentId.getSObjectType().getDescribe().getName();  //Get object name
            
            if(sObjName=='EmailMessage' && !attachment.ContentType.startsWith('image')){  //If Attachment parent is Email
              emailMsgIds.add(attParentId);   //create a list of EmailMessage Ids
            }
        
                
            if(sObjName=='Case'|| (sObjName=='EmailMessage' && !attachment.ContentType.startsWith('image'))){
                     
                     FeedItem post = new FeedItem();
                     post.ParentId = attParentId; 
                     post.Body = 'Attachment added';
                     post.Type = 'ContentPost';
                     post.ContentData = attachment.body;
                     post.ContentFileName = attachment.Name;
                     post.Title = attachment.Name;
               if(IsPortalUser)     
                     post.Visibility = 'AllUsers';
               else
                     post.Visibility = 'InternalUsers';
                     listOfFeedFiles.add(post);                        
                   
                   if(sObjName=='Case')       
                      listtoDelete.add(attachment.id);      //Delete Attachment only if it's on Case not from EmailMessage
                }
        
     }
               
    for(EmailMessage em:[Select id,parentId from EmailMessage where id IN :emailMsgIds])
    emailMsgIdMap.put(em.id,em.parentId);            //EmailMessage ParentId
    
    for(FeedItem fit:listOfFeedFiles)
      {
        if(emailMsgIdMap.containsKey(fit.ParentId))
           {
               fit.ParentId=emailMsgIdMap.get(fit.ParentId);            //Modify ParentId for Email Attachments to be cloned
               fit.Body = 'Email Attachment added';                    //Modify Body of Email Attachment to be cloned.
           }
         
      }
      
    if(!listofFeedFiles.isEmpty()){
         System.debug('Insert feed'+listOfFeedFiles);
         insert listOfFeedFiles;  
     }   
   
     for(Attachment at : [Select Id from Attachment where Id in :listtoDelete]){
         toDelete.add(at);
     }

     system.debug('toDelete**'+toDelete);
     if(!toDelete.isEmpty()) 
         delete toDelete; 
    }
    
    Public static void handleBeforeDeleteActions(map<id,Attachment> oldMap){
        delete [select id from PR_Attachment__c where Attachment_Id__c IN: oldMap.keySet()];
    }
}