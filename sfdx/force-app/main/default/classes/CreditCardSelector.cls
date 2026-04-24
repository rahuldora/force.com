public with sharing class CreditCardSelector extends fflib_SObjectSelector {
    
    public Schema.SObjectType getSObjectType() {
        return Credit_Card__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Credit_Card__c.Id,
            Credit_Card__c.Credit_Card_Name__c,
            Credit_Card__c.Amount_Utilised__c,
            Credit_Card__c.Available_Limit__c,
            Credit_Card__c.Total_Limit__c
        };
    }

    /**
     * @name        : getCreditCards
     * @param       : null 
     * @return      : List of Credit_Card__c
     * @description : Method that fetches the list of all Credit_Card__c
     */
    public List<Credit_Card__c> getCreditCards() {
        return (List<Credit_Card__c>) Database.query(
            newQueryFactory()
                .toSOQL()
        );
    }

    /**
     * @name        : getCreditCards
     * @param       : recordId => Id of Credit_Card__c 
     * @return      : Credit_Card__c record
     * @description : Method that fetches the Credit_Card__c record for the specified recordId
     */
    public Credit_Card__c getCreditCardById(Id recordId) {
        return (Credit_Card__c) Database.query(
            newQueryFactory()
                .setCondition('Id =:recordId')
                .toSOQL()
        );
    }

}