import { LightningElement, track } from 'lwc';
import fetchCreditCards from '@salesforce/apex/CreditCardsPageController.fetchCreditCards';
import EditCreditCardModal from 'c/editCreditCardModal';

const columns = [
    { 
        label: 'Card Name', 
        fieldName: 'Credit_Card_Name__c', 
        type: 'text' 
    },
    { 
        label: 'Amount Utilised', 
        fieldName: 'Amount_Utilised__c', 
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR',   // ✅ Key part
            minimumFractionDigits: 2
        }
    },
    { 
        label: 'Available Limit', 
        fieldName: 'Available_Limit__c', 
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR',   // ✅ Key part
            minimumFractionDigits: 2
        } 
    },
    { 
        label: 'Total Limit', 
        fieldName: 'Total_Limit__c',
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR',   // ✅ Key part
            minimumFractionDigits: 2
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [{ 
                label: 'Edit', 
                name: 'Edit' 
            }]
        }
    }
];

export default class CreditCardsPage extends LightningElement {

    // Datatable variables
    columns = columns;
    @track data = [];
    
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
        fetchCreditCards()
        .then(results => {
            if(results){
                this.data = results;
                this.hasRecords = ((Array.isArray(this.data)) && (this.data.length === 0)) ? false : true;
                this.isLoading = false;
            }
            else {
                this.data = [];
                this.isLoading = false;
                this.hasRecords = false;
            }
        })
        .catch(error => {
            console.error(error.stack);     
            this.data = [];
            this.isLoading = false;
            this.hasRecords = false;
        });
    }

    // Row action Handler
    async handleRowAction(event) {
        const row = event.detail.row;
        console.log(JSON.stringify(row));
        const result = await EditCreditCardModal.open({
            label: 'Edit Credit Card',
            size: 'small',
            recordId: row.Id
        });
        this.isLoading = true;
        this.getRecords();
    }

}