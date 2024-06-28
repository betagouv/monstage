import { Controller } from 'stimulus';
import { checkPasswordCommon } from '../utils/events';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'requiredField',
    'submitButton',
    'passwordHint',
    'passwordInput',
    'length',
    'uppercase',
    'lowercase',
    'special',
    'number',
  ];

  checkForm() {
    const requiredField = this.requiredFieldTarget;
    const submitButton  = this.submitButtonTarget;
    const passwordInput = this.passwordInputTarget;
    let oneEmptyFieldAtLeast = false;
    if (requiredField.value === '' || passwordInput.value === '') {
      oneEmptyFieldAtLeast = true;
    }
    submitButton.disabled = oneEmptyFieldAtLeast;
  }

  checkPassword() {
    const passwordHintElement        = this.passwordHintTarget;
    const passwordInputTargetElement = this.passwordInputTarget;
    const submitButton               = this.submitButtonTarget;
    const $hint = $(passwordHintElement);
    const $input = $(passwordInputTargetElement);
    if (passwordInputTargetElement.value.length === 0) {
      $input.attr('class', 'form-control');
      $hint.attr('class', 'text-muted');
      passwordHintElement.innerText = '(6 caractères au moins)';
      submitButton.disabled = true;
    } else if (passwordInputTargetElement.value.length < 6) {
      $input.attr('class', 'form-control is-invalid');
      $hint.attr('class', 'invalid-feedback');
      passwordHintElement.innerText = '6 caractères minimum sont attendus';
      submitButton.disabled = true;
    } else {
      $input.attr('class', 'form-control is-valid');
      $hint.attr('class', 'd-none');
      submitButton.disabled = false;
    }
  }

  checkFullPassword() {
    const password = this.passwordInputTarget.value;

    this.lengthTarget.style.color = password.length >= 12 ? "green" : "red"
    this.uppercaseTarget.style.color = /[A-Z]/.test(password) ? "green" : "red"
    this.lowercaseTarget.style.color = /[a-z]/.test(password) ? "green" : "red"
    this.numberTarget.style.color = /[0-9]/.test(password) ? "green" : "red"
    this.specialTarget.style.color = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/.test(password) ? "green" : "red"
  }


  requiredFieldTargetConnected() {
    this.checkForm();
    this.submitButtonTarget.disabled = true;
  }
}
