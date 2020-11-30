import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'type',
    'selectType',
    'weeksContainer',
    'maxCandidatesGroup',
    'maxCandidatesInput',
  ];

  onChooseType(event) {
    this.chooseType(event.target.value)
  }

  onInduceType(event) {
    this.induceType(event.target.value)
  }

  induceType(value){
    const baseType = this.data.get('baseType');
    const inducedType = (value == 'troisieme_generale') ? `${baseType}s::WeeklyFramed` : `${baseType}s::FreeDate`;
    $(this.typeTarget).attr('value', inducedType)
    this.chooseType(inducedType);
  }

  chooseType(value) {
    const baseType = this.data.get('baseType');
    switch (value) {
      case `${baseType}s::WeeklyFramed`:
        showElement($(this.weeksContainerTarget))
        $(this.weeksContainerTarget).attr('data-select-weeks-skip', true)
        break;
      case `${baseType}s::FreeDate`:
        hideElement($(this.weeksContainerTarget));
        $(this.weeksContainerTarget).attr('data-select-weeks-skip', false)
        break;
    }
  }

  // show/hide group internship custom controls
  toggleInternshipType(event) {
    if (event.target.value === 'true') {
      hideElement($(this.maxCandidatesGroupTarget));
      this.maxCandidatesInputTarget.value = undefined;
    } else {
      showElement($(this.maxCandidatesGroupTarget));
      this.maxCandidatesInputTarget.value = 1;
    }
  }

  connect() {
    this.induceType(this.selectTypeTarget.value)
  }

  disconnect() {}
}
