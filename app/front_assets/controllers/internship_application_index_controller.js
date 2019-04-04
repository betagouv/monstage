import { Controller } from "stimulus"
import { toggleElement, isVisible } from "../utils/dom";

export default class extends Controller {
  static targets = [ "collapsible",
                     "linkIconContainer" ]

  toggle() {
    const $collapsibleTarget = $(this.collapsibleTarget);
    const $linkIconContainer = $(this.linkIconContainerTarget);

    toggleElement($collapsibleTarget);
    if (isVisible($collapsibleTarget)) {
      $linkIconContainer.html(`<i class="fas fa-chevron-right"></i>`)
    } else {
      $linkIconContainer.html(`<i class="fas fa-chevron-down"></i>`)
    }
  }
}
