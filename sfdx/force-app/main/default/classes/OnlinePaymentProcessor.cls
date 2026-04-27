public with sharing class OnlinePaymentProcessor implements PaymentProcessor {
    
    private Map<String, Bank_Account__c> bankMap;
    private Map<String, Credit_Card__c> cardMap;
    
    /**
     * @name        : OnlinePaymentProcessor
     * @param       : null
     * @return      : null
     * @description : constructor method
     */
    public OnlinePaymentProcessor() {

        // Initialising the bankMap
        this.bankMap = new Map<String, Bank_Account__c>();
        // Querying the Bank Account data
        fflib_QueryFactory bankQuery = new fflib_QueryFactory(Bank_Account__c.SObjectType);
        bankQuery.selectField(Bank_Account__c.Id)
        .selectField(Bank_Account__c.Bank_Account_Name__c)
        .selectField(Bank_Account__c.Account_Type__c)
        .selectField(Bank_Account__c.Balance__c);
        // Preparing the bankMap
        for(Bank_Account__c account : Database.query(bankQuery.toSOQL())) {
            this.bankMap.put(account.Bank_Account_Name__c+' - '+account.Account_Type__c, account);
        }

        // Initialising the cardMap
        this.cardMap = new Map<String, Credit_Card__c>();
        // Querying the Credit Card data
        fflib_QueryFactory cardQuery = new fflib_QueryFactory(Credit_Card__c.SObjectType);
        cardQuery.selectField(Credit_Card__c.Id)
        .selectField(Credit_Card__c.Credit_Card_Name__c)
        .selectField(Credit_Card__c.Amount_Utilised__c);
        // Preparing the cardMap
        for(Credit_Card__c card : Database.query(cardQuery.toSOQL())) {
            this.cardMap.put(card.Credit_Card_Name__c, card);
        }

    }

    /**
     * @name        : recordInsertion
     * @param       : List<Financial_Transaction__c> => List of Financial_Transaction__c records
     *              : boolean
     * @return      : null
     * @description : method to process the record insertion of Financial_Transaction__c records whose payment type is "Online"
     */
    public void recordInsertion(List<Financial_Transaction__c> txnRecords, boolean insertFlag) {

        if (txnRecords == null || txnRecords.isEmpty()) { return; }
        fflib_SObjectUnitOfWork uow = initializeUnitOfWork();
        for(Financial_Transaction__c txn : txnRecords) {
            processTransaction(txn, insertFlag, uow);
        }
        uow.commitWork();

    }

    /**
     * @name        : initializeUnitOfWork
     * @param       : null
     * @return      : fflib_SObjectUnitOfWork => returns the fflib_SObjectUnitOfWork object 
     * @description : method to initialize the fflib_SObjectUnitOfWork object
     */
    private fflib_SObjectUnitOfWork initializeUnitOfWork() {
        
        return new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Credit_Card__c.SObjectType,
                Bank_Account__c.SObjectType
            }
        );

    }

    /**
     * @name        : processTransaction
     * @param       : Financial_Transaction__c => Financial_Transaction__c record
     *              : boolean => flag variable to process insertion when true & to process deletion when false
     *              : fflib_SObjectUnitOfWork => Object to implement Unit of work
     * @return      : null
     * @description : method to process the Financial_Transaction__c record
     */
    private void processTransaction(Financial_Transaction__c txn, boolean insertFlag, fflib_SObjectUnitOfWork uow) {
        
        if(txn.Transaction_Type__c == 'Income') {
            processIncomeTransaction(txn, insertFlag, uow);
        } 
        else {
            processExpenseTransaction(txn, insertFlag, uow);
        }

    }

    /**
     * @name        : processIncomeTransaction
     * @param       : Financial_Transaction__c => Financial_Transaction__c record
     *              : boolean => flag variable to process insertion when true & to process deletion when false
     *              : fflib_SObjectUnitOfWork => Object to implement Unit of work
     * @return      : null
     * @description : method to process the Financial_Transaction__c record whose transaction type is "Income"
     */
    private void processIncomeTransaction(Financial_Transaction__c txn, boolean insertFlag, fflib_SObjectUnitOfWork uow) {
        
        Bank_Account__c bankAccount = this.bankMap.get(txn.Payment_Instrument_Detail__c);
        Decimal amt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
        // Preserve previous intended sign: insert -> increase the balance, else -> decrease
        bankAccount.Balance__c = bankAccount.Balance__c + (insertFlag ? amt : -amt);
        uow.registerDirty(bankAccount);
    
    }

    /**
     * @name        : processExpenseTransaction
     * @param       : Financial_Transaction__c => Financial_Transaction__c record
     *              : boolean => flag variable to process insertion when true & to process deletion when false
     *              : fflib_SObjectUnitOfWork => Object to implement Unit of work
     * @return      : null
     * @description : method to process the Financial_Transaction__c record whose transaction type is "Expense" or "Savings"
     */
    private void processExpenseTransaction(Financial_Transaction__c txn, boolean insertFlag, fflib_SObjectUnitOfWork uow) {
    
        // Card payment adjustments for credit card bill payments
        if (txn.Category__c == 'Credit Card Bill Payment') {
            Credit_Card__c card = this.cardMap.get(txn.Description__c);
            Decimal cardAmt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
            // On insert we reduce Amount_Utilised (payment made), on delete we increase it back
            card.Amount_Utilised__c = card.Amount_Utilised__c + (insertFlag ? -cardAmt : cardAmt);
            uow.registerDirty(card);
        }
        // Bank balance adjustment
        Bank_Account__c bankAccount = this.bankMap.get(txn.Payment_Instrument_Detail__c);
        Decimal amt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
        // Expense reduces balance on insert, restores on delete
        bankAccount.Balance__c = bankAccount.Balance__c + (insertFlag ? -amt : amt);
        uow.registerDirty(bankAccount);

    }
    
}