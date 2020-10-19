import $ from 'jquery';
import { Controller } from 'stimulus';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['checkboxesContainer', 'weekCheckboxes', 'hint'];

  connect() {
    if (this.getForm() === null) {
      return;
    }

    $(this.getForm()).on('submit', this.handleSubmit.bind(this));
  }

  // toggle all weeks options
  handleToggleWeeks(event) {
    if($('#all_year_long').is(":checked")){
      $(".custom-control-checkbox-list").addClass('d-none')
      $(".custom-control-checkbox-list").hide()
    } else {
      $(".custom-control-checkbox-list").hide()
      $(".custom-control-checkbox-list").removeClass('d-none')
      $(".custom-control-checkbox-list").slideDown()
    }

    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop('checked', $(event.target).prop('checked'));
    });
    if(event.target.checked){
       hideElement($(this.checkboxesContainerTarget));
    } else{
      showElement($(this.checkboxesContainerTarget));
    }
  }

  // on week checked
  handleCheckboxesChanges() {
    if (!this.hasAtLeastOneCheckbox()) {
      this.onAtLeastOneWeekSelected();
    } else {
      this.onNoWeekSelected();
    }
  }

  handleSubmit(event) {
    if (this.data.get('skip')) {
      return event;
    }
    if (!this.hasAtLeastOneCheckbox()) {
      this.onAtLeastOneWeekSelected();
    } else {
      this.onNoWeekSelected();
      event.preventDefault();
      return false;
    }
    return event;
  }

  // getters
  getFirstInput() {
    const inputs = this.weekCheckboxesTargets;
    return inputs[0];
  }

  getForm() {
    if (!this.getFirstInput() || !this.getFirstInput().form) {
      return null;
    }
    return this.getFirstInput().form;
  }

  hasAtLeastOneCheckbox() {
    const selectedCheckbox = $(this.weekCheckboxesTargets).filter(':checked');
    return selectedCheckbox.length === 0;
  }

  // ui helpers
  onNoWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);

    showElement($hint);
    $checkboxesContainer.addClass('is-invalid');
  }

  onAtLeastOneWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);

    hideElement($hint);
    $checkboxesContainer.removeClass('is-invalid');
  }
}
