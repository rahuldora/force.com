public with sharing class MonthlyTrackerSelector extends fflib_SObjectSelector {
    
    public Schema.SObjectType getSObjectType() {
        return Monthly_Tracker__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Monthly_Tracker__c.Id,
            Monthly_Tracker__c.Month__c,
            Monthly_Tracker__c.Year__c,
            Monthly_Tracker__c.Bonus__c,
            Monthly_Tracker__c.CapitalGain__c,
            Monthly_Tracker__c.Cook__c,
            Monthly_Tracker__c.CreditCardBillPayment__c,
            Monthly_Tracker__c.Food__c,
            Monthly_Tracker__c.Fuel__c,
            Monthly_Tracker__c.GiftGiven__c,
            Monthly_Tracker__c.GiftReceived__c,
            Monthly_Tracker__c.Groceries__c,
            Monthly_Tracker__c.HouseBills__c,
            Monthly_Tracker__c.Interest__c,
            Monthly_Tracker__c.InternetBill__c,
            Monthly_Tracker__c.Loan__c,
            Monthly_Tracker__c.Maid__c,
            Monthly_Tracker__c.MedicalBill__c,
            Monthly_Tracker__c.Misc__c,
            Monthly_Tracker__c.Others__c,
            Monthly_Tracker__c.Paycheck__c,
            Monthly_Tracker__c.Refund__c,
            Monthly_Tracker__c.Savings__c,
            Monthly_Tracker__c.Travel__c,
            Monthly_Tracker__c.Bonus_Projected__c,
            Monthly_Tracker__c.CapitalGain_Projected__c,
            Monthly_Tracker__c.Cook_Projected__c,
            Monthly_Tracker__c.CreditCardBillPayment_Projected__c,
            Monthly_Tracker__c.Food_Projected__c,
            Monthly_Tracker__c.Fuel_Projected__c,
            Monthly_Tracker__c.GiftGiven_Projected__c,
            Monthly_Tracker__c.GiftReceived_Projected__c,
            Monthly_Tracker__c.Groceries_Projected__c,
            Monthly_Tracker__c.HouseBills_Projected__c,
            Monthly_Tracker__c.Interest_Projected__c,
            Monthly_Tracker__c.InternetBill_Projected__c,
            Monthly_Tracker__c.Loan_Projected__c,
            Monthly_Tracker__c.Maid_Projected__c,
            Monthly_Tracker__c.MedicalBill_Projected__c,
            Monthly_Tracker__c.Misc_Projected__c,
            Monthly_Tracker__c.Others_Projected__c,
            Monthly_Tracker__c.Paycheck_Projected__c,
            Monthly_Tracker__c.Refund_Projected__c,
            Monthly_Tracker__c.Savings_Projected__c,
            Monthly_Tracker__c.Travel_Projected__c,
            Monthly_Tracker__c.TotalExpense__c,
            Monthly_Tracker__c.TotalIncome__c
        };
    }

    public Monthly_Tracker__c getTrackerRecord(String month, String year) {

        return (Monthly_Tracker__c) Database.query(
            newQueryFactory()
                .setCondition(
                    'Month__c =:month ' + 
                    'AND Year__c =:year'
                )
                .toSOQL()
        );

    }

}