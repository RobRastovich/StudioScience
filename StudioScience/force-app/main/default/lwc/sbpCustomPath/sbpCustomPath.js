import { LightningElement,api,wire,track } from 'lwc';
import getPickListValues from '@salesforce/apex/SBP_CustomPath.getStatus';
import getCaseRecord from '@salesforce/apex/SBP_CustomPath.getCaseRecord';
import System_Information from '@salesforce/label/c.System_Information';

export default class SbpCustomPath extends LightningElement {
    @api metadataRecord;
    @track statusoptions;
    @api recordId;
    @api selectedStatusValue;
    @api selectedSubstatusValue;
    @api currentStep;

    connectedCallback() {
        getCaseRecord({recordId : this.recordId })
        .then(result => {
            if (result != null || result !== undefined ) {
                this.selectedStatusValue = result.Status;
                if (result.Sub_Status__c != null && result.Sub_Status__c != undefined) {
                    this.selectedSubstatusValue = result.Sub_Status__c;
                }
                getPickListValues({ brand : 'Laphroaig Single Cask' })  
                .then(data => {  
                    if (data !== '' && data !== undefined && data !== null) {  
                        this.metadataRecord = data;
                        this.bindCustomPath();
                    }
                })
                .catch(error => {
                });
            }
        })
        .catch(error => {
        });
    }
    
    bindCustomPath(){
        var data = this.metadataRecord;
        var status = []; 
        for (var key in data) {
            if (data.hasOwnProperty(key)) {
                const statusValue = data[key];
                if (!status.filter(e => e.label === statusValue).length > 0) {
                    status.push({label: statusValue, value: statusValue});
                }
            }
        }
        if (status.length > 0) {
            this.statusoptions = status;
            if (this.selectedSubstatusValue != null & this.selectedSubstatusValue != undefined) {
                this.currentStep = this.selectedStatusValue +'-'+ this.selectedSubstatusValue;
            } else {
                this.currentStep = this.selectedStatusValue;
            }
        }
    }
}