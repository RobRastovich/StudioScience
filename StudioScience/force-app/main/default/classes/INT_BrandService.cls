public without sharing class INT_BrandService {
    public static void syncPublicGroups (List<INT_Brand__c> records, Map<Id, INT_Brand__c> priorValues) {
        // public groups to upsert indexed by brand id
        Map<Id, Group> groups = new Map<Id, Group>();

        // detect new or changed brands
        for (INT_Brand__c b : records) {
            if (String.isNotEmpty(b.Id) && b.Name != priorValues.get(b.Id)?.Name) {
                groups.put(
                    b.Id,
                    new Group(
                        Name = b.Name,
                        DeveloperName = b.Id
                    )
                );
            }
        }

        // assign id field for exisiting groups before upserting them
        for (Group g : [
            SELECT Id, DeveloperName 
            FROM Group
            WHERE DeveloperName IN :groups.keySet()]
        ) {
            if (groups.containsKey(g.DeveloperName)) {
                groups.get(g.DeveloperName).Id = g.Id;
            }
        }

        upsert groups.values();
    }
}