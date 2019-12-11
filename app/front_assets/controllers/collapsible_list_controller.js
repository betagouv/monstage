import $ from 'jquery';
import { Controller } from 'stimulus';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['hiddenElement', 'showMoreButton', 'lastVisibleElement'];

  showMore(event) {
    $(this.element)
      .find('.last-visible')
      .removeClass('last-visible');
    hideElement($(this.showMoreButtonTarget));
    $(this.hiddenElementTargets).each((i, el) => {
      showElement($(el));
    });
    event.preventDefault();
  }
}
