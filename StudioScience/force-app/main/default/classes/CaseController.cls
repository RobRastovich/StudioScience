public without sharing class CaseController {
  public static final String ABANDONED_RT = 'Abandoned Cases';

  @AuraEnabled
  public static List<Case> getCases() {
    String CurrentUser = UserInfo.getUserId();
    return [SELECT Id, CaseNumber, CreatedDate, Status, Owner.Name, Subject, RecordType.Name, Type, Submitter__r.Name FROM Case WHERE Submitter__c = :CurrentUser AND Submitted__c = True AND RecordType.Name != :ABANDONED_RT ORDER BY CaseNumber DESC];
  }

  @AuraEnabled
  public static Boolean getUserProf() {
    User u = [Select id, AccountId, UserType, ProfileId from User where id = :UserInfo.getUserId()];
    string uid = u.id;
    List<Profile> p = [SELECT UserLicense.Name FROM Profile WHERE id = :u.ProfileId limit 1];
    String usrLic = p[0].UserLicense.Name;
    String usrAcc = u.AccountId;

    if (usrLic == 'Customer Community Plus')
      return true;
    else
      return false;
  }

  @AuraEnabled
  public static List<Case> getClosedCases() {
    String CurrentUser = UserInfo.getUserId();
    return [SELECT Id, CaseNumber, ClosedDate, CreatedDate, toLabel(Status), Owner.Name, Subject, RecordType.Name, Type, Submitter__r.Name, toLabel(Category_1__c), LastModifiedDate FROM Case WHERE Submitter__c = :CurrentUser AND Submitted__c = True AND IsClosed = true AND RecordType.Name != :ABANDONED_RT ORDER BY CaseNumber DESC];
  }

  @AuraEnabled
  public static List<Case> getOpenCases() {
    String CurrentUser = UserInfo.getUserId();
    return [SELECT Id, CaseNumber, CreatedDate, toLabel(Status), Owner.Name, Subject, RecordType.Name, Type, Submitter__r.Name, toLabel(Category_1__c), LastModifiedDate FROM Case WHERE Submitter__c = :CurrentUser AND IsClosed != true AND Submitted__c = True AND RecordType.Name != :ABANDONED_RT ORDER BY CaseNumber DESC];
  }

  @AuraEnabled
  public static List<Case> getAllClosedCases() {

    if (getUserProf()) {
      UserAccess ua = new UserAccess();
      Set<Case> userCaseSet = ua.userCases();
      List<Case> sumitterCaselist = [Select id from case where Submitter__c = :UserInfo.getUserId()];
      userCaseSet.addAll(sumitterCaselist);
      List<Case> csList = [SELECT id, Account.Name, CaseNumber, CreatedDate, Status, Owner.Name, Subject, RecordType.Name, Type, Submitter__r.Name FROM Case WHERE IsClosed = true AND id IN :userCaseSet AND Submitted__c = True AND RecordType.Name != :ABANDONED_RT ORDER BY CaseNumber DESC];
      return csList;
    } else
      return null;
  }

  @AuraEnabled
  public static List<Case> getAllOpenCases() {

    if (getUserProf()) {
      UserAccess ua = new UserAccess();
      Set<Case> userCaseSet = ua.userCases();
      List<Case> sumitterCaselist = [Select id from case where Submitter__c = :UserInfo.getUserId()];
      userCaseSet.addAll(sumitterCaselist);
      return [SELECT id, Account.Name, CaseNumber, CreatedDate, Status, Owner.Name, Subject, RecordType.Name, Type, Submitter__r.Name FROM Case WHERE IsClosed != true AND id IN :userCaseSet AND Submitted__c = True AND RecordType.Name != :ABANDONED_RT ORDER BY CaseNumber DESC];
    } else
      return null;
  }

  @AuraEnabled
  public static Boolean reopenCases(List<String> caseIdList, String reopenExplanation) {
    EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Case_Reopened' LIMIT 1];
    List<Case> reopenedCases = new List<Case>();
    List<FeedItem> chatterPosts = new List<FeedItem>();
    Map<String, Object> reopenExplanationMap = (Map<String, Object>) JSON.deserializeUntyped(reopenExplanation);
    Boolean success = true;
    Set<String> caseIdSet = new Set<String>();
    for (String caseId : caseIdList) {
      if (!caseIdSet.contains(caseId)) {
        reopenedCases.add(new Case(Id = caseId, isReOpened__c = true, Status = 'In Progress', Reopen_Explanation__c = (String)(reopenExplanationMap.get(caseId))));
        caseIdSet.add(caseId);
        FeedItem post = new FeedItem();
        post.ParentId = caseId;
        post.Body = 'The case has been re-opened with the following explanation:\n' + (String)(reopenExplanationMap.get(caseId));
        post.Type = 'TextPost';
        post.Title = 'Case Re-opened';
        chatterPosts.add(post);
      }
    }
    try {
      update reopenedCases;
      insert chatterPosts;
    } catch (DMLException e) {
      success = false;
    }
    return success;
  }
}