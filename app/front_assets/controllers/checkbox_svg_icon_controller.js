import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'border', 'option' ]

  connect(){
    this.optionTarget.checked = false
  }

  onCheck(e){
    e.preventDefault();
    this.borderTarget.classList.toggle('active')
  }
}
