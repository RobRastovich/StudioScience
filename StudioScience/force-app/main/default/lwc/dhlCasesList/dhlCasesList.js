import { LightningElement, track, api, wire } from 'lwc';
import getCasesList from '@salesforce/apex/CNT_DTC_DHLCases.getCasesList';  
import getCasesCount from '@salesforce/apex/CNT_DTC_DHLCases.getCasesCount'; 
 
export default class DhlCasesList extends LightningElement {
    @track cases;  
    @track error;  
    @api currentpage;  
    @api pagesize;  
    @track searchKey;
    @track isLoaded = false;  
    totalpages;  
    localCurrentPage = null;  
    isSearchChangeExecuted = false;  
    value = 'Assigned to me';
    addtionalInformation;
    isSortCaseNumber = true;
    isSortName = true;
    isSortType = true;
    isSortStatus = true;
    isSortCreatedOn = true;
    @track sortOrder = 'desc';
    sortedColumn;
    @api customClass = 'fontBgTheme';  
    @api customClass1 = 'slds-truncate customFontWhite';
    @api customClass3 = 'slds-m-bottom_small';
    @api handleNavigation;
    @api customClass2 = ''; 
    @api customClassName = 'fontBgTheme';
    @api customClass_Name = 'slds-truncate customFontWhite'; 
    @api customClassStatus = 'fontBgTheme';
    @api customClass_Status = 'slds-truncate customFontWhite';
    @api customClassType = 'fontBgTheme';
    @api customClass_Type = 'slds-truncate customFontWhite';
    @api customClassCreatedOn = 'fontBgTheme';
    @api customClass_CreatedOn = 'slds-truncate customFontWhite';
    @track recordId='';
    caseId;

    get options() {
        return [
            { label: 'DHL Portal', value: 'DHL Portal' },
            { label: 'Assigned to me', value: 'Assigned to me' },
            { label: 'Closed Cases', value: 'Closed'},
        ];
    }

    handleChange(event) {
        this.isLoaded = false;
        this.value = event.detail.value;
        if (this.addtionalInformation !== this.value) {  
            this.isSearchChangeExecuted = false;  
            this.addtionalInformation = event.target.value;  
            this.currentpage = 1;  
            this.isLoaded = true;
        }  
    }

    pageSizeOptions =  
    [  
        { label: '5', value: 5 },  
        { label: '10', value: 10 },  
        { label: '25', value: 25 },  
        { label: '50', value: 50 },  
        { label: 'All', value: '' },  
    ];

    sort(e){
        if(this.sortedColumn === e.currentTarget.dataset.id){
            this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
        }else{
            this.sortOrder = 'asc';
        }        
        var reverse = this.sortOrder === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.cases));
        table.sort((a,b) => {return a[e.currentTarget.dataset.id] > b[e.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
        this.sortedColumn = e.currentTarget.dataset.id;        
        this.cases = table; 
    }

    sortCaseNumber(e){
        this.isSortCaseNumber = !this.isSortCaseNumber;
        this.sort(e);
    }

    sortName(e){
        this.isSortName = !this.isSortName;
        this.sort(e);
    }

    sortType(e){
        this.isSortType = !this.isSortType;
        this.sort(e);
    }

    sortStatus(e){
        this.isSortStatus = !this.isSortStatus;
        this.sort(e);
    }

    sortCreatedOn(e){
        this.isSortCreatedOn = !this.isSortCreatedOn;
        this.sort(e);
    }

    handleKeyChange(event) {
        this.isLoaded = false;
        if (this.searchKey !== event.target.value) {  
            this.isSearchChangeExecuted = false;  
            this.searchKey = event.target.value;  
            this.currentpage = 1;  
            this.isLoaded = true;
        }
        this.dispatchEvent(new CustomEvent('currentpagechange', {  
            detail: this.currentpage  
        }));  
    }
    
    getQueryParameters() {
        let urlString = (window.location != window.parent.location) ? document.referrer : document.location.href;
        let url = new URL(urlString);
        let recordId = url.searchParams.get("Id");
        if (recordId !== undefined && recordId !== null) {
            this.caseId = recordId;
        }
    }

    renderedCallback() { 
        this.isLoaded = true; 
        this.getQueryParameters();
        if (this.caseId !== undefined && this.caseId !== null ) {
            const redirectToDetailPage = new CustomEvent("detailpage", {
                detail: {displaylist: false, caseid : this.caseId}
            });
            this.dispatchEvent(redirectToDetailPage);
        }
        // This line added to avoid duplicate/multiple executions of this code.  
        if (this.isSearchChangeExecuted && (this.localCurrentPage === this.currentpage)) {  
            return;  
        }  
        this.isSearchChangeExecuted = true;  
        this.localCurrentPage = this.currentpage;  
        getCasesCount({ searchString: this.searchKey, addInfo : this.addtionalInformation })  
        .then(recordsCount => {  
            this.totalrecords = recordsCount;  
            if (recordsCount !== 0 && !isNaN(recordsCount)) {  
                this.totalpages = Math.ceil(recordsCount / this.pagesize);  
                getCasesList({ pagenumber: this.currentpage, numberOfRecords: recordsCount, pageSize: this.pagesize, searchString: this.searchKey, addInfo : this.addtionalInformation, sortOrder : this.sortOrder })  
                .then(caseList => {  
                    this.cases = caseList;
                    this.error = undefined; 
                    this.isLoaded = true;  
                })  
                .catch(error => {  
                    this.error = error;  
                    this.Cases = undefined;
                    this.isLoaded = false;  
                });  
            } else {  
                this.cases = [];  
                this.totalpages = 1;  
                this.totalrecords = 0; 
                this.isLoaded = true;  
            }  
            const event = new CustomEvent('recordsload', {  
                detail: recordsCount  
            });  
            this.dispatchEvent(event);  
        })  
        .catch(error => {  
        this.error = error;  
        this.totalrecords = undefined;  
        });  
    }

    mouseOver (evt) {
        this.customClass = 'customClass';
        this.customClass1 = 'slds-truncate customFontRed';
    }

    mouseOut (evt) {
        this.customClass = 'fontBgTheme';
        this.customClass1 = 'slds-truncate customFontWhite';
    }

    mouseOverName (evt) {
        this.customClassName = 'customClass';
        this.customClass_Name = 'slds-truncate customFontRed';
    }

    mouseOutName (evt) {
        this.customClassName = 'fontBgTheme';
        this.customClass_Name = 'slds-truncate customFontWhite';
    }

    mouseOverType (evt) {
        this.customClassType = 'customClass';
        this.customClass_Type = 'slds-truncate customFontRed';
    }

    mouseOutType (evt) {
        this.customClassType = 'fontBgTheme';
        this.customClass_Type = 'slds-truncate customFontWhite';
    }

    mouseOverStatus (evt) {
        this.customClassStatus = 'customClass';
        this.customClass_Status = 'slds-truncate customFontRed';
    }

    mouseOutStatus (evt) {
        this.customClassStatus = 'fontBgTheme';
        this.customClass_Status = 'slds-truncate customFontWhite';
    }

    mouseOverCreatedOn (evt) {
        this.customClassCreatedOn = 'customClass';
        this.customClass_CreatedOn = 'slds-truncate customFontRed';
    }

    mouseOutCreatedOn (evt) {
        this.customClassCreatedOn = 'fontBgTheme';
        this.customClass_CreatedOn = 'slds-truncate customFontWhite';
    }

    handleNavigate(event) {
        var rowId = event.target.id;
        if (rowId.length > 18) {
            rowId = rowId.substring(0,18);
        }
        const redirectToDetailPage = new CustomEvent("detailpage", {
            detail: {displaylist: false, caseid : rowId}
        });
        this.dispatchEvent(redirectToDetailPage);
    }

    mouseOverAnchr(evt) {
        var val = evt.target.id;
        var elem = this.template.querySelector('[id="'+val+'"]');
        if (elem) {
            elem.style='color: #CC0000 !important; font-weight: bold;';
        }
    }

    mouseOutAnchr(evt) {
        var val = evt.target.id;
        var elem = this.template.querySelector('[id="'+val+'"]');
        if (elem) {
            elem.style='';
        }
    }
}