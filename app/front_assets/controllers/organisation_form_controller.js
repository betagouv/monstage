import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'organisationName',
    'invalidFeedback',
    'validFeedback',
    'groupBlock',
    'groupLabel',
    'groupNamePublic',
    'groupNamePrivate',
    'selectGroupName',
  ];

  static values = { token: String };

  onChooseType(event) {
    this.chooseType(event.target.value)
  }

  onInduceType(event) {
    this.induceType(event.target.value)
  }

  induceType(value){
    const induced_type = (value == 'troisieme_generale') ? 'InternshipOffers::WeeklyFramed' : 'InternshipOffers::FreeDate';
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

  validateForm(event) {
    const latitudeInput = document.getElementById('internship_offer_coordinates_latitude');
    if (!latitudeInput.validity.valid) {
      document.getElementById('js-internship_offer_autocomplete').focus();
    }
    return event;
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
      $(this.groupLabelTarget).text('Groupe (optionnel)');
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

  checkSiren(event) {
    this.hideFeedbackMessages();
    const siren = event.target.value.replace(/\s/g, '');
    const sirenToken = this.tokenValue;
    if (siren.length === 9) {
      const Params = {
        headers: {
          Accept: 'application/json',
          Authorization: `Bearer ${sirenToken}`,
        },
        method: "GET"
      }
      const SirenUrl = `https://api.insee.fr/entreprises/sirene/V3/siret?q=siren:${siren}`;
      fetch(SirenUrl, Params)
        .then(data=> {
          if (data.status === 200) {
            $(this.validFeedbackTarget).show();
            return data.json();
          } else {
            this.invalidSiren();
            return
          }
        })
        .then(res=> {
          $(this.organisationNameTarget).val(res.etablissements[0].uniteLegale.denominationUniteLegale);
        })
        .catch(error=> {
          this.invalidSiren();
        })
    } else {
      if (siren.length > 0) {
        this.invalidSiren();
      }
    }
    return
  }

  invalidSiren() {
    $(this.invalidFeedbackTarget).show();
    $(this.organisationNameTarget).val('');
  }

  hideFeedbackMessages() {
    $(this.invalidFeedbackTarget).hide();
    $(this.validFeedbackTarget).hide();
  }

  connect() {
    this.element.addEventListener('submit', this.validateForm, false);
  }

  disconnect() {}
}
