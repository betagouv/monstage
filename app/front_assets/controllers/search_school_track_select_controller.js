import { Controller } from 'stimulus';
import { enableInput, disableInput } from  '../utils/dom';

export default class extends Controller {

  static targets = [
    'schoolTrackInput', // select
    'inputPlaceholder'  // used as 'label/placeholder'
    ]

  connect(){
    this.updateVisibleForm(this.schoolTrackInputTarget.value);
  }

  onSchoolTrackChange(changeEvent){
    this.updateVisibleForm(changeEvent.currentTarget.value);
  }

  updateVisibleForm(value) {
    const $inputPlaceholder = $(this.inputPlaceholderTarget);
    if (value == 'troisieme_generale') {
      enableInput($inputPlaceholder)
    } else {
      disableInput($inputPlaceholder)
    }
  }
}
