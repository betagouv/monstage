import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['label'];
  static values = {
    for: String,
    enable: Boolean,
  };

  forElement(){
    return document.getElementById(this.forValue);
  }
  focusTrixInput(event) {
    this.forElement().focus();

    return event;
  }

  connect(){
    this.refOnClick = this.focusTrixInput.bind(this);
    this.element.addEventListener('click', this.refOnClick)
  }

  initialize(){
    if (this.enableValue !== null) {
      this.forElement().contentEditable = this.enableValue;
    }
  }

  disconnect(){
    this.element.removeEventListener('click', this.refOnClick)
  }
}
