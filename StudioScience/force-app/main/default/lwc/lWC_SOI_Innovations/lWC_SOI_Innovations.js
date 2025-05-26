import { LightningElement, track, wire, api } from 'lwc';
import getInnovationSampleRecords from '@salesforce/apex/CNT_LWC_SOI_Innovations.getInnovationSampleRecords';
import saveInnovationRecords from '@salesforce/apex/CNT_LWC_SOI_Innovations.saveInnovationRecords';
import filterStatesByCountry from '@salesforce/apex/SFT_SampleOrderFormController.filterStatesByCountry';
import getSoldToPicklistValues from '@salesforce/apex/CNT_LWC_SOI_Innovations.getSoldToPicklistValues';
import getSampleKitShipAddressMap from '@salesforce/apex/CNT_LWC_SOI_Innovations.getSampleKitShipAddressMap';
import innovationSampleLabel from '@salesforce/label/c.Innovation_Samples';
import cutoffDateLabel from '@salesforce/label/c.Cutoff_Date';
import submittedByLabel from '@salesforce/label/c.Submitted_By';
import emailLabel from '@salesforce/label/c.Email_Label';
import soldToLabel from '@salesforce/label/c.Sold_To';
import beamCanadaLabel from '@salesforce/label/c.Beam_Canada_Label';
import costCenterLabel from '@salesforce/label/c.Cost_Center';
import costCenterHelptext from '@salesforce/label/c.Cost_center_helptext_message';
import wbsElementLabel from '@salesforce/label/c.WBS_Element';
import projectInformationLabel from '@salesforce/label/c.Project_Information';
import notesLabel from '@salesforce/label/c.Notes';
import resubmissionLabel from '@salesforce/label/c.Resubmission_due_to_change';
import submitLabel from '@salesforce/label/c.Submit_Label';
import resetLabel from '@salesforce/label/c.Reset';
import submissionLabel from '@salesforce/label/c.SUBMISSION';
import submitModalMessage from '@salesforce/label/c.Submit_modal_message';
import cancelLabel from '@salesforce/label/c.Cancel_Label';
import okLabel from '@salesforce/label/c.Ok';
import warningLabel from '@salesforce/label/c.WARNING';
import incorrectModalMessage from '@salesforce/label/c.Incorrect_fields_modal_message';
import resetModalMessage from '@salesforce/label/c.Reset_form_modal_message';
import errorOccurredLabel from '@salesforce/label/c.ERROR_OCCURRED';
import errorModalMessage from '@salesforce/label/c.Error_occurred_modal_message';
import successMessage from '@salesforce/label/c.Innovation_form_Success_message';
import fieldErrorMessage from '@salesforce/label/c.Field_Error_Message';
import notesHelptext from '@salesforce/label/c.Notes_Helptext';
import resubmissionHelptext from '@salesforce/label/c.Resubmission_Helptext';

export default class LWC_SOI_Innovations extends LightningElement {
    @track isPageVisible = true;
    @api country = 'USA';
    @track innovationSamples;
    @track innovationSample;
    @track cutoffDate;
    @track submittedBy;
    @track email;
    @track soldToOptions;
    @track soldTo;
    @track canadaCheck = false;
    @track costCenter;
    @track wbsElement;
    @track notes;
    @track resubmission = false;
    @api stateFilterValues;
    @track innovationSamplesMap = new Map();
    @track innovationSampleId = '';
    @track childCmp;
    @api shipAddressMap = new Map();
    innovationFormLabelsList = {
        innovationSampleLabel, cutoffDateLabel, submittedByLabel, emailLabel, soldToLabel, beamCanadaLabel, costCenterLabel, costCenterHelptext,
        wbsElementLabel, projectInformationLabel, notesLabel, resubmissionLabel, submitLabel, resetLabel, submissionLabel, submitModalMessage, cancelLabel,
        okLabel, warningLabel, incorrectModalMessage, resetModalMessage, errorOccurredLabel, errorModalMessage, successMessage, fieldErrorMessage,
        notesHelptext, resubmissionHelptext
    };

    connectedCallback() {
        this.fetchShipAddressMap();
        this.fetchStateValuesByCountry();
    }

    save() {
        const isParentFieldsValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea')]
                                    .reduce((validSoFar, inputCmp) => {
                                        inputCmp.reportValidity();
                                        return validSoFar && inputCmp.checkValidity();
                                    }, true);
        this.childCmp = this.template.querySelector('c-lwc-soi-innovation-order-table');
        this.childCmp.validateFields();
        const isChildFieldsValid = this.childCmp.isChildFieldsValid;
        if(isParentFieldsValid && isChildFieldsValid) {
            this.openModalForSubmit();
        } else {
            this.openModalForInvalid();
        }
    }

    finalSubmission() {
        this.closeModalForSubmit();
        this.saveRecord();
    }

    saveRecord() {
        let jsonFormString = {
            'innovationSampleId' : this.innovationSampleId,
            'submittedBy' : this.submittedBy,
            'email' : this.email,
            'soldTo' : this.soldTo,
            'costCenter' : this.costCenter,
            'wbsElement' : this.wbsElement,
            'region' : this.childCmp.region,
            'projectList' : JSON.stringify(this.childCmp.updatedProjectList),
            'notes' : this.notes,
            'resubmission' : this.resubmission
        }
        saveInnovationRecords({jsonFormString : JSON.stringify(jsonFormString)})
        .then(result => {
            if(result) {
                this.isPageVisible = false;
            } else {
                this.openModalForError();
            }
        })
        .catch(error => {
            console.log(error);
        })
    }

    clearAll() {
        this.openModalForReset();
    }

    clearAllData() {
        this.closeModalForReset();
        this.innovationSample = null;
        this.cutoffDate = null;
        this.submittedBy = null;
        this.email = null;
        this.canadaCheck = false;
        this.country = 'USA';
        this.costCenter = null;
        this.wbsElement = null;
        this.notes = null;
        this.resubmission = false;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.type === 'checkbox') {
                element.checked = false;
            }
        });
        this.childCmp = this.template.querySelector('c-lwc-soi-innovation-order-table');
        this.childCmp.clearChildData();
    }
    
    openModalForSubmit() {
        this.template.querySelector('.modalSubmitId').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdropSubmitId').classList.add('slds-fade-in-open');        
    }
    
    closeModalForSubmit() {
        this.template.querySelector('.modalSubmitId').classList.remove('slds-fade-in-open');
        this.template.querySelector('.backdropSubmitId').classList.remove('slds-fade-in-open');
    }
    
    openModalForInvalid() {
        this.template.querySelector('.modalIncorrectId').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdropIncorrectId').classList.add('slds-fade-in-open');        
    }
    
    closeModalForInvalid() {
        this.template.querySelector('.modalIncorrectId').classList.remove('slds-fade-in-open');
        this.template.querySelector('.backdropIncorrectId').classList.remove('slds-fade-in-open');
    }

    openModalForReset() {
        this.template.querySelector('.modalFormResetId').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdropFormResetId').classList.add('slds-fade-in-open');
    }

    closeModalForReset() {
        this.template.querySelector('.modalFormResetId').classList.remove('slds-fade-in-open');
        this.template.querySelector('.backdropFormResetId').classList.remove('slds-fade-in-open');
    }

    openModalForError() {
        this.template.querySelector('.modalFormErrorId').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdropFormErrorId').classList.add('slds-fade-in-open');
    }

    closeModalForError() {
        this.template.querySelector('.modalFormErrorId').classList.remove('slds-fade-in-open');
        this.template.querySelector('.backdropFormErrorId').classList.remove('slds-fade-in-open');
    }

    @wire(getInnovationSampleRecords)
    wiredInnovationSampleRecords({data, error}) {
        if(data) {
            let sampleRecords = [];
            for(var index = 0; index < data.length; index++) {
                sampleRecords.push({label : data[index].Name, value : data[index].Name});
                this.innovationSamplesMap.set(data[index].Name, [data[index].End_Date__c, data[index].Id]);
            }
            this.innovationSamples = sampleRecords;
        } else if(error) {
            console.log(error);
        }
    }

    @wire(getSoldToPicklistValues)
    wiredSoldToOptions({data, error}) {
        if(data) {
            let soldToList = [];
            for(var index = 0; index < data.length; index++) {
                soldToList.push({label : data[index][0], value : data[index][1]});
            }
            this.soldToOptions = soldToList;
            if(this.soldToOptions.length > 0) {
                this.soldTo = this.soldToOptions[0].label;
            }
        } else if(error) {
            console.log(error);
        }
    }

    fetchShipAddressMap() {
        getSampleKitShipAddressMap({country : this.country})
        .then(result => {
            for(let state in result) {
                let addressMap = new Map();
                for(let shipPoint in result[state]) {
                    addressMap.set(shipPoint, result[state][shipPoint]);
                }
                this.shipAddressMap.set(state, addressMap);
            }
        })
        .catch(error => {
            console.log(error);
        })
    }

    fetchStateValuesByCountry() {
        filterStatesByCountry({country : this.country})
        .then(result => {
            result.sort();
            var stateList = [];
            for(let index = 0; index < result.length; index++) {
                stateList.push({label : result[index], value : result[index]});
            }
            this.stateFilterValues = stateList;
        })
        .catch(error => {
            console.log(error);
        })
    }

    handleChange(event) {
        let fieldname = event.target.name;
        if(fieldname == 'innovationSample') {
            this.innovationSample = event.target.value;
            this.cutoffDate = this.innovationSamplesMap.get(this.innovationSample)[0];
            this.innovationSampleId = this.innovationSamplesMap.get(this.innovationSample)[1];
        } else if(fieldname == 'submittedBy') {
            this.submittedBy = event.target.value;
        } else if(fieldname == 'email') {
            this.email = event.target.value;
        } else if(fieldname == 'soldTo') {
            this.soldTo = event.target.value;
        } else if(fieldname == 'canadaCheckbox') {
            if(event.target.checked) {
                this.canadaCheck = true;
                this.country = 'Canada';
            } else {
                this.canadaCheck = false;
                this.country = 'USA';
            }
            this.costCenter = null;
            this.wbsElement = null;
            this.fetchShipAddressMap();
            this.fetchStateValuesByCountry();
            this.childCmp = this.template.querySelector('c-lwc-soi-innovation-order-table');
            this.childCmp.resetState();
            this.childCmp.resetTableFields();
        } else if(fieldname == 'costCenter') {
            this.costCenter = event.target.value;
        } else if(fieldname == 'wbsElement') {
            this.wbsElement = event.target.value;
        } else if(fieldname == 'notes') {
            this.notes = event.target.value;
        } else if(fieldname == 'resubmissionCheckbox') {
            this.resubmission = event.target.checked;
        }
    }
}