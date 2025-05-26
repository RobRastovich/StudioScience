public class ComplianceKickoffAttachmentCntrl {
    @AuraEnabled 
    public static void UpdateAttachments (String CaseId){
        
     //Below lines 
     List<Case> childCases = new List<Case>();
     childCases = [SELECT id,CaseNumber FROM Case WHERE ParentId=:CaseId  AND (Recordtype.DeveloperName='Customer_Data' OR Recordtype.DeveloperName='Inquiry')];
     List<ContentDocument> DocumentList = new List<ContentDocument>();  
     Set<Id> documentIds = new Set<Id>();  //store file ids
     List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
     if(CaseId!=null){
      cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink 
                                    where LinkedEntityId=:CaseId];
      }                                
     for(ContentDocumentLink cdLink:cdl){  
       documentIds.add(cdLink.ContentDocumentId);  // Document ids
     }
     System.debug('====Child ids====='+childCases);
         List<ContentDocumentLink> childcontdoclist = new  List<ContentDocumentLink>();
         List<ContentDocumentLink> Existingcontdoclist = new  List<ContentDocumentLink>();
         Set<Id>CaseIds = new Set<Id>();
         
         for(Case caserec:childCases){
             CaseIds.add(caserec.id);
         }
         Map<id,ContentDocumentLink>ExistingContDocMap = new Map<id,ContentDocumentLink>();
         if(CaseIds.size()>0){
         //Existingcontdoclist = [SELECT ID,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:documentIds AND LinkedEntityId IN: CaseIds];
         Existingcontdoclist = [SELECT ID,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: CaseIds];
         }
         System.debug('====Exisitng docs====='+Existingcontdoclist);
         
         if(Existingcontdoclist.size()>0){
         for(ContentDocumentLink cont:Existingcontdoclist ){
             if(!ExistingContDocMap.containsKey(cont.ContentDocumentId)){
                 ExistingContDocMap.put(cont.ContentDocumentId,cont);
             }else 
                 ExistingContDocMap.get(cont.ContentDocumentId);
         }

         for(id child:documentIds){
           if(ExistingContDocMap.containsKey(child) ){
               documentIds.remove(child);
               CaseIds.remove(ExistingContDocMap.get(child).LinkedEntityId);
           }
           
        }
        
      }
      System.debug('=====Case ids====='+CaseIds);
      System.debug('=====Document ids====='+documentIds);
      for(id caserec:CaseIds){
         for(id child:documentIds){
            ContentDocumentLink docLink = new ContentDocumentLink();
                docLink.LinkedEntityId = caserec;
                docLink.ContentDocumentId = child;
                childcontdoclist.add(docLink);
          }
        }
        try{
        insert childcontdoclist;
        }
        catch(exception e){
        String errorMessage = 'Error creating attachments' + e.getMessage() + '\n' + e.getStackTraceString();
                CreateExceptionLog.insertErrorLog('caseServices', 'kickoffCustomerdata', String.valueOf(errorMessage), 'Fatal');
        }
          
        
    }

}