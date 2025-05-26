import { LightningElement, track, api } from 'lwc';
 
export default class DhlSelectType extends LightningElement {
    @api selectedvalue;
    @track isLoaded = true;
    @api displayComboCmp = false;
    @api error = false;
    @api casedata;
    
    get options() {
        return [
            { label: 'Physical Return', value: 'Physical Return' }
        ];
    }

    connectedCallback() {
        if (this.selectedvalue == '' || this.selectedvalue == 'undefined' || this.selectedvalue == null) {
            this.error = true;
        } else{
            this.error = false;
        }
    }

    handleChange(event) {
        this.selectedvalue = event.target.value;
        this.casedata = event.target.casedata;
        
        if (this.selectedvalue == '' || this.selectedvalue == 'undefined' || this.selectedvalue == null) {
            this.error = true;
        } else{
            this.error = false;
        }
    }

    showToast() {
        if (this.selectedvalue == '' || this.selectedvalue == 'undefined' || this.selectedvalue == null) {
            this.template.querySelector('c-custom-toast').showToast('error', 'Please select an option to proceed.');
        } 
    }

    nextStep() {
        this.isLoaded = false;
        if (this.selectedvalue == '' || this.selectedvalue == 'undefined' || this.selectedvalue == null) {
            this.error = true;
        } else {
            this.error = false;
            const selectedEvent = new CustomEvent("nextpage", {
                detail: {selectedvalue: this.selectedvalue,
                casedata : this.casedata}
            });
            this.dispatchEvent(selectedEvent);
        }
        this.isLoaded = true;
    }
}