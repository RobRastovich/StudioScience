import { LightningElement, track, api } from 'lwc';
import {
    DSC_Address, DSC_Address_2, DSC_City, DSC_State, DSC_Country, DSC_Street_Address,
    DSC_error_Street_Address_must_not_be_empty, DSC_Postal_Code, DSC_error_City_must_not_be_empty,
    DSC_error_Postal_Code_must_not_be_empty, DSC_error_State_must_not_be_empty, DSC_Select_a_Country,
    DSC_error_Please_select_a_country
} from './label';

export default class LXC_addressOfContactUs extends LightningElement {
    @track DSC_Address;
    @track DSC_Street_Address;
    @track DSC_Address_2;
    @track DSC_City;
    @track DSC_State;
    @track DSC_Country;
    @track DSC_error_Street_Address_must_not_be_empty;
    @track DSC_Postal_Code;
    @track DSC_error_Postal_Code_must_not_be_empty;
    @track DSC_error_City_must_not_be_empty;
    @track DSC_error_State_must_not_be_empty;
    @track DSC_Select_a_Country;
    @track DSC_error_Please_select_a_country;
    @track countories = [];
    @api country;
    @api newaccount;
    addressDataObject = {}
    @api validate() {
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
    connectedCallback(){
        this.DSC_Address = DSC_Address;
        this.DSC_Street_Address = DSC_Street_Address;
        this.DSC_Address_2 = DSC_Address_2;
        this.DSC_City = DSC_City;
        this.DSC_State = DSC_State;
        this.DSC_Country = DSC_Country;
        this.DSC_error_Street_Address_must_not_be_empty = DSC_error_Street_Address_must_not_be_empty;
        this.DSC_Postal_Code = DSC_Postal_Code;
        this.DSC_error_City_must_not_be_empty = DSC_error_City_must_not_be_empty;
        this.DSC_error_Postal_Code_must_not_be_empty = DSC_error_Postal_Code_must_not_be_empty;
        this.DSC_error_State_must_not_be_empty = DSC_error_State_must_not_be_empty;
        this.DSC_Select_a_Country = DSC_Select_a_Country;
        this.DSC_error_Please_select_a_country = DSC_error_Please_select_a_country;
        this.countories = JSON.parse(JSON.stringify(this.country));
        let countriesOfInterest = this.countories.filter((obj)=>{return obj.value != "United States"});
        let sortedCountries = countriesOfInterest.sort((a, b) => (a.label == b.label ? 0 : +(a.label > b.label) || -1))
        let usaCountry =  this.countories.filter((obj) => {return obj.value == "United States"});
        this.countories = usaCountry.concat(sortedCountries);
    }

    handleChangeOfInput(event) {
        if(event.target.dataset.id === "streetaddressId") {
            this.addressDataObject["PersonMailingStreet"] = event.target.value;
        }
        else if(event.target.dataset.id === "address2Id") {
            this.addressDataObject["Address2"] = event.target.value;
        }
        else if(event.target.dataset.id === "postalcodeId") {
            this.addressDataObject["PersonMailingPostalCode"] = event.target.value;
        }
        else if(event.target.dataset.id === "cityId") {
            this.addressDataObject["PersonMailingCity"] = event.target.value;
        }
        else if(event.target.dataset.id === "stateId") {
            this.addressDataObject["PersonMailingState"] = event.target.value;
        }
        else if(event.target.dataset.id === "countryId") {
            this.addressDataObject["PersonMailingCountry"] = event.target.value;
        }
        const selectedEvent = new CustomEvent('addressdataevent', { detail: this.addressDataObject });
        this.dispatchEvent(selectedEvent);
    }
}