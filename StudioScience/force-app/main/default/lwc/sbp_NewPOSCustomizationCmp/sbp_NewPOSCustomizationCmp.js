import { LightningElement, track, wire, api } from 'lwc';
import getPOSItem from '@salesforce/apex/SBP_NewPOSCustomizationCmpCtrl.getPOSItems';
import getRelatedBarrel from '@salesforce/apex/SBP_NewPOSCustomizationCmpCtrl.getRelatedBarrels';
import getPOSMetaData from '@salesforce/apex/SBP_NewPOSCustomizationCmpCtrl.getPOSMetaData';
import insertPOSItem from '@salesforce/apex/SBP_NewPOSCustomizationCmpCtrl.insertPOSItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Testing extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api objectRecordTypeId;

    @track brand = '';
    @track isMM = false;
    @track wiredPOSItem = [];
    @track viewAllURL;
    @track numberOfPOSItems = 0;
    @track isShowModal = false;
    @track Barrel = null;
    @track statusValue = '';
    @track carrierValue = '';
    @track uploadedBy = null;
    @track typeValue = null;
    @track insertTextValue;
    @track typeOptions = [];
    @track insertTextOptions = [];
    @track Date = null;
    @api Quantity = null;
    @track Street = null;
    @track InsertText = null;
    @track SignatureCheckbox = false;
    @track StaveCheckbox = false;
    @track IOCode = null;
    @track Company = null;
    @track Attention = null;
    @track AttentionEmail = null;
    @track City = null;
    @track State = null;
    @track Zip = null;
    @track Phone = null;
    @track TrackingNumber = null;
    @track TrackingURL = null;
   
    handleTypeChange(event) {
        this.typeValue = event.detail.value;
        let dependentValues;
        if (this.typeValue == 'Bottle Necker' || this.typeValue == 'Hang Tag') {
            dependentValues = [
                {label: 'Account Name', value: 'Account Name'},
                {label: 'Bottle Label Text', value: 'Bottle Label Text'},
                {label: 'Custom Text', value: 'Custom Text'},
            ];
        } else if (this.typeValue.includes('Plate') || this.typeValue.includes('Label') || this.typeValue=='POS Item' ||
                    this.typeValue=='French Mocha Stave Ring' || this.typeValue=='Mendiant Stave Ring') {
            dependentValues = [{ label: '--None--', value: '' }];
        } else if (this.typeValue == 'Trophy Piece' || this.typeValue == 'Case Card' || 
                   this.typeValue == 'Commemorative Barrelhead') {
            dependentValues = [{label: 'Account Name', value: 'Account Name'}];
        } else {
            dependentValues = [
                {label: 'Account Name', value: 'Account Name'},
                {label: 'Bottle Label Text', value: 'Bottle Label Text'},
            ];
        }
        this.insertTextOptions = dependentValues;
    }
    
    @wire(getPOSItem, { caseId: "$recordId"})
    getPOSItemMap({ data, error }) {
        if (data) {
            data.forEach((POSItem)=>{
                let posData = {'Name' : POSItem.Name, 'URL' : '/lightning/r/POS_Customization__c/'+POSItem.Id+'/view', 
                                'Type' : POSItem.Type__c, 'Get_Insert_Text_From' : POSItem.Get_Insert_Text_From__c, 
                                'Insert_Text' : POSItem.Insert_Text__c };
                this.wiredPOSItem.push(posData);
                return;
            });
            this.numberOfPOSItems = this.wiredPOSItem.length;
        } else if (error) {
            console.log(error);
        }
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    saveDetails() {
        insertPOSItem({ "type": this.typeValue, "uploadedBy": this.uploadedBy, "insertTextValue":  this.insertTextValue,
                        "POSdate": this.Date, "barrelId": this.Barrel, "quantity": this.Quantity, "street": this.Street,
                        "insertText": this.InsertText, "carrier": this.carrierValue, "signatureCheckbox": this.SignatureCheckbox,
                        "status": this.statusValue, "staveCheckbox": this.StaveCheckbox, "IOCode": this.IOCode, "company": this.Company, 
                        "attention": this.Attention, "attEmail": this.AttentionEmail, "city": this.City, "state": this.State, 
                        "zip": this.Zip, "phone": this.Phone, "trackId": this.TrackingNumber, "trackUrl": this.TrackingURL
        })
        .then(result => {
            let test = result;
            this.isShowModal = false;
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Record created succesfully',
                variant: 'Success',
            });
            this.dispatchEvent(evt);
        })
        .catch(error => {
            console.log(error);
            this.isShowModal = false;
        });
    }

    handleGetInsertTextChange(event) {
        this.insertTextValue = event.detail.value;
    }

    @wire(getRelatedBarrel, { caseId: "$recordId"})
    getRelatedBarrel({data, error}) {
        let barrelId;
        if (data) {
            data.forEach((barrel)=>{
                barrelId = barrel.Id;
                this.brand = barrel.Brand__c;
                if(barrel.Brand__c == 'Makers Mark') {
                    this.isMM = true;
                }
                return;
            });
            this.Barrel = barrelId;
            this.viewAllURL = '/lightning/r/Barrel__c/'+barrelId+'/related/POS_Customizations__r/view?ws=%2Flightning%2Fr%2FCase%2F'+this.recordId+'%2Fview';
        }
        else if (error) {
            console.log(error);
        }
    }

    @wire(getPOSMetaData, { caseId: "$recordId"})
    getPOSMetaData({data, error}) {
        if(this.brand == 'Laphroaig Single Cask') {
            this.typeOptions.push({ label: 'LSC Bottle Plate Line 1', value: 'LSC Bottle Plate Line 1'});
        } else if(this.brand == 'Makers Mark') {
            this.typeOptions.push({ label: 'Bottle Label Text City and State', value: 'Bottle Label Text City and State'});
            this.typeOptions.push({ label: 'Bottle Plate Text', value: 'Bottle Plate Text'});
        } else if(this.brand == 'El Tesoro') {
            this.typeOptions.push({ label: 'ET Bottle Plate Line 1', value: 'ET Bottle Plate Line 1'});
            this.typeOptions.push({ label: 'ET Bottle Plate Line 2', value: 'ET Bottle Plate Line 2'});
            this.typeOptions.push({ label: 'ET Bottle Plate Line 3', value: 'ET Bottle Plate Line 3'});
        } else if(this.brand == 'Knob Creek') {
            this.typeOptions.push({ label: 'Bottle Plate Text', value: 'Bottle Plate Text'});
        }
        if (data) {
            for (let key in data) {
                this.typeOptions.push({ label: key, value: key});
            }
        }    
        else if (error) {
            console.log(error);
        }
    }

    get statusOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Item Received', value: 'Item Received'},
        ];
    }
    handleStatusChange(event) {
        this.statusValue = event.detail.value;
    }

    get carrierOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'UPS', value: 'UPS' },
            { label: 'FedEx', value: 'FedEx' },
            { label: 'DHL', value: 'DHL'},
        ];
    }
    handleCarrierChange(event) {
        this.carrierValue = event.detail.value;
    }

    handleUploadedByChange(event){
        this.uploadedBy = event.detail.recordId;
    } 

    handleDateChange(event) {
        this.Date = event.detail.value;
    }

    handleQuantityChange(event) {
        this.Quantity = event.detail.value;
    }

    handleStreetChange(event) {
        this.Street = event.detail.value;
    }
    
    handleInsertTextChange(event) {
        this.InsertText = event.detail.value;
    }

    handleAttentionChange(event) {
        this.Attention = event.detail.value;
    }

    handleAttentionEmailChange(event) {
        this.AttentionEmail = event.detail.value;
    }

    handleCompanyChange(event) {
        this.Company = event.detail.value;
    }

    handleIOCodeChange(event) {
        this.IOCode = event.detail.value;
    }

    handleStateChange(event) {
        this.State = event.detail.value;
    }

    handleCityChange(event) {
        this.City = event.detail.value;
    }

    handleZipChange(event) {
        this.Zip = event.detail.value;
    }

    handlePhoneChange(event) {
        this.Phone = event.detail.value;
    }

    handleTrackingNumberChange(event) {
        this.TrackingNumber = event.detail.value;
    }

    handleTrackingURLChange(event) {
        this.TrackingURL = event.detail.value;
    }

    handleSignatureCheckboxChange(event) {
        this.SignatureCheckbox = event.target.checked;
    }

    handleStaveCheckboxChange(event) {
        this.StaveCheckbox = event.target.checked;
    }
}