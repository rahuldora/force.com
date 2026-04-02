import { api, LightningElement, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTxnRecords from '@salesforce/apex/FinancialTransactionsPageController.getTxnRecords';
import EditTransactionModal from 'c/editTransactionModal';

const columns = [
    { 
        label: 'Date', 
        fieldName: 'Transaction_Date__c', 
        type: 'Date' 
    },
    { 
        label: 'Amount', 
        fieldName: 'Amount__c', 
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR',   // ✅ Key part
            minimumFractionDigits: 2
        }
    },
    { 
        label: 'Description', 
        fieldName: 'Description__c', 
        type: 'text' 
    },
    { 
        label: 'Category', 
        fieldName: 'Category__c', 
        type: 'text' 
    },
    { 
        label: 'Payment Method', 
        fieldName: 'Payment_Method__c', 
        type: 'text' 
    },
    { 
        label: 'Payment Instrument', 
        fieldName: 'Payment_Instrument__c', 
        type: 'text' 
    },
    { 
        label: 'Payment Instrument Detail', 
        fieldName: 'Payment_Instrument_Detail__c', 
        type: 'text' 
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { 
                    label: 'Edit', 
                    name: 'edit' 
                },
                { 
                    label: 'Delete', 
                    name: 'delete' 
                }
            ]
        }
    }
];

export default class TransactionRecords extends LightningElement {

    columns = columns;
    @track data = [];
    @track visibleData = [];
    
    pageNo;
    pageSize = 20;
    totalPages;

    isLoading = false;
    
    @api txnType;
    @api month;
    @api year;

    constructor() {
        super();
    }

    connectedCallback() {
        this.getRecords();
    }
    
    @api getRecords() {
        this.isLoading = true;
        getTxnRecords({
            txnType : this.txnType,
            month : this.month,
            year : this.year
        })
        .then(results => {
            if(results && results.length > 0) {
                this.data = results;
                this.totalPages = Math.ceil(this.data.length / this.pageSize);
                this.pageNo = 1;
                this.displayData();
            }
            else {
                this.data = [];
                this.visibleData = [];
                this.pageNo = 0;
                this.totalPages = 0;
            }
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error.stack);
            this.data = [];
            this.visibleData = [];
            this.isLoading = false;
        })
    }

    async handleRowAction(event){
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.Id;
        if(actionName === 'delete') {
            try {
                await deleteRecord(rowId);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Transaction deleted!!!',
                        variant: 'success'
                    })
                );
            }
            catch(error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed',
                        message: 'Transaction deletion failed!!!',
                        variant: 'error'
                    })
                );
            }
        }
        else {
            const result = await EditTransactionModal.open({
                label: 'Edit Transaction',
                size: 'small',
                recordId: rowId
            });
            this.isLoading = true;
            this.getRecords();
        }
    }

    displayData() {
        const start = (this.pageNo - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.visibleData = this.data.slice(start, end);
    }

    handleNext() {
        if (this.pageNo < this.totalPages) {
            this.pageNo++;
            this.displayData();
        }
    }

    handlePrevious() {
        if (this.pageNo > 1) {
            this.pageNo--;
            this.displayData();
        }
    }

    get disableNext() {
        return this.pageNo >= this.totalPages;
    }

    get disablePrevious() {
        return this.pageNo <= 1;
    }

}