import { LightningElement,api,wire,track } from 'lwc';
import manageStatus from '@salesforce/apex/CNT_DTC_ManageStatus.manageStatus';
import getCaseRecord from '@salesforce/apex/CNT_DTC_ManageStatus.getCaseRecord';
import getStatus from '@salesforce/apex/CNT_DTC_ManageStatus.getStatusFromMetadata';

export default class DtcManageStatus extends LightningElement {
    @api selectedStatusValue;
    @api selectedSubstatusValue;
    @api selectedTypeValue;
    @api selectedHowCanWeHelpYou;
    @track isLoaded = true;
    @track isDisabled = true;
    @api error = false;
    @track substatusoptions;
    @api recordId;
    @api metadataRecord;
    @track statusoptions;
    
    connectedCallback() {
        this.isLoaded = false;
        getCaseRecord({recordId : this.recordId })
        .then(result => {
            if (result === null || result === undefined ) {
                this.isLoaded = true;
                this.template.querySelector('c-custom-toast').showToast('error', 'Case Record not found on manage status page.');
                return;
            } 
            if ((result.AdditionalInformation__c === undefined || result.AdditionalInformation__c === '') 
                || (result.Status === undefined || result.Status === '')) {
                this.isLoaded = true;
                this.template.querySelector('c-custom-toast').showToast('error', 'Missing either Type(i.e. Additional Information) or Status from this case record. Both are mandatory for Manage Status.');
                return;
            }
            else {
                this.selectedTypeValue = result.AdditionalInformation__c;
                this.selectedHowCanWeHelpYou = result.How_can_we_help__c;
                getStatus({ caseType : this.selectedTypeValue, howCanWeHelpYou : this.selectedHowCanWeHelpYou})  
                .then(data => {  
                    if (data !== '' && data !== undefined && data !== null) {  
                        this.metadataRecord = data;
                        this.selectedStatusValue = result.Status;
                        this.bindStatusAndSubStatusPicklist();
                        if (result.Sub_Status__c != undefined && result.Sub_Status__c != '') {
                            this.isDisabled = false;
                            this.selectedSubstatusValue = result.Sub_Status__c;
                        }
                    }
                })
                .catch(error => {
                    this.isLoaded = true;
                    this.template.querySelector('c-custom-toast').showToast('error', 'An error has occured. Please contact administrator.');
                });
            }
            this.isLoaded = true;
        })
        .catch(error => {
            this.isLoaded = true;
            this.template.querySelector('c-custom-toast').showToast('error', 'An error has occured. Please contact administrator.');
        });
    }

    bindStatusAndSubStatusPicklist(){
        var data = this.metadataRecord;
        var status = []; 
        var subStatus = []; 
        for (var key in data) {
            if (data.hasOwnProperty(key)) {
                const statusValue = key;
                const subStatusValue = data[key];
                if (!status.filter(e => e.label === statusValue).length > 0) {
                    status.push({label: statusValue, value: statusValue});
                    if (subStatusValue != undefined && subStatusValue != '' 
                    && subStatusValue.length > 0 && this.selectedStatusValue === statusValue) {
                        for (let subIndex = 0; subIndex < subStatusValue.length; subIndex++) {
                            const sub_Status = subStatusValue[subIndex];
                            if (!subStatus.filter(e => e.label === sub_Status).length > 0) {
                                subStatus.push({label: sub_Status, value: sub_Status});
                            }
                        }
                    }
                }
            }
        }
        if (status.length > 0) {
            this.statusoptions = status;
            this.isStatusDisabled = false;
        } else {
            this.isStatusDisabled = true;
        }
        if (subStatus.length > 0) {
            this.substatusoptions = subStatus;
            this.isDisabled = false;
        } else {
            this.isDisabled = true;
            this.substatusoptions = '';
            this.selectedSubstatusValue = '';
        }
    }

    handleStatusChange(event) {
        this.selectedStatusValue = event.target.value;
        this.selectedSubstatusValue = '';
        var subStatus = []; 
        var data = this.metadataRecord;
        for (var key in data) {
            if (data.hasOwnProperty(key)) {
                const statusValue = key;
                const subStatusValue = data[key];
                if (subStatusValue != undefined && subStatusValue != '' 
                && subStatusValue.length > 0 && this.selectedStatusValue === statusValue) {
                    for (let subIndex = 0; subIndex < subStatusValue.length; subIndex++) {
                        const sub_Status = subStatusValue[subIndex];
                        if (!subStatus.filter(e => e.label === sub_Status).length > 0) {
                            subStatus.push({label: sub_Status, value: sub_Status});
                        }
                    }
                }
            }
        }
        if (subStatus.length>0) {
            this.substatusoptions = subStatus;
            this.isDisabled = false;
        } else {
            this.isDisabled = true;
            this.substatusoptions = '';
            this.selectedSubstatusValue = '';
        }
    }

    handleSubStatusChange(event) {
        this.selectedSubstatusValue = event.target.value;
    }

    showToast() {
        if (this.selectedStatusValue == '' || this.selectedStatusValue == 'undefined' || this.selectedStatusValue == null) {
            this.template.querySelector('c-custom-toast').showToast('error', 'Please select an option.');
        } 
    }

    handleSubmit() {
        this.isLoaded = false;
        if (this.selectedStatusValue == '' || this.selectedStatusValue == 'undefined' || this.selectedStatusValue == null) {
            this.template.querySelector('c-custom-toast').showToast('error', 'Please select an option.');
            return;
        } 
        manageStatus({ status : this.selectedStatusValue, substatus: this.selectedSubstatusValue, recordId : this.recordId })
        .then(result => {
            if (result === null || result === undefined ) {
                this.isLoaded = true;
                this.template.querySelector('c-custom-toast').showToast('error', 'Status not updated.');
                return;
            } else {
                this.template.querySelector('c-custom-toast').showToast('success', 'Status updated successfully.');
                this.selectedTypeValue = result.AdditionalInformation__c;
                this.selectedStatusValue = result.Status;
                if (result.Sub_Status__c != undefined && result.Sub_Status__c != '') {
                    this.isDisabled = false;
                    this.selectedSubstatusValue = result.Sub_Status__c;
                }
                this.connectedCallback();
                this.isLoaded = true;
                const selectedEvent = new CustomEvent('linked', { detail: this.recordId });
                this.dispatchEvent(selectedEvent);
            }
        })
        .catch(error => {
            this.isLoaded = true;
            var errorDetails = error.body.message;
            console.log('Error-DTCManageStatus-'+errorDetails);
            if (errorDetails != '' && errorDetails != undefined && 
                errorDetails.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                var txt = errorDetails.substring(errorDetails.indexOf(',') + 1);
                var displaymsg = txt.split(":")[0];
                this.template.querySelector('c-custom-toast').showToast('error', displaymsg);
            } else {
                this.template.querySelector('c-custom-toast').showToast('error', 'An error has occured. Please contact administrator.');
            }
        });
    }
}