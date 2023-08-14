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
    this.checkForm();
  }

  disconnect() {}
}
