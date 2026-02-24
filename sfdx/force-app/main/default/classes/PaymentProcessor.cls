public interface PaymentProcessor {
    
    void recordInsertion(List<Financial_Transaction__c> txnRecords, boolean insertFlag);
    
}