import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'requiredField',
    'submitButton'
  ];

  validateForm(event) {
    const latitudeInput = document.getElementById('internship_offer_coordinates_latitude');
    if (!latitudeInput.validity.valid) {
      document.getElementById('js-internship_offer_autocomplete').focus();
    }
    return event;
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
    // this.element.addEventListener('submit', this.validateForm, false);
    setTimeout( () => {
      this.checkForm();
    }, 100);
  }

  disconnect() {}
}
