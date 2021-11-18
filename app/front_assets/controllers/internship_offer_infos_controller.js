import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'type',
    'selectType',
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

  onChooseType(event) {
    this.chooseType(event.target.value)
  }

  onInduceType(event) {
    this.induceType(event.target.value)
  }

  induceType(value){
    const inducedType = (value == 'troisieme_generale') ? `${this.baseTypeValue}s::WeeklyFramed` : `${this.baseTypeValue}s::FreeDate`;
    $(this.typeTarget).attr('value', inducedType)
    this.chooseType(inducedType);
  }

  chooseType(value) {
    switch (value) {
      case `${this.baseTypeValue}s::WeeklyFramed`:
        showElement($(this.weeksContainerTarget))
        $(this.weeksContainerTarget).attr('data-select-weeks-skip-validation-value', false)
        break;
      case `${this.baseTypeValue}s::FreeDate`:
        hideElement($(this.weeksContainerTarget));
        $(this.weeksContainerTarget).attr('data-select-weeks-skip-validation-value', true)
        break;
    }
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
    this.induceType(this.selectTypeTarget.value)
    this.checkOnCandidateCount()
  }

  disconnect() {}
}
