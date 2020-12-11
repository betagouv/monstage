import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['label'];

  forElement(){
    return document.getElementById(this.data.get('for'))
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
    if (this.data.get('enable') !== null) {
      this.enableTrixInput()
    }
  }
  disconnect(){
    this.element.removeEventListener('click', this.refOnClick)
  }
}
