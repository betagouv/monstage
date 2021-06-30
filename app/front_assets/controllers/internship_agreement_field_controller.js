import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [ 'field', 'helper' ];

  checkRequiredField(event) {
    if (event.target.value == '') {
      $(this.helperTarget).attr("class", "required-form-field input-helper")
    } else {
      $(this.helperTarget).attr("class", "valid-form-field input-helper")
    }
  }

  checkRequiredTrixField(event) {
    if (event.target.innerText < 2) {
      $(this.helperTarget).attr("class", "required-form-field input-helper")
    } else {
      $(this.helperTarget).attr("class", "valid-form-field input-helper")
    }
  }
}
