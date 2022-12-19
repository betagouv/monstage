import { Controller } from 'stimulus';
import { enableInput, disableInput } from  '../utils/dom';

export default class extends Controller {

  static targets = [
    'dateInput', // select
    'inputPlaceholder',  // used as 'label/placeholder'
    'searchByDateContainer'
  ]

  connect() {
    const $inputPlaceholder = $(this.inputPlaceholderTarget);
    enableInput($inputPlaceholder)
    this.searchByDateContainerTarget.classList.remove('d-none')
    this.searchByDateContainerTarget.classList.remove('d-sm-block')
  }
}
