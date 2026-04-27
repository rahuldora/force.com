public with sharing class MonthlyTrackersPageController {
    
    /**
     * @name        : getTracker
     * @param       : String => month value
     *              : String => year value
     * @return      : Monthly_Tracker__c => returns Monthly_Tracker__c record based on the month and year value
     * @description : method to fetch the Monthly_Tracker__c record
     */
    @AuraEnabled
    public static Monthly_Tracker__c getTracker(String month, String year){
        return MonthlyTrackerService.getTrackerRecord(month, year);
    }
    
}