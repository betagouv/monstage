import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'requiredField',
    'submitButton'
  ];
  static values = {
    baseType: String
  }

  checkForm() {
    console.log('checkForm');
    const requiredFields = this.requiredFieldTargets;
    const submitButton = this.submitButtonTarget;

    requiredFields.forEach(field => {
      field.addEventListener('input', () => {
        for (const requiredField of requiredFields) {
          if (requiredField.value === '') {
            submitButton.disabled = true;
            return;
          }
        }
        submitButton.disabled = false;
      });
    });
  }

  connect() {
    console.log('internship_offer_infos_controller');
    this.checkForm();
  }

  disconnect() {}
}
