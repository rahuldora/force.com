public without sharing class OnlinePaymentProcessor implements PaymentProcessor {
    
    private Map<String, Bank_Account__c> bankMap;
    private Map<String, Credit_Card__c> cardMap;
    
    public OnlinePaymentProcessor() {

        this.bankMap = new Map<String, Bank_Account__c>();
        this.cardMap = new Map<String, Credit_Card__c>();
        for(Bank_Account__c account : [SELECT Id, Bank_Account_Name__c, Account_Type__c, Balance__c
                                        FROM Bank_Account__c]) {
            this.bankMap.put(account.Bank_Account_Name__c+' - '+account.Account_Type__c, account);
        }
        for(Credit_Card__c card : [SELECT Id, Credit_Card_Name__c, Amount_Utilised__c
                                        FROM Credit_Card__c]) {
            this.cardMap.put(card.Credit_Card_Name__c, card);
        }

    }

    public void recordInsertion(List<Financial_Transaction__c> txnRecords, boolean insertFlag) {

        if (txnRecords == null || txnRecords.isEmpty()) { return; }
        for (Financial_Transaction__c txn : txnRecords) {
            processTransaction(txn, insertFlag);
        }
        if (!bankMap.isEmpty()) {
            Database.update(bankMap.values());
        }
        if (!cardMap.isEmpty()) {
            Database.update(cardMap.values());
        }

    }

    // --- Helpers extracted to reduce cognitive complexity ---
    private void processTransaction(Financial_Transaction__c txn, Boolean insertFlag) {

        if (txn == null) { return; }
        switch on txn.Transaction_Type__c {
            when 'Income' {
                handleIncome(txn, insertFlag);
            }
            when 'Expense' {
                handleExpense(txn, insertFlag);
            }
            when else {
                handleExpense(txn, insertFlag);
            }
        }

    }

    private void handleIncome(Financial_Transaction__c txn, Boolean insertFlag) {

        Bank_Account__c account = bankMap.get(txn.Payment_Instrument_Detail__c);
        if (account == null) { return; }
        Decimal amt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
        account.Balance__c = account.Balance__c + (insertFlag ? amt : -amt);

    }

    private void handleExpense(Financial_Transaction__c txn, Boolean insertFlag) {

        // Card payment adjustments for credit card bill payments
        if (txn.Category__c == 'Credit Card Bill Payment') {
            Credit_Card__c card = cardMap.get(txn.Description__c);
            if (card != null) {
                Decimal cardAmt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
                // On insert we reduce Amount_Utilised (payment made), on delete we increase it back
                card.Amount_Utilised__c = card.Amount_Utilised__c + (insertFlag ? -cardAmt : cardAmt);
            }
        }
        // Bank balance adjustment
        Bank_Account__c account = bankMap.get(txn.Payment_Instrument_Detail__c);
        if (account == null) { return; }
        Decimal amt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
        // Expense reduces balance on insert, restores on delete
        account.Balance__c = account.Balance__c + (insertFlag ? -amt : amt);

    }

}