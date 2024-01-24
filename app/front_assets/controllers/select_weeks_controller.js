import $ from 'jquery';
import { Controller } from 'stimulus';
import { fetch } from 'whatwg-fetch';
import { showElement, hideElement } from '../utils/dom';
import { attach, detach, EVENT_LIST } from '../utils/events';
import { endpoints } from '../utils/api';

// @schools [School, School, School]
// return {weekId: [school, ...]}
const mapNumberOfSchoolHavingWeek = (schools) => {
  const weeksSchoolsHash = {};

  $(schools).each((ischool, school) => {
    $(school.weeks).each((iweek, week) => {
      weeksSchoolsHash[week.id] = (weeksSchoolsHash[week.id] || []).concat([school]);
    });
  });
  return weeksSchoolsHash;
};
export default class extends Controller {
  static targets = [
    'checkboxesContainer',
    'weekCheckboxes',
    'hint',
    'inputWeekLegend',
    'legendContainer',
    'submitButton',
  ];
  static values = {
    skipValidation: Boolean
  }

  connect() {
    if (this.getForm() === null) {
      return;
    }

    this.onCoordinatesChangedRef = this.fetchSchoolsNearby.bind(this);
    this.onSubmitRef = this.handleSubmit.bind(this);
    this.onApiSchoolsNearbySuccess = this.showSchoolDensityPerWeek.bind(this);
    this.attachEventListeners();
  }

  weekCheckboxesTargetConnected() {
    this.weekCheckboxesTargets.forEach((el) => {
      el.addEventListener('change', this.handleCheckboxesChanges.bind(this));
    });
    this.handleCheckboxesChanges();
  }

  disconnect() {
    this.detachEventListeners();
  }

  unBubbleUp(event) {
    event.preventDefault();
  }

  attachEventListeners() {
    attach(EVENT_LIST.COORDINATES_CHANGED, this.onCoordinatesChangedRef);
    $(this.getForm()).on('submit', this.onSubmitRef);
  }

  detachEventListeners() {
    detach(EVENT_LIST.COORDINATES_CHANGED, this.onCoordinatesChangedRef);
    $(this.getForm()).off('submit', this.onSubmitRef);
  }

  fetchSchoolsNearby(event) {
    fetch(endpoints.apiSchoolsNearby(event.detail), { method: 'POST' })
      .then((response) => response.json())
      .then(this.onApiSchoolsNearbySuccess);
  }
  handleCheckboxesChanges() {
    if (!this.hasAtLeastOneCheckbox()) {
      this.onAtLeastOneWeekSelected();
    } else {
      this.onNoWeekSelected();
    }
  }

  showSchoolDensityPerWeek(schools) {
    const weeksSchoolsHash = mapNumberOfSchoolHavingWeek(schools);

    $(this.inputWeekLegendTargets).each((i, el) => {
      const weekId = parseInt(el.getAttribute('data-week-id'), 10);
      const schoolCountOnWeek = (weeksSchoolsHash[weekId] || []).length;

      el.innerText = `${schoolCountOnWeek.toString()} etablissement`;
      el.classList.add(function(threshold){
        switch (threshold) {
          case 0:
            return 'bg-dark-70';
          case 1:
            return 'bg-success-20';
          case 2:
            return 'bg-success-30';
          case 4:
            return 'bg-success-40';
          default:
            return 'bg-success';
        }
      }(schoolCountOnWeek))
      el.classList.remove('d-none');

    });
  }

  // toggle all weeks options
  showAllYearLong(event) {
    if ($('#all_year_long').is(':checked')) {
      $('.custom-control-checkbox-list').addClass('d-none');
      $('#specific_weeks').prop( "checked", false);
    } else {
      $('.custom-control-checkbox-list').removeClass('d-none');
    }

    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop('checked', false);
    });
    if (event.target.checked) {
      hideElement($(this.checkboxesContainerTarget));
    } else {
      showElement($(this.checkboxesContainerTarget));
    }
  }

  showSpecificWeeks(event) {
    if ($('#specific_weeks').is(':checked')) {
      $('.custom-control-checkbox-list').removeClass('d-none');
      $('#all_year_long').prop( "checked", false);
    } else {
      $('.custom-control-checkbox-list').addClass('d-none');
    }


    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop('checked', false);
    });
      
    if (event.target.checked) {
      showElement($(this.checkboxesContainerTarget));
    } else {
      hideElement($(this.checkboxesContainerTarget));
    };
    
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
    if (this.skipValidationValue) {
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
    this.submitButtonTarget.disabled = true;

    showElement($hint);
    $checkboxesContainer.addClass('is-invalid');
    try {
      $checkboxesContainer.get(0).scrollIntoView()
    } catch(e) {
      // not supported
    }
  }

  onAtLeastOneWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);
    this.submitButtonTarget.disabled = false;

    hideElement($hint);
    $checkboxesContainer.removeClass('is-invalid');
  }
}
