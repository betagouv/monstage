import { Controller } from "stimulus"
import { toggleElement, hideElement, isVisible } from "../utils/dom";

export default class extends Controller {
  static targets = [ "collapsible",
                     "linkIconContainer",
                     "motivation",
                     "linkTextShowMore" ]

  toggle() {
    const $collapsibleTarget = $(this.collapsibleTarget);
    const $linkIconContainer = $(this.linkIconContainerTarget);
    const $linkTextShowMore = $(this.linkTextShowMoreTarget);
    toggleElement($collapsibleTarget);
    toggleElement($linkTextShowMore);
    $(this.motivationTarget).toggleClass('text-truncate-max-height-50')
    if (isVisible($collapsibleTarget)) {
      $linkIconContainer.html(`<i class="fas fa-2x fa-chevron-down"></i>`)
    } else {
      $linkIconContainer.html(`<i class="fas fa-2x fa-chevron-right"></i>`)
    }
  }
}
