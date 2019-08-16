import { Controller } from "stimulus"
import { showElement, hideElement } from "../utils/dom";

export default class extends Controller {
  static targets = [ "containerForm",
                     "containerShowFormLink" ]


  showForm(event) {
    showElement($(this.containerFormTarget))
    hideElement($(this.containerShowFormLinkTarget))
  }

  hideForm(event) {
    hideElement($(this.containerFormTarget))
    showElement($(this.containerShowFormLinkTarget))
  }

  connect() {
    if (window.location.hash === '#internship-application-form') {
      this.showForm()
      window.location.hash = '#internship-application-form'
    }
  }
}
