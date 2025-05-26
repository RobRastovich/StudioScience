import { LightningElement } from 'lwc';
import newEmailDeliveryWizard from 'c/intNewEmailDeliveryWizard';

export default class IntPortalHomeActions extends LightningElement {
  handleClick(event) {
    switch (event.currentTarget.dataset.name) {
      case 'new':
        newEmailDeliveryWizard.open({
          size: 'medium',
          description: 'Wizard',
          label: 'My Label'
        });
        break;
      default:
        break;
    }
  }
}