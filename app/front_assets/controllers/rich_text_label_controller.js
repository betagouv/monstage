import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['label'];
  static values = {
    for: String,
    enable: Boolean,
  };
  forElement(){
    return document.getElementById(this.forvalue);
  }
  focusTrixInput(event) {
    this.forElement().focus();

    return event;
  }
  enableTrixInput(bool){
    this.forElement().contentEditable = bool
  }

  connect(){
    this.refOnClick = this.focusTrixInput.bind(this);
    this.element.addEventListener('click', this.refOnClick)
  }
  initialize(){
    if (this.enableValue !== null) {
      this.enableTrixInput()
    }
  }
  disconnect(){
    this.element.removeEventListener('click', this.refOnClick)
  }
}
