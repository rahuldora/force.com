public with sharing class FinancialTransactionHelper {
    
    public static Map<String, Monthly_Tracker__c> prepareTrackerMap() {

        // result Map
        Map<String, Monthly_Tracker__c> resultMap = new Map<String, Monthly_Tracker__c>();
        // Querying the data
        fflib_QueryFactory query = new fflib_QueryFactory(Monthly_Tracker__c.SObjectType);
        query.selectField(Monthly_Tracker__c.Id)
        .selectField(Monthly_Tracker__c.Month__c)
        .selectField(Monthly_Tracker__c.Year__c);
        for(Monthly_Tracker__c tracker : Database.query(query.toSOQL())) {
            resultMap.put(tracker.Month__c+'-'+tracker.Year__c, tracker);
        }
        return resultMap;

    }

    // method to checking the need to create a new Monthly_Tracker__c record
    public static List<Monthly_Tracker__c> checkTrackersForCreation(List<Financial_Transaction__c> newTransactionRecords, Map<String, Monthly_Tracker__c> trackerMap) {

        String month;
        String year;
        List<Monthly_Tracker__c> trackersToBeCreated = new List<Monthly_Tracker__c>();
        
        for(Financial_Transaction__c record : newTransactionRecords) {
            month = Datetime.newInstance(record.Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('MMMM');
            year = record.Transaction_Date__c.year().toString();
            String key = month+'-'+year;
            if(!trackerMap.containsKey(key)) {
                Monthly_Tracker__c newTracker = new Monthly_Tracker__c(
                    Month__c = month,
                    Year__c = year,
                    Bonus_Projected__c = 0,
                    CapitalGain_Projected__c = 0,
                    Cook_Projected__c = 0,
                    CreditCardBillPayment_Projected__c = 0,
                    Food_Projected__c = 0,
                    Fuel_Projected__c = 0,
                    GiftGiven_Projected__c = 0,
                    GiftReceived_Projected__c = 0,
                    Groceries_Projected__c = 0,
                    HouseBills_Projected__c = 0,
                    Interest_Projected__c = 0,
                    InternetBill_Projected__c = 0,
                    Loan_Projected__c = 0,
                    Maid_Projected__c = 0,
                    MedicalBill_Projected__c = 0,
                    Misc_Projected__c = 0,
                    Others_Projected__c = 0,
                    Paycheck_Projected__c = 0,
                    Refund_Projected__c = 0,
                    Savings_Projected__c = 0,
                    Travel_Projected__c = 0
                );
                trackerMap.put(key, newTracker);
                trackersToBeCreated.add(newTracker);
            }
        }
        return trackersToBeCreated;

    }

    // method to create the tracker records
    public static List<Monthly_Tracker__c> createTrackers(List<Monthly_Tracker__c> trackersToBeCreated) {

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> {
                Monthly_Tracker__c.SObjectType
            }
        );
        uow.registerNew(trackersToBeCreated);
        uow.commitWork();
        return trackersToBeCreated;

    }

    // method to map Monthly_Tracker__c to Financial_Transaction__c records
    public static void mapTrackerToRecords(List<Financial_Transaction__c> newTransactionRecords, Map<String, Monthly_Tracker__c> trackerMap) {
        
        String month;
        String year;
        List<Monthly_Tracker__c> trackerRecords = checkTrackersForCreation(newTransactionRecords, trackerMap);

        if(trackerRecords != null && trackerRecords.size() != 0) {
            createTrackers(trackerRecords);
            trackerMap = prepareTrackerMap();
        }
       try {
            for(Financial_Transaction__c record : newTransactionRecords) {
                month = Datetime.newInstance(record.Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('MMMM');
                year = record.Transaction_Date__c.year().toString();
                String key = month+'-'+year;
                record.Monthly_Tracker__c = trackerMap.get(key).Id;
            }
        }
        catch(Exception e) {
            System.debug('Issue with the tracker record insertion.Please review the issue!');
        }

    }

    // method to create the Payment Map
    public static Map<String, List<Financial_Transaction__c>> createPaymentTypeMap(List<Financial_Transaction__c> txnRecords) {

        Map<String, List<Financial_Transaction__c>> paymentTypeMap = new Map<String, List<Financial_Transaction__c>>();
        // Group records by payment type
        for(Financial_Transaction__c txn : txnRecords) {
            if(!paymentTypeMap.containsKey(txn.Payment_Method__c)){
                paymentTypeMap.put(txn.Payment_Method__c, new List<Financial_Transaction__c>());
            }
            paymentTypeMap.get(txn.Payment_Method__c).add(txn);
        }
        return paymentTypeMap;

    }
    
}