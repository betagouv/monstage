import $ from 'jquery';
import { Controller } from 'stimulus';
import Turbolinks from 'turbolinks';

export default class extends Controller {
  static targets = ['hiddenButton', 'fakeButton'];

  selectStudentClassRoom() {
    const fakeButton = this.fakeButtonTarget;
    $(fakeButton).prop("disabled", false); 
  }

  clickFakeButton(event) {
    event.preventDefault();
    const hiddenButton = this.hiddenButtonTarget;
    $(hiddenButton).click();
  }
}
