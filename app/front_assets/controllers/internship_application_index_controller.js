import $ from 'jquery';
import { Controller } from 'stimulus';
import { toggleElement, hideElement, showElement, isVisible } from '../utils/dom';

export default class extends Controller {
  static targets = ['collapsible', 'linkIconContainer', 'motivation', 'linkTextShowMore'];

  klassRight() { return ("fr-icon--lg fr-icon-arrow-right-s-line text-danger"); }
  klassDown() { return ("fr-fi--lg fr-icon-arrow-down-s-line text-danger"); }

  initialize(){
    $(this.linkIconContainerTarget).html(`<span aria-hidden="true" class="${this.klassRight()}"></span>`);
    $(this.motivationTarget).addClass('text-truncate-max-height-50');
    hideElement($(this.collapsibleTarget));
    showElement($(this.linkTextShowMoreTarget));
  }

  toggle() {
    const $collapsibleTarget = $(this.collapsibleTarget);
    const $linkIconContainer = $(this.linkIconContainerTarget);
    const $linkTextShowMore = $(this.linkTextShowMoreTarget);
    toggleElement($collapsibleTarget);
    toggleElement($linkTextShowMore);
    $(this.motivationTarget).toggleClass('text-truncate-max-height-50');
    if (isVisible($collapsibleTarget)) {
      $linkIconContainer.html(`<span class="${this.klassDown()}"></span>`); 
    } else {
      $linkIconContainer.html(`<span class="${this.klassRight()}"></span>`);
    }
  }
}
