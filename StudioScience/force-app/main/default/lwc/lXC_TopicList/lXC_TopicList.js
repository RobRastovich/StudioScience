import { LightningElement, track, wire, api } from 'lwc';
import fetchTopicList from'@salesforce/apex/CNT_TopicList.fetchTopicList';
import insertTopicAssignments from'@salesforce/apex/CNT_TopicList.insertTopicAssignments';
import deleteTopicAssignments from'@salesforce/apex/CNT_TopicList.deleteTopicAssignments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LXC_TopicList extends LightningElement {
    @track page = 1; //initialize 1st page
    @track data = []; //data  displayed in the table
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @api pageSize = 7; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @track selectedRows = [];
    @api recordId;
    @track disableButton = true;
    @track searchKey = '';
    @track mapHoldTopicNameWithAssgId = {};
    @track mapHoldTopicIdWithRecord = {};
    @track isLoaded = false;
    @track wiredTopicsList = [];
    @track isPreviousDisable = false;
    @track isNextDisable = false;
    @track searchingOnList;
    @track accessInsertButton = false;
    @track searchDataPresent = false;
    
    @track isShowModal = false;
    @track showList = false;
    @track showPill = false;
    @track items = []; //contains all the records.
    @track itemsunchanged = [];
    @track selectedItems = []; //contains all topics which are slected on case record.
    @track wiredAccountList = [];
    @track setTopicsName = new Set();
    @track countoftopic;
    topicsColumns = [
        { label: 'Topics Name', fieldName: 'Name', hideDefaultActions: true },
    ];

    @track isShowInsertTopicModal = false;
    @track topicCount = 0;

    @api connectedCallback(){
        const caseId = this.recordId;
        fetchTopicList({caseId: caseId})
        .then((result)=>{
            var data = result;
            this.countoftopic = data[0].innerWrapper.countOfLastTopic;
            if(data.length > 0){
                this.accessInsertButton = data[0].innerWrapper.isUserAccessibleInsertButton;
                const mapNameWIthAssgId = new Map();
                const mapTopicIdWithRecord = new Map();
                var selectedTopicsList = [];
                var itemsList = [];
                var disablePillComp = false;
                for(var i = 0; i < data.length; i++) {
                    this.setTopicsName.add(data[i].topicRecord.Name.toUpperCase());
                    mapTopicIdWithRecord.set(
                        data[i].topicRecord.Id , data[i].topicRecord,
                    )
                    if(!data[i].isSelected){
                        itemsList.push(data[i].topicRecord);
                    }else{
                        disablePillComp = true;
                        mapNameWIthAssgId.set(
                           data[i].topicRecord.Name , data[i].topicAssignmentId,
                        );
                        selectedTopicsList.push({
                            label: data[i].topicRecord.Name,
                            name: data[i].topicRecord.Name,
                            href:"/"+data[i].topicRecord.Id,
                            Id: data[i].topicRecord.Id,
                        });
                    }
                }
                if(selectedTopicsList.length > 0){
                    this.selectedItems = selectedTopicsList;
                }
                if(itemsList.length > 0){
                    this.items = itemsList;
                    this.itemsunchanged = itemsList;
                    this.showList = true;
                }else{
                    this.itemsunchanged = itemsList;
                    this.showList = false;
                }
                if(mapTopicIdWithRecord.size > 0){
                    this.mapHoldTopicIdWithRecord = mapTopicIdWithRecord;
                }
                
                this.mapHoldTopicNameWithAssgId = mapNameWIthAssgId;
                this.totalRecountCount = this.items.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                //here we slice the data according page size
                this.data = this.items.slice(0, this.pageSize);
                this.startingRecord = 1;
                this.page = 1;
                this.endingRecord = (this.totalRecountCount > this.pageSize)
                                    ? this.pageSize : this.totalRecountCount;
                if(this.selectedItems.length > 0){
                    this.showPill = true;
                    if(this.selectedItems.length>5){
                        this.topicCount = 5 + '+';
                    }
                    else {
                        this.topicCount = this.selectedItems.length;
                    }
                }
                if(!disablePillComp){
                    this.showPill = false;
                    this.topicCount = 0;
                }
                this.isLoaded = false;
            }else{
                this.accessInsertButton = data[0].innerWrapper.isUserAccessibleInsertButton;
                this.showList = false;
                this.isLoaded = false;
            }
        })
        .catch((error)=>{
            console.log(error);
        });
    }

    showModalBox() { 
        if(this.items.length == 0){
            this.showList = false;
        }
        this.isShowModal = true;
    }

    hideModalBox() { 
        this.selectedRows = [];
        this.isShowModal = false;
        this.disableButton = true;
        this.handlepagination(this.pageSize, this.itemsunchanged);
        this.showList = true;
        this.isNextDisable = false;
        this.isPreviousDisable = true;
    }

    handlePrevious() {  
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        } 
    }  

    handleNext() {  
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }  
    }  

    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }

    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        let selectedItemsSet = new Set(this.selectedRows);
        let loadedItemsSet = new Set();
        this.data.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                selectedItemsSet.delete(id);
            }
        });
        this.selectedRows = [...selectedItemsSet];
        if(this.selectedRows.length > 0){
            this.disableButton = false;
        }else{
            this.disableButton = true; 
        }
    }

    handleClick(){
        this.isLoaded = true;
        const topicsIds = this.selectedRows;
        const caseId = this.recordId;
        this.showPill = false;
        insertTopicAssignments({ topicsIds: topicsIds,
            caseId: caseId})
            .then((result)=>{
               this.isShowModal = false;
               this.items = [];
               this.connectedCallback();
               this.selectedRows = [];
               this.disableButton = true;
               this.template.querySelector('c-custom-toast').showToast('success', 'The Topic is Assigned Successfully.');
            })
            .catch((error)=>{
                console.log(error);
        });
    }

    handleKeyChange(event){
        this.searchKey = event.target.value;
        searchKeyVar = event.target.value;
        this.data.forEach(function(topic) {
            let searchKeyName = ssearchKeyVar.toLowerCase();
            let topicName = topic.Name.toLowerCase();
            if(topicName.startwith(searchKeyName)){
                this.items.push(topic);
            }
        });
        this.totalRecountCount = this.items.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.data = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
    }

    handleDelete(event){
        const topicname = event.detail[0].Name;
        var topiAssgIdSend = this.mapHoldTopicNameWithAssgId.get(topicname);
        deleteTopicAssignments({topicAssgId: topiAssgIdSend.toString()})
            .then((result)=>{
                this.connectedCallback();
            })
            .catch((error)=>{
                console.log(error);
        });
    }

    handlepagination(pageSize, itemsList){
        this.items = itemsList;
        if(this.searchingOnList){
            this.endingRecord = (this.items.length > this.pageSize)? this.pageSize : this.items.length;
        }else{
            this.endingRecord = (this.totalRecountCount > this.pageSize)
                                    ? this.pageSize : this.totalRecountCount;
        }
        this.startingRecord = 1;
        this.totalRecountCount = this.items.length;
        this.data = this.items.slice(0, this.pageSize);
        this.page = 1;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        const handleNextPreButtons = this.template.querySelector('c-lxc-pagination');
        if(handleNextPreButtons != null){
            handleNextPreButtons.handleNextPrevButtonAccess(this.pageSize, this.totalRecountCount);
        }
    }

    handleSearchComp(event) {
        if( JSON.parse(JSON.stringify(event.detail))[1] > 0) {
            this.searchingOnList = true;
            if(event.detail[0].length > 0){
                this.data = [];
                this.searchDataPresent = true;
                var filterdata = event.detail[0];
                this.showList = true;
                this.handlepagination(this.pageSize, event.detail[0]);
            }else{
                 this.searchDataPresent = false;
                 this.showList = false;
            }
        }
        else {
            this.searchingOnList = false;
            if(this.itemsunchanged.length > 0){
                this.showList = true;
            }else{
                this.showList = false;
            }
            this.handlepagination(this.pageSize, this.itemsunchanged);
        }
        if(this.template.querySelector('[data-id="datatable"]') != null){
            this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
        }
    }

    closeInsetTopicModal(){
        this.isShowInsertTopicModal = false;
    }

    showInsertTopic(event){
        this.isShowInsertTopicModal = true;
    }
    
    handletoast(event){
        this.connectedCallback();
        let topicMessage = JSON.parse(JSON.stringify(event.detail));
        this.template.querySelector('c-custom-toast').showToast(topicMessage.type, topicMessage.message);
    }
}