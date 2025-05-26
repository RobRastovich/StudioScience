import { LightningElement, track, api } from 'lwc';  
const PAGE_SIZE = 5;
 
export default class DhlListView extends LightningElement {
    @api page = 1;  
    @api totalrecords;  
    @api _pagesize = PAGE_SIZE;  
    @track displayCasesList = true;
    @api caseid;
    get pagesize() {  
        return this._pagesize;  
    }  
    set pagesize(value) {  
        this._pagesize = value;  
    }  
    handlePrevious() {  
        if (this.page > 1) {  
        this.page = this.page - 1;  
        }  
    }  
    handleNext() {  
        if (this.page < this.totalPages)  
        this.page = this.page + 1;  
    }  
    handleFirst() {  
        this.page = 1;  
    }  
    handleLast() {  
        this.page = this.totalPages;  
    }  
    handleRecordsLoad(event) {  
        this.totalrecords = event.detail;  
        this.totalPages = Math.ceil(this.totalrecords / this.pagesize);  
    }  
    handlePageChange(event) {  
        this.page = event.detail;  
    }
    handleDetailPage(event) {
        this.displayCasesList = event.detail.displaylist;
        this.caseid = event.detail.caseid;
    }
    handleDetailToListPage(event) {
        this.displayCasesList = event.detail;
    } 
}