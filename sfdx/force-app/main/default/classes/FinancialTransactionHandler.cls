public with sharing class FinancialTransactionHandler extends TriggerHandler{
    
    // trigger variables
    private List<Financial_Transaction__c> newTransactionRecords;
    private List<Financial_Transaction__c> oldTransactionRecords;
    private Map<Id, Financial_Transaction__c> newTransactionRecordsMap;
    private Map<Id, Financial_Transaction__c> oldTransactionRecordsMap;

    // map variable for easy mapping
    private Map<String, Monthly_Tracker__c> trackerMap = new Map<String, Monthly_Tracker__c>();
    // list to store the Tracker records to be created
    private List<Monthly_Tracker__c> trackersToBeCreated;
    
    // map variable containing payment_method to Object name
    private Map<String,String> paymentMap;

    public class CustomException extends Exception {}
    
    public FinancialTransactionHandler() {
        
        // this.setMaxLoopCount(2);
        
        this.newTransactionRecords = (List<Financial_Transaction__c>)Trigger.new;
        this.oldTransactionRecords = (List<Financial_Transaction__c>)Trigger.old;
        this.newTransactionRecordsMap = (Map<Id, Financial_Transaction__c>)Trigger.newMap;
        this.oldTransactionRecordsMap = (Map<Id, Financial_Transaction__c>)Trigger.oldMap;
        
        this.trackerMap = new Map<String, Monthly_Tracker__c>();
        this.trackersToBeCreated = new List<Monthly_Tracker__c>();

        prepareTrackerMap();
        
    }

    /********************Trigger context functions********************/
    // beforeInsert Logic
    public override void beforeInsert() {

        mapTrackerToRecords();

    }
    
    // afterInsert Logic
    public override void afterInsert() {
        
        Map<String, List<Financial_Transaction__c>> paymentTypeMap = createPaymentTypeMap(this.newTransactionRecords);
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), true);
            }
        }
        
    }
    
    // beforeUpdate Logic
    public override void beforeUpdate() {
        
        mapTrackerToRecords();
        
    }
    
    // afterUpdate Logic
    public override void afterUpdate() {
        
        Map<String, List<Financial_Transaction__c>> paymentTypeMap = createPaymentTypeMap(this.oldTransactionRecords);
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), false);
            }
        }
        paymentTypeMap = createPaymentTypeMap(this.newTransactionRecords);
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), true);
            }
        }

    }

    // afterDelete Logic
    public override void afterDelete() {

        Map<String, List<Financial_Transaction__c>> paymentTypeMap = createPaymentTypeMap(this.oldTransactionRecords);
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), false);
            }
        }

    }

    // afterUndelete Logic
    public override void afterUndelete() {

        Map<String, List<Financial_Transaction__c>> paymentTypeMap = createPaymentTypeMap(this.oldTransactionRecords);
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), true);
            }
        }

    }
    
    /********************Other helper methods********************/
    // method to prepare map of Monthly_Tracker__c
    public void prepareTrackerMap() {
        
        for(Monthly_Tracker__c  tracker : [SELECT Id, Month__c, Year__c 
                                            FROM Monthly_Tracker__c]) {
            this.trackerMap.put(tracker.Month__c+'-'+tracker.Year__c, tracker);
        }

    }

    // method to checking the need to create a new Monthly_Tracker__c record
    public boolean checkTrackersForCreation() {

        String month;
        String year;
        boolean checkFlag = false;
        
        for(Financial_Transaction__c record : this.newTransactionRecords) {
            month = Datetime.newInstance(record.Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('MMMM');
            year = record.Transaction_Date__c.year().toString();
            String key = month+'-'+year;
            if(!this.trackerMap.containsKey(key)) {
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
                this.trackersToBeCreated.add(newTracker);
                checkFlag = true;
                this.trackerMap.put(key, newTracker);
            }
        }
        return checkFlag;

    }

    // method to create the tracker records
    public void createTrackers() {

        for(Database.SaveResult sr : Database.insert(this.trackersToBeCreated, true)) {
            if(!sr.isSuccess()){
                throw new CustomException();
            }
        }

    }

    // method to map Monthly_Tracker__c to Financial_Transaction__c records
    public void mapTrackerToRecords() {
        
        String month;
        String year;
        if(checkTrackersForCreation()){
            createTrackers();
            prepareTrackerMap();
        }

       try {
            for(Financial_Transaction__c record : this.newTransactionRecords) {
                month = Datetime.newInstance(record.Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('MMMM');
                year = record.Transaction_Date__c.year().toString();
                String key = month+'-'+year;
                record.Monthly_Tracker__c = this.trackerMap.get(key).Id;
            }
        }
        catch(Exception e) {
            System.debug('Issue with the tracker record insertion.Please review the issue!');
        }

    }

    // method to create a map of payment method to Financial_Transaction__c records
    public Map<String, List<Financial_Transaction__c>> createPaymentTypeMap(List<Financial_Transaction__c> txnRecords) {

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