public without sharing class RollupSummaryUtility {
     
    //the following class will be used to house the field names
    //and desired operations
    public class fieldDefinition {
        public String operation {get;set;}
        public String childField {get;set;}
        public String parentField {get;set;}
         
        public fieldDefinition (String o, String c, String p) {
            operation = o;
            childField = c;
            parentField = p;
        }
    }
     
    public static void rollUpTrigger(list<fieldDefinition> fieldDefinitions,
    							list<sObject> records, String childObject, String childParentLookupField, 
    							String parentObject, String queryFilter, String dateFieldName) {
    								
		//ASSUMPTION: All calls to rollupTrigger will be dealing with Currency fields. If this tool is to be used
		//for other rollups (as it can be), please make the Multi-currency logic "smart."
		Map<String,CurrencyType> allCurrencies = BI_UtilityLogic.GetCurrencies();
		System.debug(LoggingLevel.INFO,'Found all currencies: ' + allCurrencies.size());
			        
        //Limit the size of list by using Sets which do not contain duplicate
        //elements prevents hitting governor limits
        set<Id> parentIds = new set<Id>();         
        for(sObject s : records) {
            parentIds.add((Id)s.get(childParentLookupField));
            System.debug(LoggingLevel.INFO, 'triggered child sObject: ' + s);
        }
        
        //ASSUMPTION: Get the existing Currency selections of the parent records. <MarketingPlanID,IsoCode>		
		/*
		Map<Id,String> mPlanCurrencies = new Map<Id,String>();		
		for (MarketingPlan__c s : [SELECT Id, CurrencyIsoCode FROM MarketingPlan__c WHERE Id IN :parentIds]) {
			mPlanCurrencies.put(s.Id, s.CurrencyIsoCode);
		}			
        */
        
        //populate query text strings to be used in child aggregrator and 
        //parent value assignment
        String fieldsToAggregate = '';
        String parentFields = '';
         
        for(fieldDefinition d : fieldDefinitions) {
            fieldsToAggregate += d.operation + '(' + d.childField + ') ' + ', ';
            parentFields += d.parentField + ', ';
        }
         
        //Using dynamic SOQL with aggergate results to populate parentValueMap
        String aggregateQuery = 'Select ' + fieldsToAggregate + 
        childParentLookupField + ' from ' + childObject + ' where  ' + 
        childParentLookupField + ' IN :parentIds ' + queryFilter + ' ' +
        ' group by ' + childParentLookupField;
         
        //Map will contain one parent record Id per one aggregate object
        map<Id, AggregateResult> parentValueMap = new map <Id, AggregateResult>();
         
        for(AggregateResult q : Database.query(aggregateQuery)){
            parentValueMap.put((Id)q.get(childParentLookupField), q);
			System.debug(LoggingLevel.INFO, 'AggResult: ' + q);
        }
         
        //list of parent object records to update
        list<sObject> parentsToUpdate = new list<sObject>();
        
        //Add the relevant date field for the parent record
        if(dateFieldName != null && !String.isBlank(dateFieldName)){
            parentFields += dateFieldName + ', ';
        }

        //ASSUMPTION: Retrieving CurrencyIsoCode is an assumption and could break.
        String parentQuery = 'select ' + parentFields + ' Id, CurrencyIsoCode' +
         ' from ' + parentObject + ' where Id IN :parentIds';
         
        //for each affected parent object, retrieve aggregate results and 
        //for each field definition add aggregate value to parent field
        for(sObject s : Database.query(parentQuery)) {
            System.debug(LoggingLevel.INFO, 'queried parent sObject: ' + s);
            Integer row = 0; //row counter reset for every parent record
            for(fieldDefinition d : fieldDefinitions) {
                String field = 'expr' + row.format();
                AggregateResult r = parentValueMap.get(s.Id);
                //r will be null if no records exist 
                //(e.g. last record deleted)
                if(r != null) { 
                    Decimal value = ((Decimal)r.get(field) == null ) ? 0 : 
                        (Decimal)r.get(field);
                        
                    //ASSUMPTION: Assume tool is only being used on Currency fields. Need to make sure the value takes into account
                    //multi-currency of the parent being updated.
                    //TODO: make this more configurable/intelligent.
                    //AggregateResult always returns a Currency amount in CORPORATE CURRENCY (USD) - multiple value by ExchangeRate.
                    /*
					System.debug(LoggingLevel.INFO,'Finding MP Currency from system currencies to extract desired exchange rate: ' + (String)s.get('CurrencyIsoCode'));
                    CurrencyType exchangeRate = allCurrencies.get((String)s.get('CurrencyIsoCode'));
                    if (exchangeRate == null) {
                    	System.debug(LoggingLevel.INFO,'Exchange Rate NOT Found');
                    } else {
                    	System.debug(LoggingLevel.INFO,'Exchange Rate Found: ' + exchangeRate.IsoCode + ' : ' + exchangeRate.ConversionRate);	
                    }
					*/                   

					Schema.DisplayType effectiveDateType = Schema.getGlobalDescribe().get(parentObject).getDescribe().
												fields.getMap().get(dateFieldName.toLowerCase()).
												getDescribe().getType();
					Decimal convertedValue = CurrencyConversionUtility.doConversion(effectiveDateType, (String) s.get('CurrencyIsoCode'), String.valueOf(s.get(dateFieldName)), value, false);
					s.put(d.parentField, convertedValue == null ? value : convertedValue);
                    
                } else {
                    s.put(d.parentField, 0);
                }
                row += 1; //plus 1 for every field definition after first
            }
            parentsToUpdate.add(s);
        }
         
        //if parent records exist, perform update of all parent records 
        //with a single DML statement
        if(parentsToUpdate.Size() > 0) {
            update parentsToUpdate;
        }
         
    }
}