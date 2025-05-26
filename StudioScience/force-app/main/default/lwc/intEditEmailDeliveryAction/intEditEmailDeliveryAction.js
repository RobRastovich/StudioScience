import { LightningElement, api, wire } from 'lwc';
import editEmailDeliveryWizard from 'c/intEditEmailDeliveryWizard';

export default class IntEditEmailDeliveryAction extends LightningElement {
    @api recordId;

    @api invoke() {
        editEmailDeliveryWizard.open({
            size: 'medium',
            description: 'Wizard',
            recordId : this.recordId,
            label: 'Edit Email Delivery'
          });
    }

}