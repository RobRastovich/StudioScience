import { wire, LightningElement } from 'lwc';

import { loadStyle } from "lightning/platformResourceLoader";
//Importing Brand Logo & Brand Backgroung Image
import PrestigeResources from '@salesforce/resourceUrl/PrestigeResources';

//Importing Lead object and needed fields
import LEAD_OBJECT from '@salesforce/schema/Lead';
import TELEPHONE_FIELD from '@salesforce/schema/Lead.Telephone__c';
import PREFERRED_BRAND_FIELD from '@salesforce/schema/Lead.Preferred_Brands__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Lead.Description';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';
import PRIVACY_CONSENT_FIELD from '@salesforce/schema/Lead.Privacy_Consent__c';
import MARKETING_CONSENT_FIELD from '@salesforce/schema/Lead.HasOptedOutOfEmail';
import PRESTIGE_LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.Prestige_Lead_Source__c';
export default class LeadForm extends LightningElement {

	leadRecord = {};
	objectApiName = LEAD_OBJECT;
	descriptionField = DESCRIPTION_FIELD;
	leadSourceField = LEAD_SOURCE_FIELD.fieldApiName;
	telephoneField = TELEPHONE_FIELD.fieldApiName;
	marketingConsentField = MARKETING_CONSENT_FIELD.fieldApiName;
	privacyConsentField = PRIVACY_CONSENT_FIELD.fieldApiName;
	preferredBrandField = PREFERRED_BRAND_FIELD;

	spinnerStatus = true;
	isFormVisible = true;
	isError = false;

	errorMessage;
	privacyPolicy;
	thankYouMessage = 'Thank you for registering your interest in our Private Client offer and services. One of our consultants will contact you within 72 hour to discuss in more detail.';
	marketingConsentMessage = 'Please click to confirm that you are happy for the Suntory Global Spirits Private Client team to contact you regarding product offer, exclusive events and brand experiences.';

	containerClass = 'form_container';
	// CSS, Logo & Background Image attributes
	brandLogo = PrestigeResources + '/images/SuntoryGlobalSpirits.png';
	BGImage = PrestigeResources + '/images/SuntoryGlobalSpiritsBG.jpg';
	externalstyling = PrestigeResources + '/css/LeadFormExternalStyling.css';

	get getBackgroundImage(){
		return `background-image:url("${this.BGImage}")`;
	}

	constructor() {
		super();
		Promise.all([
			loadStyle(this, this.externalstyling )
		])
		.catch(error => {
			this.showError();
			console.log('ERROR 1 ::: ', error);
		});

	}
	connectedCallback(){
		try {
			let privacyPolicylink ="<a href=https://www.beamsuntory.com/en/privacy-policy target=_blank> "+ 'privacy policy.' + "</a>"; 
			this.privacyPolicy = "<div>" + 'I agree to the collection and processing of my personal data in line with the' + " " +privacyPolicylink +"</div>";
			this.errorMessage = "<p>"+'Sorry, there has been an error and your form has not been submitted. If this error continues, please contact '+"<a href=mailto:PrestigeApplicationsupport@beamsuntory.com> "+ 'PrestigeApplicationsupport@beamsuntory.com' + "</a>"+' directly.'+"</P>"
			setTimeout(() => {
				this.spinnerStatus = false;
			}, 2500);
		} catch (error) {
			this.showError();
			console.log('ERROR 2 ::: ', error);
		}
	}
	renderedCallback(){
		try {
			if(this.isFormVisible){
				this.template.querySelector('[data-firstname="FirstName"]').focus();
			}
		} catch (error) {
			console.log('ERROR 3 ::: ', error);
		}
	}

	handleLeadInputChange(event){
		try {
			event.preventDefault();
			this.leadRecord[event.target.name] = event.target.value;
			if(event.target.value == ''){
				this.leadRecord[event.target.name] = event.target.checked;
			}
		} catch (error) {
			console.log('ERROR 4 ::: ', error);
		}
	}

	handleValidate(){
		var allValid = [...this.template.querySelectorAll('lightning-input','lightning-combobox','lightning-textarea')
						].reduce((validSoFar, inputCmp) => {
								inputCmp.reportValidity();
								return validSoFar && inputCmp.checkValidity();
						}, true);
		return allValid;
	}

	showError(){
		this.containerClass = 'form_container message_container';
		this.isFormVisible = false;
		this.isError = true;
		this.spinnerStatus = false;
	}
	handleSubmit(event) {
		try {
			event.preventDefault();
			this.spinnerStatus = true;
			let allValid = this.handleValidate();
			if(!allValid){
				this.spinnerStatus = false;
				return ;
			}
			this.leadRecord[LEAD_SOURCE_FIELD.fieldApiName] = 'Web';
			this.leadRecord[PRESTIGE_LEAD_SOURCE_FIELD.fieldApiName] = 'Web';
			let JSONVal = JSON.parse(JSON.stringify(event.detail.fields));
			for (let [key, value] of Object.entries(JSONVal)) {
				this.leadRecord[key] = value;
			}
			let fields = this.leadRecord;
			this.template.querySelector('lightning-record-edit-form').submit(fields);
		} catch (error) {
			this.showError();
		}	
	}
	handleSuccess(event){
		this.isFormVisible = false;
		this.spinnerStatus = false;
		this.containerClass = 'form_container message_container';
	}
	handleError(event){
		const payload = event.detail.message;
		console.log(JSON.stringify(payload));
		this.showError();
    }
}