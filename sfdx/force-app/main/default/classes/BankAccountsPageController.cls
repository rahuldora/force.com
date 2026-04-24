public with sharing class BankAccountsPageController {
    
    /**
     * @name        : fetchBankAccounts
     * @param       : null
     * @return      : List<Bank_Account__c> => Returns the List of Bank_Account__c
     * @description : Method that returns the List of Bank Account details present in the org
     */
    @AuraEnabled
    public static List<Bank_Account__c> fetchBankAccounts(){
        return BankAccountService.getBankAccounts();
    }

    /**
     * @name        : fetchBankAccountById
     * @param       : recordId => Id of the Bank_Account__c
     * @return      : Bank_Account__c => Returns the Bank_Account__c record
     * @description : Method that returns the Bank Account details for the provided recordId
     */
    @AuraEnabled
    public static Bank_Account__c fetchBankAccountById(Id recordId){
        return BankAccountService.getBankAccountById(recordId);
    }

    /**
     * @name        : amountTransfer
     * @param       : amount => Amount to be transferred from source bank to target bank
     *                fromBankAccountId => Id of source bank
     *                toBankAccountId => Id of target bank
     * @return      : String => return Successful on updating both source and target bank, otherwise Failed
     * @description : Method that processes the amount transferred from source bank to target bank
     */
    @AuraEnabled
    public static String transferAmount(Decimal amount, String fromBankAccountId, String toBankAccountId){
        Id fromBankId = (Id)fromBankAccountId;
        Id toBankId = (Id)toBankAccountId;
        return BankAccountService.amountTransfer(amount, fromBankId, toBankId);
    }

    /**
     * @name        : updateBankAccount
     * @param       : account => Bank_Account__c to be updated
     * @return      : String => return Successful on updating the provided Bank_Account__c, otherwise Failed
     * @description : Method that updates the Bank_Account__c record values provided
     */
    @AuraEnabled
    public static String updateBankAccount(Bank_Account__c record){
        return BankAccountService.updateBankAccount(record);
    }

}