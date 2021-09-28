import { Controller } from 'stimulus';
import { enableInput, disableInput } from  '../utils/dom';

export default class extends Controller {

  static targets = [
    'schoolTrackInput', // select
    'inputPlaceholder',  // used as 'label/placeholder'
    'searchByDateContainer'
  ]

  connect(){
    this.updateVisibleForm(this.schoolTrackInputTarget.value);
  }

  onSchoolTrackChange(changeEvent){
    this.updateVisibleForm(changeEvent.currentTarget.value);
  }

  updateVisibleForm(value) {
    const $inputPlaceholder = $(this.inputPlaceholderTarget);
    const searchByDateContainer = this.searchByDateContainerTarget
    if (value == 'troisieme_generale') {
      enableInput($inputPlaceholder)
      this.searchByDateContainerTarget.classList.remove('d-none')
      this.searchByDateContainerTarget.classList.remove('d-sm-block')
    } else {
      disableInput($inputPlaceholder)
      this.searchByDateContainerTarget.classList.add('d-none')
      this.searchByDateContainerTarget.classList.add('d-sm-block')
    }
  }
}
