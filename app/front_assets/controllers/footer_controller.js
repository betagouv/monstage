import $ from 'jquery';
import { Controller } from 'stimulus';
import { hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['placeholder', 'fixedContent'];

  close() {
    hideElement($(this.fixedContentTarget));
    this.resize();
    localStorage.setItem('fixedFooterShown', true);
  }

  resize() {
    $(this.placeholderTarget).height($(this.fixedContentTarget).height());
  }

  connect() {
    this.resize();

    if (!localStorage.getItem('fixedFooterShown')) {
      this.fixedContentTarget.classList.remove('d-none');
    }
  }
}
