public with sharing class BankAccountsPageController {
    
    @AuraEnabled
    public static List<Bank_Account__c> fetchBankAccounts(){
        return BankAccountService.getBankAccounts();
    }

    @AuraEnabled
    public static Bank_Account__c fetchBankAccountById(Id recordId){
        return BankAccountService.getBankAccountById(recordId);
    }

    @AuraEnabled
    public static String transferAmount(Decimal amount, String fromBankAccountId, String toBankAccountId){
        Id fromBankId = (Id)fromBankAccountId;
        Id toBankId = (Id)toBankAccountId;
        return BankAccountService.amountTransfer(amount, fromBankId, toBankId);
    }

    @AuraEnabled
    public static String updateBankAccount(Bank_Account__c record){
        return BankAccountService.updateBankAccount(record);
    }

}