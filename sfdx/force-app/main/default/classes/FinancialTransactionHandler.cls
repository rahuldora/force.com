public with sharing class FinancialTransactionHandler extends fflib_SObjectDomain {

    public class CustomException extends Exception {}

    // map variable for easy mapping
    private Map<String, Monthly_Tracker__c> trackerMap;
    // list to store the Tracker records to be created
    private List<Monthly_Tracker__c> trackersToBeCreated;
    // map variable containing payment_method to Object name
    private Map<String,String> paymentMap;

    public FinancialTransactionHandler(List<Financial_Transaction__c> sObjectList) {

        // Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
        // Initialising the trackerMap
        this.trackerMap = FinancialTransactionHelper.prepareTrackerMap();
        // this.trackersToBeCreated = new List<Monthly_Tracker__c>(); 

    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {

		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new FinancialTransactionHandler((List<Financial_Transaction__c>)sObjectList);
		}

	}

    // beforeInsert Logic
    public override void onBeforeInsert() {
        FinancialTransactionHelper.mapTrackerToRecords((List<Financial_Transaction__c>)getRecords(), this.trackerMap);
    }

    // afterInsert Logic
    public override void onAfterInsert() {
        
        Map<String, List<Financial_Transaction__c>> paymentTypeMap = FinancialTransactionHelper.createPaymentTypeMap((List<Financial_Transaction__c>)getRecords());
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), true);
            }
        }
        
    }

    // beforeUpdate Logic
    public override void  onBeforeUpdate(Map<Id,SObject> existingRecords) {
        FinancialTransactionHelper.mapTrackerToRecords((List<Financial_Transaction__c>)getRecords(), this.trackerMap);
    }

    // afterUpdate Logic
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        
        // Map conversion
        Map<Id, Financial_Transaction__c> oldTxnMap = (Map<Id, Financial_Transaction__c>)existingRecords;
        // paymentTypeMap containing old values for removeing the old values
        Map<String, List<Financial_Transaction__c>> paymentTypeMap = FinancialTransactionHelper.createPaymentTypeMap(oldTxnMap.values());
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), false);
            }
        }
        // paymentTypeMap containing new values for adding the new values
        paymentTypeMap = FinancialTransactionHelper.createPaymentTypeMap((List<Financial_Transaction__c>)getRecords());
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), true);
            }
        }

    }

    // afterDelete Logic
    public override void onAfterDelete(){

        Map<Id, Financial_Transaction__c> oldTxnMap = (Map<Id, Financial_Transaction__c>)this.ExistingRecords;
        Map<String, List<Financial_Transaction__c>> paymentTypeMap = FinancialTransactionHelper.createPaymentTypeMap(oldTxnMap.values());
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), false);
            }
        }

    }

    // afterUndelete Logic
    public override void onAfterUndelete() {

        Map<String, List<Financial_Transaction__c>> paymentTypeMap = FinancialTransactionHelper.createPaymentTypeMap((List<Financial_Transaction__c>)getRecords());
        for(String paymentType : paymentTypeMap.keySet()){
            PaymentProcessor processor = PaymentProcessorFactory.getProcessor(paymentType);
            if(processor != null){
                processor.recordInsertion(paymentTypeMap.get(paymentType), true);
            }
        }

    }

}