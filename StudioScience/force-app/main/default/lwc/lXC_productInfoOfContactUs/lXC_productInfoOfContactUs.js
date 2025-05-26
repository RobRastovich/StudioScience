import { api, LightningElement, track } from 'lwc';
import {
    DSC_Product_Information, DSC_Product, DSC_What_size_is_the_bottle, Do_you_still_have_the_product,
    DSC_Issue_Type, DSC_Lot_Code, DSC_click_LOT_CODE_HELP, DSC_Select_a_Product, DSC_Select_a_Size,
    DSC_error_Please_select_a_product, DSC_error_Please_select_a_bottle_size, DSC_Select_an_option,
    DSC_error_Please_select_do_you_still_have_the_product, DSC_Select_an_Issue_Type,
    DSC_error_Please_select_an_issue_type,  DSC_error_Lot_code_must_not_be_empty,
    DSC_click_LOT_CODE_VIDEO
} from './label'
import lotCodeDictionarySet1 from '@salesforce/resourceUrl/lotCodeDictionarySet1';
import lotCodeDictionarySet2 from '@salesforce/resourceUrl/lotCodeDictionarySet2';
import lotCodeDictionarySet3 from '@salesforce/resourceUrl/lotCodeDictionarySet3';
import VIDEOSAMPLE from '@salesforce/resourceUrl/OnTheRocksLotCodeVideo';
export default class LXC_productInfoOfContactUs extends LightningElement {
    @track DSC_Product_Information;
    @track DSC_Product;
    @track DSC_What_size_is_the_bottle;
    @track Do_you_still_have_the_product;
    @track DSC_Issue_Type;
    @track DSC_Lot_Code;
    @track DSC_click_LOT_CODE_HELP;
    @track DSC_click_LOT_CODE_VIDEO;
    @track DSC_Select_a_Product;
    @track DSC_error_Please_select_a_product;
    @track DSC_Select_a_Size;
    @track DSC_error_Please_select_a_bottle_size;
    @track DSC_Select_an_option;
    @track DSC_error_Please_select_do_you_still_have_the_product;
    @track DSC_Select_an_Issue_Type;
    @track DSC_error_Please_select_an_issue_type;
    @track DSC_error_Lot_code_must_not_be_empty;
    productDataObject = {}
    @track ishowLotCode = true;
    @track ishowModal = false;
    @track ishowModalLotCodeVideo = false;
    @track imgSrc;
    @api newcase;
    @api product;
    @api doyoustillhaveproduct;
    @api lotcode;
    @track productList = [];
    @api issuesdata;
    @track issueList = [];
    @track showVideo = false;
    @track showImage = false;
    @api productsizeoption;
    sampleUrl = VIDEOSAMPLE;
    @api validate() {
        let isValid = true;
        let isComboFlag = false;
        const combobox = this.template.querySelectorAll("lightning-combobox");
        combobox.forEach(Element=> {
            if(!Element.reportValidity()) {
                isValid =  false;
                isComboFlag = true;
            }
        })
        const inputs = this.template.querySelectorAll("lightning-input");
        inputs.forEach(Element=> {
            if(Element.dataset.id === "lotcodeId" && Element.reportValidity()) {
                if(Element.value.length < 6) {
                    Element.setCustomValidity("Your entry is too short.");
                    isValid = false;
                }
                else {
                    isValid = true;
                    Element.setCustomValidity("");
                }
            }
            if(!Element.reportValidity()) {
                isValid = false;
            }
        })
        if(!this.ishowLotCode && !isComboFlag) {
            isValid = true;
        }
        return isValid;
    }

    async connectedCallback() {
        this.DSC_Product_Information = DSC_Product_Information;
        this.DSC_Product = DSC_Product;
        this.DSC_What_size_is_the_bottle = DSC_What_size_is_the_bottle;
        this.Do_you_still_have_the_product = Do_you_still_have_the_product;
        this.DSC_Issue_Type = DSC_Issue_Type;
        this.DSC_Lot_Code = DSC_Lot_Code;
        this.DSC_click_LOT_CODE_HELP = DSC_click_LOT_CODE_HELP;
        this.DSC_click_LOT_CODE_VIDEO = DSC_click_LOT_CODE_VIDEO;
        this.DSC_Select_a_Product = DSC_Select_a_Product;
        this.DSC_error_Please_select_a_product = DSC_error_Please_select_a_product;
        this.DSC_Select_a_Size = DSC_Select_a_Size;
        this.DSC_error_Please_select_a_bottle_size = DSC_error_Please_select_a_bottle_size;
        this.DSC_Select_an_option = DSC_Select_an_option;
        this.DSC_error_Please_select_do_you_still_have_the_product = DSC_error_Please_select_do_you_still_have_the_product;
        this.DSC_Select_an_Issue_Type = DSC_Select_an_Issue_Type;
        this.DSC_error_Please_select_an_issue_type = DSC_error_Please_select_an_issue_type;
        this.DSC_error_Lot_code_must_not_be_empty = DSC_error_Lot_code_must_not_be_empty;
        this.product.forEach(ele=> {
            let obj = JSON.parse(JSON.stringify(ele));
            obj['label'] = obj.Product__c;
            obj['value'] = obj.Value__c;
            this.productList.push(obj);
        })
        let issues = JSON.parse(JSON.stringify(this.issuesdata));
        issues.forEach(ele=>{
            ele['label'] = ele.Label__c;
            ele['value'] = ele.Name__c;
            this.issueList.push(ele);
        });
        if(this.newcase.Do_you_still_have_the_product__c.toUpperCase() === 'I no longer have the bottle'.toUpperCase()) {
            this.ishowLotCode = false;
        }
        let lotcodeMetadata = JSON.parse(JSON.stringify(this.lotcode))[0];
        let lotcodeDictionaryList = [lotCodeDictionarySet1, lotCodeDictionarySet2, lotCodeDictionarySet3];
        this.imgSrc = "";
        if(lotcodeMetadata) {
            if(lotcodeMetadata.Static_Resource_For_Video__c){
               this.ishowModalLotCodeVideo = true;
            }
        for(let j=0; j<lotcodeDictionaryList.length; j++) {
            let response = await fetch(lotcodeDictionaryList[j]+"/"+lotcodeMetadata.Static_Resource_Name__c+'.'+lotcodeMetadata.Format_Of_Lotcode__c);
            if(response.ok) {
                this.imgSrc = lotcodeDictionaryList[j]+"/"+lotcodeMetadata.Static_Resource_Name__c+'.'+lotcodeMetadata.Format_Of_Lotcode__c;
                break;
                }
            }
        }
    }

    hideModalBox() {
        this.ishowModal = false;
        this.showImage = false;
        this.showVideo = false;
    }

    showModal() {
        this.ishowModal = true;
        this.showImage = true;
    }
    showModalForVideo(){
        this.ishowModal = true;
        this.showVideo = true;
    }
    handleChangeOfInput(event) {
        if(event.target.dataset.id === "productId") {
            this.productDataObject["Product_Type__c"] = event.target.value;
        }
        else if(event.target.dataset.id === "sizeId") {
            this.productDataObject["Product_Size__c"] = event.target.value;
        }
        else if(event.target.dataset.id === "sampleId") {
            let lotcode = event.detail.value;
            if(lotcode.toUpperCase() === 'I no longer have the bottle'.toUpperCase()) {
                this.ishowLotCode = false;
                // this.productDataObject["Lot_Code__c"] = "";
            }
            else {
                this.ishowLotCode = true;
            }
            this.productDataObject["Do_you_still_have_the_product__c"] = event.target.value;
            const selectedEvent = new CustomEvent('ishowlotcode', { detail: this.ishowLotCode });
            this.dispatchEvent(selectedEvent);
        }
        else if(event.target.dataset.id === "issueId") {
            this.productDataObject["Issue__c"] = event.target.value;
        }
        else if(event.target.dataset.id === "lotcodeId") {
            this.productDataObject["Lot_Code__c"] = event.target.value;
            const inputLotcode = this.template.querySelector(`[data-id="lotcodeId"]`);
            if(event.target.value.length < 6) {
                inputLotcode.setCustomValidity("Your entry is too short.");
            }
            else {
                inputLotcode.setCustomValidity("");
            }
        }
        const selectedEvent = new CustomEvent('productdataevent', { detail: this.productDataObject });
        this.dispatchEvent(selectedEvent);
    }
}