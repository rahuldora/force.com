import { LightningElement, track, wire } from 'lwc';

import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import TXN_OBJECT from '@salesforce/schema/Financial_Transaction__c';
import CATEGORY_FIELD from '@salesforce/schema/Financial_Transaction__c.Category__c';
import TRACKER_OBJECT from '@salesforce/schema/Monthly_Tracker__c';

import getTracker from '@salesforce/apex/MonthlyTrackersPageController.getTracker';

export default class TrackerRecord extends LightningElement {

    isLoading;
    // Default RecordType ID of the Financial_Transaction__c
    txnRecordTypeId;
    // contains the recordId of the tracker records
    recordId; 
    // Contains the data which needs to be upserted
    dataTobeUpdated = {}; 
    // Contains the dataMap from which the table is displayed
    @track dataMap = [];
    // Contains the month & year data
    @track planner = {month: '', year: ''};
    
    /**************************************** Getter methods ****************************************/
    // getter method to set the monthOptions
    get monthOptions() {
        const monthNames = Array.from({ length: 12 }, (item, i) =>
            new Date(2024, i, 1).toLocaleString('en-US', { month: 'long' })
        );
        let monthList = [];
        monthNames.forEach(val => {
            monthList = [
                ...monthList,
                {label: val, value: val}
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
                {label: i.toString(), value: i.toString()}
            ];
        }
        return yearList;
    }
    
    /**************************************** Wire methods ****************************************/
    // wire method to fetch the default recordType Id of Financial_Transaction__c
    @wire(getObjectInfo, { objectApiName: TXN_OBJECT})
    results({ error, data }) {
        if(data) {
            this.txnRecordTypeId = data.defaultRecordTypeId;
        }
        else if (error) {
            console.error('Error occured while fetching the RecordType ::', JSON.stringify(error));
        }
    }
    
    // wire method to fetch the picklist values along with their controlling fields
    @wire(getPicklistValues, { recordTypeId: '$txnRecordTypeId', fieldApiName: CATEGORY_FIELD})
    categoryPickListInfo({ data, error }) {
        if(data) {
            this.createDataMap(data);
            this.isLoading = true;
            this.loadData();
        }
        else if(error) {
            console.error('Error occurred while fetching Category Picklist::', JSON.stringify(error));
        }
    }
    
    /**************************************** Constructor ****************************************/
    constructor() {
        super();
        const today = new Date();
        this.planner['month'] = this.monthOptions[today.getMonth()].value;
        this.planner['year'] = today.getFullYear().toString();
    }
    
    /**************************************** Helper methods ****************************************/
    // method to create the dataMap structure for storing and displaying the tracker data
    createDataMap(picklistData) {
        this.dataTobeUpdated = {};
        const iconMap = {'Income': 'action:update', 'Expense': 'action:record', 'Savings': 'action:new_account'};
        Object.keys(picklistData.controllerValues).map(controller => {
            let controllerIndex = picklistData.controllerValues[controller];
            let mapValues = picklistData.values.filter(element => element.validFor.includes(controllerIndex));
            let actualValues = [];
            mapValues.forEach(element => {
                let labelValue;
                if((element.label === 'Gift') && (controller === 'Income')) {
                    labelValue = 'GiftReceived';
                }
                else if((element.label === 'Gift') && (controller === 'Expense')) {
                    labelValue = 'GiftGiven';
                }
                else {
                    labelValue = element.label.replaceAll(' ','');
                }
                actualValues = [
                    ...actualValues,
                    {
                        label: (element.label === 'Credit Card Bill Payment') ? 'Credit Bills' : element.label, 
                        actualLabel: labelValue, 
                        actual: 0, 
                        projected: 0, 
                        diff: 0, 
                        diffStyle: 'color: #50C878'
                    }
                ];
            });
            this.dataMap = [
                ...this.dataMap,
                {txnType: controller, iconValue: iconMap[controller], values: actualValues}
            ];
        });
    }
    
    // method to capture the month/year in order to fetch the related tracker data
    handleAction(event) {
        const field = event.target.name;
        this.planner[field] = event.detail.value;
        this.dataTobeUpdated = {};
        this.isLoading = true;
        this.loadData();
    }
    
    // method to load the tracker data
    async loadData() {
        let fetchedData;
        this.recordId = '';
        try {
            fetchedData = await getTracker({
                month: this.planner.month,
                year: this.planner.year
            });
        }
        catch(error) {
            console.error('Error fetching the data');
        }
        finally {
            if(fetchedData) {
                this.recordId = fetchedData['Id'];
                this.processData(fetchedData);
            }
            else {
                this.resetValue();
            }
            this.isLoading = false;
        }
    }
    
    // method to map the tracker data to dataMap for displaying
    processData(data) {
        this.dataMap = this.dataMap.map(categoryGroup => {
            const updatedValues = categoryGroup.values.map(element => {
                const actual = data[element.actualLabel + '__c'] || 0;
                const projected = data[element.actualLabel + '_Projected__c'] || 0;
    
                let diffValue = actual - projected;
                let diff = (categoryGroup.txnType === 'Expense') ? -diffValue : diffValue;
    
                return {
                    ...element,
                    actual,
                    projected,
                    diff,
                    diffStyle: diff < 0 ? 'color: #D2042D' : 'color: #50C878'
                };
            });
    
            return {
                ...categoryGroup,
                values: updatedValues
            };
        });
    }
    
    // method to set all the values in the dataMap to 0 if no records were found
    resetValue() {
        this.dataMap = this.dataMap.map(categoryGroup => {
            const resetValues = categoryGroup.values.map(element => {
                return {
                    ...element,
                    actual: 0,
                    projected: 0,
                    diff: 0,
                    diffStyle: 'color: #50C878'
                };
            });
    
            return {
                ...categoryGroup,
                values: resetValues
            };
        });
    }
    
    // method to capture the data changes
    changeHandler(event) {
        const labelName = event.target.name;
        const newValue = event.target.value;
        const fieldName = labelName+'_Projected__c';
        this.dataTobeUpdated[fieldName] = newValue;
        // update UI reactive dataMap
        this.dataMap = this.dataMap.map(categoryGroup => {
            const updatedValues = categoryGroup.values.map(element => {
                if(element.actualLabel === labelName) {
                    const diffValue = element.actual - newValue;
                    const diff = (categoryGroup.txnType === 'Expense') ? -diffValue : diffValue;
                    return {
                        ...element,
                        projected: newValue,
                        diff,
                        diffStyle: (diff < 0) ? 'color: #D2042D' : 'color: #50C878'
                    };
                }
                return element;
    
            });
            return {
                ...categoryGroup,
                values: updatedValues
            };
        });
    }
    
    // method to handle the Insert / Update operation of the tracker data
    async clickHandler() {
        // No Changes done => No Insertion / Updation
        if(Object.keys(this.dataTobeUpdated).length === 0){
            const event = new ShowToastEvent({
                    title: 'No Change detected!',
                    message: 'No changes in the value has been detected!\n Please update the value and then click on "Update" button.',
                    variant: 'warning'
                });
                this.dispatchEvent(event);
            return;
        }
        // New Record needs to be created
        if(this.recordId === ''){
            this.dataMap.map(categoryGroup => {
                const updatedValues = categoryGroup.values.map(element => {
                    const fieldName = element.actualLabel +'_Projected__c';
                    const keyList = Object.keys(this.dataTobeUpdated);
                    if(!keyList.includes(fieldName)) {
                        this.dataTobeUpdated[fieldName] = 0;
                    }
                });
            });
            const fields = {
                ...this.dataTobeUpdated,
                Month__c: this.planner.month,
                Year__c: this.planner.year
            };
            const recordInput = { 
                apiName: TRACKER_OBJECT.objectApiName, 
                fields: fields 
            };
            try {
                await createRecord(recordInput);
                const event = new ShowToastEvent({
                    title: 'Creation successful!',
                    message: 'Record has been created successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.dataTobeUpdated = {};
                this.isLoading = true;
                this.loadData();
            }
            catch(error) {
                const event = new ShowToastEvent({
                    title: 'Creation Unsuccessful!',
                    message: 'There was a error in record creation!',
                    variant: 'error'
                });
                this.dispatchEvent(event);
                console.error(error.body.message);
            }
        }
        // Updation to be done
        else {
            this.dataTobeUpdated['Id'] = this.recordId;
            const fields = this.dataTobeUpdated;
            const recordInput = { fields };
            try {
                await updateRecord(recordInput);
                this.isLoading = true;
                this.loadData();
                this.dataTobeUpdated = {};
                const event = new ShowToastEvent({
                    title: 'Updation successful!',
                    message: 'Record has been updated successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            }
            catch(error) {
                console.error('Error updating the tracker');
                console.error(error.body.message);
                this.isLoading = true;
                this.loadData();
                this.dataTobeUpdated = {};
                const event = new ShowToastEvent({
                    title: 'Updation Unsuccessful!',
                    message: 'Record updation failed!',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
        }
    }

}