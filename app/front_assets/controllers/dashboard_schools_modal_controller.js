import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  openModal() {
    $('#notice-school-manager-empty-weeks').modal('show');
  }

  connect() {
    setTimeout(() => {
      this.openModal();
    }, 100);
  }
}
