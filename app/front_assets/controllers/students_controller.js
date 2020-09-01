import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['fakeButton'];

  selectStudentClassRoom() {
    const fakeButton = this.fakeButtonTarget;
    $(fakeButton).prop("disabled", false);
  }
}
