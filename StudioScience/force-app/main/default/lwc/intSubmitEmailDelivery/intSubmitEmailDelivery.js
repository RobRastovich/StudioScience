import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getRecTypes from '@salesforce/apex/INT_RecordTypeService.getRecordTypesByDeveloperName';

export default class IntSubmitEmailDelivery extends NavigationMixin(LightningElement) {
  @api recordId;
  recordTypes;

  @wire(getRecord, {
    recordId: '$recordId',
    fields: ['INT_EmailDelivery__c.INT_Segmentation__c']
  })
  async wiredEmailDelivery({ error, data }) {
    if (data && !this.recordTypes) {
      this.recordTypes = await getRecTypes({ sObjectApiName: 'INT_EmailDelivery__c' });
      this.stopLoading();
    }

    if (error) {
      console.error(error);
    }
  }

  async handleClick(event) {
    this.startLoading();

    switch (event.currentTarget.dataset.name) {
      case 'save':
        if (this.refs.notes.value && this.refs.notes.value.trim().length) {
          await createRecord({
            apiName: 'FeedItem',
            fields: {
              ParentId: this.recordId,
              Body: 'Submission comments:\n' + this.refs.notes.value.trim()
            }
          });
        }

        await updateRecord({
          fields: {
            Id: this.recordId,
            INT_Status__c: 'Submitted',
            RecordTypeId: this.recordTypes.INT_EmailDeliveryReadOnly.Id
          }
        });

        let url = await this[NavigationMixin.GenerateUrl]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.recordId,
            actionName: 'view'
          }
        });

        window.location.replace(url);
        break;

      case 'cancel':
        this.dispatchEvent(new CloseActionScreenEvent());

      default:
        break;
    }
  }

  startLoading() {
    this.refs.spinner.classList.remove('slds-hide');
    this.refs.body.classList.add('slds-hide');
  }

  stopLoading() {
    this.refs.spinner.classList.add('slds-hide');
    this.refs.body.classList.remove('slds-hide');
  }
}