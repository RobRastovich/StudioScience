import { LightningElement,api,wire,track } from 'lwc';
import createCase from '@salesforce/apex/CNT_DTC_DHLCases.createCase';
export default class DhlCustomer extends LightningElement {
    @track error; 
    @track disableField = false;
    @track showButtons = true;
    @api spinnerStatus = false;
    @track isLoaded = true;
    @api selectedvalue;
    @track pageTitle;
    @api recordId;
    @api updateMode = false;
    @track value = '';
    @track issuevalue = '';
    @track statusValue = '';
    @api phoneRegex = '[0-9]{10}$';
    @track isReplacementTypeOfCase = false;
    @api casedata = {
        Program_Subscription__c : '', First_name__c : '', Last_name__c : '', Email_Address__c : '',
        Consumer_Street__c : '', Consumer_City__c : '', Consumer_State__c : '',
        Consumer_Postal_Code__c : '', Consumer_Country__c : '', OrderID__c : '',
        UPS_Tracking_Number__c : '', UPS_Reason_For_Return__c : '', CaseNumber : '', Id : '',
        DHL_Status__c : '', Customer_Phone_Number__c : '', Damage_Issue__c : '', AdditionalInformation__c : ''
    }
    @track caserecorddata = {
        Program_Subscription__c : '', First_name__c : '', Last_name__c : '', Email_Address__c : '',
        Consumer_Street__c : '', Consumer_City__c : '', Consumer_State__c : '',
        Consumer_Postal_Code__c : '', Consumer_Country__c : '', OrderID__c : '',
        UPS_Tracking_Number__c : '', UPS_Reason_For_Return__c : '', CaseNumber : '', Id : '',
        DHL_Status__c : '', Customer_Phone_Number__c : '', Damage_Issue__c : '', AdditionalInformation__c : ''
    }
    get programOptions() {
        return [
            { label: 'Whisky Drop', value: 'Whisky Drop' },
            { label: 'Barreled & Boxed', value: 'Barreled & Boxed' },
        ];
    }
    get statusOptions() {
        return [
            { label: 'Damage', value: 'Damage' },
            { label: 'Unsuccessful Delivery Attempts', value: 'Unsuccessful Delivery Attempts' },
        ];
    }
    get issueOptions() {
        return [
            { label: 'Damage', value: 'Damage' },
            { label: 'Lost', value: 'Lost' },
        ];
    }
    connectedCallback() {
        if (this.selectedvalue !== '' && this.selectedvalue !== 'undefined' && this.selectedvalue !== null) {
            this.pageTitle = 'Customer Information ( Form Type : '+this.selectedvalue+' )';
            this.caserecorddata.AdditionalInformation__c = this.selectedvalue;
        }
        if (this.recordId == undefined && this.caserecorddata != undefined) {
            this.recordId = this.caserecorddata.Id;
        }
        if (this.caserecorddata.Consumer_Country__c === undefined 
            || this.caserecorddata.Consumer_Country__c === '') {
                this.caserecorddata.Consumer_Country__c = 'US';
        }
    }    

    handleValueChange (event){
        if(event.target.name == 'Program_Subscription__c'){
            this.caserecorddata.Program_Subscription__c = event.target.value;  
            this.value = event.target.value;
        }
        if(event.target.name == 'First_name__c'){
            this.caserecorddata.First_name__c = event.target.value;  
        }
        if(event.target.name == 'Last_name__c'){
            this.caserecorddata.Last_name__c = event.target.value;  
        }
        if(event.target.name == 'Email_Address__c'){
            this.caserecorddata.Email_Address__c = event.target.value;  
        }
        if(event.target.name == 'Consumer_Street__c'){
            this.caserecorddata.Consumer_Street__c = event.target.value;  
        }
        if(event.target.name == 'Consumer_City__c'){
            this.caserecorddata.Consumer_City__c = event.target.value;  
        }
        if(event.target.name == 'Consumer_State__c'){
            this.caserecorddata.Consumer_State__c = event.target.value;  
        }
        if(event.target.name == 'Consumer_Postal_Code__c'){
            this.caserecorddata.Consumer_Postal_Code__c = event.target.value;  
        }
        if(event.target.name == 'Consumer_Country__c'){
            this.caserecorddata.Consumer_Country__c = event.target.value;  
        }
        if(event.target.name == 'OrderID__c'){
            this.caserecorddata.OrderID__c = event.target.value;  
        }
        if(event.target.name == 'UPS_Tracking_Number__c'){
            this.caserecorddata.UPS_Tracking_Number__c = event.target.value;  
        }
        if(event.target.name == 'UPS_Reason_For_Return__c'){
            this.caserecorddata.UPS_Reason_For_Return__c = event.target.value;  
        }
        if(event.target.name == 'DHL_Status__c'){
            this.caserecorddata.DHL_Status__c = event.target.value;  
            this.statusValue = event.target.value;
        }
        if(event.target.name == 'Customer_Phone_Number__c'){
            this.caserecorddata.Customer_Phone_Number__c = event.target.value;  
        }
        if(event.target.name == 'Damage_Issue__c'){
            this.caserecorddata.Damage_Issue__c = event.target.value;  
            this.issuevalue = event.target.value;
        }
        if (this.caserecorddata.Id != undefined && this.caserecorddata.Id != '' && this.updateMode == false) {
            this.updateMode = false;
        }
        this.casedata = this.caserecorddata;
        this.error = false;
    }

    handleRedirect(event){
        const redirectToDetailPage = new CustomEvent("detailpage", {
            detail: {displaycasedetail: true, createdcaseid : this.recordId}
        });
        this.dispatchEvent(redirectToDetailPage);
    }

    handleBack(event){
        if (this.casedata == undefined || this.casedata == null) {
            this.casedata = this.caserecorddata;  
        }
        const selectedPrevEvent = new CustomEvent("prevpage", {
            detail: {selectedvalue:this.selectedvalue,
                casedata : this.casedata}
        });
        this.dispatchEvent(selectedPrevEvent);
    }

    handleEdit(event){
        this.disableField = false;
    }

    handleSubmit(event){
        this.isLoaded = false;
        var isFormValid = this.isInputValid();
        if(!isFormValid) {
            this.error = true;
            this.isLoaded = true;
            this.template.querySelector('c-custom-toast').showToast('error', 'Required field is either empty or has incorrect format.');
            return;
        } else {
            this.error = false;
        }
        let existingCaseId = this.caserecorddata.Id;
        createCase({ caseInfo : this.caserecorddata })
            .then(result => {
                if (result === null || result === undefined ) {
                    this.isLoaded = true;
                    this.template.querySelector('c-custom-toast').showToast('error', 'Record creation failed!');
                    return;
                }
                if(this.caserecorddata !== undefined && result !== undefined && result !== null &&  result != '') {
                    this.error = undefined;
                    this.caserecorddata = result;
                    this.casedata = result;
                    this.recordId = result.Id;
                    this.value = this.caserecorddata.Program_Subscription__c;
                    var strStatus = this.caserecorddata.DHL_Status__c;
                    if (strStatus != undefined && strStatus != '' && strStatus != null) {
                        var statusSubString = strStatus.substring(
                            strStatus.indexOf("(") + 1, 
                            strStatus.lastIndexOf(")")
                        );
                        this.statusValue = statusSubString;
                    }
                    var damageIssueValue = this.caserecorddata.Damage_Issue__c;
                    if (damageIssueValue != undefined && damageIssueValue != '' && damageIssueValue != null) {
                        this.issuevalue = this.caserecorddata.Damage_Issue__c;
                    }
                    this.showButtons = true;
                    this.disableField = true;
                    this.isLoaded = true;
                    if (existingCaseId != undefined && existingCaseId != null && existingCaseId != '') {
                        this.template.querySelector('c-custom-toast').showToast('success', 'Record updated successfully. Case Number : '+result.CaseNumber);
                        this.updateMode = false;
                    } else {
                        this.template.querySelector('c-custom-toast').showToast('success', 'Record created successfully. Case Number : '+result.CaseNumber);
                    }
                }
            })
            .catch(error => {
                var errorDetails = error.body.message;
                console.log('Error-DHLCustomer-'+errorDetails);
                if (errorDetails != '' && errorDetails != undefined && 
                    errorDetails.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    var txt = errorDetails.substring(errorDetails.indexOf(',') + 1);
                    var displaymsg = txt.split("!")[0];
                    this.template.querySelector('c-custom-toast').showToast('error', displaymsg);
                } else {
                    this.template.querySelector('c-custom-toast').showToast('error', 'An error has occured. Please contact administrator.');
                } 
                this.isLoaded = true;
            });
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            this.caserecorddata[inputField.name] = inputField.value;
        });
        return isValid;
    }
}