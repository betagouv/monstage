import $ from 'jquery';
import { Controller } from 'stimulus';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['displayButton', 'hideButton'];

  toggleToolnote() {
    $('.tool-note').toggleClass('d-none');
    $(this.displayButtonTarget).toggleClass('d-none');
    $(this.hideButtonTarget).toggleClass('d-none');
  }
}
