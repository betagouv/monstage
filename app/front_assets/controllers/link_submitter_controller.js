import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ["link"];

  connect() { }

  submit(event) {
    const elem = this.linkTarget;
    elem.closest('form').submit();
  }

}
