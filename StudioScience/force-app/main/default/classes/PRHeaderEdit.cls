public class PRHeaderEdit {
    private ApexPages.StandardController controller;
    public Map<Id,Profile> profileMap {get;set;}
    private PR_Header__c prHeaderRec;
    public string prHeaderRecId {get; set;}
    public Boolean isnoAccess {get; set;}
    
    public PRHeaderEdit(ApexPages.StandardController controller){
        this.controller = controller;
        isnoAccess = false;
        profileMap = new Map<Id,Profile>([Select Id, Name From Profile Where Name IN ('Field Marketing Analyst - Platform','Field Marketing Director - Platform','Field Marketing Manager - Platform','System Administrator')]);
        prHeaderRecId = ApexPages.currentPage().getParameters().get('id');
        prHeaderRec = [select id from PR_Header__c where id =: prHeaderRecId Limit 1];
        if(!profileMap.keySet().contains(UserInfo.getProfileId())){
            isnoAccess = true;
        }
    }
    
    public PageReference redirectEdit() {
        /*if(isnoAccess){
            return new ApexPages.pageReference ('/'+prHeaderRec.Id+'/e?retURL=%2F'+prHeaderRec.Id +'&nooverride=1'); 
        }*/
        return new ApexPages.PageReference ('/apex/EditPRHeaderVF');
    }
    
}