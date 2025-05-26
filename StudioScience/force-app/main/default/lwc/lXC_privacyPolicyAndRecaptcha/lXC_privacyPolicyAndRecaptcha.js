import { LightningElement, track, api } from 'lwc';
import lang from '@salesforce/i18n/lang';
import ReCaptcha_Message from '@salesforce/label/c.ReCaptcha_Message';
import {
    Contact_Us_Page_Privacy_Consent, DSC_Contact_Us_Page_Privacy_Policy, DSC_Contact_Us_Page_Privacy_Consent_Text
} from './label';

export default class LXC_privacyPolicyAndRecaptcha extends LightningElement {
    @track Contact_Us_Page_Privacy_Consent;
    @track DSC_Contact_Us_Page_Privacy_Policy;
    @track DSC_Contact_Us_Page_Privacy_Consent_Text;
    @track privacyPolicy = DSC_Contact_Us_Page_Privacy_Consent_Text + " ";
    @track src;
    @track reCaptchaTokenData;
    @track ReCaptcha_Message;
    @track ishowError = false;
    @track isRecaptchaClicked = false;
    @track ishowPrivacyError = false;
    @track chekBoxClass = "slds-form-element";
    @api ischeckedprivacypolicy;
    @api validate() {
        // const inputs = this.template.querySelector("lightning-input");
        let isValid = true;
        // if(!inputs.reportValidity()) {
        //     isValid = false;
        // }
        if(!this.ischeckedprivacypolicy) { 
            this.ishowPrivacyError = true;
            this.chekBoxClass = "slds-form-element slds-has-error";
            isValid = false;
        }
        
        if(!this.isRecaptchaClicked){
            isValid = false;
            this.ishowError = true;
        }
        return isValid;
    }
    connectedCallback() {
        this.Contact_Us_Page_Privacy_Consent = Contact_Us_Page_Privacy_Consent;
        this.DSC_Contact_Us_Page_Privacy_Policy = DSC_Contact_Us_Page_Privacy_Policy;
        this.DSC_Contact_Us_Page_Privacy_Consent_Text = DSC_Contact_Us_Page_Privacy_Consent_Text;
        this.ReCaptcha_Message = ReCaptcha_Message;
        // this.src = "https://beamsuntory--d2cdev.sandbox.my.site.com"+'consumercomplaint/VFP_ReCaptcha?lang=' + lang;
        this.src = window.location.origin+'/consumercomplaint/VFP_ReCaptcha?lang=' + lang;
        window.addEventListener('message', this.handleRecaptcha);
    }
    renderedCallback(){
        if(this.ischeckedprivacypolicy) {
            const inputCheckBox = this.template.querySelector(`[data-id='input']`);
            if(inputCheckBox) {
                inputCheckBox.setAttribute('checked',''); 
                this.ishowPrivacyError = false;
                this.chekBoxClass = "slds-form-element";
            }
        }
    }
    disconnectedCallback() {
        window.removeEventListener('message', this.handleRecaptcha);
    }
     
    handleRecaptcha=(event)=>{

        if (event.data.name == 'reCaptchaToken') {
            this.reCaptchaTokenData = event.data.payload ? event.data.payload : '';
            if(this.reCaptchaTokenData.length>0) {
                this.isRecaptchaClicked = true;
                this.ishowError = false;
            }
            else {
                this.isRecaptchaClicked = false;
                this.ishowError = true;
            }
            // console.log("event", event);
        }
    }

    @api getData() {
        return this.reCaptchaTokenData;
    }

    handleChangePrivacyPolicy(event) {
        if(!event.target.checked) {
            this.ishowPrivacyError = true;
            this.chekBoxClass = "slds-form-element slds-has-error";
        }
        else {
            this.ishowPrivacyError = false;
            this.chekBoxClass = "slds-form-element";
        }
        
        const selectedEvent = new CustomEvent('handleprivacycheckbox', { detail: event.target.checked });
        this.dispatchEvent(selectedEvent);
    }

    @api resetRecaptcha() {
        this.template.querySelector('iframe').contentWindow.postMessage('resetReCaptcha', '*');
    }
}