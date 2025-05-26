import { LightningElement, api, wire } from 'lwc';
import fileUploadWizard from 'c/intFileUploadWizard';

export default class IntEditFileUploadAction extends LightningElement {
    @api recordId;

    @api invoke() {
        fileUploadWizard.open({
            size: 'medium',
            description: 'Wizard',
            recordId : this.recordId,
            action: 'Edit',
            label: 'Edit Design Files'
          });
    }

}