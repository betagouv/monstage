import { Controller } from "stimulus"
import { toggleElement } from "../utils/dom"


export default class extends Controller {
  static targets = [ "maxCandidatesGroup",
                     "selectWeeks",
                     "allYearLong" ]

  // show/hide group internship custom controls
  toggleCanBeAppliedSection(event) {
    toggleElement(this.maxCandidatesGroupTarget)
  }

  // toggle all weeks options
  toggleWeeks(event) {
    Array.from(this.selectWeeksTarget.children).forEach((option) => {
      option.selected = this.allYearLongTarget.checked
    })
  }

}
