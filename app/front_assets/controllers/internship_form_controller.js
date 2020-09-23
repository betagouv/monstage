import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'maxCandidatesGroup',
    'maxCandidatesInput',
    'selectSchoolBlock',
    'groupBlock',
    'type',
    'groupLabel',
    'groupNamePublic',
    'groupNamePrivate',
    'selectGroupName',
    'operatorsBlock',
    'operator',
    'selectType',
    'weeksContainer'
  ];

  onChooseType(event) {
    this.chooseType(event.target.value)
  }

  onInduceType(event) {
    this.induceType(event.target.value)
  }

  induceType(value){
    const induced_type = (value == 'bac_pro') ? 'InternshipOffers::FreeDate' : 'InternshipOffers::WeeklyFramed';
    $(this.typeTarget).attr('value', induced_type)
    this.chooseType(induced_type);
  }

  chooseType(value) {
    switch (value) {
      case 'InternshipOffers::WeeklyFramed':
        showElement($(this.weeksContainerTarget))
        $(this.weeksContainerTarget).attr('data-select-weeks-skip', true)
        break;
      case 'InternshipOffers::FreeDate':
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

  handleClickIsPublic(event) {
    const { value } = event.target;
    showElement($(this.groupBlockTarget));
    if (event.target.value === 'true') {
      $(this.groupLabelTarget).html(`
        Institution de tutelle
        <abbr title="(obligatoire)" aria-hidden="true">*</abbr>
      `);
      $(this.selectGroupNameTarget).prop('required', true);
    } else {
      $(this.groupLabelTarget).text('Groupe (facultatif)');
      $(this.selectGroupNameTarget).prop('required', false);
    }
    this.toggleGroupNames(value === 'true');
  }

  toggleGroupNames(isPublic) {
    if (isPublic) {
      $(this.selectGroupNameTarget)
        .find('option')
        .first()
        .text('-- Veuillez sélectionner une institution de tutelle --');
      $(this.groupNamePublicTargets).show();
      $(this.groupNamePrivateTargets).hide();
    } else {
      $(this.selectGroupNameTarget)
        .find('option')
        .first()
        .text('-- Indépendant --');
      $(this.groupNamePublicTargets).hide();
      $(this.groupNamePrivateTargets).show();
    }
  }

  validateForm(event) {
    const latitudeInput = document.getElementById('internship_offer_coordinates_latitude');
    if (!latitudeInput.validity.valid) {
      document.getElementById('js-internship_offer_autocomplete').focus();
    }
    return event;
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
      console.log("check")
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
    this.element.addEventListener('submit', this.validateForm, false);
  }

  disconnect() {}
}
