public without sharing class CashPaymentProcessor implements PaymentProcessor {
    
    /**
     * @name        : recordInsertion
     * @param       : txnRecords => List of Financial_Transaction__c to be processed
     *                insertFlag => true for insert, false for delete
     * @return      : null
     * @description : Method that processes the record Insertion if the payment method is Cash
     */
    public void recordInsertion(List<Financial_Transaction__c> txnRecords, boolean insertFlag) {

        System.debug('Will be developed later to incorporate the wallet feature for cash handling!');

    }

}