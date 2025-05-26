import { LightningElement, track, api, wire } from 'lwc';
import getPickListValues from '@salesforce/apex/CNT_ContactUs.getPickListValuesForLwc';
import createCase from '@salesforce/apex/CNT_ContactUs.createCase' 	
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import {
    DSC_button_Back, DSC_button_Save_amp_Next, DSC_button_Submit, Whisky_Drop_Membership_Program,
    Barreled_Boxed_Membership_Program, Shipping_Delivery_Questions, DSC_Attachment, 
    DSC_Can_you_attach_a_picture, File_Format, Error_Review, Error_Message, Success_Message, Limited_Online_Releases
} from './label'
 import staticResource from '@salesforce/resourceUrl/CRM_GlobalCSS';
export default class LXC_lwc_ContactUs extends LightningElement {
    @api myRecordId;
    brand = "";
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.brand = currentPageReference.state.brand;
    }
    brandData;
    @track newCase = {};
    @track newAccount = {};
    @track DSC_button_Back;
    @track DSC_button_Save_amp_Next;
    @track DSC_button_Submit;
    @track Whisky_Drop_Membership_Program;
    @track Barreled_Boxed_Membership_Program;
    @track Shipping_Delivery_Questions;
    @track DSC_Attachment;
    @track DSC_Can_you_attach_a_picture;
    @track File_Format;
    @track Error_Review;
    @track Error_Message;
    @track Success_Message;
    @track howCanWeHelpYou = "";
    @track howCanIHelpYouOption = [];
    @track additionalInfoOption = [];
    @track countories = [];
    @track productList;
    @track issues = [];
    @track dagmageIssues = [];
    @track productSizeOption = [];
    @track doYouStillHaveProduct = []
    @track currentStep = "1";
    @track submitButtonLabel = "Submit"; 
    @track pageIndex = 0;
    @track productPackagingIssue;
    @track isProductVisibleObj;
    @track ishowSelectAnOption = false;
    @track ishowPersonalInfo = false;
    @track ishowAddress = false;
    @track ishowProductInfo = false;
    @track ishowMoreDetails = false;
    @track ishowProgrssIndicator = false;
    @track ishowbackButton = false;
    @track isbackButtonDisable = true;
    @track ishowProductInMore = false;
    @track ishowTelNum = false;
    @track ishowCountry = true;
    @track ishowDamageIssue = false;
    @track ishowAttachment = false;
    @track ishowPrivacyAndRecaptcha=false;
    @track ishowToast = false;
    @track ishowSubmit = false;
    @track documentId = [];
    @track recaptchaResponse = "";
    @track isloaded = false;
    @track brandLotcode;
    @track uploadedDocuments = [];
    @track ishowLastMessage = false;
    @track isComplaint = false;
    @track isCheckedPrivacyPolicy = false;
    @track ishowLotcodeInProduct = false;
    @track isFileSelected = false;
    @track lastMessage;
    @track lastMessageType;
    @track confirmEmail;
    //@track deleteDocumentId = [];
    async connectedCallback() {
        loadStyle(this, staticResource + '/global.css');
        this.newCase = {
            'sobjectType':'Case',                                                     
            'Brand__c' : '', 
            'Origin': 'Web',
            'AdditionalInformation__c': '',
            'How_can_we_help__c' : '',
            'Product_Type__c' : '',
            'Product_Size__c' : '',
            'Issue__c' : '',
            'Lot_Code__c' : '',
            'Description' : '',
            'Do_you_still_have_the_product__c' : '',
            'Contact_Us_Page_Privacy_Consent__c' : '',
            'Damage_Issue__c':''
        }
        this.newAccount = {
            'sobjectType':'Account',
            'FirstName' : '',
            'LastName' : '',
            'PersonEmail' : '',
            'PersonMailingCity': '',
            'PersonMailingState' : '',
            'PersonMailingCountry' : '',
            'PersonMailingPostalCode' : '',
            'PersonMailingStreet' : '',
            'Address2' : '',
            'Phone': ''
        }
        this.DSC_button_Back = DSC_button_Back;
        this.DSC_button_Save_amp_Next = DSC_button_Save_amp_Next;
        this.DSC_button_Submit = DSC_button_Submit;
        this.Whisky_Drop_Membership_Program = Whisky_Drop_Membership_Program;
        this.Barreled_Boxed_Membership_Program = Barreled_Boxed_Membership_Program;
        this.Shipping_Delivery_Questions = Shipping_Delivery_Questions;
        this.DSC_Attachment = DSC_Attachment;
        this.DSC_Can_you_attach_a_picture = DSC_Can_you_attach_a_picture;
        this.File_Format = File_Format;
        this.Error_Review = Error_Review;
        this.Error_Message = Error_Message;
        this.Success_Message = Success_Message;
        this.newCase.Brand__c = this.brand;
        if(this.brand.length>0){
            await getPickListValues({brand:this.brand})
            .then((result)=>{
                this.brandData = result;
            })
            .catch((error)=>{
                console.log(error);
                // this.template.querySelector('c-custom-toast').showToast('error', "This brand does not present");
                return;
            }); 
            this.howCanIHelpYouOption = this.brandData.hasOwnProperty('BrandCategoryHelpMapping__c') ? this.brandData['BrandCategoryHelpMapping__c'][0] : [];
            this.countories = this.brandData.hasOwnProperty('Country_of_Interest__c') ? this.brandData['Country_of_Interest__c'] : [];
            this.productList = this.brandData.hasOwnProperty(this.brand) ? this.brandData[this.brand] : [];
            this.dagmageIssues = this.brandData.hasOwnProperty('Damage_Issue__c') ? this.brandData['Damage_Issue__c'] : [];
            this.issues = this.brandData.hasOwnProperty('Issue__c') ? this.brandData['Issue__c'] : [];
            this.productSizeOption = this.brandData.hasOwnProperty('Product_Size__c') ? this.brandData['Product_Size__c'] : [];
            this.doYouStillHaveProduct = this.brandData.hasOwnProperty('Do_you_still_have_the_product__c') ? this.brandData['Do_you_still_have_the_product__c'] : [];
            this.productPackagingIssue = this.brandData.hasOwnProperty('productPackagingIssue') ? this.brandData['productPackagingIssue'] : "";
            this.isProductVisibleObj = this.brandData.hasOwnProperty('isProductVisible') ? this.brandData['isProductVisible'] : {};
            this.brandLotcode = this.brandData['lotCodeResource']? this.brandData['lotCodeResource'] : [];
        }
        
        if(this.brandData) {
            this.ishowSelectAnOption = true;
            this.ishowPersonalInfo = true;
            this.ishowMoreDetails = true;
            this.ishowAttachment = true;
            this.ishowPrivacyAndRecaptcha = true;
            this.ishowSubmit = true;
        }  
    }

    handleSelectedOption(event) {
        this.howCanWeHelpYou = event.detail;
        this.newCase['How_can_we_help__c'] = event.detail;
        this.newCase['AdditionalInformation__c'] = "";
        let ishowAdditionalInfo = true;
        this.ishowDamageIssue = false;
        if(this.howCanWeHelpYou.toLowerCase() === this.productPackagingIssue.toLowerCase()) {
            this.pageIndex = 1;
            this.submitButtonLabel = DSC_button_Save_amp_Next;
            this.ishowMoreDetails = false;
            this.ishowAddress = true;
            this.ishowProgrssIndicator = true;
            this.ishowTelNum = true;
            this.ishowCountry = false;
            this.ishowAttachment = false;
            this.ishowPrivacyAndRecaptcha = false;
            ishowAdditionalInfo = false;
            this.isComplaint = true;
        }
        else {
            this.ishowAddress = false;
            this.submitButtonLabel = DSC_button_Submit;
            this.ishowbackButton = false;
            this.ishowProgrssIndicator = false;
            this.ishowProductInfo = false;
            this.ishowMoreDetails = true;
            this.ishowTelNum = false;
            this.ishowCountry = true;
            this.ishowAttachment = true;
            this.ishowPrivacyAndRecaptcha = true;
            this.pageIndex = 0;
            this.isComplaint = false;
        }
        if(this.isProductVisibleObj.hasOwnProperty(this.howCanWeHelpYou) && ishowAdditionalInfo) {
            this.ishowProductInMore = this.isProductVisibleObj[this.howCanWeHelpYou];
        }
        else {
            this.ishowProductInMore = false;
        }    
        
    }
    handleAdditionalInfo(event){
        const additionalInformation = event.detail;
        this.newCase['AdditionalInformation__c'] = event.detail;
        if(this.howCanWeHelpYou != undefined && ((this.howCanWeHelpYou === Whisky_Drop_Membership_Program)
            || (this.howCanWeHelpYou === Barreled_Boxed_Membership_Program) 
            || (this.howCanWeHelpYou === Limited_Online_Releases))) {
                if(additionalInformation === Shipping_Delivery_Questions) {
                    this.ishowDamageIssue = true;
                }
                else {
                    this.ishowDamageIssue = false;
                }
        }
        else {
            this.ishowDamageIssue = false;
        }
        if(this.isProductVisibleObj.hasOwnProperty(this.howCanWeHelpYou+" - "+additionalInformation)) {
            this.ishowProductInMore = this.isProductVisibleObj[this.howCanWeHelpYou+" - "+additionalInformation];
        }
        else {
            this.ishowProductInMore = false;
        }
    }

    handleSubmit(event) {
        if(event.target.label === DSC_button_Save_amp_Next) {
            if(this.validateForm(this.pageIndex)) {
                if(this.pageIndex < 3){
                    this.pageIndex += 1;
                    this.currentStep = "" + this.pageIndex;
                    this.isbackButtonDisable = false;
                    if(this.pageIndex === 2) {
                        this.showPage(2);
                    }
                }
            }
            else {
                this.template.querySelector('c-custom-toast').showToast('error', this.Error_Review);
                return;
            }
        }
        else if(event.target.label === DSC_button_Submit) {
            if(this.validateForm(this.pageIndex)) {
                this.isloaded = true;
                this.handleCreateCase();
            }
            else {
                this.template.querySelector('c-custom-toast').showToast('error', this.Error_Review);
                return;
            }
        }
        
    }

    handlebackButton(event) {
        if(this.pageIndex>1) {
            this.pageIndex--;
            this.currentStep = "" + this.pageIndex;    
        }
        if(this.pageIndex === 1) {
            this.showPage(1);
        }
    }
    showPage(pageIndex) {
        if(pageIndex === 1) {
            this.ishowSelectAnOption = true;
            this.ishowPersonalInfo = true;
            this.ishowAddress = true;
            this.ishowProductInfo = false;
            this.ishowMoreDetails = false;
            this.ishowbackButton = false;
            this.ishowAttachment = false;
            this.ishowPrivacyAndRecaptcha = false;
            this.submitButtonLabel = DSC_button_Save_amp_Next;
        }
        else if(pageIndex === 2) {
            this.ishowbackButton = true;
            this.ishowSelectAnOption = false;
            this.ishowPersonalInfo = false;
            this.ishowAddress = false;
            this.ishowProductInfo = true;
            this.ishowMoreDetails = true;
            this.ishowPrivacyAndRecaptcha = true;
            this.ishowAttachment = true;
            this.submitButtonLabel = DSC_button_Submit;
            this.isbackButtonDisable = false;
            this.ishowbackButton = true;
        }
        return true;
    }
    validateForm(currentPage) {
        let isFormValid = true;
        if(currentPage===0) {
            const validateHowCanIHelp = this.template.querySelector('c-l-X-C-_how-Can-I-Help-You-Option-Contact-Us').validate();
            if(!validateHowCanIHelp) {
                isFormValid = false;
            }
            const validatePersonalInfo = this.template.querySelector('c-l-X-C-_personal-Info-Of-Contact-Us').validate();
            if(!validatePersonalInfo) {
                isFormValid = false;
            }
            const validateMoreDetatils = this.template.querySelector('c-l-W-C-_more-Details-Of-Contact-Us').validate();
            if(!validateMoreDetatils) {
                isFormValid = false;
            }
            const validatePrivacyAndRecaptcha = this.template.querySelector('c-l-X-C-_privacy-Policy-And-Recaptcha').validate();
            if(!validatePrivacyAndRecaptcha) {
                isFormValid = false;
            }
        }
        else if(currentPage === 1) {
            const validateHowCanIHelp = this.template.querySelector('c-l-X-C-_how-Can-I-Help-You-Option-Contact-Us').validate();
            if(!validateHowCanIHelp) {
                isFormValid = false;
            }
            const validatePersonalInfo = this.template.querySelector('c-l-X-C-_personal-Info-Of-Contact-Us').validate();
            if(!validatePersonalInfo) {
                isFormValid = false;
            }
            const validateAddress = this.template.querySelector('c-l-X-C-_address-Of-Contact-Us').validate();
            if(!validateAddress) {
                isFormValid = false;
            }
        }
        else if(currentPage === 2) {
            const validateProductInfo = this.template.querySelector('c-l-X-C-_product-Info-Of-Contact-Us').validate();
            if(!validateProductInfo) {
                isFormValid = false;
            }
            const validateMoreDetatils = this.template.querySelector('c-l-W-C-_more-Details-Of-Contact-Us').validate();
            if(!validateMoreDetatils) {
                isFormValid = false;
            }
            const validatePrivacyAndRecaptcha = this.template.querySelector('c-l-X-C-_privacy-Policy-And-Recaptcha').validate();
            if(!validatePrivacyAndRecaptcha) {
                isFormValid = false;
            }
        }
        return isFormValid;
    }

    handleIshowLotCode(event) {
        this.ishowLotcodeInProduct = event.detail;
    }

    handlePersonalInfo(event) {
        try{
            Object.keys(event.detail).forEach(key => {
                if(key === 'ConfirmEmail') {
                    this.confirmEmail = event.detail[key];
                }
                else if(this.newCase.hasOwnProperty(key)) {
                    this.newCase[key] = event.detail[key];
                }
                else if(this.newAccount.hasOwnProperty(key)) {
                    this.newAccount[key] = event.detail[key];
                }
                
            });
        }
        catch(error) {
            console.error(error);
        }
    }

    handleMoreDetailInfo(event) {
        try{
            Object.keys(event.detail).forEach(key => {
                this.newCase[key] = event.detail[key];
            });
        }
        catch(error) {
            console.error(error);
        }
    }

    handleAddressInfo(event) {
        try{
            Object.keys(event.detail).forEach(key => {
                this.newAccount[key] = event.detail[key];
            });
        }
        catch(error) {
            console.error(error);
        }
    }

    handleProductInfo(event) {
        try{
            Object.keys(event.detail).forEach(key => {
                this.newCase[key] = event.detail[key];
            });
        }
        catch(error) {
            console.error(error);
        }
    }

    handlePrivacyPolicyInfo(event) {
        this.isCheckedPrivacyPolicy = event.detail;
        this.newCase.Contact_Us_Page_Privacy_Consent__c = event.detail;
    }

    handleFileUploader(event){
        const uploadedFiles = event.detail.files;
        this.documentId = [];
        if(uploadedFiles.length > 0) {
            this.isFileSelected = true;
            uploadedFiles.forEach(element => {
                this.uploadedDocuments.push(element.name);
                this.documentId.push(element.documentId);
            });
        }
    }

    async handleCreateCase() {
        // if(!this.ishowProductInMore && this.howCanWeHelpYou.toLowerCase() !== this.productPackagingIssue.toLowerCase()) {
        //     this.newCase.Product_Type__c = "";
        // }
        // if(this.ishowDamageIssue === false) {
        //     this.newCase.Damage_Issue__c = "";
        // }
        // if(this.ishowLotcodeInProduct === false) {
        //     this.newCase.Lot_Code__c = "";
        // }
        // if(this.howCanWeHelpYou.toLowerCase() !== this.productPackagingIssue.toLowerCase()) {
        //     this.newCase.Product_Size__c = "";
        //     this.newCase.Do_you_still_have_the_product__c = "";
        //     this.newCase.Issue__c = "";
        //     this.newAccount.PersonMailingStreet = "";
        //     this.newAccount.PersonMailingCity = "";
        //     this.newAccount.PersonMailingPostalCode = "";
        //     this.newAccount.PersonMailingState = "";
        //     this.newCase.Lot_Code__c = "";
        // }
        
        // this.isloaded = false; 
        
        let response;
        this.recaptchaResponse = this.template.querySelector('c-l-X-C-_privacy-Policy-And-Recaptcha').getData();
        Object.keys(this.newAccount).forEach(k => this.newAccount[k] == '' && delete this.newAccount[k]);
        if(this.newAccount.hasOwnProperty('Address2')) {
            delete this.newAccount['Address2'];
        }
        Object.keys(this.newCase).forEach(k => this.newCase[k] == '' && delete this.newCase[k]);
        // let account = JSON.parse(JSON.stringify(this.newAccount));
        // if(account.hasOwnProperty('ConfirmEmail')) {
        //     delete account['ConfirmEmail'];
        // }
        // console.log("this.newAccount", JSON.parse(JSON.stringify(this.newAccount)));
        // console.log("newAccount", JSON.parse(JSON.stringify(account)));
        await createCase({caseObj:this.newCase, caseId:null, isComplaint:this.isComplaint, reCaptchaResponse:this.recaptchaResponse, accountObj:this.newAccount, accountId:null, documentIdList:this.documentId, deleteDocumentIdList:this.deleteDocumentId})
        .then((result)=>{
            response = result;
        })
        .catch((error)=>{
            console.log(error);
        });
        if(response!==null) {
            if(response.hasOwnProperty('caseId')) {
                this.lastMessage = this.Success_Message;
                this.lastMessageType = "slds-text-heading_medium slds-text-color_success";
                // this.template.querySelector('c-custom-toast').showToast('success', "The Form has Submitted Successfully");
            }
            else if(response.hasOwnProperty('error')) {
                this.lastMessage = this.Error_Message;
                this.lastMessageType = "slds-text-heading_medium slds-text-color_error";
                // this.template.querySelector('c-custom-toast').showToast('error', "The Form has not Submitted Successfully");
            }
            this.isloaded = false;
            this.ishowSelectAnOption = false;
            this.ishowPersonalInfo = false;
            this.ishowMoreDetails = false;
            this.ishowAttachment = false;
            this.ishowPrivacyAndRecaptcha = false;
            this.ishowSubmit = false;
            this.ishowAddress = false;
            this.ishowProductInfo = false;
            this.ishowMoreDetails = false;
            this.isbackButtonDisable = false;
            this.ishowAttachment = false;
            this.ishowPrivacyAndRecaptcha = false;
            this.ishowProgrssIndicator = false;
            this.ishowbackButton = false;
            this.ishowLastMessage = true;
        } 
    }
    // handleFileUpload(event){
    //     var index = event.currentTarget.dataset.id;
    //     this.deleteDocumentId.push(this.documentId[index]);
    //     this.uploadedDocuments.splice(index, 1);
    //     this.documentId.splice(index, 1);
    //     if(this.uploadedDocuments.length === 0){
    //         this.isFileSelected = false;
    //     }
    //     console.log('Apple')
    //     this.template.querySelector('[data-id="fileuploadid"]').reset();
    //     console.log('Apple 1')
    //     //this.dispatchEvent(new RefreshEvent());
    // }
}