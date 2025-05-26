import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseRecord from '@salesforce/apex/CNT_DTC_DHLCases.getCaseRecord';
export default class dhlCase extends LightningElement {
    activeSections = ['Customer Details','Order Details'];
    @track error;
    @track disablleOrderFields = true;
    @track showButtons = true;
    @api spinnerStatus = false;
    @api caseid;
    @api createdcaseid;
    @track displayList = true;
    isLoaded = false;
    @track recordId;
    @track caseRecordData={};
    @track isDisplay= true;
    caseIdFromURL;
    @track isEditable = true;
    
    @wire(getCaseRecord,{ recordId: '$recordId' })
    fetchCaseSummary({ error, data }) {
        if (data) {
            this.isLoaded = true;
            this.caseRecordData = data;
            this.toCheckAdditionalInformation();
        } else if (error) {
            
        }
    }

    toCheckAdditionalInformation(){
        if(this.caseRecordData.AdditionalInformation__c == 'Payment Decline' 
        || this.caseRecordData.AdditionalInformation__c == 'Membership Cancellation' 
        || this.caseRecordData.AdditionalInformation__c == 'Cancel Shipment'){
            this.isDisplay = false;
        }
        if(this.caseRecordData.Status.includes('Closed')){
            this.isEditable = false;
        }
    }

    connectedCallback() {
        /*caseid is coming from listview page */
        if (this.caseid != undefined && this.caseid != '') {
            this.recordId = this.caseid;
            this.displayList = true;
        }
        /*createdcaseid is coming from case creation form */
        if (this.createdcaseid != undefined && this.createdcaseid != '') {
            this.recordId = this.createdcaseid;
            this.displayList = false;
        } 
    }

    handleSubmit(event){
        this.spinnerStatus = !this.spinnerStatus;
    }

    handleError(event){
        this.spinnerStatus = false;
        this.spinnerStatus = false;
        if(this.spinnerStatus == false) {
            this.template.querySelector('c-custom-toast').showToast('error', JSON.stringify(event.detail.detail));
            return;
        } 
    }

    handleSuccess(event) {
        this.spinnerStatus = false;
        this.disablleOrderFields = true;
        this.showButtons = true;
        if(this.spinnerStatus == false) {
            this.template.querySelector('c-custom-toast').showToast('success', 'Record is updated successfully');
            return;
        } 
    }

    handleEdit(){
        this.disablleOrderFields = false;
        this.showButtons = false;
    }
    handleCancel(){
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.disablleOrderFields = true;
        this.showButtons = true;
    }

    handleRedirectToCreate(event){
        const redirectToCreatePage = new CustomEvent("detailtocreatepage", {
            detail: false
        });
        this.dispatchEvent(redirectToCreatePage);
    }

    handleRedirectToList(event){
        this.getQueryParameters(event);
        const redirectToListPage = new CustomEvent("detailtolistpage", {
            detail: true
        });
        this.dispatchEvent(redirectToListPage);
    }

    getQueryParameters(event) {
        let urlString = (window.location != window.parent.location) ? document.referrer : document.location.href;
        let url = new URL(urlString);
        let recordId = url.searchParams.get("Id");
        if (recordId !== undefined && recordId !== null) {
            this.caseIdFromURL = recordId;
            var updatedURL = this.removeParam("Id", url.toString());
            top.postMessage({
                eventType: "Go Back Event",
                url: updatedURL
            }, window.location.origin);
        }
    }

    removeParam(key, sourceURL) {
        var rtn = sourceURL.split("?")[0],
            param,
            params_arr = [],
            queryString = (sourceURL.indexOf("?") !== -1) ? sourceURL.split("?")[1] : "";
        if (queryString !== "") {
            params_arr = queryString.split("&");
            for (var i = params_arr.length - 1; i >= 0; i -= 1) {
                param = params_arr[i].split("=")[0];
                if (param === key) {
                    params_arr.splice(i, 1);
                }
            }
            if (params_arr.length) rtn = rtn + "?" + params_arr.join("&");
        }
        return rtn;
    }
}