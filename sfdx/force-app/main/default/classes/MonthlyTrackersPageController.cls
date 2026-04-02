public with sharing class MonthlyTrackersPageController {
    
    @AuraEnabled
    public static Monthly_Tracker__c getTracker(String month, String year){
        return MonthlyTrackerService.getTrackerRecord(month, year);
    }
    
}