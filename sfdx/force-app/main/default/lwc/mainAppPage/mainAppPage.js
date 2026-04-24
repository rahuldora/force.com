import { LightningElement } from 'lwc';

export default class MainAppPage extends LightningElement {

    isLoading = true;

    renderedCallback() {
        this.isLoading = false;
    }

}