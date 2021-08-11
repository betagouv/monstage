import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'input', 'searchByDateContainer' ]

  connect(){
    this.inputTargets.map((element) => {
      if (element.checked) {
         element.parentNode.classList.add('active')
      }

      if (element.checked && element.value == 'troisieme_generale') {
        this.searchByDateContainerTarget.classList.remove('d-none')
      } else {
        this.searchByDateContainerTarget.classList.add('d-none')
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

    if (currentTarget.checked && currentTarget.value == 'troisieme_generale') {
      this.searchByDateContainerTarget.classList.remove('d-none')
    } else {
      this.searchByDateContainerTarget.classList.add('d-none')
    }
  }
}
