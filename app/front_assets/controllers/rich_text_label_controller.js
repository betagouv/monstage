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
   this.enableTrixInput(this.data.get('enable'))
  }
  disconnect(){
    this.element.removeEventListener('click', this.refOnClick)
  }
}
