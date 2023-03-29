import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'checkToggle'
  ];
  toggle(e) {
    this.checkToggleTarget.closest('form').submit();
  }
}