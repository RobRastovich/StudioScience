import { LightningElement, track, api } from 'lwc';
import {
    DSC_Please_select_an_option, DSC_Additional_Information, DSC_How_can_we_help_you,
    DSC_error_Please_select_a_help_option, DSC_error_Please_select_additional_information,
    DSC_Select_an_option
} from './label'

export default class LXC_howCanIHelpYouOptionContactUs extends LightningElement {
    @track DSC_Please_select_an_option;
    @track DSC_Additional_Information
    @track DSC_How_can_we_help_you;
    @track DSC_error_Please_select_a_help_option;
    @track DSC_error_Please_select_additional_information;
    @track DSC_Select_an_option;
    @track options=[];
    @track isAdditionalInfo = false;
    @track additionalInfoOption = [];
    @api newcase;
    @api optiondata;
    @api validate(){
        let isValid = true;
        const combobox = this.template.querySelectorAll("lightning-combobox");
        combobox.forEach(Element=> {
            if(!Element.reportValidity()) {
                isValid = false;
            }
        })
        return isValid;
    }
    connectedCallback() {
        this.DSC_Please_select_an_option = DSC_Please_select_an_option;
        this.DSC_How_can_we_help_you = DSC_How_can_we_help_you;
        this.DSC_Additional_Information = DSC_Additional_Information;
        this.DSC_error_Please_select_a_help_option = DSC_error_Please_select_a_help_option;
        this.DSC_error_Please_select_additional_information = DSC_error_Please_select_additional_information;
        this.DSC_Select_an_option = DSC_Select_an_option;
        let optionlist = Object.keys(this.optiondata);
        optionlist.forEach(Element=> {
            this.options.push({label:Element, value:Element});
        });
    }

    handleChangeInput(event) {
        if(event.target.dataset.id === "howCanIHelpId") {
            const howCanWeHelpYou = event.detail.value;
            let additionalInfo = JSON.parse(JSON.stringify(this.optiondata[howCanWeHelpYou]));
            if(additionalInfo.length>0) {
                this.additionalInfoOption = [];
                additionalInfo.forEach(Element=> {
                    this.additionalInfoOption.push({label:Element, value:Element});
                });
                this.isAdditionalInfo = true;
                const addtionalOpt = this.template.querySelector('[data-id="additionalInfoId"]');
                if(addtionalOpt) {
                    addtionalOpt.value = "";
                }
            }
            else {
                this.isAdditionalInfo = false;
            }

            const selectedEvent = new CustomEvent('selectedoption', { detail: howCanWeHelpYou });
            this.dispatchEvent(selectedEvent);
        }
        else if(event.target.dataset.id === "additionalInfoId") {
            let additionalInfo = event.detail.value;
            const selectedEvent = new CustomEvent('selectedadditionalinfo', { detail:additionalInfo });
            this.dispatchEvent(selectedEvent);
        }  
    }
}