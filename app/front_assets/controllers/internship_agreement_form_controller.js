import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [ 'displayButton', 'hideButton' ];

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

  checkRequiredTrixField(event) {
    if (event.target.innerText < 2) {
      event.target.classList.remove('valid-form-field')
      event.target.classList.add('required-form-field')
    } else {
      event.target.classList.remove('required-form-field')
      event.target.classList.add('valid-form-field')
    }
  }
}
