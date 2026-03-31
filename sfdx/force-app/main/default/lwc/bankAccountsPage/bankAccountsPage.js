import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchBankAccounts from '@salesforce/apex/BankAccountsPageController.fetchBankAccounts';
import TransferAmountModal from 'c/transferAmountModal';
import EditBankAccountModal from 'c/editBankAccountModal';

const columns = [
    { 
        label: 'Account Number', 
        fieldName: 'Name', 
        type: 'text' 
    },
    { 
        label: 'Account Name', 
        fieldName: 'Bank_Account_Name__c', 
        type: 'text' 
    },
    { 
        label: 'Account Type', 
        fieldName: 'Account_Type__c', 
        type: 'text' 
    },
    { 
        label: 'Balance', 
        fieldName: 'Balance__c',
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR',   // ✅ Key part
            minimumFractionDigits: 2
        }
    },
    { 
        label: 'Minimum Balance', 
        fieldName: 'Minimum_Balance__c',
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR',   // ✅ Key part
            minimumFractionDigits: 2
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Edit', name: 'Edit' }
            ]
        }
    }
];

export default class BankAccountsPage extends LightningElement {

    // Datatable variables
    columns = columns;
    @track 
    data = [];
    
    // Flag variable
    hasRecords = false;

    // Flag variable for loading
    isLoading = false;
    
    constructor() {
        super();
    }

    connectedCallback(){
        this.isLoading = true;
        this.getRecords();
    }

    // helper method to make an imperative call to apex
    getRecords() {
        fetchBankAccounts()
        .then(results => {
            this.data = results;
            this.hasRecords = ((Array.isArray(this.data)) && (this.data.length === 0)) ? false : true;
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error.stack);     
            this.data = [];
            this.isLoading = false;
        });
    }

    // Row action Handler
    async handleRowAction(event) {
        const row = event.detail.row;
        const result = await EditBankAccountModal.open({
            label: 'Edit Bank Account',
            size: 'medium',
            recordId: row.Id
        });
        this.isLoading = true;
        this.getRecords();
    }

    // Handle Transfer
    async handleTransfer() {
        const result = await TransferAmountModal.open({
            label: 'Transfer Amount',
            size: 'small',
        });
        this.isLoading = true;
        this.getRecords();
    }

    // // Display Success Toast
    // showSuccessToast() {
    //     const evt = new ShowToastEvent({
    //         title: 'Success',
    //         message: 'Amount transferred successfully',
    //         variant: 'success'
    //     });
    //     this.dispatchEvent(evt);
    // }

    // // Display Error Toast
    // showErrorToast() {
    //     const evt = new ShowToastEvent({
    //         title: 'Error',
    //         message: 'Amount transfer Unsuccessful!',
    //         variant: 'error'
    //     });
    //     this.dispatchEvent(evt);
    // }

}