import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'alert'
  ];
  removeAlert(e) {
    this.alertTargets.forEach((alert) => {
      alert.classList.add('d-none');
    });
  }
  alertTargetConnected(e) {
  }
}