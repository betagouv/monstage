import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = ['confirmationCheck', 'agreementValidationButton'];
  initialize(){
    this.mustBeChecked()
  }

  mustBeChecked() {
    let is_disabled = false
    this.confirmationCheckTargets.forEach((el) => {
      if (!($(el).is(":checked"))) { is_disabled = true ; return }
    })

    const submitButton = this.agreementValidationButtonTarget;
    $(submitButton).prop("disabled", is_disabled)
  }
}
