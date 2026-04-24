public with sharing class BankAccountService {
    
    /**
     * @name        : getBankAccounts
     * @param       : null
     * @return      : List<Bank_Account__c> => Returns the List of Bank_Account__c
     * @description : Method that returns the List of Bank Account details present in the org
     */
    public static List<Bank_Account__c> getBankAccounts() {

        BankAccountSelector selector = new BankAccountSelector();
        return selector.getBankAccounts();
        
    }

    /**
     * @name        : getBankAccountById
     * @param       : recordId => Id of the Bank_Account__c
     * @return      : Bank_Account__c => Returns the Bank_Account__c record
     * @description : Method that returns the Bank Account details for the provided recordId
     */
    public static Bank_Account__c getBankAccountById(Id recordId) {

        BankAccountSelector selector = new BankAccountSelector();
        return selector.getBankAccountById(recordId);

    }

    /**
     * @name        : amountTransfer
     * @param       : amount => Amount to be transferred from source bank to target bank
     *                fromBankAccountId => Id of source bank
     *                toBankAccountId => Id of target bank
     * @return      : String => return Successful on updating both source and target bank, otherwise Failed
     * @description : Method that processes the amount transferred from source bank to target bank
     */
    public static String amountTransfer(Decimal amount, Id fromBankAccountId, Id toBankAccountId) {

        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Bank_Account__c.SObjectType
            }
        );

        String successFlag = 'Successful';

        BankAccountSelector selector = new BankAccountSelector();
        // Fetch the from bank account record
        Bank_Account__c fromBA = selector.getBankAccountById(fromBankAccountId);
        // Deduct the amount from the Balance
        fromBA.Balance__c -= amount;
        uow.registerDirty(fromBA);

        // Fetch the from bank account record
        Bank_Account__c toBA = selector.getBankAccountById(toBankAccountId);
        toBA.Balance__c += amount;
        uow.registerDirty(toBA);

        try {
            // Commit the work
            uow.commitWork();
        }
        catch(Exception e) {
            successFlag = 'Failed';
        }
        return successFlag;
        
    }

    /**
     * @name        : updateBankAccount
     * @param       : account => Bank_Account__c to be updated
     * @return      : String => return Successful on updating the provided Bank_Account__c, otherwise Failed
     * @description : Method that updates the Bank_Account__c record values provided
     */
    public static String updateBankAccount(Bank_Account__c account) {

        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Bank_Account__c.SObjectType
            }
        );

        uow.registerDirty(account);
        String successFlag = 'Successful';
        try {
            // Commit the work
            uow.commitWork();
        }
        catch(Exception e) {
            successFlag = 'Failed';
        }
        return successFlag;

    }

}