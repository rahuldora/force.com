import { LightningElement, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NewTransactionModal from 'c/newTransactionModal';

export default class FinancialTransactionsPage extends LightningElement {

    @track planner = {
        month : 0,
        year : 0
    };

    // getter method to set the monthOptions
    get monthOptions() {
        const monthNames = Array.from({ length: 12 }, (item, i) =>
            new Date(2024, i, 1).toLocaleString('en-US', { month: 'long' })
        );
        let monthList = [];
        let counter = 1;
        monthNames.forEach(val => {
            monthList = [
                ...monthList,
                {
                    label: val, 
                    value: counter++
                }
            ];
        });
        return monthList;
    }

    // getter method to set the monthOptions
    get yearOptions() {
        let yearList = [];
        for(let i=2025; i<2100; i++) {
            yearList = [
                ...yearList,
                {
                    label: i.toString(), 
                    value: i
                }
            ];
        }
        return yearList;
    }

    constructor() {
        super();
        const today = new Date();
        this.planner['month'] = this.monthOptions[today.getMonth()].value;
        this.planner['year'] = today.getFullYear();
    }

    connectedCallback() {
        
    }

    handleAction(event) {
        const fieldName = event.target.name;
        const fieldValue = parseInt(event.target.value);
        this.planner[fieldName] = fieldValue;
        const children = this.template.querySelectorAll('c-transaction-records');
        children.forEach(child => {
            child.month = this.planner.month;
            child.year = this.planner.year;
            child.getRecords();
        });
    }

    async handleClick() {
        const result = await NewTransactionModal.open({
            label: 'New Transactions',
            size: 'large'
        });
        if (result){
            const message = (result === 'success') ? 
            'Records were created successfully!' :
            'Record creation failed due to some error. Please try again!';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Record Creation Status',
                    message: message,
                    variant: result
                })
            );
        }
        // Calling the child components method
        const children = this.template.querySelectorAll('c-transaction-records');
        children.forEach(child => {
            child.getRecords();
        });
    }

}