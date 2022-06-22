import { Controller } from "@hotwired/stimulus";
import { getParamValueFromUrl } from '../utils/urls'

export default class extends Controller {
  static targets = ['button'];

  //builtin function see : https://stimulus.hotwired.dev/reference/lifecycle-callbacks
  buttonTargetConnected() {
    if (getParamValueFromUrl('opened_modal') === 'true') {
      this.buttonTarget.setAttribute('data-fr-opened', 'true');
    }
  }
}
