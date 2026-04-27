public with sharing class FinancialTransactionService {
    
    /**
     * @name        : getTransactionRecords
     * @param       : String => Transaction type
     *              : Integer => Contains the month value
     *              : Integer => Contains the year value
     * @return      : List<Financial_Transaction__c> => List of Financial_Transaction__c records based on the parameters passed
     * @description : method to fetch the Financial_Transaction__c records
     */
    public static List<Financial_Transaction__c> getTransactionRecords(String txnType, Integer month, Integer year) {

        FinancialTransactionSelector selector = new FinancialTransactionSelector();
        return selector.getRecordsByTxnType(txnType, month, year);

    }
    
    /**
     * @name        : getTransactionRecordById
     * @param       : Id => record id of the Financial_Transaction__c
     * @return      : Financial_Transaction__c => Financial_Transaction__c record based on the record id parameter passed
     * @description : method to fetch the Financial_Transaction__c record
     */
    public static Financial_Transaction__c getTransactionRecordById(Id recordId) {

        FinancialTransactionSelector selector = new FinancialTransactionSelector();
        return selector.getTransactionRecordById(recordId);

    }

    /**
     * @name        : updateRecord
     * @param       : Financial_Transaction__c => Financial_Transaction__c record that needs to be updated
     * @return      : String => returns Successful on updation of the record, otherwise Failed
     * @description : method to update the Financial_Transaction__c record
     */
    public static String updateRecord(Financial_Transaction__c txn) {

        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Financial_Transaction__c.SObjectType
            }
        );
        uow.registerDirty(txn);
        String successFlag = 'Successful';
        try {
            // Commit the work
            uow.commitWork();
        }
        catch(Exception e) {
            successFlag = 'Failed';
        }
        return successFlag;

    }

    /**
     * @name        : PickListValueClass
     * @description : Wrapper class to contain the 
     *                Payment_Method__c => Payment_Instrument__c => Payment_Instrument_Detail__c 
     *                picklist value
     */
    public class PickListValueClass {
        List<PaymentMethod> records;
    }
    public class PaymentMethod {
        String paymentMethod;
        List<PaymentInstrument> paymentInstrument;
    }
    public class PaymentInstrument {
        String paymentInstrument;
        List<String> paymentInstrumentDetail;
    }

    /**
     * @name        : getPaymentMethodDependentOptions
     * @param       : null
     * @return      : String => returns json string of the PickListValueClass wrapper class
     *                          containing the Payment_Method__c => Payment_Instrument__c => Payment_Instrument_Detail__c 
     *                          picklist value
     * @description : method to fetch the Payment_Method__c => Payment_Instrument__c => Payment_Instrument_Detail__c 
     *                picklist value
     */
    public static String getPaymentMethodDependentOptions() {

        // Initialise the list PaymentMethod
        List<PaymentMethod> paymentMethods = new List<PaymentMethod>();
        // Describe the field
        Schema.DescribeFieldResult fieldResult = Financial_Transaction__c.Payment_Method__c.getDescribe();
        // Create the PaymentMethod picklist
        for(Schema.PicklistEntry pe : fieldResult.getPicklistValues()) {
            PaymentMethod pm = new PaymentMethod();
            pm.paymentMethod = pe.getLabel();
            paymentMethods.add(pm);
        }
        for(PaymentMethod pm : paymentMethods) {
            // For Cash
            if(pm.paymentMethod == 'Cash'){
                PaymentInstrument pi = new PaymentInstrument();
                pi.paymentInstrument = 'Cash';
                pi.paymentInstrumentDetail = new List<String>{'Cash'};
                
                List<PaymentInstrument> piList = new List<PaymentInstrument>();
                piList.add(pi);
                
                pm.paymentInstrument = piList;
            }
            // For Credit Card
            else if(pm.paymentMethod == 'Credit Card'){
                PaymentInstrument pi = new PaymentInstrument();
                pi.paymentInstrument = 'Credit Card';
                pi.paymentInstrumentDetail = getCreditCards();
                
                List<PaymentInstrument> piList = new List<PaymentInstrument>();
                piList.add(pi);
                
                pm.paymentInstrument = piList;
            }
            // For Online
            else {
                PaymentInstrument pi1 = new PaymentInstrument();
                pi1.paymentInstrument = 'Joint Account';
                pi1.paymentInstrumentDetail = getBankAccounts('Joint Account');
                
                PaymentInstrument pi2 = new PaymentInstrument();
                pi2.paymentInstrument = 'Savings Account';
                pi2.paymentInstrumentDetail = new List<String>();
                pi2.paymentInstrumentDetail = getBankAccounts('Savings Account');
                
                List<PaymentInstrument> piList = new List<PaymentInstrument>();
                piList.add(pi1);
                piList.add(pi2);

                pm.paymentInstrument = piList;
            }
        }
        PickListValueClass pvc = new PickListValueClass();
        pvc.records = paymentMethods;
        String jsonString = JSON.serialize(pvc);
        return jsonString;

    }

    /**
     * @name        : getCreditCards
     * @param       : null
     * @return      : List<String> => returns list of credit card names
     * @description : method to fetch the credit card names
     */
    private static List<String> getCreditCards() {

        // Create a List of String for result
        List<String> result = new List<String>();
        // Query the Credit Cards using the CreditCardSelector
        CreditCardSelector selector = new CreditCardSelector();
        for(Credit_Card__c card : selector.getCreditCards()) {
            result.add(card.Credit_Card_Name__c);
        }
        return result;

    }

    /**
     * @name        : getBankAccounts
     * @param       : null
     * @return      : List<String> => returns list of Bank account names
     * @description : method to fetch the bank account names
     */
    private static List<String> getBankAccounts(String acctType) {

        // Create a List of String for result
        List<String> result = new List<String>();
        // Query the Bank Accounts using the BankAccountSelector
        BankAccountSelector selector = new BankAccountSelector();
        for(Bank_Account__c bankAccount : selector.getBankAccounts()) {
            if(bankAccount.Account_Type__c == acctType){
                String val = bankAccount.Bank_Account_Name__c + ' - ' + bankAccount.Account_Type__c;
                result.add(val);
            }
        }
        return result;

    }

    /**
     * @name        : createRecords
     * @param       : List<Financial_Transaction__c> => List of transaction records
     * @return      : String => returns success on creation of the record, otherwise error
     * @description : method to create the transaction records provided
     */
    public static String createRecords(List<Financial_Transaction__c> txnRecords) {

        String successFlag = 'success';

        // Create a Unit Of Work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Financial_Transaction__c.SObjectType
            }
        );
        uow.registerNew(txnRecords);
        try {
            // Commit the work
            uow.commitWork();
        }
        catch(Exception e) {
            successFlag = 'error';
        }
        return successFlag;

    }
    
}