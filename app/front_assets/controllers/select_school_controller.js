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

const makeClassRoomOption = (classRoom) => {
  const option = document.createElement("option");
  option.value = classRoom.id
  option.textContent = classRoom.name
  return option;
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
    const searchValue = this.inputSearchCityTarget.value
    const searchRegExp = new RegExp(formatSearchStringForRegexp(searchValue), 'i')
    const startAutocompleteAtLength = 1;

    if (searchValue.length > startAutocompleteAtLength) {
      this.showCitiesList();
    }

    Array.from(this.cityItemTargets).forEach((element) => {
      if (searchRegExp.test(element.textContent)) {
        showElement(element)
      } else {
        hideElement(element)
      }
    })
  }

  onSelectCity(event) {
    const cityName = event.target.textContent

    this.selectCity(cityName);
    this.resetSchoolsList();
    this.resetClassRoomList([]);
  }

  onSelectSchool(event) {
    this.resetClassRoomList(JSON.parse(event.target.dataset.classRoomAvailable))
  }

  onResetCityClicked() {
    this.inputSearchCityTarget.value = null;
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
    this.inputSearchCityTarget.value = val
    Array.from(this.schoolItemTargets).forEach((element) => {
      if (searchRegExp.test(element.dataset.city)) {
        showElement(element)
      } else {
        hideElement(element)
      }
    })
  }


  // -
  // UI Helpers
  // -
  resetClassRoomList(classRoomList) {
    const hasClassRooms = classRoomList.length > 0
    const defaultOption = makeClassRoomOption({
      id: "",
      name: hasClassRooms
            ? "-- Veuillez selectionner une classe --"
            : "-- Aucune classe disponible --"
    })

    this.classRoomSelectTarget.disabled= !hasClassRooms;
    this.classRoomSelectTarget.innerHTML = ""
    this.classRoomSelectTarget.appendChild(defaultOption)
    classRoomList.forEach( (classRoom) => {
      this.classRoomSelectTarget.appendChild(makeClassRoomOption(classRoom))
    })
  }

  resetSchoolsList() {
    Array.from(this.schoolItemTargets).forEach((element) => {
      if (element.checked) {
        element.checked = false;
      }

    })
  }

  hideSchoolsList() {
    hideElement(this.listSchoolsTarget);
    showElement(this.placeholderSchoolInputTarget);
  }

  showSchoolsList() {
    showElement(this.listSchoolsTarget);
    hideElement(this.placeholderSchoolInputTarget);
  }

  hideCitiesList() {
    hideElement(this.listCitiesTarget);
  }

  showCitiesList() {
    showElement(this.listCitiesTarget);
  }

  // -
  // Life Cycle
  // -
  connect() {
    // should be bound via Stimulus ; but change event sucks?
    this.inputSearchCityTarget.addEventListener(
      "keyup",
      this.onSearchCityKeystroke.bind(this)
    )

    const currentCityName = this.inputSearchCityTarget.value;
    if (currentCityName) {
      this.selectCity(currentCityName);
    } else {
      this.hideSchoolsList();
      this.hideCitiesList();
    }
  }
}
