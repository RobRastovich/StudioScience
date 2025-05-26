public without sharing class BI_UtilityLogic {
	
	public static ID getRecordTypeId(String sObjectName, String recordTypeName){
		return [SELECT id FROM recordtype WHERE DeveloperName = :recordTypeName AND SobjectType =:sObjectName limit 1].id;
	}
	
	public static Map<ID, String> getRecordTypeIdsByDeveloperNames(String sObjectName, List<String> recordTypeDevNames){
		List<RecordType> theTypes = [SELECT id, DeveloperName FROM recordtype WHERE DeveloperName IN :recordTypeDevNames AND SobjectType =:sObjectName];
		Map<ID, String> results = new Map<ID, String>();
		
		for (RecordType t : theTypes) {
			results.put(t.id, t.DeveloperName);		
		}
		return results;
	}
	public static Map<String, ID> getRecordTypeNamesByIds(String sObjectName, List<String> recordTypeDevNames){
		List<RecordType> theTypes = [SELECT id, DeveloperName FROM recordtype WHERE DeveloperName IN :recordTypeDevNames AND SobjectType =:sObjectName];
		Map<String, ID> results = new Map<String, ID>();
		
		for (RecordType t : theTypes) {
			results.put(t.DeveloperName,t.id);		
		}
		return results;
	}
	
	private static Map<String,CurrencyType> systemCurrencies;
	public static Map<String,CurrencyType> GetCurrencies() {
		
		if (systemCurrencies != null) {
			System.debug(LoggingLevel.INFO,'Returning cached currencies.');
			return systemCurrencies;	
		} else {
			System.debug(LoggingLevel.INFO,'Instantiating list currencies.');
			systemCurrencies = new Map<String,CurrencyType>();			
			List<CurrencyType> curs = [SELECT IsActive, IsCorporate, IsoCode, ConversionRate, DecimalPlaces FROM CurrencyType];
			for (CurrencyType c : curs) {
				System.debug(LoggingLevel.INFO,c.IsoCode);
				systemCurrencies.put(c.IsoCode, c);
			}
			return systemCurrencies;
		}
	}

	//Key is Currency Code [i.e. USD/MXN/CAD]
	private static Map<String, List<Currency_Conversion_Rate__mdt> > conversionRateMap;
	//Queries for Custom Metadata Type Currency_Conversion_Rate__mdt and returns a map
	//where the key is the Currency Code and the list is individual lists that correspond to each
	//currency code
	public static Map<String, List<Currency_Conversion_Rate__mdt> > getConversionRateMap(){
		if(conversionRateMap != null){
			System.debug(LoggingLevel.INFO,'Returning cached conversion rates.');
		} else {
			System.debug(LoggingLevel.INFO,'Instantiating map of conversion rates.');
			conversionRateMap = new Map<String, List<Currency_Conversion_Rate__mdt> >();
			List<Currency_Conversion_Rate__mdt> rates = [SELECT Currency_Code__c, Conversion_Rate__c, Effective_Start_Date__c, Effective_End_Date__c FROM Currency_Conversion_Rate__mdt];
			for(Currency_Conversion_Rate__mdt rate: rates){
				if(!conversionRateMap.containsKey(rate.Currency_Code__c)){
					conversionRateMap.put(rate.Currency_Code__c, new List<Currency_Conversion_Rate__mdt>());
				}
				conversionRateMap.get(rate.Currency_Code__c).add(rate);
			}
		}
		return conversionRateMap;
	}
}