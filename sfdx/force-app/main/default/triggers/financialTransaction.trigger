trigger financialTransaction on Financial_Transaction__c (before insert, after insert, before update,  after update, after delete, after undelete) {

    new FinancialTransactionHandler().run();

}