import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'input' ]

  connect(){
    console.log('connected checkboxes')

    if (this.inputTarget.checked) {
       this.inputTarget.parentNode.classList.add('active')
    }
  }

  onChange(changeEvent){
    if (this.inputTarget.checked) {
      this.inputTarget.parentNode.classList.add('active')
    } else {
      this.inputTarget.parentNode.classList.remove('active')
    }
  }
}
