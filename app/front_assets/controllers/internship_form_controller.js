import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "maxCandidatesGroup",
                     "selectWeeks" ]

  // show/hide group internship custom controls
  toggleCanBeAppliedSection(event) {
    $(this.maxCandidatesGroupTarget).toggleClass('d-none');
  }

  // show/hide div next of element
  toggleClosestHelpSign(event) {
    $(event.target).next().toggleClass('d-none');
  }

  // toggle all weeks options
  toggleWeeks(event) {
    $(this.selectWeeksTarget).find("option").each((i, el) => {
      $(el).prop('selected', $(event.target).prop('checked'))
    })
  }

}
