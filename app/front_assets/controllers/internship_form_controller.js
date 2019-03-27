import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "maxCandidatesGroup",
                     "maxCandidatesInput",
                     "selectWeeks" ]

  // show/hide group internship custom controls
  toggleInternshipType(event) {
    toggleElement($(this.maxCandidatesGroupTarget))
    if (event.target.id == 'internship_type_true') {
      this.maxCandidatesInputTarget.value = 1
    }
  }

  // toggle all weeks options
  toggleWeeks(event) {
    $(this.selectWeeksTarget).find("option").each((i, el) => {
      $(el).prop('selected', $(event.target).prop('checked'))
    })
  }

}
