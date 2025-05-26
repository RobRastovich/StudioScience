import { api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LightningModal from 'lightning/modal';
import createDesignFileRecords from '@salesforce/apex/INT_EmailDeliveryController.createDesignFileRecords';
import getBaseUrl from '@salesforce/apex/INT_EmailDeliveryController.getBaseUrl';

const mimeTypeIconMap = {
    'application/pdf': 'doctype:pdf',
    'image/png': 'doctype:image',
    'image/jpeg': 'doctype:image',
    'text/plain': 'doctype:txt',
    'application/msword': 'doctype:word',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'doctype:word',
    'application/vnd.ms-excel': 'doctype:excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'doctype:excel',
    'application/vnd.ms-powerpoint': 'doctype:ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'doctype:ppt',
    // Add more mappings as needed
};

export default class IntFileUploadWizard extends NavigationMixin(LightningModal) {
    @api recordId;
    @api action;
    uploadedFilesInfo = [];
    showLinkDetails = true;
    showFileDetails = false;
    isAddLinkDisabled = true;
    isFileUploadDisabled = true;
    isSaveDisabled = true;
    uploadedLinksInfo = [];
    mapFileCategory = new Map();
    selectedCategory;
    selectedURL;
    baseUrl;
    showCancelButton = false;
    showSkipButton = false;

    handleLoad() {
        if (this.action == 'Edit') {
            this.showCancelButton = true;
        }
        else {
            this.showSkipButton = true;
        }
        this.template.querySelector('button[name="AddLink"]').classList.add('slds-button_brand');
        this.template.querySelector('button[name="AddFiles"]').classList.add('slds-button_neutral');

        this.fetchBaseUrl();
        this.stopLoading();
    }

    startLoading() {
        this.refs.spinner.classList.remove('slds-hide');
        this.refs.body.classList.add('slds-hide');
    }

    stopLoading() {
        this.checkForm();
        this.refs.spinner.classList.add('slds-hide');
        this.refs.body.classList.remove('slds-hide');
    }

    handleButtonClick(event) {
        switch(event.target?.name) {
            case 'AddLink':
                this.showLinkDetails = true;
                this.showFileDetails = false;
                this.template.querySelector('button[name="AddLink"]').classList.remove('slds-button_neutral');
                this.template.querySelector('button[name="AddFiles"]').classList.remove('slds-button_brand');
                this.template.querySelector('button[name="AddLink"]').classList.add('slds-button_brand');
                this.template.querySelector('button[name="AddFiles"]').classList.add('slds-button_neutral');
                this.checkForm();
                break;
            case 'AddFiles':
                this.showFileDetails = true;
                this.showLinkDetails = false;
                this.template.querySelector('button[name="AddLink"]').classList.remove('slds-button_brand');
                this.template.querySelector('button[name="AddFiles"]').classList.remove('slds-button_neutral');
                this.template.querySelector('button[name="AddLink"]').classList.add('slds-button_neutral');
                this.template.querySelector('button[name="AddFiles"]').classList.add('slds-button_brand');
                this.checkForm();
                break;

            default:
                break;    
        }

        switch(event.target?.dataset?.action) {
            case 'Save':
                this.handleSave();
                break; 
            case 'Skip':
                this.close('success');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                    }
                });
                break; 
            case 'Cancel':
                this.close('success');
                break; 

            default:
                break;    
        }
    }  

    handleChange(event) {
        switch (event.target?.fieldName) {
            case 'INT_Category__c':
                this.selectedCategory = event.target.value;
                this.checkForm();
                break;

            case 'INT_Hyperlink__c':
                this.selectedURL = event.target.value;
                this.checkForm();
                break;

            default:
                break;
        }
    }

    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;
        let documentIds = uploadedFiles.map(file => file.documentId);
        let filesInfo = uploadedFiles.map(file => ({
            documentId: file.documentId,
            title: file.name,
            downloadUrl: this.baseUrl + '/sfc/servlet.shepherd/document/download/'+file.documentId,
            icon: mimeTypeIconMap[file.mimeType] || 'doctype:unknown',
            category : this.selectedCategory
        }));

        if (this.mapFileCategory && this.mapFileCategory.get(this.selectedCategory)) {
            let existingDocumentIds = this.mapFileCategory.get(this.selectedCategory);
            this.mapFileCategory.set(this.selectedCategory, [...existingDocumentIds , ...documentIds]);
        }
        else {
            this.mapFileCategory.set(this.selectedCategory, documentIds);
        }
        
        this.uploadedFilesInfo = [...this.uploadedFilesInfo, ...filesInfo];
        this.selectedCategory = '';
        this.checkForm();
    }

    handleSave() {
        this.startLoading();

        let designFileRecords = [];
        this.mapFileCategory.forEach((value, key) => {
            let designFileRecord = {
                    INT_Type__c: 'Binary',
                    INT_EmailDelivery__c: this.recordId,
                    INT_Category__c: key
            };
            designFileRecords.push(designFileRecord);
        })
            
        if (this.uploadedLinksInfo.length > 0) {
            this.uploadedLinksInfo.forEach((recordLink) => {
                designFileRecords.push(recordLink.fields);
            });
        }

        const mapFileCategory = Object.fromEntries(this.mapFileCategory);
        createDesignFileRecords({
            designFileRecords : designFileRecords,
            mapFileCategoryJson : JSON.stringify(mapFileCategory)
        })
        .then(() => {
            this.close('success');

            if (this.action && this.action == 'Edit') {
                let url = this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                      recordId: this.recordId,
                      actionName: 'view'
                    }
                  });
              
                window.location.replace(url);
            }
            else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                    }
                });
            }
            console.log('Design File records created successfully.');
        })
        .catch(error => {
            console.log('Error creating design file records.', error);
        }); 
    }

    handleSuccess(event) {
        this.stopLoading();
    }

    handleAddLinks() {
        if (this.selectedCategory && this.selectedURL) {
            let linkInfo = {
                id: this.uploadedLinksInfo.length,
                apiName: 'INT_DesignFiles__c',
                fields: {
                    INT_Type__c: 'Link',
                    INT_EmailDelivery__c: this.recordId,
                    INT_Category__c: this.selectedCategory,
                    INT_Hyperlink__c: this.selectedURL
                }
            };
            this.uploadedLinksInfo = [...this.uploadedLinksInfo, linkInfo];
            this.selectedCategory = '';
            this.selectedURL = '';
            this.checkForm();
        }
    }

    handleDeleteLink(event) {
        const deletedLinkId = event.target.dataset.id;
        this.uploadedLinksInfo = this.uploadedLinksInfo.filter(link => link.id != deletedLinkId);
        this.checkForm();
    }

    handleDeleteFile(event) {
        const deletedDocumentId = event.target.dataset.id;
        let deletedFileCategory = this.uploadedFilesInfo.filter(file => file.documentId == deletedDocumentId)[0].category;

        let updatedContentDocIds = this.mapFileCategory.get(deletedFileCategory).filter(id => id != deletedDocumentId);
        if (updatedContentDocIds.length > 0) {
            this.mapFileCategory.set(deletedFileCategory, updatedContentDocIds);
        }
        else {
            this.mapFileCategory.delete(deletedFileCategory);
        }

        this.uploadedFilesInfo = this.uploadedFilesInfo.filter(file => file.documentId != deletedDocumentId);
        this.checkForm();
    }

    checkForm() {
        this.isAddLinkDisabled = !this.selectedCategory || !this.selectedURL;
        this.isFileUploadDisabled = !this.selectedCategory;
        this.isSaveDisabled = this.uploadedLinksInfo.length == 0 && this.mapFileCategory.size == 0;
    }

    fetchBaseUrl(){
        getBaseUrl()
        .then((result) => {
            this.baseUrl = result;
        })
        .catch(error => {
            console.log('Error fetching url.', error);
        }); 
    }

}