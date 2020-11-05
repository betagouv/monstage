import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['confirmationCheck', 'agreementValidationButton', 'displayButton', 'hideButton'];
  initialize(){
    this.mustBeChecked()
  }

  mustBeChecked() {
    let is_disabled = false
    this.confirmationCheckTargets.forEach((el) => {
      if (!($(el).is(":checked"))) { is_disabled = true ; return }
    })

    const submitButton = this.agreementValidationButtonTarget;
    $(submitButton).prop("disabled", is_disabled)
  }

  toggleToolnote() {
    $('.tool-note').toggleClass('d-none');
    $(this.displayButtonTarget).toggleClass('d-none');
    $(this.hideButtonTarget).toggleClass('d-none');
  }

  checkRequiredField(event) {
    if (event.target.value == '') {
      event.target.parentElement.classList.remove('valid-form-field')
      event.target.parentElement.classList.add('required-form-field')
    } else {
      event.target.parentElement.classList.remove('required-form-field')
      event.target.parentElement.classList.add('valid-form-field')
    }
  }
}
