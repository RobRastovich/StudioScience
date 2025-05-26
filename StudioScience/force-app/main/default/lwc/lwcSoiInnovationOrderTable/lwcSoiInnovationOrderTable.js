import { LightningElement, track, api, wire } from 'lwc';
import filterOfficeValueByStateMap from '@salesforce/apex/CNT_LWC_SOI_Innovations.filterOfficeValueByStateMap';
import getRegionOptions from '@salesforce/apex/CNT_LWC_SOI_Innovations.getRegionOptions';
import stateProvinceLabel from '@salesforce/label/c.State_Province_Label';
import regionLabel from '@salesforce/label/c.Region_Label';
import shipPointLabel from '@salesforce/label/c.Legal_Ship_Point';
import attentionToLabel from '@salesforce/label/c.Attention_To';
import phoneLabel from '@salesforce/label/c.Phone_Label';
import recipientEmailLabel from '@salesforce/label/c.Recipient_Email';
import quantityLabel from '@salesforce/label/c.Quantity_per_variant';
import addLabel from '@salesforce/label/c.Add';
import deleteLabel from '@salesforce/label/c.Delete_Label';
import fieldErrorMessage from '@salesforce/label/c.Field_Error_Message';
import addressLabel from '@salesforce/label/c.Address';
import phoneHelptext from '@salesforce/label/c.Phone_Helptext';

export default class LwcSoiInnovationOrderTable extends LightningElement {
    @track projectList = [];
    @api country;
    @api stateFilterValues;
    @track state;
    @track shipPointList;
    @track addressId;
    @track recipientEmail;
    @track quantity;
    @track attentionTo;
    @track phone;
    @api updatedProjectList = [];
    @api isChildFieldsValid = false;
    @track regionOptions;
    @api region;
    @api shipAddressMap;
    @track address;
    @track addressNameMap = new Map();
    orderTableLabelsList = {
        stateProvinceLabel, regionLabel, shipPointLabel, attentionToLabel, phoneLabel, recipientEmailLabel,
        quantityLabel, addLabel, deleteLabel, fieldErrorMessage, addressLabel, phoneHelptext
    };

    connectedCallback() {
        this.addProjectRecord();
    }

    addRow(event) {
        this.addProjectRecord();
        this.isDelvisible = true;
    }
    
    removeRow(event) {
        let rowIndex = event.target.accessKey;
        this.projectList.splice(rowIndex, 1);
        if(this.projectList.length == 1) {
            this.isDelvisible = false;
        }
        this.updatedProjectList = this.projectList;
    }

    addProjectRecord() {
        this.projectList.push({
            'legalShipPoint' : '',
            'recipientEmail' : '',
            'quantity' : '',
            'attentionTo' : '',
            'phone' : '',
            'addressId' : '',
            'address' : ''
        });
    }

    @api
    validateFields() {
        this.isChildFieldsValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea')]
                                  .reduce((validSoFar, inputCmp) => {
                                      inputCmp.reportValidity();
                                      return validSoFar && inputCmp.checkValidity();
                                  }, true);
    }

    handleStateChange(event) {
        this.state = event.target.value;
        this.fetchOfficeValueByState();
        this.resetTableFields();
    }

    @wire(getRegionOptions)
    wiredRegionOptions({data, error}) {
        if(data) {
            let regionList = [];
            for(var index = 0; index < data.length; index++) {
                regionList.push({label : data[index][0], value : data[index][1]});
            }
            this.regionOptions = regionList;
        } else if(error) {
            console.log(error);
        }
    }

    fetchOfficeValueByState() {
        filterOfficeValueByStateMap({country : this.country, stateVal : this.state})
        .then(result => {
            let shipList = [];
            for(let address in result) {
                shipList.push({label : address, value : address});
                this.addressNameMap.set(address, result[address]);
            }
            this.shipPointList = shipList;
        })
        .catch(error => {
            console.log(error);
        })
    }

    handleChange(event) {
        let fieldname = event.target.name;
        let accessKey = event.target.accessKey;
        if(fieldname == 'region') {
            this.region = event.target.value;
        } else if(fieldname == 'legalShipPoint') {
            this.projectList[accessKey].legalShipPoint = event.target.value;
            this.projectList[accessKey].addressId = this.shipAddressMap.get(this.state).get(event.target.value);
            this.projectList[accessKey].address = this.addressNameMap.get(this.projectList[accessKey].legalShipPoint);
        } else if(fieldname == 'recipientEmail') {
            this.projectList[accessKey].recipientEmail = event.target.value;
        } else if(fieldname == 'quantity') {
            this.projectList[accessKey].quantity = event.target.value;
        } else if(fieldname == 'attentionTo') {
            this.projectList[accessKey].attentionTo = event.target.value;
        } else if(fieldname == 'phone') {
            this.projectList[accessKey].phone = event.target.value;
        }
        this.updatedProjectList = this.projectList;
    }

    @api
    clearChildData() {
        this.state = null;
        this.region = null;
        this.resetTableFields();
    }

    @api
    resetTableFields() {
        this.projectList = [];
        this.addProjectRecord();
        this.isDelvisible = false;
        this.updatedProjectList = this.projectList;
    }

    @api
    resetState() {
        this.state = null;
    }
}