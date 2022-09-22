import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['confirmation'];

  connect() {
    this.confirmationTarget.classList.add('d-none');
  }
}