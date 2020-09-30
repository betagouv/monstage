import $ from 'jquery';
import { Controller } from 'stimulus';
import { toggleElement, hideElement, showElement, isVisible } from '../utils/dom';

export default class extends Controller {
  static targets = ['collapsible', 'linkIconContainer', 'motivation', 'linkTextShowMore'];

  initialize(){
    const $collapsibleTarget = $(this.collapsibleTarget);
    const $linkIconContainer = $(this.linkIconContainerTarget);
    const $linkTextShowMore = $(this.linkTextShowMoreTarget);
    hideElement($collapsibleTarget);
    showElement($linkTextShowMore);
    $(this.motivationTarget).addClass('text-truncate-max-height-50');
    $linkIconContainer.html(`<i class="fas fa-2x fa-caret-right just-red"></i>`);
  }

  toggle() {
    const $collapsibleTarget = $(this.collapsibleTarget);
    const $linkIconContainer = $(this.linkIconContainerTarget);
    const $linkTextShowMore = $(this.linkTextShowMoreTarget);
    toggleElement($collapsibleTarget);
    toggleElement($linkTextShowMore);
    $(this.motivationTarget).toggleClass('text-truncate-max-height-50');
    if (isVisible($collapsibleTarget)) {
      $linkIconContainer.html(`<i class="fas fa-2x fa-caret-down just-red"></i>`);
    } else {
      $linkIconContainer.html(`<i class="fas fa-2x fa-caret-right just-red"></i>`);
    }
  }
}
