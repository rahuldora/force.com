public without sharing class CreditCardPaymentProcessor implements PaymentProcessor {
    
    private Map<String, Credit_Card__c> cardMap;
    
    /**
     * @name        : CreditCardPaymentProcessor (Constructor)
     * @param       : null
     * @return      : null
     * @description : constructor method
     */
    public CreditCardPaymentProcessor() {

        // Initialising the Card Map
        this.cardMap = new Map<String, Credit_Card__c>();
        // Querying the Credit Card data
        fflib_QueryFactory query = new fflib_QueryFactory(Credit_Card__c.SObjectType);
        query.selectField(Credit_Card__c.Id)
        .selectField(Credit_Card__c.Credit_Card_Name__c)
        .selectField(Credit_Card__c.Amount_Utilised__c);
        
        for(Credit_Card__c card : Database.query(query.toSOQL())) {
            this.cardMap.put(card.Credit_Card_Name__c, card);
        }

    }

    /**
     * @name        : recordInsertion
     * @param       : txnRecords => List of Financial_Transaction__c to be processed
     *                insertFlag => true for insert, false for delete
     * @return      : null
     * @description : Method that processes the record Insertion if the payment method is Credit Card
     */
    public void recordInsertion(List<Financial_Transaction__c> txnRecords, boolean insertFlag) {

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> {
                Credit_Card__c.SObjectType
            }
        );

        for(Financial_Transaction__c txn : txnRecords) {
            Credit_Card__c card = cardMap.get(txn.Payment_Instrument_Detail__c);
            try{
                Decimal amt = (txn.Amount__c == null) ? 0 : txn.Amount__c;
                // Preserve previous intended sign: insert -> increase the utilisation, else -> decrease
                card.Amount_Utilised__c = card.Amount_Utilised__c + (insertFlag ? amt : -amt);
                uow.registerDirty(card);
            }
            catch(Exception e) {}
        }
        uow.commitWork();

    }

}