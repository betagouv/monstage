import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'checkToggle'
  ];
  
  toggle(e) {
    e.preventDefault();
    if (e.params['type'] == 'form') {
      this.checkToggleTarget.closest('form').submit();
    }
  }
}