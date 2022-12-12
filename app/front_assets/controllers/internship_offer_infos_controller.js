import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'type',
    'weeksContainer',
    'studentsMaxGroupGroup',
    'studentsMaxGroupInput',
    'maxCandidatesInput',
    'wholeYear',
    'collectiveButton',
    'individualButton'
  ];
  static values = {
    baseType: String
  }

  checkOnCandidateCount() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    (maxCandidates === 1) ? this.collectiveOptionInhibit(true) : this.collectiveOptionInhibit(false);
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

  handleMaxCandidatesChanges() {
    this.checkOnCandidateCount();
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10)
    if (maxCandidates === 1) { this.withIndividualToggling() }
  }

  // show/hide group (maxStudentsPerGroup>1) internship custom controls
  toggleInternshipmaxStudentsPerGroup(event) {
    const toggleValue = event.target.value;
    (toggleValue === 'true') ? this.withIndividualToggling() : this.withCollectiveToggling()
  }

  withIndividualToggling() {
    const groupSizeElt = $(this.studentsMaxGroupGroupTarget);
    hideElement(groupSizeElt);
    this.studentsMaxGroupInputTarget.setAttribute('min', 1);
    this.studentsMaxGroupInputTarget.value = 1;
  }

  withCollectiveToggling() {
    const groupSizeElt = $(this.studentsMaxGroupGroupTarget);
    showElement(groupSizeElt);
    this.studentsMaxGroupInputTarget.setAttribute('min', 2);
    this.studentsMaxGroupInputTarget.value = 2;
  }

  connect() {
    this.checkOnCandidateCount()
  }

  disconnect() {}
}
