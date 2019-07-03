import { Controller } from "stimulus"
import { hideElement, showElement } from "../utils/dom";
export default class extends Controller {
  static targets = [ 'container' ];

  toggle() {
    $(this.containerTarget).toggleClass('feedback-form-open')
  }
}
