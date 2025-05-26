import {LightningElement,wire,track,api} from 'lwc';
import mapTopicAssignments from '@salesforce/apex/TopicReport.mapTopicAssignments';
import CRM_CustomSuccessMessage from '@salesforce/label/c.CRM_CustomSuccessMessage';
import CRM_CustomErrorMessage from '@salesforce/label/c.CRM_CustomErrorMessage';

export default class TopicReport extends LightningElement {
    columnHeader = ['Topic Name','Created By','Created Date', 'Case Number', 'Record Type', 'Brand'];

    @api recordId;
    @track error;

    @track match = [];
    @track parentData = [];
    //sorting
    @track isAsc = false;
    @track isDsc = false;
    @track isTopicNameSort = false;
    @track isCaseOwnerSort = false;
    @track sortedDirection = 'asc';
    @track sortedColumn;

    //filter
    @track today;
    @track endDate = new Date();
    @track startDate = new Date(this.endDate.getFullYear(), this.endDate.getMonth(), 1); 
    @api getShowContainer = false;
    @api getFilterMenu = false;
    @api showRecordType = false;
    @api dateDiffExceeded = false;
    @api inValidDateRange = false;
    selectedRecordType = '';
    isStartDateNull = false;
    isEndDateNull = false;
    @track isFutureEndDate = false;
    @track isFutureStartDate = false;

    @track isLoading = false;
    //====================
    @track isDoneDisable = false;
    @track currentStartDate;
    @track currentEndDate;
    @track showOldStartDate;
    @track showOldEndDate;
    @track showRecordTypeValue;
    consumerinquiriesdata;
    qualityclaimdata;
    recordTypeList = [];
    @track errorMessage = "";
    // @track isDisableApply = false;
    intlDateObj = new Intl.DateTimeFormat('en-US', {
        timeZone: "America/New_York"
    });

    get options() {
        return [
            { label: 'Consumer Inquiry', value: 'Consumer Inquiry' },
            { label: 'Quality Claim', value: 'Quality Claim' },
            { label: 'Consumer Inquiry - Quality Claim', value: 'Consumer Inquiry - Quality Claim'}
        ];
    } 

    //pagination
    @track noRecordFound = false;
    @track isDisabled = false;
    @track pageList;
    @track recordToShowList;
    @track currentPageNumber = 1;
    @track totalPages = 0;
    @track isTotal = false;
    @track pageSize = 10;
    @track allData = [];
    @track pageNumber = 1;
    @track lastSelected = '';

    getFormatedDate(dateObject) {
        let day = dateObject.getDate();
        let month = dateObject.getMonth()+1;
        let year = dateObject.getFullYear();
        return day+"-"+month+"-"+year;
    }

    getFormatedDate2(dateObject) {
        let day = dateObject.getDate();
        let month = dateObject.getMonth()+1;
        let year = dateObject.getFullYear();
        return year+"-"+month+"-"+day;
    }

    getFormatedDate3(dateObject) {
        let day = dateObject.getDate();
        let month = dateObject.getMonth()+1;
        let year = dateObject.getFullYear();
        return year+"-"+month+"-"+day;
    }
     connectedCallback() {
        this.startDate.setHours(0,0,0,0);
        this.endDate.setHours(0,0,0,0);
        this.isLoading = true;
        this.showOldStartDate = this.getFormatedDate2(this.startDate);
        this.showOldEndDate = this.getFormatedDate2(this.endDate);
        this.currentStartDate = this.getFormatedDate2(this.startDate);
        this.currentEndDate = this.getFormatedDate2(this.endDate);
        this.showRecordTypeValue = 'Consumer Inquiry';
        this.selectedRecordType = 'Consumer Inquiry';
        this.recordTypeList = ['Consumer Inquiry'];
        this.today = new Date().toDateString();
        this.getMapTopicAssignments(this.startDate, this.endDate, this.recordTypeList);
        
    }
    
    getMapTopicAssignments(startDate, endDate, recordTypeList) {
        mapTopicAssignments({startDate : this.getFormatedDate3(new Date(startDate)), endDate : this.getFormatedDate3(new Date(endDate)), recordTypeList : recordTypeList})
        .then((result) => {
            if (result) {
                let listOfTopic = [];
                for (let key in result) {
                    let caseOwners = [];
                    let caseDate = [];
                    let caseNumbers = [];
                    let recordType = [];
                    let brandName = [];
                    result[key].forEach(element => {
                        caseOwners.push(element.Owner.Name);
                        var date = new Date(element.CreatedDate);
                        caseDate.push(date.toDateString());
                        caseNumbers.push(element.CaseNumber);
                        recordType.push(element.RecordType.Name);
                        brandName.push(element.Brand__c);
                    });  
                    let elt = {
                        'TopicName' : key,
                        'CaseData' : 
                            {
                                'CaseOwner' : caseOwners,
                                'CreatedDate' : caseDate,
                                'CaseNumber' : caseNumbers,
                                'RecordType' : recordType,
                                'brandName' : brandName
                            },
                    };
                    listOfTopic.push(elt);
                  }
                let sNum = 1;
                listOfTopic.forEach(ele =>{
                    ele["S_No"] = sNum;
                    sNum++;
                })
                this.match = listOfTopic;
                let count = this.match.length;
                if (count == 0) {
                    this.noRecordFound = true;
                }
                else {
                    this.noRecordFound = false;
                }
                this.totalPages = Math.ceil(count / this.pageSize);
                this.currentPageNumber = 1;
                this.firstpage();
                this.buildData();
                this.isLoading = false;
                this.template.querySelector('c-custom-toast').showToast('success', CRM_CustomSuccessMessage);
            }
        })
        .catch(error => {
            this.error = error;
            this.template.querySelector('c-custom-toast').showToast('error', CRM_CustomErrorMessage);
        });
    }

    toggleMenu() {
        this.menuClass = this.menuClass === '' ? 'show' : '';
        this.burgerClass = this.burgerClass === '' ? 'open' : '';
    }

    firstpage() {
        if (this.currentPageNumber === 1) {
            this.isDisabled = true;
            this.firstSelected = 'selected';
        } else {
            this.firstSelected = '';
            this.isDisabled = false;
        }
        if (this.currentPageNumber === this.totalPages) {
            this.isTotal = true;
            this.lastSelected = 'selected';
        } else {
            this.isTotal = false;
            this.lastSelected = '';
        }
        if (this.totalPages === 0) {
            this.isTotal = true;
            this.isDisabled = true;
        }
    }

    buildData() {
        var data = [];
        var pageNumber = this.currentPageNumber;
        var pageSize = this.pageSize;
        var allData = this.match;
        var x = (pageNumber - 1) * pageSize;

        //creating data-table data
        for (; x < (pageNumber) * pageSize; x++) {
            if (allData[x]) {
                data.push(allData[x]);
            }
       }
        this.recordToShowList = [];
        for(let i = 0 ; i < 10 ; i++) {
            if(data[i] !== undefined) {
                this.recordToShowList.push(data[i]);
            }
        }
        this.generatePageList(pageNumber);
        this.lastSelected = '';
        this.selected = '';
        for (let i = 0; i < this.pageList.length; i++) {
            if (this.currentPageNumber === this.pageList[i].num) {
                this.pageList[i].selectedClass = 'selected';
            } else {
                this.pageList[i].selectedClass = '';
        if (this.currentPageNumber === 1) {
            this.selected = 'selected';
        }

        if (this.currentPageNumber === this.totalPages) {
            this.lastSelected = 'selected';
        }
    }
}
    }
    generatePageList(pageNumber) {
        this.pageNumber = pageNumber;
        let pageList = [];
        let totalPages = this.totalPages;
        if (totalPages > 1) {
            if (totalPages <= 10) {
                let counter = 2;
                for (; counter < (totalPages); counter++) {
                    pageList.push(this.pageNumberIntoObj(counter));
                }
            } else {
                if (pageNumber < 5) {
                    pageList.push(this.pageNumberIntoObj(2), this.pageNumberIntoObj(3), this.pageNumberIntoObj(4), this.pageNumberIntoObj(5), this.pageNumberIntoObj(6));
                } else {
                    if (pageNumber > (totalPages - 5)) {
                        pageList.push(
                            this.pageNumberIntoObj(totalPages - 5),
                            this.pageNumberIntoObj(totalPages - 4),
                            this.pageNumberIntoObj(totalPages - 3),
                            this.pageNumberIntoObj(totalPages - 2),
                            this.pageNumberIntoObj(totalPages - 1));
                    } else {
                        pageList.push(
                            this.pageNumberIntoObj(pageNumber - 2),
                            this.pageNumberIntoObj(pageNumber - 1),
                            this.pageNumberIntoObj(pageNumber),
                            this.pageNumberIntoObj(pageNumber + 1),
                            this.pageNumberIntoObj(pageNumber + 2));
                    }
                }
            }
        }
        this.pageList = pageList;
        if (this.pageList.length > 0) {
            this.isListValue = true;
        } else {
            this.isListValue = false;
        }
        if (totalPages > 1) {
            this.showFirst = true;
        } else {
            this.showFirst = false;
        }
        this.isNoRecordFound = (totalPages === 0);
    }
 
    pageNumberIntoObj(num) {
        return {
            num: num,
            selectedClass: ''
        };
    }

    onNext() {
       var pageNumber = this.currentPageNumber;
       this.currentPageNumber = pageNumber + 1;
       this.firstpage();
       this.buildData();
    }

   onPrev() {
       var pageNumber = this.currentPageNumber;
       this.currentPageNumber = pageNumber - 1;
       this.firstpage();
       this.buildData();
   }

   processMe(event) {
       this.currentPageNumber = parseInt(event.target.name);
       this.firstpage();
       this.buildData();
   }
   onFirst() {
       this.currentPageNumber = 1;
       this.firstpage();
       this.buildData();
   }
   onLast() {
       this.currentPageNumber = this.totalPages;
       this.firstpage();
       this.buildData();
   }

    sortTopicName(event) {
        this.isTopicNameSort = true;
        this.isCaseOwnerSort = false;
        this.sortData(event.currentTarget.dataset.field, event.currentTarget.dataset.id);
        this.recordToShowList = this.match;
        let count = this.recordToShowList.length
        this.totalPages = Math.ceil(count / this.pageSize);
        this.currentPageNumber = 1;
        this.firstpage();
        this.buildData();
    }
    reBuildPagination() {
        this.totalPages = Math.ceil(44 / this.pageSize);
        this.currentPageNumber = 1;
        this.firstpage();
        this.buildData();
    }
    sortData(sortColumnName, direction) {
        this.match = JSON.parse(JSON.stringify(this.match)).sort((a, b) => {
            a.TopicName = a.TopicName ? JSON.parse(JSON.stringify(a.TopicName)) : ''; // Handle null values
            b.TopicName = b.TopicName ? JSON.parse(JSON.stringify(b.TopicName)) : '';
            if(direction == 'asc') {
                return a.TopicName.toLowerCase().codePointAt() - b.TopicName.toLowerCase().codePointAt()
            } else {
                return b.TopicName.toLowerCase().codePointAt() - a.TopicName.toLowerCase().codePointAt()
            }
        });;
    }
    // validate the date
    isDateVaidate(startDate, endDate) {
        this.dateDiffExceeded = false;
        this.inValidDateRange = false;
        if(startDate !== '' && endDate !== '') {
            let date1 = new Date(startDate);
            let date2 = new Date(endDate);
            date1.setHours(0,0,0,0);
            date2.setHours(0,0,0,0);
            let sDate = new Date(startDate);
            let eDate = new Date(endDate);
            if(((eDate.getTime() - sDate.getTime())/(1000 * 3600 * 24)+1) > 90) {
                // this.dateDiffExceeded = true;
                this.inValidDateRange = true;
                this.errorMessage = "Date range must be less than or equal to 90 days.";
                this.isDoneDisable = true;
                return false;
            } else if(date2 < date1) {
                // this.dateDiffExceeded = false;
                this.inValidDateRange = true;
                this.isDoneDisable = true;
                this.errorMessage = "Start date must be less than end date."
                return false;
            } 
            const endDateInput  = this.template.querySelector(`[data-id="enddate"]`);
            const startDateInput  = this.template.querySelector(`[data-id="startdate"]`);
            if(endDateInput.reportValidity() === false || startDateInput.reportValidity() === false) {
                this.isDoneDisable = true;
                return false;
            }
            this.isDoneDisable = false;
            this.inValidDateRange = false;
            return true;
        }
    }

    handleChangeAction(event){
        
        if(event.target.name == 'startdate'){
            // console.log('this start ', this.oldStartDate)
            if(!isNaN(event.target.value)) {
                this.isDoneDisable = true;
                this.isStartDateNull = true;
                this.inValidDateRange = true;
                this.errorMessage = "Date input field should not be null."
                return;
            }
            //this.startDate = new Date(event.target.value);
            this.currentStartDate = this.getFormatedDate2(new Date(event.target.value));
            //this.showOldStartDate = this.getFormatedDate(this.startDate);
            this.isStartDateNull = false;
            this.inValidDateRange = false;
        }
        if(event.target.name == 'enddate'){
            if(!isNaN(event.target.value)) {
                this.isDoneDisable = true;
                this.isEndDateNull = true;
                this.inValidDateRange = true;
                this.errorMessage = "Date input field should not be null."
                return;
            }
            //this.endDate = new Date(event.target.value);
            this.currentEndDate = this.getFormatedDate2(new Date(event.target.value));
           // this.showOldEndDate = this.getFormatedDate(this.endDate);
            this.isEndDateNull = false;
            this.inValidDateRange = false;
        }

        if(!this.isStartDateNull && !this.isEndDateNull) {
            this.isDoneDisable = false;
            this.isDateVaidate(this.currentStartDate, this.currentEndDate);
        }
    }
    
    // searchAction() {
        
    //     this.dateDiffExceeded = false;
    //     this.inValidDateRange = false;
    //     let date1 = this.startDate;
    //     let date2 = this.endDate;
    //     date1.setHours(0,0,0,0);
    //     date2.setHours(0,0,0,0);
    //     // this.isFutureStartDate = false;
    //     // this.isFutureEndDate = false;
    //     // if(date2 > new Date() || date1 > new Date()) {
    //     //     if(date1 > new Date()) {
    //     //         this.isFutureStartDate = true;
    //     //     } 
    //     //     if(date2 > new Date()) { 
    //     //         this.isFutureEndDate = true;
    //     //     }
    //     //     if(((this.endDate.getTime() - this.startDate.getTime())/(1000 * 3600 * 24)+1) > 90) {
    //     //         console.log('coming in 90 day validation')
    //     //         this.dateDiffExceeded = true;
    //     //         this.inValidDateRange = false;
    //     //         return;
    //     //     } else if(date2 < date1){
    //     //         console.log('coming in start end date validation')
    //     //         this.dateDiffExceeded = false;
    //     //         this.inValidDateRange = true;
    //     //         return;
    //     //     } else {
    //     //         this.dateDiffExceeded = false;
    //     //         this.inValidDateRange = false;
    //     //     }
    //     //     return;
    //     // }
    //     if(((this.endDate.getTime() - this.startDate.getTime())/(1000 * 3600 * 24)+1) > 90) {
    //         this.dateDiffExceeded = true;
    //         this.inValidDateRange = false;
    //         return;
    //     } else if(date2 < date1){
    //         this.dateDiffExceeded = false;
    //         this.inValidDateRange = true;
    //         return;
    //     } 
    //     const endDateInput  = this.template.querySelector(`[data-id="enddate"]`);
    //     const startDateInput  = this.template.querySelector(`[data-id="startdate"]`);
    //     if(endDateInput.reportValidity() === false || startDateInput.reportValidity() === false){
    //         return;
    //     }
    //     //else {
    //         this.isLoading = true;
    //         this.dateDiffExceeded = false;
    //         this.inValidDateRange = false;
    //         console.log('Orange A '+this.startDate);
    //         this.oldStartDate = this.getFormatedDate2(this.startDate);
    //         console.log('Orange B '+this.startDate);
    //         this.oldEndDate = this.getFormatedDate2(this.endDate);
    //         this.showOldStartDate = this.getFormatedDate(this.startDate);
    //         console.log('Orange C '+this.startDate);
    //         this.showOldEndDate = this.getFormatedDate(this.endDate);
    //         this.getMapTopicAssignments(this.startDate, this.endDate, this.recordTypeList);
    //         console.log('Orange D '+this.startDate);
    //         //this.showRecordTypeValue = this.selectedRecordType;
    //         this.closeAction();
    //         console.log('Orange E '+this.startDate);
    //         this.showFilterMenu();
            

    //     //}
    // }

    searchRecordTypeFilterButton() {
        this.isLoading = true;
        // this.noRecordFound = false
        this.getMapTopicAssignments(this.showOldStartDate, this.showOldEndDate, this.recordTypeList);
        // this.showRecordTypeValue = this.selectedRecordType;
        this.closeAction();
        this.showFilterMenu();
    }

    handleChangeRecordType(event) {
        if(event.detail.value === 'Quality Claim') {
            this.selectedRecordType = 'Quality Claim';
        }
        else if(event.detail.value === 'Consumer Inquiry - Quality Claim') {
            this.selectedRecordType = 'Consumer Inquiry - Quality Claim';
        }
        else {
            this.selectedRecordType = 'Consumer Inquiry';
        }
    }

    
 
    handleClickFilter(event) {
    //   this.isDisableApply = false;
        // this.currentStartDate = this.showOldStartDate;
        // this.currentEndDate = this.showOldEndDate;
        // this.inValidDateRange = false;
        // this.isDoneDisable = false;
        this.getShowContainer = true;
        this.showRecordType = false;
    }

    handleRecordType(event) {
        this.currentStartDate = this.showOldStartDate;
        this.currentEndDate = this.showOldEndDate;
        this.inValidDateRange = false;
        this.isDoneDisable = false;
        this.showRecordType = true;
        this.getShowContainer = false;
    }

    closeAction(){
        //this.isFutureEndDate = false;
        //this.isFutureStartDate = false;
        // this.template.querySelector(".pop").style="display:none"
        this.getShowContainer = false;
        this.showRecordType = false;
        // this.dateDiffExceeded = false
        this.inValidDateRange = false
        this.currentStartDate = this.showOldStartDate;
        this.currentEndDate = this.showOldEndDate;
        this.isDoneDisable = false;
        // this.startDate = new Date(this.currentStartDate);
        // this.endDate = new Date(this.currentEndDate);
        // this.isDisableApply = false;
        //this.endDate = new Date(); 
        //this.startDate = new Date(this.endDate.getFullYear(), this.endDate.getMonth(), 1);
        // if(this.dateDiffExceeded === true){
        //     this.endDate = new Date(); 
        //     this.startDate = new Date(this.endDate.getFullYear(), this.endDate.getMonth(), 1);
        //     this.dateDiffExceeded = false;
        // }
        // if(this.inValidDateRange === true){
        //     this.endDate = new Date(); 
        //     this.startDate = new Date(this.endDate.getFullYear(), this.endDate.getMonth(), 1);
        //     this.inValidDateRange = false;
        // }
    }

    showFilterMenu(event) {
        
        this.isDoneDisable = false;
        // this.getFilterMenu = true;
        this.currentStartDate = this.showOldStartDate;
        this.currentEndDate = this.showOldEndDate;
        this.inValidDateRange = false;
        if(this.getFilterMenu === true) {
            this.getFilterMenu = false;
        }
        else {
            this.getFilterMenu = true;
        }
        // if(this.dateDiffExceeded === true) {
        //     this.endDate = new Date(); 
        //     this.startDate = new Date(this.endDate.getFullYear(), this.endDate.getMonth(), 1);
        //     this.dateDiffExceeded = false;
        // }
        // if(this.inValidDateRange === true) {
        //     this.endDate = new Date(); 
        //     this.startDate = new Date(this.endDate.getFullYear(), this.endDate.getMonth(), 1);
        //     this.inValidDateRange = false;
        // }
        // if(this.getFilterMenu === true) {
        //     this.getFilterMenu = false;
        //     this.template.querySelector(".filter-icon").style="background-color:white; --sds-c-icon-color-foreground-default: rgb(54, 51, 50)";
        // }
        // else{
        //     this.getFilterMenu = true;
        //     this.template.querySelector(".filter-icon").style="background-color:rgb(3, 123, 252); --sds-c-icon-color-foreground-default: white";
        // }
    }

    doneMethodForFilter(event) {
        if(event.target.name === 'datefilter') {
            console.log("this.startDate", this.currentStartDate);
            console.log("this.endDate", this.currentEndDate);
            // let startDate = 
            if(this.isDateVaidate(this.currentStartDate, this.currentEndDate)) {
                this.showOldStartDate = this.currentStartDate;
                this.showOldEndDate = this.currentEndDate;
                this.closeAction();
            }
        }
        if(event.target.name === 'recordtypefilter') {
            if(this.selectedRecordType === 'Quality Claim') {
                this.recordTypeList = ['Quality Claim'];
            }
            else if(this.selectedRecordType === 'Consumer Inquiry - Quality Claim') {
                this.recordTypeList = ['Consumer Inquiry','Quality Claim'];
            }
            else if(this.selectedRecordType === 'Consumer Inquiry') {
                this.recordTypeList = ['Consumer Inquiry'];
            }
            if(this.selectedRecordType !== "") {
                this.showRecordTypeValue = this.selectedRecordType;
            }
            this.closeAction(); 
        }
    }

    exportContactData(){
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td{';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<thead>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</thead>';
        // Add the data rows
        this.match.forEach(record => {
            for(let key in record.CaseData.CaseOwner){
                doc += '<tr>';
                doc += '<td>'+record.TopicName+'</td>';
                doc += '<td>'+record.CaseData.CaseOwner[key]+'</td>';
                doc += '<td>'+record.CaseData.CreatedDate[key]+'</td>';
                doc += '<td>'+record.CaseData.CaseNumber[key]+'</td>';
                doc += '<td>'+record.CaseData.RecordType[key]+'</td>';
                doc += '<td>'+record.CaseData.brandName[key]+'</td>';
                doc += '</tr>'
            }
            doc += '</tbody>';
            });
            
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'Tagging Report.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}