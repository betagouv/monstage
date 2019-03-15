import { Controller } from "stimulus"

const flexibleSearch = (searchText) => {
  return searchText.replace(/ /g, ".")
                   .replace(/-/g, ".")
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
    const val = $(this.inputSearchCityTarget).val()
    const searchRegExp = new RegExp(flexibleSearch(val), 'i')

    if (val.length > 1) {
      this.showCitiesList();
    }

    $(this.cityItemTargets).each((i, el) => {
      const $el = $(el);

      if (searchRegExp.test($el.text())) {
        $el.removeClass('d-none');
      } else {
        $el.addClass('d-none');
      }
    })
  }

  onSelectCity(event) {
    const $sourceTarget = $(event.target)
    const val = $sourceTarget.text()

    this.selectCity(val);
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
    const searchRegExp = new RegExp(flexibleSearch(val), 'i');

    this.hideCitiesList()
    this.showSchoolsList()

    $(this.inputSearchCityTarget).val(val)
    $(this.schoolItemTargets).each((i, el) => {
      const $el = $(el);

      if (searchRegExp.test($el.data('city'))) {
        $el.removeClass('d-none');
      } else {
        $el.addClass('d-none');
      }
    })
  }


  // -
  // UI Helpers
  // -
  resetClassRoomList(classRoomList) {
    const $classRoomSelectTarget = $(this.classRoomSelectTarget);

    if (classRoomList.length > 0) {
      $classRoomSelectTarget.attr('readonly', false)
      $classRoomSelectTarget.html(
        $(`<option value="">-- Veuillez selectionner une classe --</option>`)
      )
      $.each(classRoomList, (i, el) => {
        $classRoomSelectTarget.append($(`<option value="${el.id}">${el.name}</option>`))
      })
    } else {
      $classRoomSelectTarget.attr('readonly', true)
      $classRoomSelectTarget.html(
        $(`<option value="">-- Aucune classe disponible --</option>`)
      )
    }
  }

  // BUGGY, uncheck props fails
  resetSchoolsList() {
    $(this.schoolItemTargets).each((i, el) => {
      if (el.checked) {
        el.checked = false;
        console.log('uncheck', el.name, el);
      }

    })
  }

  hideSchoolsList() {
    $(this.listSchoolsTarget).addClass('d-none');
    $(this.placeholderSchoolInputTarget).removeClass('d-none');
  }

  showSchoolsList() {
    $(this.listSchoolsTarget).removeClass('d-none');
    $(this.placeholderSchoolInputTarget).addClass('d-none');
  }

  hideCitiesList() {
    $(this.listCitiesTarget).addClass('d-none');
  }

  showCitiesList() {
    $(this.listCitiesTarget).removeClass('d-none');
  }

  // -
  // Life Cycle
  // -
  connect() {
    // should be bound via Stimulus ; but change event sucks?
    $(this.inputSearchCityTarget)
      .on("keyup", this.onSearchCityKeystroke.bind(this))

    const currentValue = $(this.inputSearchCityTarget).val();
    if (currentValue) {
      this.selectCity(currentValue);
    } else {
      this.hideSchoolsList();
      this.hideCitiesList();
    }
  }
}
