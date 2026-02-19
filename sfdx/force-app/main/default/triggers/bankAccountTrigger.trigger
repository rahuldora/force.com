trigger bankAccountTrigger on Bank_Account__c (after insert, after update, after undelete) {

    new BankAccountHandler().run();

}