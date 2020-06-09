import { Controller } from 'stimulus';
import $ from 'jquery';
import findBootstrapEnvironment from '../utils/responsive';

const DELAY_BEFORE_REMOVAL = 10000

export default class extends Controller {
  static targets = ['root']

  removeAlert() {
    $(this.rootTarget).slideUp()
  }

  connect(){
    if (findBootstrapEnvironment() == 'xs') {
      this.timeout = setTimeout(this.removeAlert.bind(this),
                                DELAY_BEFORE_REMOVAL)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}
