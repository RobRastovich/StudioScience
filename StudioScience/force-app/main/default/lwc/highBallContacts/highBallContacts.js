import { LightningElement,api,wire } from 'lwc';
import getContactList from '@salesforce/apex/ContactQuery.getContactList';

export default class HighBallContacts extends LightningElement {
    @api recordId;
    @api accountid;
    @api contactid;
    @api conid;
    @api AccountContactFirstName;
    @api AccountContactLastName;
    @api AccountContactEmail;
    @api AccountContactPhone;
    @api AccountContactFirstName1;
    @api AccountContactLastName1;
    @api AccountContactEmail1;
    @api AccountContactPhone1;
    @api BuyerContactFirstName;
    @api BuyerContactLastName;
    @api BuyerContactEmail;
    @api BuyerContactPhone;  
    @api value = '';
    @api accountcontactvalue = '';
    @api buyercontactvalue = '';
    @api newCreate = false;
    @api newAccountContactCreate = false;
    @api newBuyerContactCreate = false;
    contactOptions = [];
    requiredMessage = 'Please fill out all the required fields';
    validity = false;

    
    genericOnChange(event){
        this[event.target.name] = event.target.value;
    }

    @wire(getContactList, {'acctId' : '$accountid'})
    wiredContacts({data , error}) {     
        if(data) {    
            var arr = []; 
            for(var i = 0 ; i< data.length; i++){
                arr.push({
                    label : data[i].Name, 
                    value: data[i].Id 
                }) 
            }
            arr.push({ 
                "label" : 'New Contact',
                "value"  : 'NewContact'
            });
        this.contactOptions = arr;      
        }else if(error){
            this.error = error;
        }
    }

    accountcontacthandlechange(event){
        this.accountcontactvalue = event.detail.value;
        this.contactid=event.detail.value;
        if(this.accountcontactvalue == 'NewContact')
        {
            this.newAccountContactCreate=true;
        }
        else{
            this.newAccountContactCreate=false;
        }
    }

    buyercontacthandlechange(event){
        this.buyercontactvalue = event.detail.value;
        this.conid=event.detail.value;
        if(this.buyercontactvalue == 'NewContact')
        {
            this.newBuyerContactCreate=true;
        }
        else{
            this.newBuyerContactCreate=false;
        }
    }

    @api
    validate(){
        if(this.validateInput()){
            return{
                isValid: true
            };
        }else{
            return{
                isValid: false,
                errorMessage: this.requiredMessage
            };
        }
    }

    validateInput(){
        if(!this.accountcontactvalue || (this.accountcontactvalue == 'NewContact' && (this.AccountContactFirstName == undefined || this.AccountContactFirstName.length === 0 || this.AccountContactLastName == undefined || this.AccountContactLastName.length === 0 || this.AccountContactEmail == undefined || this.AccountContactEmail.length === 0 || this.AccountContactPhone == undefined || this.AccountContactPhone.length === 0  ))|| (this.buyercontactvalue == 'NewContact' && (this.BuyerContactFirstName == undefined || this.BuyerContactFirstName.length === 0 || this.BuyerContactLastName == undefined || this.BuyerContactLastName.length === 0 || this.BuyerContactEmail == undefined || this.BuyerContactEmail.length === 0 || this.BuyerContactPhone == undefined || this.BuyerContactPhone.length === 0 ))){
                    this.validity = false;
        }
        else{
            this.validity = true;
        }
        return this.validity;
    }   
}