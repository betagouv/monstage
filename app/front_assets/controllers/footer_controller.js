import $ from 'jquery';
import { Controller } from 'stimulus';
import { hideElement } from '../utils/dom';
export default class extends Controller {
  static targets = ['placeholder', 'fixedContent'];

  close() {
    hideElement($(this.element));
  }

  resize() {
    $(this.placeholderTarget).height($(this.fixedContentTarget).height());
  }

  connect() {
    this.resize();
  }
}
