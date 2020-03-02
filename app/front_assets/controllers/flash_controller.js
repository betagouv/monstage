import { Controller } from 'stimulus';
import $ from 'jquery';

function findBootstrapEnvironment() {
  let envs = ['xs', 'sm', 'md', 'lg', 'xl'];
  let el = document.createElement('div');
  document.body.appendChild(el);

  let curEnv = envs.shift();

  for (let env of envs.reverse()) {
      el.classList.add(`d-${env}-none`);

      if (window.getComputedStyle(el).display === 'none') {
          curEnv = env;
          break;
      }
  }

  document.body.removeChild(el);
  return curEnv;
}

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
