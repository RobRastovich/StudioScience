/**************************************************************************************
 Apex Class Name     : PR_Team_TriggerHandler
 Created Date        : 10-Nov-2019
 Auther              : Harikrishna P 
 Function            : Handles events from the PR_Team_Trigger
 Test Class          : BS_PR_Team_Trigger_Test
 Updates :
*************************************************************************************/

public class PR_Team_TriggerHandler{
    
	public static void handleAfterInsert(List<PR_Team__c> Trigger_New){
		if(Trigger_New.size()>0)createShareRecord(Trigger_New);
    }	
	
    public static void handleBeforeDelete(Map<Id, PR_Team__c> Trigger_oldMap) {
        set<id> UserIdSet=new set<id>();
		set<id> PRHeaderIdSet=new set<id>();
        ID currentUserId=Userinfo.getUserId();
		for(PR_Team__c pt:Trigger_oldMap.values()){
			if(currentUserId == pt.PR_Header_OwnerID__c){
				UserIdSet.add(pt.Collaborator__c);
				PRHeaderIdSet.add(pt.PR_Header__c);
			}
			else {
				pt.adderror('Only record owner can delete.');
			}
		}
		if(UserIdSet.size()>0 && PRHeaderIdSet.size()>0) deleteShareRecord(UserIdSet,PRHeaderIdSet);
    }
	
	public static void createShareRecord(List<PR_Team__c> Trigger_New) {
		
		List<PR_Header__Share> PRHShareList = new List<PR_Header__Share>();
		ID currentUserId=Userinfo.getUserId();
		for (PR_Team__c pt : Trigger_New) {									  		
			if(currentUserId == pt.PR_Header_OwnerID__c) {
			  PR_Header__Share Share= new PR_Header__Share(
				ParentId= pt.PR_Header__c,
				UserOrGroupId= pt.Collaborator__c,
				AccessLevel= pt.Access_Level__c);				
			  PRHShareList.add(Share);
			}
			else {
				pt.adderror('Only record owner can share.');
			}
		}			
		if(PRHShareList.size()>0) insert PRHShareList;
	}
		
	public static void deleteShareRecord(set<id> UserIdSet, set<id> PRHeaderIdSet) {
		Delete [SELECT Id, ParentId, UserOrGroupId FROM PR_Header__Share Where UserOrGroupId IN:UserIdSet AND ParentId IN:PRHeaderIdSet];
	}
}