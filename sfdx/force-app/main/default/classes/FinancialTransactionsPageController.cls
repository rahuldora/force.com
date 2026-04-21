public with sharing class FinancialTransactionsPageController {
    
    @AuraEnabled
    public static List<Financial_Transaction__c> getTxnRecords(String txnType, Integer month, Integer year){
        return FinancialTransactionService.getTransactionRecords(txnType, month, year);
    }
    
    @AuraEnabled
    public static Financial_Transaction__c getTxnRecordById(Id recordId){
        return FinancialTransactionService.getTransactionRecordById(recordId);
    }
    
    @AuraEnabled
    public static String updateTransaction(Financial_Transaction__c txn){
        return FinancialTransactionService.updateRecord(txn);
    }

    @AuraEnabled(cacheable=true)
    public static String getPaymentMethodDependentOptions(){
        return FinancialTransactionService.getPaymentMethodDependentOptions();
    }
    
}