import { Controller } from 'stimulus';
import $ from 'jquery';
import { isMobile } from '../utils/responsive';

const DELAY_BEFORE_REMOVAL = 10000

export default class extends Controller {
  static targets = ['root']

  removeAlert() {
    $(this.rootTarget).slideUp()
  }

  connect(){
    if (isMobile()) {
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
