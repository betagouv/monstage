import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['confirmation'];

  connect() {
    // debugger;
    this.confirmationTarget.classList.add('d-none');
  }
}