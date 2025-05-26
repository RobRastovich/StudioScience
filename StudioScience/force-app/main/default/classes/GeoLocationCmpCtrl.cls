public class GeoLocationCmpCtrl {

	/**************************************************************************************************************
	Author:        Craig Austgen
	Company:       Slalom, LLC
	Description:	updates geolocation fields on a particular object
	History
	<Date>      <Authors Name>     <Brief Description of Change>
	10/2018     	Craig Austgen       Initial Creation

	***************************************************************************************************************/
	@AuraEnabled
	public static sObject updateGeoLocation(String recordId, String geoLocationFieldName, Decimal latitude, Decimal longitude) {
		String latFieldName = geoLocationFieldName + '__Latitude__s';
		String longFieldName = geoLocationFieldName + '__Longitude__s';

		if(String.isBlank(recordId)){
			return null;
		}

		sObject sObj = Id.valueOf(recordId).getSObjectType().newSObject(Id.valueOf(recordId));
		sObj.put(latFieldName, latitude);
		sObj.put(longFieldName, longitude);

		update sObj;

		return sObj;
	}
}