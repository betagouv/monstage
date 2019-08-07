import { Controller } from "stimulus"
import { toggleElement } from "../utils/dom";

export default class extends Controller {
  static targets = [ "weekCheckboxes" ]

  // toggle all weeks options
  toggleWeeks(event) {
    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop('checked', $(event.target).prop('checked'))
    })
  }
}
