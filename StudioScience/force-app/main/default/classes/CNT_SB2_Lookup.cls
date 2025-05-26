public class CNT_SB2_Lookup {

    @AuraEnabled(cacheable=true)
    public static String getFieldLabel(String sObjectName, String lookupField) {
        return UTL_Describe.getFieldDescribe(sObjectName, lookupField).getLabel();
    }

    @AuraEnabled
    public static List<sObject> getRecords(
        String sObjectName, String lookupField, String referenceField, String referenceSubField, String searchString, String filters,
        List<String> fieldNamesToSearch, Boolean searchFromMultipleFields) {
        try {
            List<FilterActionWrapper> filterActions = null;
            if(!String.isEmpty(filters) && filters != null && filters.trim() != '') {
                filterActions = (List<FilterActionWrapper>)JSON.deserialize(filters, List<FilterActionWrapper>.class);
            }

            List<sObject> listOfSObjectResults = new List<sObject>();
            Schema.DescribeFieldResult fieldDescribe = UTL_Describe.getFieldDescribe(sObjectName, lookupField);
            List<Schema.sObjectType> objectsLookedUpTo = fieldDescribe.getReferenceTo();
            referenceField = String.escapeSingleQuotes(referenceField);
            Integer maxReturnable = Math.round(1001 / objectsLookedUpTo.size()) + 1;

            for (Schema.sObjectType objectLookedUpTo : objectsLookedUpTo) {
                Schema.DescribeSObjectResult objectDescribe = objectLookedUpTo.getDescribe();
                String sObjectNameLookedUpTo = objectDescribe.getName();
                String selectStatement = 'SELECT Id, ' + handleReferenceField(sObjectNameLookedUpTo, referenceField, fieldNamesToSearch, 
                    searchFromMultipleFields);
                if (referenceSubField != null) {
                    selectStatement += ', ' +  String.escapeSingleQuotes(referenceSubField);
                }
                String whereStatement = '';

                if (searchString != null && searchString.trim() != '') {
                    if(searchFromMultipleFields && fieldNamesToSearch != null) {
                        whereStatement += ' (';
                        for(Integer i = 0; i < fieldNamesToSearch.size(); i++) {
                            whereStatement += ' ' + fieldNamesToSearch[i] + ' LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'' + 
                                (fieldNamesToSearch.size() != i + 1 ? ' OR' : '');
                        }
                        whereStatement += ') ';
                    }
                    else {
                        whereStatement += ' ' + referenceField + ' LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\''; 
                        whereStatement += ' AND ' + referenceField + ' != null';
                    }
                }

                whereStatement = handleGroupObject(whereStatement, sObjectNameLookedUpTo);
                whereStatement = handleRecordTypeObject(whereStatement, sObjectNameLookedUpTo, sObjectName);

                if (filterActions != null && !filterActions.isEmpty()) {
                    if (whereStatement != '') {
                        whereStatement += ' AND';
                    }
                    System.Debug('--'+filterActions);
                    for (FilterActionWrapper action : filterActions) {
                        String lastThree;
                        if(whereStatement.length()>3) {
                            lastThree = whereStatement.substring(whereStatement.length()-3, whereStatement.length());
                            System.debug('lastThree--'+lastThree);
                        }
                        if(!String.isEmpty(action.field) && !String.isEmpty(whereStatement) && (String.isEmpty(lastThree) || lastThree!= 'AND')) {
                            whereStatement += ' AND';
                        }
                        whereStatement += ' ' + action.buildClause();
                    }
                }

                if (whereStatement != '') {
                    whereStatement = ' WHERE' + whereStatement;
                }
				SYstem.debug('whereStatement--'+whereStatement);
                listOfSObjectResults.addAll(
                    Database.Query(selectStatement + ' FROM ' + sObjectNameLookedUpTo + whereStatement + ' LIMIT ' + maxReturnable)
                );
            }
            return listOfSObjectResults;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '|' + e.getStackTraceString());
        }
    }

    @AuraEnabled(cacheable=true)
    public static sObject getRecordById(String sObjectName, String lookupField, String referenceField, String referenceSubField, List<String> fieldNamesToSearch, String recordId) {
        try {
            Schema.DescribeFieldResult fieldDescribe = UTL_Describe.getFieldDescribe(sObjectName, lookupField);
            for (Schema.sObjectType objectLookedUpTo : fieldDescribe.getReferenceTo()) {
                Schema.DescribeSObjectResult objectDescribe = objectLookedupTo.getDescribe();
                String sObjectNameLookedUpTo = objectDescribe.getName();
                if (!recordId.startsWithIgnoreCase(objectDescribe.getKeyPrefix())) {
                    continue;
                } else {
                    referenceField = String.escapeSingleQuotes(handleReferenceField(sObjectNameLookedUpTo, referenceField, null, false));
                    String selectStatement = 'SELECT Id ';
                    if (referenceSubField != null) {
                        selectStatement += ', ' +  String.escapeSingleQuotes(referenceSubField);
                    }
                    if(fieldNamesToSearch != null && fieldNamesToSearch.size() > 0) {
                        selectStatement += ', ' + String.join(fieldNamesToSearch, ', ');
                    }
                    return Database.Query(selectStatement + ' FROM ' + sObjectNameLookedUpTo + ' WHERE Id = :recordId');
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @testVisible
    private static String handleReferenceField(String objectName, String referenceField, List<String> fieldNamesToSearch, 
        Boolean searchFromMultipleFields) {
        if(searchFromMultipleFields && fieldNamesToSearch != null) {
            referenceField = String.join(fieldNamesToSearch, ', ');
        }
        else if (objectName == 'User' && referenceField.toLowerCase() == 'name') {
            referenceField = 'firstName, lastName';
        } else if (fieldNamesToSearch != null) {
            referenceField = String.join(fieldNamesToSearch, ', ');
        }
        return referenceField;
    }

    @testVisible
    private static String handleGroupObject(String whereStatement, String sObjectNameLookupUpTo) {
        if (sObjectNameLookupUpTo == 'Group') {
            if (whereStatement != '') {
                whereStatement += ' AND';
            }
            whereStatement += ' Type = \'Queue\'';
        }
        return whereStatement;
    }

    @testVisible
    private static String handleRecordTypeObject(String whereStatement, String sObjectNameLookupUpTo, String sObjectName) {
        if (sObjectNameLookupUpTo == 'RecordType') {
            if (whereStatement != '') {
                whereStatement += ' AND';
            }
            whereStatement += ' sObjectType = \'' + sObjectName + '\'';
        }
        return whereStatement;
    }

    private class FilterActionWrapper {
        public String type {get; set;}
        public String field {get; set;}
        public String operator {get; set;}
        public String value {get; set;}
        public Boolean stringWrap {get; set;}
        public FilterActionWrapper() {}
        public String buildClause() {
            if (type == 'operator') {
                return String.escapeSingleQuotes(value);
            } else {
                if (value != 'null' && value != null) {
                    if(operator != 'IN') {
                        if (stringWrap == null || stringWrap) {
                            value = ' \'' + String.escapeSingleQuotes(value) + '\'';
                        } else {
                            value = ' ' + value.replaceAll('\'','');
                        }
                    }
                    else {
                        value = ' ' + value;
                    }
                }
                return field.replaceAll('\'', '') + ' ' + operator.replaceAll('\'', '') + value;
            }
        }
    }

}