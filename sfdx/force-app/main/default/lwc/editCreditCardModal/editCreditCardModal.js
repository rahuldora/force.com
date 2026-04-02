import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import fetchCreditCardById from '@salesforce/apex/CreditCardsPageController.fetchCreditCardById';
import updateCreditCard from '@salesforce/apex/CreditCardsPageController.updateCreditCard';

export default class EditCreditCardModal extends LightningModal {
    @api recordId;
    @track record = {};

    constructor() {
        super();
    }

    connectedCallback(){
        this.loadRecord();
    }

    loadRecord() {
        fetchCreditCardById({ recordId: this.recordId})
        .then(result => {
            if(result) {
                this.record = result;
                console.log(JSON.stringify(this.record));
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
        updateCreditCard({
            card : this.record
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