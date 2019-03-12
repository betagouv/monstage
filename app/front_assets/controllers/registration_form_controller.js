import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "emailLabel" ];

  changeEmailLabel(event) {
    let userType = event.target.options[event.target.selectedIndex].value;

    this.emailLabelTarget.textContent = (userType === 'SchoolManager') ? 'Courriel professionnel' : 'Courriel'
  }

}
