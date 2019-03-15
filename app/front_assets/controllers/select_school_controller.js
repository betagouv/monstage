import { Controller } from "stimulus"

const flexibleSearch = (searchText) => {
  return searchText.replace(" ", ".")
                   .replace("-", ".")
}
export default class extends Controller {
  static targets = [ "inputSearchCity",
                     "listSchools",
                     "listCities",
                     "cityItem",
                     "cityContainer",
                     "schoolItem",
                     "resetSearchCityButton",
                     "placeholderSchoolInput" ]

  onSelectedCity(event) {
    const $sourceTarget = $(event.target)
    const val = $sourceTarget.text()

    this.selectCity(val);
  }

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

  resetCitySearch() {
    $(this.inputSearchCityTarget).val("");
    this.hideCitiesList();
    this.hideSchoolsList();
    $(this.schoolItemTarges).each((i, el) => {
      if ($(el).prop('checked', false));
    })
  }

  filterCities(event) {
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

  connect() {
    $(this.inputSearchCityTarget)
      .on("keyup", this.filterCities.bind(this))
    const currentValue = $(this.inputSearchCityTarget).val();
    if (currentValue) {
      this.selectCity(currentValue);
    } else {
      this.hideSchoolsList();
      this.hideCitiesList();
    }
  }
}
