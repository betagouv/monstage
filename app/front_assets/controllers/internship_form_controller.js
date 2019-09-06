import { Controller } from 'stimulus';
import $ from 'jquery';
import { toggleElement, showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'maxCandidatesGroup',
    'maxCandidatesInput',
    'selectSchoolBlock',
    'groupBlock',
    'groupLabel',
    'groupNamePublic',
    'groupNamePrivate',
    'selectGroupName',
    'operatorsBlock',
    'operator',
  ];

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

  toggleSelectSchoolBlock(event) {
    toggleElement($(this.selectSchoolBlockTarget));
  }

  handleClickWithOperator(event) {
    if (event.target.value === 'true') {
      showElement($(this.operatorsBlockTarget));
    } else {
      hideElement($(this.operatorsBlockTarget));
      $(this.operatorTargets).each((i, el) => {
        el.checked = false;
      });
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

  connect() {
    this.element.addEventListener('submit', this.validateForm, false);
  }

  disconnect() {}
}
