public with sharing class UserAccess{

        public Set<Case> userCases()
    {
        List<Case> allCases=[Select id from Case];
       
        Set<Case> caseIdSet = new Set<Case>();
        caseIdSet.addAll(allCases);
        system.debug('caseIdSet===>'+caseIdSet);
        return caseIdSet;
    }
    
}