trigger creditCardTrigger on Credit_Card__c (
    after insert,
    after update,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(CreditCardHandler.class);
}