@isTest(seeAllData=false)
public class CurrencyConversionUtilityTest{
	static testmethod void testDateExtraction() {
		//Passing data
		String year = '2016';
		String date1 = '01/01/2016';
		String date2 = '2016-01-01';
		String datetime1 = '2016-01-01 00:00:00';
		String datetime2 = '01/01/2016 12:00 AM';
		//Catching data
		String badYear1 = '201a';
		String badYear2 = '2015a';
		String badDate1 = '01-01-2016';
		String badDate2 = '2016/01/01';
		String badDateTime1 = '2016/01/01 00:00:00';
		String badDateTime2 = '01-01-2016 12:00 AM';
		//No exceptions are expected here
		CurrencyConversionUtility.extractDate(Schema.DisplayType.String, year);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.String, date1);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.String, date2);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.String, datetime1);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.String, datetime2);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.Date, date1);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.Date, date2);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.DateTime, datetime1);
		CurrencyConversionUtility.extractDate(Schema.DisplayType.DateTime, datetime2);
		//Here, we're anticipating "BI_NullPointerException," a throwable version of
		//the standard NullPointer Exception
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.String, badYear1);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.String, badYear2);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.String, badDate1);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.String, badDateTime1);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.Date, badDate1);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.Date, badDate2);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.DateTime, badDateTime1);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
		try{
			CurrencyConversionUtility.extractDate(Schema.DisplayType.DateTime, badDateTime2);
			System.assert(false);
		} catch(BI_NullPointerException e){
			System.assert(true);
		}
    }
}