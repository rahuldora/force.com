import { track } from 'lwc';
import LightningModal from 'lightning/modal';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchBankAccounts from '@salesforce/apex/BankAccountsPageController.fetchBankAccounts';
import transferAmount from '@salesforce/apex/BankAccountsPageController.transferAmount';

export default class TransferAmountModal extends LightningModal {

    // Variables required to DML operation
    @track bankAccountTransfer = {
        amount : 0,
        transferFrom : '',
        transferTo: ''
    }

    // Variable to store the options for Bank Accounts
    @track bankAccountOptions = [];

    // Flag variable to determine whether the page is loading
    isLoading = false;

    constructor() {
        super();
        this.bankAccountTransfer.amount = 0;
    }

    connectedCallback() {
        this.isLoading = true;
        this.generateBankAccountOptions();
    }

    generateBankAccountOptions() {
        fetchBankAccounts()
        .then(results => {
            if(results) {
                this.bankAccountOptions = [];
                this.bankAccountOptions = results.map(element => {
                    let labelValue = element.Bank_Account_Name__c + 
                        ' - ' + element.Account_Type__c + 
                        '(' + element.Name + ')';
                    return {
                        label: labelValue,
                        value: element.Id
                    };
                });
            }
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error.stack);
            this.bankAccountOptions = [];
            this.isLoading = false;
        })
    }

    changeHandler(event) {
        const fieldName = event.target.name;
        this.bankAccountTransfer[fieldName] = event.target.value;
    }
    
    handleTransfer() {
        let errorFlag = false;
        let message = '';
        if(this.bankAccountTransfer['amount'] == 0) {
            errorFlag = true;
            message = 'Amount needs to be filled!';
        }
        else if(this.bankAccountTransfer.transferFrom === '' || this.bankAccountTransfer.transferTo === '') {
            errorFlag = true;
            message = '"From Bank Account" or "To Bank Account" needs to be filled!';
        }
        else if(this.bankAccountTransfer.transferFrom === this.bankAccountTransfer.transferTo) {
            errorFlag = true;
            message = '"From Bank Account" and "To Bank Account" cannot be same!';
        }
        
        if(errorFlag) {
            // this.showErrorToast(message);
            alert(message);
        }
        else {
            this.processAmountTransfer();
        }
    }

    processAmountTransfer() {
        transferAmount({
            amount : this.bankAccountTransfer.amount,
            fromBankAccountId : this.bankAccountTransfer.transferFrom,
            toBankAccountId : this.bankAccountTransfer.transferTo
        })
        .then(result => {
            alert('Amount Transfer status : '+result);
            this.close();
        })
        .catch(error => {
            alert('Amount Transfer status : Failed');
            this.close();
        });
    }

    // ShowToastEvent doesnot work inside LightningModal
    // showErrorToast(message) {
    //     const evnt = new ShowToastEvent({
    //         title : 'Amount Transfer Info!',
    //         message : message,
    //         variant : 'warning'
    //     });
    //     this.dispatchEvent(evnt);
    // }

}