import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getRecord, updateRecord, createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import TXN_OBJECT from '@salesforce/schema/Financial_Transaction__c';
// import PAYMENT_METHOD_FIELD from '@salesforce/schema/Financial_Transaction__c.Payment_Method__c';
import CATEGORY_FIELD from '@salesforce/schema/Financial_Transaction__c.Category__c';

import getTxnRecordById from '@salesforce/apex/FinancialTransactionsPageController.getTxnRecordById';
import updateTransaction from '@salesforce/apex/FinancialTransactionsPageController.updateTransaction';
import getPaymentMethodDependentOptions from '@salesforce/apex/FinancialTransactionsPageController.getPaymentMethodDependentOptions';

export default class EditTransactionModal extends LightningModal {

    @api recordId;
    @api mode;

    @track record = {};
    
    txnRecordTypeId;
    categoryMap;
    dependentPicklistMap;
    
    txnTypeOptions = [];
    @track categoryOptions = [];
    paymentMethodOptions = [];
    @track paymentInstrumentOptions = []
    @track paymentInstrumentDetailOptions = [];

    isLoading;

    // wire method to fetch the default recordType Id of Financial_Transaction__c
    @wire(getObjectInfo, { 
        objectApiName: TXN_OBJECT
    })
    results({ error, data }) {
        if(data) {
            this.txnRecordTypeId = data.defaultRecordTypeId;
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
            this.prepareCategorymap(data);
            this.prepareCategoryOptions();
        }
        else if(error) {
            console.error('Error occurred while fetching Category Picklist::', JSON.stringify(error));
        }
    }

    // helper method to prepare the categoryMap for generating the dependent picklist value based on the txnType
    prepareCategorymap(data) {
        const controllerMap = data.controllerValues;
        const values = data.values;
        // Reverse map => index => txnType
        const indexToTypeMap = {};
        Object.keys(controllerMap).forEach(key => {
            indexToTypeMap[controllerMap[key]] = key;
        });
        // Initialize result map
        const result = {};
        // Loop through dependent values
        values.forEach(item => {
            item.validFor.forEach(index => {
                const txnType = indexToTypeMap[index];
                if (!result[txnType]) {
                    result[txnType] = [];
                }
                result[txnType].push(item.value);
            });
        });
        // Convert to required structure
        this.categoryMap = Object.keys(result).map(key => {
            return {
                txnType: key,
                values: result[key]
            };
        });
        // to prepare the txnType options
        this.prepareTxnTypeOptions(controllerMap);
    }
    
    // helper method to create the txnTypeOptions
    prepareTxnTypeOptions(controllerValues) {
        this.txnTypeOptions = [];
        Object.keys(controllerValues).forEach(key => {
            let val = {
                label : key,
                value : key
            }
            this.txnTypeOptions.push(val);
        });
    }

    // helper method to create the categoryOptions
    prepareCategoryOptions() {
        if(this.record.Id === undefined) {
            return;
        }
        this.categoryOptions = [];
        this.categoryMap.forEach(element => {
            if(element.txnType === this.record.Transaction_Type__c) {
                element.values.forEach(val => {
                    let optionValue = {
                        label : val,
                        value : val
                    };
                    this.categoryOptions.push(optionValue);
                })
            }
        });
    }
    
    // wire method to fetch the picklist values for payment method
    // @wire(getPicklistValues, { 
    //     recordTypeId: '$txnRecordTypeId', 
    //     fieldApiName: PAYMENT_METHOD_FIELD
    // })
    // paymentMethodPickListInfo({ data, error }) {
    //     if(data) {
    //         this.preparePaymentMethodOptions(data);
    //     }
    //     else if(error) {
    //         console.error('Error occurred while fetching Payment Method Picklist::', JSON.stringify(error));
    //     }
    // }

    
    // Wire method to fetch the Payment Method => Payment Instrument => Payment Instrument Detail picklist
    @wire(getPaymentMethodDependentOptions)
    fetchDependentPicklistMap({ data, error }) {
        if(data) {
            this.dependentPicklistMap = JSON.parse(data).records;
            this.preparePaymentMethodOptions();
            this.preparePaymentInstrumentOptions();
            this.preparePaymentInstrumentDetailOptions();
        }
        else if(error) {
            console.error('Error occurred while fetching Dependent Picklist Map::', JSON.stringify(error));
        }
    }
    
    // helper method to create the paymentMethodOptions
    preparePaymentMethodOptions() {
        this.paymentMethodOptions = this.dependentPicklistMap.map(item => ({
            label: item.paymentMethod,
            value: item.paymentMethod
        }));
    }

    preparePaymentInstrumentOptions() {
        this.paymentInstrumentOptions = [];
        if(this.record.Id === undefined) {
            return;
        }
        let selectedPaymentMethod = this.record.Payment_Method__c;
        const methodObj = this.dependentPicklistMap?.find(
            item => item.paymentMethod === selectedPaymentMethod
        );
        if(!methodObj) return;

        this.paymentInstrumentOptions = methodObj.paymentInstrument.map(pi => ({
            label: pi.paymentInstrument,
            value: pi.paymentInstrument
        }));
    }

    preparePaymentInstrumentDetailOptions() {
        this.paymentInstrumentDetailOptions = [];
        if(this.record.Id === undefined) {
            return;
        }

        let selectedPaymentMethod = this.record.Payment_Method__c;
        const methodObj = this.dependentPicklistMap?.find(
            item => item.paymentMethod === selectedPaymentMethod
        );
        if(!methodObj) return;
        
        let selectedPaymentInstrument = this.record.Payment_Instrument__c;
        const instrumentObj = methodObj.paymentInstrument?.find(
            pi => pi.paymentInstrument === selectedPaymentInstrument
        );
        if(!instrumentObj) return;

        this.paymentInstrumentDetailOptions = instrumentObj.paymentInstrumentDetail.map(detail => (
            {
                label: detail,
                value: detail
            }
        ));
    }

    // helper method to create the Payment Instrument options
    // preparepaymentInstrumentOptions() {
    //     if(this.record.Id === undefined) {
    //         return;
    //     }
    //     this.categoryOptions = [];
    //     this.categoryMap.forEach(element => {
    //         if(element.txnType === this.record.Transaction_Type__c) {
    //             element.values.forEach(val => {
    //                 let optionValue = {
    //                     label : val,
    //                     value : val
    //                 };
    //                 this.categoryOptions.push(optionValue);
    //             })
    //         }
    //     });
    // }
    
    constructor() {
        super();
    }
    
    connectedCallback(){
        this.isLoading = true;
        this.loadRecord();
    }
    
    // helper method to load the record data
    loadRecord() {
        getTxnRecordById({ 
            recordId: this.recordId 
        })
        .then(result => {
            if(result) {
                this.record = result;
                // Rebuild EVERYTHING after record loads
                this.prepareCategoryOptions();
                if(this.dependentPicklistMap) {
                    this.preparePaymentMethodOptions();
                    this.preparePaymentInstrumentOptions();
                    this.preparePaymentInstrumentDetailOptions();
                }
                this.isLoading = false;
            }
        })
        .catch(error => {
            console.error(error.stack);     
            this.record = {};
            this.isLoading = false;
        });
    }
    
    // handler method to handle the value change
    changeHandler(event) {
        const fieldName = event.target.name;
        this.record[fieldName] = event.target.value;
        if(fieldName === 'Transaction_Type__c') {
            this.prepareCategoryOptions();
        }
        else if(fieldName === 'Payment_Method__c') {
            this.preparePaymentInstrumentOptions();
            this.preparePaymentInstrumentDetailOptions();
        }
        else if(fieldName === 'Payment_Instrument__c') {
            this.preparePaymentInstrumentDetailOptions();
        }
    }
    
    // handler method to update the record value
    handleUpdate() {
        this.isLoading = true;
        updateTransaction({
            txn : this.record
        })
        .then(result => {
            alert('Transaction record updation was ' + result + '!!!');
            this.isLoading = false;
            this.close();
        })
        .catch(error => {
            alert('Transaction record updation was Unsuccesful!!!');
            this.isLoading = false;
            this.close();
        })
    }
    
    // handler method to close the modal
    handleCancel() {
        this.close();
    }
    
}