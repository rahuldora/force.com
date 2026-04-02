import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import fetchBankAccountById from '@salesforce/apex/BankAccountsPageController.fetchBankAccountById';
import updateBankAccount from '@salesforce/apex/BankAccountsPageController.updateBankAccount';

const FIELDS = [
    "Bank_Account__c.Id", 
    "Bank_Account__c.Name", 
    "Bank_Account__c.Bank_Account_Name__c", 
    "Bank_Account__c.Account_Type__c", 
    "Bank_Account__c.Balance__c", 
    "Bank_Account__c.Minimum_Balance__c"
];

export default class EditBankAccountModal extends LightningModal {

    @api recordId;
    @track record = {};

    get accountTypes() {
        return [
            {
                label: 'Savings Account',
                value: 'Savings Account'
            },
            {
                label: 'Joint Account',
                value: 'Joint Account'
            }
        ]
    }

    constructor() {
        super();
    }

    connectedCallback(){
        this.loadRecord();
    }

    loadRecord() {
        fetchBankAccountById({ recordId: this.recordId})
        .then(results => {
            if(results) {
                this.record = results;
            }
        })
        .catch(error => {
            console.error(error.stack);     
            this.record = {};
        });
    }

    changeHandler(event) {
        const fieldName = event.target.name;
        this.record[fieldName] = event.target.value;
    }

    handleUpdate() {
        updateBankAccount({
            record : this.record
        })
        .then(result => {
            alert('Bank Account record updation was ' + result + '!!!');
            this.close();
        })
        .catch(error => {
            alert('Bank Account record updation was Unsuccesful!!!');
            this.close();
        })
    }

    handleCancel() {
        this.close();
    }

}