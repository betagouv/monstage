import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'border', 'option' ]

  connect(){
    console.log('hello')
    this.optionTarget.checked = false
  }

  onCheck(e){
    debugger
    e.preventDefault();
    this.borderTarget.classList.toggle('active')
  }
}
