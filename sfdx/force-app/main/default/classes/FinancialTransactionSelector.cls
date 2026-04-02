public with sharing class FinancialTransactionSelector extends fflib_SObjectSelector {
    
    public Schema.SObjectType getSObjectType() {
        return Financial_Transaction__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Financial_Transaction__c.Id,
            Financial_Transaction__c.Amount__c,
            Financial_Transaction__c.Description__c,
            Financial_Transaction__c.Payment_Instrument_Detail__c,
            Financial_Transaction__c.Payment_Instrument__c,
            Financial_Transaction__c.Payment_Method__c,
            Financial_Transaction__c.Transaction_Date__c,
            Financial_Transaction__c.Transaction_Type__c,
            Financial_Transaction__c.Category__c
        };
    }

    public List<Financial_Transaction__c> getRecordsByTxnType(String txnType, Integer month, Integer year) {

        return (List<Financial_Transaction__c>) Database.query(
            newQueryFactory()
                .setCondition(
                    'Transaction_Type__c =:txnType ' + 
                    'AND CALENDAR_MONTH(Transaction_Date__c) =:month ' +
                    'AND CALENDAR_YEAR(Transaction_Date__c) =:year'
                )
                .addOrdering('Transaction_Date__c', fflib_QueryFactory.SortOrder.DESCENDING)
                .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );

    }

    public Financial_Transaction__c getTransactionRecordById(Id recordId) {

        return (Financial_Transaction__c) Database.query(
            newQueryFactory()
                .setCondition(
                    'Id =:recordId'
                )
                .toSOQL()
        );

    }
    
}