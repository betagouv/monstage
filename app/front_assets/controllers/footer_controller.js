import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['placeholder', 'fixedContent'];

  resize() {
    $(this.placeholderTarget).height($(this.fixedContentTarget).height());
  }

  connect() {
    this.resize();
  }
}
