import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [ 'displayButton', 'hideButton' ];

  toggleToolnote() {
    $('.tool-note').toggleClass('invisible');
    $(this.displayButtonTarget).toggleClass('d-none');
    $(this.hideButtonTarget).toggleClass('d-none');
  }



}
