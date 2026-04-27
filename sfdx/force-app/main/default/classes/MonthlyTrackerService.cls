public with sharing class MonthlyTrackerService {
    
    /**
     * @name        : getTrackerRecord
     * @param       : String => month value
     *              : String => year value
     * @return      : Monthly_Tracker__c => returns Monthly_Tracker__c record based on the month and year value
     * @description : method to fetch the Monthly_Tracker__c record
     */
    public static Monthly_Tracker__c getTrackerRecord(String month, String year) {
        
        MonthlyTrackerSelector selector = new MonthlyTrackerSelector();
        return selector.getTrackerRecord(month, year);

    }
    
}