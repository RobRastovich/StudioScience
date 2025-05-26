public class SLT_Time_Interval {
    /**
    *  @description : This method is use to fetch List of Time Intervals.
    *  @args        : Set<Id> 
    *  @return      : List<Time_Interval__c>
    *  @author      : Nishant Khandal
    **/
    public static List<Time_Interval__c> getTimeIntervalByGivenID(Set<ID> timeIntervalIDs){
        List<Time_Interval__c> timeIntervals = new List<Time_Interval__c>();
        timeIntervals = [SELECT ID, Trips_Booked__c
                            FROM Time_Interval__c
                            WHERE ID IN: timeIntervalIDs];
        return timeIntervals;
    }
}