public without sharing class CreditCardPaymentProcessor implements PaymentProcessor {
    
    private Map<String, Credit_Card__c> cardMap;
    
    public CreditCardPaymentProcessor() {

        this.cardMap = new Map<String, Credit_Card__c>();
        for(Credit_Card__c card : [SELECT Id, Credit_Card_Name__c, Amount_Utilised__c
                                        FROM Credit_Card__c]) {
            this.cardMap.put(card.Credit_Card_Name__c, card);
        }

    }

    public void recordInsertion(List<Financial_Transaction__c> txnRecords, boolean insertFlag) {

        for(Financial_Transaction__c txn : txnRecords) {
            handleCardPayment(txn, insertFlag);
        }
        if (!cardMap.isEmpty()) {
            Database.update(cardMap.values());
        }

    }

    private void handleCardPayment(Financial_Transaction__c txn, Boolean insertFlag) {

        Credit_Card__c card = cardMap.get(txn.Payment_Instrument_Detail__c);
        if (card == null) { return; }
        Decimal amt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
        // Preserve previous intended sign: insert -> decrease, else -> increase
        card.Amount_Utilised__c = card.Amount_Utilised__c + (insertFlag ? amt : -amt );
        
    }

}