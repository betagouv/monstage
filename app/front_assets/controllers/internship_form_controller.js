import { Controller } from "stimulus"
import { toggleElement } from "../utils/dom"
export default class extends Controller {
  static targets = [ "maxCandidatesGroup",
                     "selectWeeks" ]

  // show/hide group internship custom controls
  toggleCanBeAppliedSection(event) {
    toggleElement($(this.maxCandidatesGroupTarget))
  }

  // show/hide div next of element
  toggleClosestHelpSign(event) {
    toggleElement($(event.target).next())
  }

  // toggle all weeks options
  toggleWeeks(event) {
    $(this.selectWeeksTarget).find("option").each((i, el) => {
      $(el).prop('selected', $(event.target).prop('checked'))
    })
  }

}
