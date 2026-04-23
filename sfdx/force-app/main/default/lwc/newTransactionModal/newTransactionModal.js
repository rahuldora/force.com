import { api, track, wire } from 'lwc';

import LightningModal from 'lightning/modal';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import TXN_OBJECT from '@salesforce/schema/Financial_Transaction__c';
import AMOUNT_FIELD from '@salesforce/schema/Financial_Transaction__c.Amount__c';
import CATEGORY_FIELD from '@salesforce/schema/Financial_Transaction__c.Category__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Financial_Transaction__c.Description__c';
import PAYMENT_INSTRUMENT_FIELD from '@salesforce/schema/Financial_Transaction__c.Payment_Instrument__c';
import PAYMENT_INSTRUMENT_DETAIL_FIELD from '@salesforce/schema/Financial_Transaction__c.Payment_Instrument_Detail__c';
import PAYMENT_METHOD_FIELD from '@salesforce/schema/Financial_Transaction__c.Payment_Method__c';
import TRANSACTION_DATE_FIELD from '@salesforce/schema/Financial_Transaction__c.Transaction_Date__c';
import TRANSACTION_TYPE_FIELD from '@salesforce/schema/Financial_Transaction__c.Transaction_Type__c';

import getPaymentMethodDependentOptions from '@salesforce/apex/FinancialTransactionsPageController.getPaymentMethodDependentOptions';
import createRecords from '@salesforce/apex/FinancialTransactionsPageController.createRecords';
export default class NewTransactionModal extends LightningModal {

    @track records = [];

    counter;

    // Flag variable to display the spinner when required
    isLoading;

    txnRecordTypeId;

    // Map variables to store the dependent picklist values
    categoryMap = {}; // Category => dependent on => Transaction Type
    paymentInstrumentMap = {}; // Payment Instrument => dependent on => Payment Method
    paymentInstrumentDetailMap = {}; // Payment Instrument Detail => dependent on => Payment Instrument

    // Option Variables
    // txnTypeOptions = [];
    // paymentMethodOptions = [];
    // @track categoryOptions = [];
    // @track paymentInstrumentOptions = []
    // @track paymentInstrumentDetailOptions = [];

    // Flag variables to detect whether all the component values are loaded
    isObjectLoaded = false;
    isCategoryPicklistLoaded = false;
    isPaymentPicklistLoaded = false;
    isRecordLoaded = false;

    /******************************************* Wire Methods - Start *******************************************/
    // wire method to fetch the default recordType Id of Financial_Transaction__c
    @wire(getObjectInfo, { 
        objectApiName: TXN_OBJECT
    })
    results({ error, data }) {
        if(data) {
            this.txnRecordTypeId = data.defaultRecordTypeId;
            this.isObjectLoaded = true;
            this.initializeUI();
        }
        else if (error) {
            console.error('Error occured while fetching the RecordType ::', JSON.stringify(error));
        }
    }

    // wire method to fetch the picklist values along with their controlling fields
    @wire(getPicklistValues, { 
        recordTypeId: '$txnRecordTypeId', 
        fieldApiName: CATEGORY_FIELD
    })
    categoryPickListInfo({ data, error }) {
        if(data) {
            this.txnTypeOptions = this.prepareTxnTypeOptions(data.controllerValues);
            this.categoryMap = this.prepareCategoryMap(data);
            this.isCategoryPicklistLoaded = true;
            this.initializeUI();
        }
        else if(error) {
            console.error('Error occurred while fetching Category Picklist::', JSON.stringify(error));
        }
    }
    
    // wire method to fetch the dependent picklist values along with their controlling fields
    @wire(getPaymentMethodDependentOptions)
    paymentMethodDependentOptionsInfo({ data, error }) {
        if(data) {
            let parsedData = JSON.parse(data);
            this.paymentMethodOptions = this.preparePaymentMethodOptions(parsedData.records);
            this.paymentInstrumentMap = this.preparePaymentInstrumentMap(parsedData.records);
            this.paymentInstrumentDetailMap = this.preparePaymentInstrumentDetailMap(parsedData.records);
            this.isPaymentPicklistLoaded = true;
            this.initializeUI();
        }
        else if(error) {
            console.error('Error occurred while fetching Dependent Picklist::', JSON.stringify(error));
        }
    }
    /******************************************* Wire Methods - End *******************************************/

    constructor() {
        super();
        this.counter = -1;
        this.isLoading = true;
    }

    // connectedCallback() {
    //     try {
    //         this.initializeUI();
    //     } 
    //     catch (error) {
    //         console.error('Initialization error:', error);
    //     }
    // }

    // Method to initialise the UI after all the components are loaded / fetched
    initializeUI() {
        if(
            !this.isObjectLoaded || 
            !this.isCategoryPicklistLoaded ||
            !this.isPaymentPicklistLoaded
        ) {
            return;
        }
        this.counter += 1;
        this.records.push({
            'index': this.counter,
            'Amount__c' : 0, 
            'Category__c' : null,
            'Description__c' : '',
            'Payment_Instrument__c' : null,
            'Payment_Instrument_Detail__c' : null,
            'Payment_Method__c' : null,
            'Transaction_Date__c' : null,
            'Transaction_Type__c' : null,
            'categoryOptions': [],
            'paymentInstrumentOptions': [],
            'paymentInstrumentDetailOptions': []
        });
        this.isLoading = false;
    }
    
    /******************************************* Handler Methods - Start *******************************************/
    // change handler method to capture the changes in the field
    handleChange(event) {
        const fieldName = event.target.name;
        const index = event.target.dataset.index;
        const fieldValue = event.target.value;
        this.records[index][fieldName] = fieldValue;
        // Clear dependent fields when controlling field changes
        if (fieldName === 'Transaction_Type__c') {
            this.records[index]['Category__c'] = null;
            this.records[index]['categoryOptions'] = this.prepareCategoryOptions(this.records[index][fieldName]);
        }
        else if (fieldName === 'Payment_Method__c') {
            this.records[index]['Payment_Instrument__c'] = null;
            this.records[index]['Payment_Instrument_Detail__c'] = null;
            this.records[index]['paymentInstrumentOptions'] = this.preparePaymentInstrumentOptions(this.records[index][fieldName]);
        }
        else if (fieldName === 'Payment_Instrument__c') {
            this.records[index]['Payment_Instrument_Detail__c'] = null;
            this.records[index]['paymentInstrumentDetailOptions'] = this.preparePaymentInstrumentDetailOptions(this.records[index][fieldName]);
        }
    }   
    
    // click handler method to process the data upon button click
    handleClick(event) {
        const operation = event.target.name;
        const index = event.target.dataset.index;
        switch (operation) {
            case 'close':
                this.close();
                break;
            case 'add_rows':
                this.addRows();
                break;
            case 'remove_row':
                this.removeRows(index);
                break;
            case 'create':
                this.createRecords();
                break;
            default:
                break;
        }
    }
    /******************************************* Handler Methods - End *******************************************/ 

    /******************************************* Helper Methods - Start *******************************************/     
    // Helper method to prepare the txnTypeOption
    prepareTxnTypeOptions(data) {
        return Object.keys(data).map(key => {
            return {
                label: key,
                value: key
            }
        })
    }
    
    // Helper method to prepare the categoryMap
    prepareCategoryMap(data) {
        let result = {};
        const controllerValues = data.controllerValues;
        const values = data.values;

        // prepare the Index to Value map
        let indexToTxnMap = {};
        Object.keys(controllerValues).forEach(key => {
            let index = controllerValues[key];
            indexToTxnMap[index] = key;
        });

        // Iterate through the dependent values for mapping
        values.forEach(item => {
            item.validFor.forEach(element => {
                let txnType = indexToTxnMap[element];
                if(!result[txnType]) {
                    result[txnType] = [];
                }
                result[txnType].push({
                    label: item.label,
                    value: item.label
                });
            });
        });
        return result;
    }

    // Helper method to prepare the Category options
    prepareCategoryOptions(txnType) {
        return this.categoryMap[txnType] || []; 
    }

    // Helper to prepare the Payment Method options
    preparePaymentMethodOptions(data) {
        return data.map(item => {
            return {
                label: item.paymentMethod,
                value: item.paymentMethod
            }
        });
    }

    // Helper to prepare the Payment Instrument Map
    preparePaymentInstrumentMap(data) {
        let result = {};
        data.forEach(item1 => {
            result[item1.paymentMethod] = [];
            item1.paymentInstrument.forEach(item2 => {
                result[item1.paymentMethod].push({
                    label: item2.paymentInstrument,
                    value: item2.paymentInstrument
                });
            });
        });
        return result;
    }

    // Helper method to prepare the Payment Instrument options
    preparePaymentInstrumentOptions(paymentMethod) {
        return this.paymentInstrumentMap[paymentMethod] || []; 
    }

    // Helper to prepare the Payment Instrument Detail Map
    preparePaymentInstrumentDetailMap(data) {
        let result = {};
        data.forEach(item1 => {
            item1.paymentInstrument.forEach(item2 => {
                result[item2.paymentInstrument] = [];
                item2.paymentInstrumentDetail.forEach(val => {
                    result[item2.paymentInstrument].push({
                        label: val,
                        value: val
                    });
                });
            });
        });
        return result;
    }

    // Helper method to prepare the Payment Instrument Detail options
    preparePaymentInstrumentDetailOptions(paymentInstrument) {
        return this.paymentInstrumentDetailMap[paymentInstrument] || []; 
    }

    // Helper method to add new rows and reorganise the records
    addRows() {
        this.isLoading = true;
        let tempRecords = this.records;
        this.counter += 1;
        tempRecords.push({
            'index': this.counter,
            'Amount__c' : 0, 
            'Category__c' : null,
            'Description__c' : '',
            'Payment_Instrument__c' : null,
            'Payment_Instrument_Detail__c' : null,
            'Payment_Method__c' : null,
            'Transaction_Date__c' : null,
            'Transaction_Type__c' : null,
            'categoryOptions': [],
            'paymentInstrumentOptions': [],
            'paymentInstrumentDetailOptions': []
        });
        this.records = [];
        this.records = tempRecords;
        this.isLoading = false;
    }
    
    // Helper method to remove the selected row
    removeRows(index) {
        this.isLoading = true;
        let tempRecords = [];
        this.counter = 0;
        this.records.forEach(items => {
            if(items.index != index) {
                tempRecords.push({
                    'index': this.counter,
                    'Amount__c' : items.Amount__c, 
                    'Category__c' : items.Category__c,
                    'Description__c' : items.Description__c,
                    'Payment_Instrument__c' : items.Payment_Instrument__c,
                    'Payment_Instrument_Detail__c' : items.Payment_Instrument_Detail__c,
                    'Payment_Method__c' : items.Payment_Method__c,
                    'Transaction_Date__c' : items.Transaction_Date__c,
                    'Transaction_Type__c' : items.Transaction_Type__c,
                    'categoryOptions': items.categoryOptions,
                    'paymentInstrumentOptions': items.paymentInstrumentOptions,
                    'paymentInstrumentDetailOptions': items.paymentInstrumentDetailOptions
                });
                this.counter += 1;
            }
        });
        this.records = [];
        this.records = tempRecords;
        this.isLoading = false;
    }

    // Helper method to create the records
    createRecords() {
        this.isLoading = true;
        if(this.checkforEmptyDetails()) {
            alert('Please fill all the details to submit for record creation!');
            this.isLoading = false;
            return;
        }
        // recordsToBeCreated to capture the record details to be created
        let recordsToBeCreated = this.records.map(item => {
            return {
                'Amount__c' : item.Amount__c, 
                'Category__c' : item.Category__c,
                'Description__c' : item.Description__c,
                'Payment_Instrument__c' : item.Payment_Instrument__c,
                'Payment_Instrument_Detail__c' : item.Payment_Instrument_Detail__c,
                'Payment_Method__c' : item.Payment_Method__c,
                'Transaction_Date__c' : item.Transaction_Date__c,
                'Transaction_Type__c' : item.Transaction_Type__c,
            }
        });
        createRecords({
            records: recordsToBeCreated
        })
        .then(result => {
            this.isLoading = false;
            this.close(result);
        })
        .catch(error => {
            this.isLoading = false;
            this.close('error');
        });
    }

    // Helper method to check whether any field is not filled
    checkforEmptyDetails() {
        let checkFlag = false;
        this.records.forEach(item => {
            if(
                item.Amount__c == 0 ||
                item.Category__c == null ||
                item.Description__c === '' ||
                item.Payment_Instrument__c == null ||
                item.Payment_Instrument_Detail__c == null ||
                item.Payment_Method__c == null ||
                item.Transaction_Date__c == null ||
                item.Transaction_Type__c == null
            ) {
                checkFlag = true;
            }
        });
        return checkFlag;
    }
    /******************************************* Helper Methods - End *******************************************/

}