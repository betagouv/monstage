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
    'wholeYear',
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

  // show/hide group (maxStudentsPerGroup>1) internship custom controls
  toggleInternshipmaxStudentsPerGroup(event) {
    const groupSizeElt = $(this.studentsMaxGroupGroupTarget);
    const toggleValue = event.target.value;
    if (toggleValue === 'true') {
      hideElement(groupSizeElt);
      this.studentsMaxGroupInputTarget.setAttribute('min', 1);
      this.studentsMaxGroupInputTarget.value = 1;
    } else {
      showElement(groupSizeElt);
      this.studentsMaxGroupInputTarget.setAttribute('min', 2);
      this.studentsMaxGroupInputTarget.value = 2;
    }
  }

  connect() {
    this.induceType(this.selectTypeTarget.value)
  }

  disconnect() {}
}
