import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['submitButton'];

  selectStudentClassRoom() {
    const submitButton = this.submitButtonTarget;
    $(submitButton).prop("disabled", false);
  }
}
