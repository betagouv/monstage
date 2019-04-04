import { Controller } from "stimulus"
import { showElement, hideElement } from "../utils/dom"

// replace dash / white space with wildcard char
// searching for Saint Denis, which is officialy written Saint-Denis
// TODO: rethink this one for accentuated chars, any idea brice?
const formatSearchStringForRegexp = (searchText) => {
  const wildcard = '.';
  return searchText.replace(/ /g, wildcard)
                   .replace(/-/g, wildcard)
}

export default class extends Controller {
  static targets = [ 'inputSearchCity',
                     'listSchools',
                     'listCities',
                     'cityItem',
                     'cityContainer',
                     'schoolItem',
                     'resetSearchCityButton',
                     'placeholderSchoolInput',
                     'classRoomSelect' ]

  // -
  // event handlers
  // -
  onSearchCityKeystroke(event) {
    const searchValue = $(this.inputSearchCityTarget).val()
    const searchRegExp = new RegExp(formatSearchStringForRegexp(searchValue), 'i')
    const startAutocompleteAtLength = 1;

    if (searchValue.length > startAutocompleteAtLength) {
      this.showCitiesList();
    }

    $(this.cityItemTargets).each((i, el) => {
      const $el = $(el);

      if (searchRegExp.test($el.text())) {
        showElement($el)
      } else {
        hideElement($el)
      }
    })
  }

  onSelectCity(event) {
    const $sourceTarget = $(event.target)
    const cityName = $sourceTarget.text()

    this.selectCity(cityName);
    this.resetSchoolsList();
    this.resetClassRoomList([]);
  }

  onSelectSchool(event) {
    const $sourceTarget = $(event.target) // clicked radio school

    this.resetClassRoomList($sourceTarget.data('classRoomAvailable'))
  }

  onResetCityClicked() {
    $(this.inputSearchCityTarget).val("");
    this.hideCitiesList();
    this.hideSchoolsList();
    this.resetSchoolsList();
    this.resetClassRoomList([]);
  }

  // -
  // used by onSelectCity and to initialize component
  // -
  selectCity(val) {
    const searchRegExp = new RegExp(formatSearchStringForRegexp(val), 'i');

    this.hideCitiesList()
    this.showSchoolsList()

    $(this.inputSearchCityTarget).val(val)
    $(this.schoolItemTargets).each((i, el) => {
      const $el = $(el);

      if (searchRegExp.test($el.data('city'))) {
        showElement($el)
      } else {
        hideElement($el)
      }
    })
  }


  // -
  // UI Helpers
  // -
  resetClassRoomList(classRoomList) {
    if (this.data.get('chooseClassRoom') != "true") {
      return;
    }
    const $classRoomSelectTarget = $(this.classRoomSelectTarget);

    if (classRoomList.length > 0) {
      $classRoomSelectTarget.attr('disabled', false)
      $classRoomSelectTarget.html(
        $(`<option value="">-- Veuillez selectionner une classe --</option>`)
      )
      $.each(classRoomList, (i, el) => {
        $classRoomSelectTarget.append($(`<option value="${el.id}">${el.name}</option>`))
      })
    } else {
      $classRoomSelectTarget.attr('disabled', true)
      $classRoomSelectTarget.html(
        $(`<option value="">-- Aucune classe disponible --</option>`)
      )
    }
  }

  resetSchoolsList() {
    $(this.schoolItemTargets).each((i, el) => {
      if (el.checked) {
        el.checked = false;
      }

    })
  }

  hideSchoolsList() {
    hideElement($(this.listSchoolsTarget))
    showElement($(this.placeholderSchoolInputTarget))
  }

  showSchoolsList() {
    showElement($(this.listSchoolsTarget))
    hideElement($(this.placeholderSchoolInputTarget))
  }

  hideCitiesList() {
    hideElement($(this.listCitiesTarget));
  }

  showCitiesList() {
    showElement($(this.listCitiesTarget));
  }

  // -
  // Life Cycle
  // -
  connect() {
    // should be bound via Stimulus ; but change event sucks?
    $(this.inputSearchCityTarget)
      .on("keyup", this.onSearchCityKeystroke.bind(this))

    const currentCityName = $(this.inputSearchCityTarget).val();
    if (currentCityName) {
      this.selectCity(currentCityName);
    } else {
      this.hideSchoolsList();
      this.hideCitiesList();
    }
  }

  disconnect() {
    $(this.inputSearchCityTarget)
      .off("keyup", this.onSearchCityKeystroke.bind(this))
  }
}
