import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [
    'schoolTrackInput',
    'inputPlaceholder',
    'dateContainer'
    ]

  connect(){
    this.updateVisibleForm(this.schoolTrackInputTarget.value);
  }

  onChange(changeEvent){
    this.updateVisibleForm(changeEvent.currentTarget.value);
  }

  updateVisibleForm(value) {
    const $inputPlaceholder = $(this.inputPlaceholderTarget);
    const $dateContainer = $(this.dateContainerTarget)
    if (value == 'troisieme_generale') {
      $inputPlaceholder.attr('readonly', false).attr('disabled', false);
      $dateContainer.removeClass('d-none').addClass('d-md-block')
    } else {
      $inputPlaceholder.attr('readonly', 'readonly').attr('disabled', 'disabled');
      $dateContainer.addClass('d-none').removeClass('d-md-block');
    }
  }
}
