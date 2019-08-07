import { Controller } from "stimulus"
import { toggleElement } from "../utils/dom";

export default class extends Controller {
  static targets = [ "maxCandidatesGroup",
                     "maxCandidatesInput",
                     "selectSchoolBlock",
                     "groupNamePublic",
                     "groupNamePrivate",
                     "selectGroupName" ]

  // show/hide group internship custom controls
  toggleInternshipType(event) {
    toggleElement($(this.maxCandidatesGroupTarget))
    if (event.target.id == 'internship_type_true') {
      this.maxCandidatesInputTarget.value = 1
    }
  }

  toggleSelectSchoolBlock(event) {
    toggleElement($(this.selectSchoolBlockTarget))
  }


  handleClickIsPublic(event) {
    const value = $(event.target).val();
    this.toggleGroupNames(value === "true");
  }

  toggleGroupNames(isPublic) {
    if (isPublic) {
      $(this.selectGroupNameTarget).find("option").first().text("-- Veuillez sélectionner une institution --")
      $(this.groupNamePublicTargets).show()
      $(this.groupNamePrivateTargets).hide()
    } else {
      $(this.selectGroupNameTarget).find("option").first().text("-- Indépendant --")
      $(this.groupNamePublicTargets).hide()
      $(this.groupNamePrivateTargets).show()
    }
  }


  connect() {
    this.toggleGroupNames(true);
  }
}
