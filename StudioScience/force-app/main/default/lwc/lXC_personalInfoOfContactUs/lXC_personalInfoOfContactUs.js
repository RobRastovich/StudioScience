import { LightningElement, track, api } from 'lwc';
import {
    DSC_Personal_Information, DSC_First_Name, DSC_Last_Name, DSC_Email_Address, DSC_Confirm_Email,
    DSC_Phone_Number, DSC_Country, DSC_error_First_Name_must_not_be_empty, DSC_error_Last_Name_must_not_be_empty,
    DSC_error_Email_Address_must_not_be_empty, DSC_error_Confirm_Email_Address_must_not_be_empty,
    DSC_error_Phone_Number_must_not_be_empty, DSC_error_Please_select_a_country, DSC_Select_a_Country,
    DTC_Issue, DTC_Select_An_Issue, Confirm_Email_Same_Error, Email_Invalid_Format
} from './label'

export default class LXC_personalInfoOfContactUs extends LightningElement {
    //label
    @track DSC_Personal_Information;
    @track DSC_First_Name;
    @track DSC_Last_Name;
    @track DSC_Email_Address;
    @track DSC_Confirm_Email;
    @track DSC_Phone_Number;
    @track DSC_Country;
    @track DSC_error_First_Name_must_not_be_empty;
    @track DSC_error_Last_Name_must_not_be_empty;
    @track DSC_error_Email_Address_must_not_be_empty;
    @track DSC_error_Confirm_Email_Address_must_not_be_empty;
    @track DSC_error_Phone_Number_must_not_be_empty;
    @track DSC_error_Please_select_a_country;
    @track DSC_Select_a_Country;
    @track DTC_Issue;
    @track DTC_Select_An_Issue;
    @track Confirm_Email_Same_Error;
    @track Email_Invalid_Format;
    personalDataObject = {};
    // parent
    @api country;
    @api ishowtelnum;
    @api damageissuesdata;
    @api ishowcountry;
    @api ishowdamageissue;
    @api newaccount;
    @api newcase;
    @api confirmemail;
    @track countories = [];
    @api validate(){
        let isvalid = true;
        const combobox = this.template.querySelectorAll("lightning-combobox");
        combobox.forEach(Element=> {
            if(!Element.reportValidity()) {
                isvalid = false;
            }
        })
        const inputs = this.template.querySelectorAll("lightning-input");
        inputs.forEach(Element=> {
            if(!Element.reportValidity()) {
                isvalid = false;
            }
        })
        return isvalid;
    }

    connectedCallback() {
        this.DSC_Personal_Information = DSC_Personal_Information;
        this.DSC_First_Name = DSC_First_Name;
        this.DSC_Last_Name = DSC_Last_Name;
        this.DSC_Email_Address = DSC_Email_Address;
        this.DSC_Confirm_Email = DSC_Confirm_Email;
        this.DSC_Phone_Number = DSC_Phone_Number;
        this.DSC_Country = DSC_Country;
        this.DSC_error_First_Name_must_not_be_empty = DSC_error_First_Name_must_not_be_empty;
        this.DSC_error_Last_Name_must_not_be_empty = DSC_error_Last_Name_must_not_be_empty;
        this.DSC_error_Email_Address_must_not_be_empty = DSC_error_Email_Address_must_not_be_empty;
        this.DSC_error_Confirm_Email_Address_must_not_be_empty = DSC_error_Confirm_Email_Address_must_not_be_empty;
        this.DSC_error_Phone_Number_must_not_be_empty = DSC_error_Phone_Number_must_not_be_empty;
        this.DSC_error_Please_select_a_country = DSC_error_Please_select_a_country;
        this.DSC_Select_a_Country = DSC_Select_a_Country;
        this.DTC_Issue = DTC_Issue;
        this.DTC_Select_An_Issue = DTC_Select_An_Issue;
        this.Confirm_Email_Same_Error = Confirm_Email_Same_Error;
        this.countories = JSON.parse(JSON.stringify(this.country));
        let countriesOfInterest = this.countories.filter((obj)=>{return obj.value != "United States"});
        let sortedCountries = countriesOfInterest.sort((a, b) => (a.label == b.label ? 0 : +(a.label > b.label) || -1))
        let usaCountry =  this.countories.filter((obj) => {return obj.value == "United States"});
        this.countories = usaCountry.concat(sortedCountries);
        this.Email_Invalid_Format = Email_Invalid_Format;
    }

    handleConfirmEmail(event) {
        try {
            let confirmEmail = this.template.querySelector('[data-id="confirmEmailId"]');//event.target.value;
            let email = this.template.querySelector('[data-id="emailId"]');
            let regex = new RegExp('[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-z]{2,3}');
            if(!confirmEmail.value) {
                confirmEmail.setCustomValidity(DSC_error_Confirm_Email_Address_must_not_be_empty);   
            }
            else if (!regex.test(confirmEmail.value)) {
                confirmEmail.setCustomValidity(Email_Invalid_Format);   
            }
            else if(email && (confirmEmail.value.toUpperCase() != email.value.toUpperCase())) {
                confirmEmail.setCustomValidity(Confirm_Email_Same_Error);
            }
            else {
                confirmEmail.setCustomValidity("");   
            }
            confirmEmail.reportValidity();
        }
        catch(e) {
            console.error(e);
        }  
        
    }

    handleChangeOfInput(event) {
        if(event.target.dataset.id === "firstNameId") {
            this.personalDataObject["FirstName"] = event.target.value;
        }
        else if(event.target.dataset.id === "lastNameId") {
            this.personalDataObject["LastName"] = event.target.value;
        }
        else if(event.target.dataset.id === "emailId") {
            this.personalDataObject["PersonEmail"] = event.target.value;
        }
        else if(event.target.dataset.id === "confirmEmailId") {
            this.personalDataObject["ConfirmEmail"] = event.target.value;
        }
        else if(event.target.dataset.id === "telNumId") {
            this.personalDataObject["Phone"] = event.target.value;
        }
        else if(event.target.dataset.id === "countryId") {
            this.personalDataObject["PersonMailingCountry"] = event.target.value;
        }
        else if(event.target.dataset.id === "dtc_issueId") {
            this.personalDataObject["Damage_Issue__c"] = event.target.value;
        }
        
        const selectedEvent = new CustomEvent('personaldata', { detail: this.personalDataObject });
        this.dispatchEvent(selectedEvent);
    }
}