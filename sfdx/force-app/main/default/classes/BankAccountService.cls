public with sharing class BankAccountService {
    
    public static List<Bank_Account__c> getBankAccounts() {

        BankAccountSelector selector = new BankAccountSelector();
        return selector.getBankAccounts();
        
    }

    public static Bank_Account__c getBankAccountById(Id recordId) {

        BankAccountSelector selector = new BankAccountSelector();
        return selector.getBankAccountById(recordId);

    }

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