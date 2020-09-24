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
    const inducedType = (value == 'bac_pro') ? `${baseType}s::FreeDate` : `${baseType}s::WeeklyFramed`;
    $(this.typeTarget).attr('value', inducedType)
    this.chooseType(inducedType);
  }

  chooseType(value) {
    const baseType = this.data.get('baseType');
    debugger
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


  handleToggleWeeklyPlanning(event){
    if($('#same_daily_planning').is(":checked")){
      $('#weekly_start').val('9:00')
      $('#weekly_end').val('17:00')
      $("#daily-planning").addClass('d-none')
      $("#daily-planning").hide()
      $("#weekly-planning").removeClass('d-none')
      $("#weekly-planning").slideDown()
    } else {
      $('#weekly_start').val('--')
      $('#weekly_end').val('--')
      $("#weekly-planning").addClass('d-none')
      $("#weekly-planning").hide()
      $("#daily-planning").removeClass('d-none')
      $("#daily-planning").slideDown()
    }
  }

  connect() {
    this.induceType(this.selectTypeTarget.value)
  }

  disconnect() {}
}
