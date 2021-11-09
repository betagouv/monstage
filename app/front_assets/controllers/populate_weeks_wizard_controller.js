import $ from 'jquery';
import {
  Controller
} from 'stimulus';
import {
  showElement,
  hideElement
} from '../utils/dom';

export default class extends Controller {
  static targets = [
    'studentsMaxGroupInput',
    'maxCandidatesInput',
    'type',
    'allYearLong',
    'weekCheckboxes',
    'hintWizard',
    'collectiveButton',
    'individualButton'
  ];

  handleCheckboxesChanges() {
    const weeklyTypes = [
      'InternshipOfferInfos::WeeklyFramed',
      'InternshipOffers::WeeklyFramed'
    ];
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    (maxCandidates === 1) ? this.collectiveOptionInhibit(true) : this.collectiveOptionInhibit(false);

    if (weeklyTypes.indexOf(this.typeTarget.value) == -1) {
      return;
    }

    const activatedWeeksCount = (this.allYearLongTarget.checked) ? this.weekCheckboxesTargets.length : this.countWeeks();
    this.messaging(this.remainingWeeksToAdd(activatedWeeksCount));
  }

  countWeeks() {
    let activatedWeeks = 0
    $(this.weekCheckboxesTargets).each((i, el) => {
      if (el.checked) {
        activatedWeeks += 1;
      }
    });
    return activatedWeeks;
  }

  remainingWeeksToAdd(activatedCount) {
    const total = parseInt(this.maxCandidatesInputTarget.value, 10);
    const groupSize = parseInt(this.studentsMaxGroupInputTarget.value, 10);
    return Math.ceil(total / groupSize) - activatedCount;
  }

  messaging(remaining) {
    if (remaining <= 0) {
      hideElement($(this.hintWizardTarget));
      return;
    }

    const content = (remaining === 1) ? "<strong>1 semaine</strong>" : `<strong>${remaining} semaines</strong>`
    this.hintWizardTarget.innerHTML = `Il reste ${content} à ajouter`
    showElement($(this.hintWizardTarget));
    return;
  }

  collectiveOptionInhibit(doInhibit) {
    if (doInhibit) {
      this.individualButtonTarget.checked = true;
      this.collectiveButtonTarget.setAttribute('disabled', true);
      this.individualButtonTarget.focus()
    } else {
      $(this.collectiveButtonTarget).prop('disabled', false);
    }
    return;
  }


  connect() {
    this.handleCheckboxesChanges();
  }

  disconnect() { }
}