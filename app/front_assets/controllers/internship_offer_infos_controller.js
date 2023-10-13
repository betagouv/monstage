import { Controller } from 'stimulus';
import $ from 'jquery';

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
    submitButton.disabled = false;

    for (var requiredField of requiredFields) {      
      if (requiredField.value === '') {
        submitButton.disabled = true;
        return;
      }
    }
    
  }

  connect() {
    this.checkForm();
  }

  disconnect() {}
}
