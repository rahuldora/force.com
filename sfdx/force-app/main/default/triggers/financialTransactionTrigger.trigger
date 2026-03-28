trigger financialTransactionTrigger on Financial_Transaction__c (
    before insert,
    after insert,
    before update,
    after update,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(Financial_Transaction__c.class);
}