public with sharing class FinancialTransactionsPageController {

    /**
     * @name        : getTxnRecords
     * @param       : String => Transaction type
     *              : Integer => Contains the month value
     *              : Integer => Contains the year value
     * @return      : List<Financial_Transaction__c> => List of Financial_Transaction__c records based on the parameters passed
     * @description : method to fetch the Financial_Transaction__c records
     */
    @AuraEnabled
    public static List<Financial_Transaction__c> getTxnRecords(String txnType, Integer month, Integer year){
        return FinancialTransactionService.getTransactionRecords(txnType, month, year);
    }

    /**
     * @name        : getTxnRecordById
     * @param       : Id => record id of the Financial_Transaction__c
     * @return      : Financial_Transaction__c => Financial_Transaction__c record based on the record id parameter passed
     * @description : method to fetch the Financial_Transaction__c record
     */
    @AuraEnabled
    public static Financial_Transaction__c getTxnRecordById(Id recordId){
        return FinancialTransactionService.getTransactionRecordById(recordId);
    }

    /**
     * @name        : updateTransaction
     * @param       : Financial_Transaction__c => Financial_Transaction__c record that needs to be updated
     * @return      : String => returns Successful on updation of the record, otherwise Failed
     * @description : method to update the Financial_Transaction__c record
     */
    @AuraEnabled
    public static String updateTransaction(Financial_Transaction__c txn){
        return FinancialTransactionService.updateRecord(txn);
    }

    /**
     * @name        : getPaymentMethodDependentOptions
     * @param       : null
     * @return      : String => returns json string of the PickListValueClass wrapper class
     *                          containing the Payment_Method__c => Payment_Instrument__c => Payment_Instrument_Detail__c 
     *                          picklist value
     * @description : method to fetch the Payment_Method__c => Payment_Instrument__c => Payment_Instrument_Detail__c 
     *                picklist value
     */
    @AuraEnabled(cacheable=true)
    public static String getPaymentMethodDependentOptions(){
        return FinancialTransactionService.getPaymentMethodDependentOptions();
    }

    /**
     * @name        : createRecords
     * @param       : List<Financial_Transaction__c> => List of transaction records
     * @return      : String => returns success on creation of the record, otherwise error
     * @description : method to create the transaction records provided
     */
    @AuraEnabled
    public static string createRecords(List<Financial_Transaction__c> records){
        return FinancialTransactionService.createRecords(records);
    }
    
}