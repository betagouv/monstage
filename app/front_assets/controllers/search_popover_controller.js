import { Controller } from 'stimulus';
import { isVisible, showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  // on desktop, the week input is popoverable. so their is a caller input
  static targets = [
    'popover',

    'searchByDateContainer',
    'searchSubmitContainer'
  ];

  show(clickEvent) {
    const $popover = $(this.popoverTarget);

    $popover.width($(this.searchByDateContainerTarget).width() +
                  $(this.searchSubmitContainerTarget).width())

    showElement($popover);
  }

  hide(clickEvent) {
    hideElement($(this.popoverTarget));
  }
}
