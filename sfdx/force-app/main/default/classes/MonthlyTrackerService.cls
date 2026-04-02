public with sharing class MonthlyTrackerService {
    
    public static Monthly_Tracker__c getTrackerRecord(String month, String year) {
        
        MonthlyTrackerSelector selector = new MonthlyTrackerSelector();
        return selector.getTrackerRecord(month, year);

    }
    
}