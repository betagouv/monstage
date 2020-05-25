import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['label'];

  focusTrixInput(event) {
    document.getElementById(this.element.getAttribute('for'))
            .focus();

    return event;
  }
  connect(){
    this.element.addEventListener('click', this.focusTrixInput.bind(this))
  }
  disconnect(){
    this.element.removeEventListener('click', this.focusTrixInput.bind(this))
  }
}
