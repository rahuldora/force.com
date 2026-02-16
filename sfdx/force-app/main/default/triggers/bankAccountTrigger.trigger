trigger bankAccountTrigger on Bank_Account__c (after insert, after update) {

    new BankAccountHandler().run();

}