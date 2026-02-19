trigger cardTrigger on Credit_Card__c (after insert, after update, after undelete) {

    new CardHandler().run();

}