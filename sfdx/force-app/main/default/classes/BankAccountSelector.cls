public with sharing class BankAccountSelector extends fflib_SObjectSelector {
    
    public Schema.SObjectType getSObjectType() {
        return Bank_Account__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Bank_Account__c.Id,
            Bank_Account__c.Name,
            Bank_Account__c.Bank_Account_Name__c,
            Bank_Account__c.Account_Type__c,
            Bank_Account__c.Balance__c,
            Bank_Account__c.Minimum_Balance__c
        };
    }

    public List<Bank_Account__c> getBankAccounts() {
        return (List<Bank_Account__c>) Database.query(
            newQueryFactory()
                .toSOQL()
        );
    }

    public Bank_Account__c getBankAccountById(Id recordId) {
        return (Bank_Account__c) Database.query(
            newQueryFactory()
            .setCondition('Id =:recordId')
            .toSOQL()
        );
    }

}