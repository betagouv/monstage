import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'requiredField',
    'submitButton',
    'trixElementCharCount',
    'maxLengthMessage'
  ];
  static values = {
    baseType: String,
    limit: Number
  }

  checkForm() {
    console.log('checkForm');
    console.log(this.requiredFieldTargets);
    console.log(this.limitValue);

    const requiredFields = this.requiredFieldTargets;
    console.log(document.querySelector('[data-internship-offer-infos-target="submitButton"]'));
    console.log(document.querySelector('[data-internship-offer-infos-target="submitButton"]'));

    const submitButton = this.submitButtonTarget;
    submitButton.disabled = false;

    for (var requiredField of requiredFields) {      
      if (requiredField.value === '') {
        submitButton.disabled = true;
        return;
      }
    }
    
  }

  checkMaxLength(event) {
    console.log('checkMaxLength');
    console.log('max value : ' + this.limitValue);
    this.updateCharCount();

    const maxLength = this.limitValue;
    const currentLength = this.requiredFieldTarget.value.length;
    this.trixElementCharCountTarget.textContent = `${currentLength} / ${maxLength} caractères`;

    if (currentLength > maxLength) {
      this.maxLengthMessageTarget.classList.remove("d-none");
      this.trixElementCharCountTarget.classList.add('text-danger');
      this.trixElementCharCountTarget.value = this.trixElementCharCountTarget.value.substring(0, maxLength);
    } else {
      this.maxLengthMessageTarget.classList.add("d-none");
      this.trixElementCharCountTarget.classList.remove('text-danger');
    }
  }

  updateCharCount() {
    const maxLength = parseInt(this.data.get("limit-value"));
    const currentLength = this.requiredFieldTarget.value.length;
    this.trixElementCharCountTarget.textContent = `${currentLength} / ${maxLength} caractères`;
  }


  connect() {
    console.log('connected connexion');
    this.checkForm();
    // this.updateCharCount();
  }

  disconnect() {}
}
