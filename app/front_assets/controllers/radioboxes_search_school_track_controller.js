import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [
    'schoolTrackInput',
    'tabPane',
    'searchByDateContainer' ,
    'desktopPlaceholder'
    ]

  connect(){
    this.updateVisibleForm(this.schoolTrackInputTarget.value);
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
}
