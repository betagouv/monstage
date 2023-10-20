import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'checkToggle', 'form'
  ];
  toggle(e) {
    e.preventDefault();
    e.stopPropagation();
    // this.formTarget.submit();
    this.checkToggleTarget.closest('form').submit();
  }
}