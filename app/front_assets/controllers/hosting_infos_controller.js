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

  onChooseType(event) {
    this.chooseType(event.target.value)
  }

  onInduceType(event) {
    this.induceType(event.target.value)
  }

  induceType(value){
    const inducedType = `${this.baseTypeValue}s::WeeklyFramed`;
    this.typeTarget.setAttribute('value', inducedType);
    this.chooseType(inducedType);
  }

  chooseType(value) {
    showElement($(this.weeksContainerTarget))
    $(this.weeksContainerTarget).attr('data-select-weeks-skip-validation-value', false)
  }

  checkOnCandidateCount() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    this.studentsMaxGroupInputTarget.setAttribute('max', maxCandidates);
  }

  updateMaxCandidateCount() {
    if (this.individualButtonTarget.checked) {
      $(this.maxCandidatesInputTarget).prop('min', 1);
      $(this.maxCandidatesInputTarget).prop('max', 100);
      $(this.maxCandidatesInputTarget).prop('value', 1);

      $(this.studentsMaxGroupInputTarget).prop('max', 1);
      $(this.studentsMaxGroupInputTarget).prop('min', 1);
      $(this.studentsMaxGroupInputTarget).prop('value', 1);
    } else {
      $(this.maxCandidatesInputTarget).prop('min', 2);
      $(this.maxCandidatesInputTarget).prop('max', 100);
      $(this.maxCandidatesInputTarget).prop('value', 2);
      $(this.studentsMaxGroupInputTarget).prop('max', 2);
    }
  }

  collectiveOptionInhibit(doInhibit) {
    if (doInhibit) {
      this.individualButtonTarget.checked = true;
      this.individualButtonTarget.focus()
    } else {
      this.collectiveButtonTarget.checked = true;
      this.withCollectiveToggling();
    }
    return;
  }

  handleMaxCandidatesChanges() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    const maxStudentsPerGroup = parseInt(this.studentsMaxGroupInputTarget.value, 10);
    if (maxStudentsPerGroup > maxCandidates) {
      $(this.studentsMaxGroupInputTarget).prop('value', maxCandidates);
    }
    $(this.studentsMaxGroupInputTarget).prop('max', maxCandidates);
    
    if (maxCandidates === 1) { this.withIndividualToggling() }
  }

  handleMaxCandidatesPerGroupChanges() {
    this.checkOnCandidateCount();
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10)
    if (maxCandidates === 1) { this.withIndividualToggling() }
  }

  // show/hide group (maxStudentsPerGroup>1) internship custom controls
  toggleInternshipmaxStudentsPerGroup(event) {
    this.updateMaxCandidateCount();
    const toggleValue = event.target.value;
    (toggleValue === 'true') ? this.withIndividualToggling() : this.withCollectiveToggling();
  }

  withIndividualToggling() {
    const groupSizeElt = $(this.studentsMaxGroupGroupTarget);
    hideElement(groupSizeElt);
    this.individualButtonTarget.checked = true;
    this.updateMaxCandidateCount();
  }

  withCollectiveToggling() {
    const groupSizeElt = $(this.studentsMaxGroupGroupTarget);
    showElement(groupSizeElt);
    this.collectiveButtonTarget.checked = true;
    this.updateMaxCandidateCount();
  }

  connect() {
    this.induceType('');
    // this.updateMaxCandidateCount();
  }

  disconnect() {}
}
