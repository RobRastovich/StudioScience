@isTest
public class TST_SLT_Time_Interval {
    @testSetup
    public static void setUpTestData(){
        List<Time_Interval__c> intervals = new List<Time_Interval__c>();
        Time_Interval__c interval = new Time_Interval__c();
        interval.Start_Date__c = Date.newInstance(2022, 08, 10);
        interval.End_Date__c = Date.newInstance(2022, 08, 20);
        interval.Max_Number_of_Groups__c = 3;
        interval.Trip_Group__c = 3;
        interval.Trips_Booked__c = 2;
        interval.Brand__c = 'Laphroaig Single Cask';
        interval.isActive__c = true;
        interval.Type__c = 'Season Program Length';
        intervals.add(interval);
        if(!intervals.isEmpty()){
            insert intervals;
        }
    }
    
    @isTest
    public static void testGetTimeIntervalByGivenID(){
        List<Time_Interval__c> interval = [SELECT Id, Trips_Booked__c
                                              FROM Time_Interval__c
                                              LIMIT 1];
        
        Test.startTest();
            List<Time_Interval__c> expectedList = SLT_Time_Interval.getTimeIntervalByGivenID(new Set<Id>{interval[0].Id});
        Test.stopTest();

        System.assertEquals(expectedList.size(), 1, 'List size is not 1');
    }
}