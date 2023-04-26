import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['modalRoot'];

  openModal() {
    $(this.modalRootTarget).modal('show');
  }
}