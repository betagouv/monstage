import $ from 'jquery';
import { Controller } from 'stimulus';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'checkboxesContainer',
    'weekCheckboxes',
    'hint',
    'yearCheckBox'
  ];

  connect() {
    if (this.getForm() === null) {
      return;
    }

    $(this.getForm()).on('submit', this.handleSubmit.bind(this));

    $(this.yearCheckBoxTarget).prop("checked", true);
    hideElement($(this.checkboxesContainerTarget))
  }

  // toggle all weeks options
  handleToggleWeeks(event) {
    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop('checked', $(event.target).prop('checked'));
    });

    const container = $(this.checkboxesContainerTarget);
    if($(event.target).prop('checked')) { hideElement(container) }
    else { showElement(container); }

    $(this.yearCheckBoxTarget).focus({preventScroll:false});
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
