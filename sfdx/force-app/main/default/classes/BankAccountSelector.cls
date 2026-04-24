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

    /**
     * @name        : getBankAccounts
     * @param       : null
     * @return      : List<Bank_Account__c> => Returns the List of Bank_Account__c
     * @description : Method that returns the List of Bank Account details present in the org
     */
    public List<Bank_Account__c> getBankAccounts() {
        return (List<Bank_Account__c>) Database.query(
            newQueryFactory()
                .toSOQL()
        );
    }

    /**
     * @name        : getBankAccountById
     * @param       : recordId => Id of the Bank_Account__c
     * @return      : Bank_Account__c => Returns the Bank_Account__c record
     * @description : Method that returns the Bank Account details for the provided recordId
     */
    public Bank_Account__c getBankAccountById(Id recordId) {
        return (Bank_Account__c) Database.query(
            newQueryFactory()
            .setCondition('Id =:recordId')
            .toSOQL()
        );
    }

}