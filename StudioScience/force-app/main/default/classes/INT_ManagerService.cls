public without sharing class INT_ManagerService {
    public static void syncSharingGroupMembership(List<INT_Manager__c> records, Map<Id, INT_Manager__c> priorValues) {
        Set<Id> usersInScope = new Set<Id>();

        for (INT_Manager__c m : records) {
            if (String.isNotEmpty(m.INT_User__c)) {
                usersInScope.add(m.INT_User__c);

                if (
                    String.isNotEmpty(m.Id) &&
                    m.INT_User__c != priorValues.get(m.Id)?.INT_User__c &&
                    String.isNotEmpty(priorValues.get(m.Id)?.INT_User__c)
                ) {
                    usersInScope.add(priorValues.get(m.Id).INT_User__c);
                }
            }
        }

        if (!usersInScope.isEmpty()) {
            System.enqueueJob(new SyncSharingGroupMembership(usersInScope));
        }
    }

    public class SyncSharingGroupMembership implements Queueable {
        public Set<Id> userIds;

        public SyncSharingGroupMembership(Set<Id> userIds) {
            this.userIds = userIds;
        }

        public void execute(QueueableContext qc) {
            Set<String> brandsInScope = new Set<String>();
            Map<Id, Group> sharingGroupByBrandId = new Map<Id, Group>();
            Map<Id, Set<Id>> requiredMembershipByUserId = new Map<Id, Set<Id>>();
            Map<Id, Map<Id, GroupMember>> currentMembershipByUserId = new Map<Id, Map<Id, GroupMember>>();

            for (Id userId : this.userIds) {
                if (String.isNotBlank(userId)) {
                    requiredMembershipByUserId.put(userId, new Set<Id>());
                    currentMembershipByUserId.put(userId, new Map<Id, GroupMember>());
                }
            }

            for (INT_Manager__c m : [
                SELECT Id, INT_User__c, INT_Brand__c
                FROM INT_Manager__c WHERE INT_User__c IN :requiredMembershipByUserId.keySet()
            ]) {
                if (String.isNotBlank(m.INT_Brand__c)) {
                    requiredMembershipByUserId.get(m.INT_User__c).add(m.INT_Brand__c);
                    brandsInScope.add(m.INT_Brand__c);
                }
            }

            for (GroupMember gm : [
                SELECT Id, Group.DeveloperName, UserOrGroupId
                FROM GroupMember WHERE
                UserOrGroupId IN: currentMembershipByUserId.keySet()]
            ) {
                try {
                    if (Id.valueOf(gm.Group.DeveloperName).getSobjectType() == Schema.INT_Brand__c.SObjectType) {
                        currentMembershipByUserId.get(gm.UserOrGroupId).put(
                            Id.valueOf(gm.Group.DeveloperName),
                            gm
                        );
                    }
                } catch (Exception e) {
                    continue;
                }
            }

            List<GroupMember> newMemberships = new List<GroupMember>();
            List<GroupMember> outdatedMemberships = new List<GroupMember>();

            for (Group g : [
                SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName IN :brandsInScope
            ]) {
                sharingGroupByBrandId.put(g.DeveloperName, g);
            }

            for (Id userId : requiredMembershipByUserId.keySet()) {
                for (Id brandId : requiredMembershipByUserId.get(userId)) {
                    if (
                        !currentMembershipByUserId.get(userId).keySet().contains(brandId) &&
                        sharingGroupByBrandId.containsKey(brandId)
                        
                        ) {
                        newMemberships.add(new GroupMember(
                            UserOrGroupId = userId,
                            GroupId = sharingGroupByBrandId.get(brandId).Id
                        ));
                    }
                }

                for (Id brandId : currentMembershipByUserId.get(userId).keySet()) {
                    if (!requiredMembershipByUserId.get(userId).contains(brandId)) {
                        outdatedMemberships.add(
                            currentMembershipByUserId.get(userId).get(brandId)
                        );
                    }
                }
            }

            insert newMemberships;
            delete outdatedMemberships;
        }
    }
}