import { api, track, wire } from 'lwc';

import LightningModal from 'lightning/modal';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';

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

export default class EditTransactionModal extends LightningModal {

    @api recordId;
    @track record = {};

    // Flag variable to display the spinner when required
    isLoading = true;

    txnRecordTypeId;

    // Map variables to store the dependent picklist values
    categoryMap = {}; // Category => dependent on => Transaction Type
    paymentInstrumentMap = {}; // Payment Instrument => dependent on => Payment Method
    paymentInstrumentDetailMap = {}; // Payment Instrument Detail => dependent on => Payment Instrument

    // Option Variables
    txnTypeOptions = [];
    paymentMethodOptions = [];
    @track categoryOptions = [];
    @track paymentInstrumentOptions = []
    @track paymentInstrumentDetailOptions = [];

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
    
    // wire method to fetch the record data
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            AMOUNT_FIELD, 
            CATEGORY_FIELD,
            DESCRIPTION_FIELD,
            PAYMENT_INSTRUMENT_FIELD,
            PAYMENT_INSTRUMENT_DETAIL_FIELD,
            PAYMENT_METHOD_FIELD,
            TRANSACTION_DATE_FIELD,
            TRANSACTION_TYPE_FIELD
        ]
    })
    recordData({ data, error }) {
        if (!this.recordId) return;
        if(data) {
            this.record = {
                'Id' : data.id,
                'Amount__c' : getFieldValue(data,AMOUNT_FIELD), 
                'Category__c' : getFieldValue(data, CATEGORY_FIELD),
                'Description__c' : getFieldValue(data, DESCRIPTION_FIELD),
                'Payment_Instrument__c' : getFieldValue(data, PAYMENT_INSTRUMENT_FIELD),
                'Payment_Instrument_Detail__c' : getFieldValue(data, PAYMENT_INSTRUMENT_DETAIL_FIELD),
                'Payment_Method__c' : getFieldValue(data, PAYMENT_METHOD_FIELD),
                'Transaction_Date__c' : getFieldValue(data, TRANSACTION_DATE_FIELD),
                'Transaction_Type__c' : getFieldValue(data, TRANSACTION_TYPE_FIELD)
            };
            this.isRecordLoaded = true;
            this.initializeUI();
        }
        else if(error) {
            console.error('Error occurred while fetching Category Picklist::', JSON.stringify(error));
        }
    }
    /******************************************* Wire Methods - End *******************************************/

    constructor() {
        super();
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
            !this.isPaymentPicklistLoaded ||
            !this.isRecordLoaded
        ) {
            return;
        }
        // set the category picklist based on the txnType
        this.categoryOptions = [];
        this.categoryOptions = this.prepareCategoryOptions(this.record.Transaction_Type__c);
        // set the payment instrument picklist based on the paymentMethod
        this.paymentInstrumentOptions = [];
        this.paymentInstrumentOptions = this.preparePaymentInstrumentOptions(this.record.Payment_Method__c);
        // set the catergory picklist based on the txnType
        this.paymentInstrumentDetailOptions = [];
        this.paymentInstrumentDetailOptions = this.preparePaymentInstrumentDetailOptions(this.record.Payment_Instrument__c);
        this.isLoading = false;
    }
    
    /******************************************* Handler Methods - Start *******************************************/
    // change handler method to capture the changes in the field
    handleChange(event) {
        const fieldName = event.target.name;
        this.record[fieldName] = event.target.value;

        // Clear dependent fields when controlling field changes
        if (fieldName === 'Transaction_Type__c') {
            this.record['Category__c'] = null;
        }
        else if (fieldName === 'Payment_Method__c') {
            this.record['Payment_Instrument__c'] = null;
            this.record['Payment_Instrument_Detail__c'] = null;
        }
        else if (fieldName === 'Payment_Instrument__c') {
            this.record['Payment_Instrument_Detail__c'] = null;
        }
        this.initializeUI();
    }   
    
    // click handler method to process the data upon button click
    handleClick(event) {
        const operation = event.target.name;
        if(operation === 'cancel') {
            this.close();
        }
        if(operation === 'update'){
            this.isLoading = true;
            const fields = {};
            Object.keys(this.record).forEach(key => {
                fields[key] = this.record[key];
            });
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                this.isLoading = false;
                this.close('success');
            })
            .catch(error => {
                this.isLoading = false;
                this.close('error');
            });
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
    /******************************************* Helper Methods - End *******************************************/
    
}