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

    public List<Credit_Card__c> getCreditCards() {
        return (List<Credit_Card__c>) Database.query(
            newQueryFactory()
                .toSOQL()
        );
    }

    public Credit_Card__c getCreditCardById(Id recordId) {
        return (Credit_Card__c) Database.query(
            newQueryFactory()
                .setCondition('Id =:recordId')
                .toSOQL()
        );
    }

}