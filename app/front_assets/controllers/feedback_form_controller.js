import { Controller } from "stimulus"
import { hideElement, showElement } from "../utils/dom";

export default class extends Controller {
  static targets = [ "callToAction",
                     "formContent" ];

  toggle() {
    $(this.element).toggleClass('feedback-form-open')
  }

  connect() {
  }


}
