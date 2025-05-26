import { LightningElement, track, api } from 'lwc';
import {DSC_More_Details, DSC_Product, DSC_Comments, DSC_Select_a_Product, 
    DSC_error_Please_select_a_product, DSC_error_Comment_must_not_be_empty} from './label'
export default class LWC_moreDetailsOfContactUs extends LightningElement {
    @track DSC_More_Details;
    @track DSC_Product;
    @track DSC_Comments;
    @track DSC_Select_a_Product;
    @track DSC_error_Please_select_a_product;
    @track DSC_error_Comment_must_not_be_empty;
    moreDetailObject = {}
    @track productList = [];
    @api newcase;
    @api product;
    @api ishowproduct;
    @api validate() {
        let isvalid = true;
        const combobox = this.template.querySelector("lightning-combobox");
        if(combobox != null) {
            if(!combobox.reportValidity()) {
                isvalid = false;
            }
        }
        const textarea = this.template.querySelector("lightning-textarea");
        if(!textarea.reportValidity()) {
            isvalid = false;
        }
        return isvalid;
    }
    connectedCallback(){
        this.DSC_More_Details = DSC_More_Details;
        this.DSC_Product = DSC_Product;
        this.DSC_Comments = DSC_Comments;
        this.DSC_Select_a_Product = DSC_Select_a_Product;
        this.DSC_error_Please_select_a_product = DSC_error_Please_select_a_product;
        this.DSC_error_Comment_must_not_be_empty = DSC_error_Comment_must_not_be_empty;
        this.product.forEach(ele=>{
            let obj = JSON.parse(JSON.stringify(ele));
            obj['label'] = obj.Product__c;
            obj['value'] = obj.Value__c;
            this.productList.push(obj);
        })
        this.productList.sort((a, b) => {
            let fa = a.label.toLowerCase(),fb = b.label.toLowerCase();
            if (fa < fb) {
                return -1;
            }
            if (fa > fb) {
                return 1;
            }
            return 0;
        });
    }

    handleChangeOfInput(event) {
        if(event.target.dataset.id === "productId") {
            this.moreDetailObject["Product_Type__c"] = event.target.value;
        }
        else if(event.target.dataset.id === "commentId") {
            this.moreDetailObject["Description"] = event.target.value;
        }
        const selectedEvent = new CustomEvent('moredetaildataevent', { detail: this.moreDetailObject });
        this.dispatchEvent(selectedEvent);
    }
}