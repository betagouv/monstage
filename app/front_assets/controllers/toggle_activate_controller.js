import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'checkToggle'
  ];
  toggle(e) {
    e.preventDefault();
    e.stopPropagation();
    this.checkToggleTarget.closest('form').submit();
  }
}