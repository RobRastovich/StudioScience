import { track, api, LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';
import findBrands from '@salesforce/apex/INT_EmailDeliveryController.getBrands';
import findMarkets from '@salesforce/apex/INT_EmailDeliveryController.getMarkets';
import findUserSettings from '@salesforce/apex/INT_EmailDeliveryController.getUserSettings';
import findPreviousDeliveries from '@salesforce/apex/INT_EmailDeliveryController.getPreviousDeliveries';
import fetchEmailDeliveryRecord from '@salesforce/apex/INT_EmailDeliveryController.getEmailDeliveryRecord';

export default class IntEditEmailDeliveryWizard extends LightningModal {
  @api recordId;
  @track recordInput = {
    apiName: 'INT_EmailDelivery__c',
    fields: {
      Id: '',
      INT_Status__c: 'Draft'
    }
  };

  @track comboboxOptions = {
    brand: [],
    region: [],
    market: [],
    filteredSends: []
  };

  selectedBrand;
  record = {};
  sendToggleValue = false;
  isSendDisabled = true;
  previousSends;
  selectedPreviousSend;
  selectedSendValue = '';
  minDate;
  invalidSendOutDate = false;

  async handleLoad(event) {
    var _brands = await findBrands();
    var _markets = await findMarkets();
    var _settings = await findUserSettings();
    var _emailDeliveryRecord = await fetchEmailDeliveryRecord({ emailDeliveryId: this.recordId });
    this.record = _emailDeliveryRecord[0];

    if (this.record.INT_PreviousDelivery__c) {
      this.sendToggleValue = true;
      this.isSendDisabled = false;
      this.selectedBrand = this.record.INT_Brand__c;
      this.fetchPreviousDeliveries(true);
    } else {
      this.sendToggleValue = false;
      this.isSendDisabled = true;
    }

    this.comboboxOptions.brand = _brands.map((b) => {
      return { label: b.Name, value: b.Id };
    });

    let _managedBrands = _settings
      .filter((s) => {
        return s.INT_Brand__c;
      })
      .map((s) => {
        return s.INT_Brand__c;
      });

    this.comboboxOptions.brand = this.comboboxOptions.brand.filter((brand) => {
      return _managedBrands.includes(brand.value);
    });

    this.comboboxOptions.market = _markets.map((m) => {
      return { label: m.Name, value: m.Id };
    });

    // Set the minimum send out date that must at least 5 days from today
    let minDate = new Date();
    minDate.setDate(minDate.getDate() + 5);
    this.minDate = minDate;

    this.stopLoading();
  }

  handleChange(event) {
    switch (event.currentTarget?.dataset?.fieldName) {
      case 'INT_Brand__c':
        let brandField = this.template.querySelector('lightning-combobox[data-field-name="INT_Brand__c"');
        this.selectedBrand = brandField.value;
        this.sendToggleValue = false;
        this.isSendDisabled = true;
        this.previousSends = null;
        this.selectedPreviousSend = null;
        this.selectedSendValue = '';
        break;

      default:
        break;
    }

    switch (event.currentTarget?.name) {
      case 'INT_SendOutDateTime__c':
        if (event.target.value) {
          let selectedDate = new Date(event.target.value);

          if (selectedDate < this.minDate) {
            this.invalidSendOutDate = true;
          } else {
            this.invalidSendOutDate = false;
          }
        }
        break;

      default:
        break;
    }

    this.checkForm();
  }

  handleClick() {
    this.startLoading();

    Array.from(this.template.querySelectorAll('lightning-input-field')).forEach((i) => {
      this.recordInput.fields[i.fieldName] = i.value;
    });

    Array.from(this.template.querySelectorAll('lightning-input')).forEach((i) => {
      this.recordInput.fields[i.name] = i.value;
    });

    Array.from(this.template.querySelectorAll('lightning-combobox')).forEach((i) => {
      this.recordInput.fields[i.dataset.fieldName] = i.value;
    });

    if (this.selectedPreviousSend) {
      this.recordInput.fields['INT_PreviousDelivery__c'] = this.selectedPreviousSend.value;
    } else {
      this.recordInput.fields['INT_PreviousDelivery__c'] = '';
    }

    this.recordInput.fields['Id'] = this.record.Id;

    this.template.querySelector('lightning-record-edit-form').submit(this.recordInput.fields);
  }

  handleSuccess(event) {
    this.close(event.detail.id);
  }

  handleCancel() {
    this.close('success');
  }

  startLoading() {
    this.refs.spinner.classList.remove('slds-hide');
    this.refs.body.classList.add('slds-hide');
    Array.from(this.template.querySelectorAll('lightning-modal-footer lightning-button')).forEach((button) => {
      button.disabled = true;
    });
  }

  stopLoading() {
    this.refs.spinner.classList.add('slds-hide');
    this.refs.body.classList.remove('slds-hide');
    Array.from(this.template.querySelectorAll('lightning-modal-footer lightning-button')).forEach((button) => {
      button.disabled = false;
    });
    this.checkForm();
  }

  checkForm() {
    if (
      Array.from(this.template.querySelectorAll('lightning-input-field')).some((i) => {
        return !i.value && !i.disabled;
      })
    ) {
      this.preventNextAction();
      return;
    }

    if (
      Array.from(this.template.querySelectorAll('lightning-combobox')).some((i) => {
        return !i.value && !i.disabled;
      })
    ) {
      this.preventNextAction();
      return;
    }

    if (this.sendToggleValue && !this.selectedSendValue) {
      this.preventNextAction();
      return;
    }

    if (this.invalidSendOutDate) {
      this.preventNextAction();
      return;
    }

    Array.from(this.template.querySelectorAll('lightning-modal-footer lightning-button')).forEach((button) => {
      button.disabled = false;
    });
  }

  preventNextAction() {
    Array.from(this.template.querySelectorAll('lightning-modal-footer lightning-button')).forEach((button) => {
      if (button.label != 'Cancel') {
        button.disabled = true;
      }
    });
  }

  handleSendToggle(event) {
    if (event.target.checked) {
      this.sendToggleValue = true;
      this.fetchPreviousDeliveries(false);
    } else {
      this.isSendDisabled = true;
      this.sendToggleValue = false;
      this.selectedPreviousSend = null;
      this.selectedSendValue = '';
      this.previousSends = null;
      this.checkForm();
    }
  }

  fetchPreviousDeliveries(initialLoad) {
    this.selectedBrand = !this.selectedBrand
      ? this.template.querySelector('lightning-combobox[data-field-name="INT_Brand__c"').value
      : this.selectedBrand;
    if (this.selectedBrand) {
      findPreviousDeliveries({
        selectedBrand: this.selectedBrand
      })
        .then((result) => {
          this.comboboxOptions.filteredSends = result.map((b) => {
            return { campaignName: b.INT_CampaignName__c, label: b.Name, value: b.Id };
          });

          if (initialLoad) {
            this.selectedPreviousSend = this.comboboxOptions.filteredSends.find(
              (pickListOption) => pickListOption.value === this.record.INT_PreviousDelivery__c
            );
            this.selectedSendValue = this.selectedPreviousSend.label;
          }

          this.isSendDisabled = false;
          this.checkForm();
        })
        .catch((error) => {
          console.log('error', error);
        });
    }
  }

  showPreviousSendOptions() {
    this.previousSends = this.comboboxOptions.filteredSends;
  }

  selectPreviousSend(event) {
    const selectedValue = event.currentTarget.dataset.value;

    this.selectedPreviousSend = this.comboboxOptions.filteredSends.find(
      (pickListOption) => pickListOption.value === selectedValue
    );

    this.selectedSendValue = this.selectedPreviousSend.label;
    this.previousSends = null;
    this.checkForm();
  }
}