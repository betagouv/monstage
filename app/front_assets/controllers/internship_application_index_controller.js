import $ from 'jquery';
import { Controller } from 'stimulus';
import { toggleElement, hideElement, isVisible } from '../utils/dom';

export default class extends Controller {
  static targets = ['collapsible', 'linkIconContainer', 'motivation', 'linkTextShowMore'];

  connect(){
    const $collapsibleTarget = $(this.collapsibleTarget);
    const $linkTextShowMore = $(this.linkTextShowMoreTarget);
    const $linkIconContainer = $(this.linkIconContainerTarget);
    hideElement($collapsibleTarget);
    $linkIconContainer.html(`<i class="fas fa-2x fa-caret-right just-red"></i>`);
    toggleElement($linkTextShowMore);
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
