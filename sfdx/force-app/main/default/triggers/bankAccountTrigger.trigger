trigger bankAccountTrigger on Bank_Account__c (
    after insert,
    after update,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(BankAccountHandler.class);
}