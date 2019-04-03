import { Controller } from "stimulus"
export const toggleElement = ($element) => $element.toggleClass('d-none');
import "../utils/bootstrap-maxlength"

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

  connect() {
    ['#internship_offer_description', '#internship_offer_employer_description'].forEach(function(field) {
      $(field).maxlength({
        alwaysShow: true,
        warningClass: "form-text text-muted mt-1", //it's the class of the element with the indicator. By default is the bootstrap "badge badge-success" but can be changed to anything you'd like.
        limitReachedClass: "form-text text-danger mt-1", //it's the class the element gets when the limit is reached. Default is "badge badge-danger". Replace with text-danger if you want it to be red.
        //separator: ' of ', //represents the separator between the number of typed chars and total number of available chars. Default is "/".
        placement: 'bottom-right-inside', //is a string, object, or function, to define where to output the counter. Possible string values are: bottom ( default option ), left, top, right, bottom-right, top-right, top-left, bottom-left and centered-right. Are also available : **bottom-right-inside** (like in Google's material design, **top-right-inside**, **top-left-inside** and **bottom-left-inside**. stom placements can be passed as an object, with keys top, right, bottom, left, and position.
      })
    })
  }
}
