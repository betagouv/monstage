import $ from 'jquery';
import { Controller } from 'stimulus';
import isMobile from '../utils/responsive';

const DELAY_BEFORE_DEPLOYING = 400;

export default class extends Controller {
  static targets = ['hamburger', 'menu', 'subscription'];

  clickOnHamburger() {
    if (isMobile()) {
      // this.hamburgerTarget.classList.remove('collapsed');
      // $(this.hamburgerTarget).attr('aria-expanded', true);
      // this.menuTarget.classList.add('show');
      // document.getElementById("subscription-hamburger").focus();
    }
  }

  connect() {
    this.timeout = setTimeout(this.clickOnHamburger.bind(this), DELAY_BEFORE_DEPLOYING);
  }
  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}