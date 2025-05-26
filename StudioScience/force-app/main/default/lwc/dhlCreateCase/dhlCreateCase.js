import { LightningElement,track,api } from 'lwc';

export default class DhlCreateCase extends LightningElement {
    @api selectedvalue;
    @api casedata;
    @track displayComboCmp = true;
    @api displayCaseDetail = false;
    @api caseid;
    @api createdcaseid;

    handleNextPage(event) {
        this.selectedvalue = event.detail.selectedvalue;
        this.casedata = event.detail.casedata;
        if (this.selectedvalue != '' && this.selectedvalue != 'undefined' && this.selectedvalue != null) {
            this.displayComboCmp = false;
        } else{
            this.displayComboCmp = true;
        }
    }

    handlePrevPage(event) {
        this.selectedvalue = event.detail.selectedvalue;
        this.displayComboCmp = true;
        this.casedata = event.detail.casedata;
    }

    handleDetailPage(event) {
        this.displayCaseDetail = event.detail.displaycasedetail;
        this.createdcaseid = event.detail.createdcaseid;
    }
    
    handleCreatePage(event) {
        this.displayCaseDetail = event.detail;
    } 
}