import { Controller } from 'stimulus';
import { isVisible, hideElement, showElement } from '../utils/dom';

export default class extends Controller {

  static targets = [
    "tabPane", // multiple targets to navigate weeks selection // months
  ];

  navigate(clickEvent) {
    const currentTarget = clickEvent.currentTarget;
    const href = new URL(currentTarget.href);
    const target = href.hash.replace(/#/, '');

    this.tabPaneTargets.map(( element) => {
      const $el = $(element)

      if (element.id == target) {
        showElement($el)
      } else if (isVisible($el)) {
        hideElement($el)
      } else {
        // no op, hidden element stays hidden
      }
    })
    clickEvent.preventDefault();
  }
}
