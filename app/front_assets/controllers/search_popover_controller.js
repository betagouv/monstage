import { Controller } from 'stimulus';
import { isVisible, showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  // on desktop, the week input is popoverable. so their is a caller input
  static targets = [
    'popover',
    'inputPlaceholder',
    'searchByDateContainer',
    'searchSubmitContainer'
  ];

  show(clickEvent) {
    if (clickEvent.currentTarget.readOnly) {
      clickEvent.preventDefault()
      return false;
    }

    const $popover = $(this.popoverTarget);

    $popover.width($(this.searchByDateContainerTarget).width() +
                  $(this.searchSubmitContainerTarget).width())

    showElement($popover);
  }

  hide(clickEvent) {
    hideElement($(this.popoverTarget));
  }
}
