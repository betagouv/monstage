import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'input' ]

  connect(){
    this.inputTargets.map((element) => {
      if (element.checked) {
         element.parentNode.classList.add('active')
      }
    })
  }

  onChange(changeEvent){
    const currentTarget = changeEvent.currentTarget
    this.inputTargets.map((element) => {
      if (element == currentTarget) {
        element.parentNode.classList.add('active')
      } else {
        element.parentNode.classList.remove('active')
      }
    })

  }
}
