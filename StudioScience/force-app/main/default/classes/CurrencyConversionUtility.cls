public class CurrencyConversionUtility { 
	//This class will be used to pass a configuration through
	//to the actual conversion function
	public class ConversionConfiguration {
		public String originalCurrencyField;
		public String effectiveDateField;
		public String convertedCurrencyField;
		public String sObjectType;
				
		public ConversionConfiguration(String o, String e,
										String c, String s){
			this.originalCurrencyField = o;
			this.effectiveDateField = e;
			this.convertedCurrencyField = c;
			this.sObjectType = s;
		}
	}

	//An overly complicated method that tries to parse a date out of numerous types of fields
	public static Date extractDate(Schema.DisplayType fieldType, String dateValue){
		System.debug(LoggingLevel.INFO, 'Original Date: '+dateValue);
        System.debug(LoggingLevel.INFO,'Parsing date information in CurrencyConversionUtility.extractDate');
		Date effectiveDate = null;
		String arbitraryDateAddition = System.Label.CurrencyConversionMMDD;
		List<String> dateAdditionValues = arbitraryDateAddition.split('/');
		Integer year, month, day;
		month = Integer.valueOf(dateAdditionValues[0]);
		day = Integer.valueOf(dateAdditionValues[1]);
		
		if(fieldType == Schema.DisplayType.String ||
			fieldType == Schema.DisplayType.Picklist ||
			fieldType == Schema.DisplayType.TextArea){
			//A year value
			if(dateValue.length() == 4){
				try{
					year = Integer.valueOf(dateValue);
					effectiveDate = Date.newInstance(year, month, day);
				} catch(TypeException e){}
			} 
			//A date value
			else if(dateValue.length()>=8 && dateValue.length() <= 10){
				try{
					effectiveDate = Date.parse(dateValue);
				} catch(TypeException e) {}
				if(effectiveDate == null){
					try{
						effectiveDate = Date.valueOf(dateValue);
					} catch(TypeException e) {}
				}
			} 
			//A datetime value
			else if(dateValue.length()>10){
				DateTime tempDate;
				try{
					tempDate = DateTime.parse(dateValue);
					effectiveDate = Date.newInstance(tempDate.year(), tempDate.month(), tempDate.day());
				} catch(TypeException e) {
				}
				if(effectiveDate == null){
					try{
						tempDate = DateTime.valueOf(dateValue);
						effectiveDate = Date.newInstance(tempDate.year(), tempDate.month(), tempDate.day());
					} catch(TypeException e){
					}
				}
			}
		} else if(fieldType == Schema.DisplayType.Date){
			try{
				effectiveDate = Date.parse(dateValue);
				} catch(TypeException e) {}
				if(effectiveDate == null){
					try{
						effectiveDate = Date.valueOf(dateValue);
					} catch(TypeException e) {}
				}
		} else if(fieldType == Schema.DisplayType.DateTime){
			DateTime tempDate;
			try{
				tempDate = DateTime.parse(dateValue);
				effectiveDate = Date.newInstance(tempDate.year(), tempDate.month(), tempDate.day());
			} catch(TypeException e) {
			}
			if(effectiveDate == null){
				try{
					tempDate = DateTime.valueOf(dateValue);
					effectiveDate = Date.newInstance(tempDate.year(), tempDate.month(), tempDate.day());
				} catch(TypeException e){
				}
			}
		}
		System.debug(LoggingLevel.INFO, 'Effective date: ' + effectiveDate);
		if(effectiveDate == null){
			throw new BI_NullPointerException();
		}
		return effectiveDate;
	}

	//isToUSD signifies which direction the conversion is going. If the source is in a foreign currency and it's moving toward a USD record,
	//it needs to be converted to USD
	//In other cases, the source is already USD and needs to be converted to the destination currency
	public static Double doConversion(Schema.DisplayType fieldType, String currencyCode, String dateValue, Decimal currencyValue, Boolean isToUSD){
        System.debug(LoggingLevel.INFO,'Doing conversion in CurrencyConversionUtility.doConversion');		
		Decimal convertedValue = null;
		Date effectiveDate = extractDate(fieldType, dateValue);
		Currency_Conversion_Rate__mdt currentRate;

		List<Currency_Conversion_Rate__mdt> rates = BI_UtilityLogic.getConversionRateMap().get(currencyCode);
		for(Currency_Conversion_Rate__mdt rate: rates){
			if(effectiveDate >= rate.Effective_Start_Date__c && effectiveDate <= rate.Effective_End_Date__c){
				currentRate = rate;
				break;
			}
		}
		if(isToUSD){
			convertedValue = currencyValue.divide(currentRate.Conversion_Rate__c, 5, System.RoundingMode.HALF_UP);
		} else if(!isToUSD){
			convertedValue = (currencyValue * currentRate.Conversion_Rate__c).setScale(5, System.RoundingMode.HALF_UP);
		}
		return convertedValue;
	}

	/**
	* @description		:Function converts a currency value sObject records to USD based on the configured date field
	* @param cfg		:A struct/enum to hold configuration data for converting the list of records
	* @param records	:The list of records that are going to be converted
	* @param isToUSD	:Boolean to state whether the records are being explicitly converted to USD or if they should
							convert to the parent's currency
	*/
	public static void convertCurrencyTrigger(ConversionConfiguration cfg, List<sObject> records, Boolean isToUSD){
        System.debug(LoggingLevel.INFO,'Entered CurrencyConversionUtility.convertCurrencyTrigger');
        //Get the Schema.DisplayType (Data Type) so we can parse the field more safely
		Schema.DisplayType effectiveDateType = Schema.getGlobalDescribe().get(cfg.sObjectType).getDescribe().
												fields.getMap().get(cfg.effectiveDateField.toLowerCase()).
												getDescribe().getType();
		if(records != null && records.size() > 0){
			for(sObject record: records){
				try{
					//ASSUMPTION: Org is Multi-Currency, which means that all objects have a 'CurrencyIsoCode'
					//standard field by default. Referencing the field should be safe
					Decimal value = (Decimal) record.get(cfg.originalCurrencyField) == null ? 0 : (Decimal) record.get(cfg.originalCurrencyField);
					String currencyCode = ((String) record.get('CurrencyIsoCode')).toUpperCase();
					Decimal convertedValue = null;
					convertedValue = doConversion(effectiveDateType, currencyCode, String.valueOf(record.get(cfg.effectiveDateField)), value, isToUSD);	
					//The converted value will be stored in the configured currency field
					//Adjust the number of decimal places to match the field in the schema
					Integer convertedScale = Schema.getGlobalDescribe().get(cfg.sObjectType).getDescribe().fields.getMap().get(cfg.convertedCurrencyField).getDescribe().getScale();
					convertedValue = convertedValue.setScale(convertedScale);

					record.put(cfg.convertedCurrencyField, convertedValue);
				} catch(NullPointerException e){
					System.debug(LoggingLevel.INFO, e.getMessage() +', this is likely caused by a missing conversion rate record');
					record.addError(BI_Constants.MISSING_CONVERSION_RATE);
				} catch(BI_NullPointerException e){
					System.debug(LoggingLevel.INFO, e.getMessage() +', this is caused by an incorrect effective date value.');
					record.addError(BI_Constants.INCORRECT_DATE_FORMAT + cfg.effectiveDateField);
				} catch(Exception e){
					System.debug(LoggingLevel.INFO, e.getMessage());
					record.addError(BI_Constants.UNEXPECTED_ERROR);
				}
			}
		}
	}
}