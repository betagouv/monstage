import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [
    'input',
    'tabPane',
    'searchByDateContainer' ,
    ]

  connect(){
    this.updateVisibleForm(this.inputTarget.value);
  }

  onChange(changeEvent){
    this.updateVisibleForm(changeEvent.currentTarget.value);
  }

  updateVisibleForm(value) {
    if (value == 'troisieme_generale') {
      this.searchByDateContainerTarget.classList.remove('d-none')
    } else {
      this.searchByDateContainerTarget.classList.add('d-none')
    }
  }

  clear(clickEvent) {

  }
}
