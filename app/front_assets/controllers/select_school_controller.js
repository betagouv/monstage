import { Controller } from "stimulus"
import { showElement, hideElement } from "../utils/dom"

/*
todo:
1. search via ajax
2. show list of cities in : select-school.listCities (/!\ already selected /!\)
  ```
  <% School.all.map(&:city).uniq.each do |city|
    <a class="list-group-item"
       data-city="<%= city %>"
       data-action="click->select-school#onSelectCity"
       data-target="select-school.cityItem">
      <%= city %>
    </a>
  <% end %>
  ```
3. on select city : show radio list in : select-school.listSchools (/!\ already selected /!\)
  ```
  <% School.all.includes(:class_rooms).each do |school| %>
    <div class="custom-control custom-radio"
         data-target="select-school.schoolItem"
         data-city="<%= school.city %>">
      <%= form.radio_button :school_id,
                            school.id,
                            class: 'custom-control-input',
                            id: "select-school-#{school.id}",
                            required: required,
                            data: {
                              "action": "change->select-school#onSelectSchool",
                              "class-room-available": school.class_rooms.to_json
                            } %>
      <%= form.label :school_id, "#{school.name} - #{school.city}",
                     class: 'custom-control-label',
                     for: "select-school-#{school.id}" %>
    </div>
  <% end %>
  ```

4. on select class room (/!\ already selected /!\):
```
<%= form.select :class_room_id,
                options_from_collection_for_select((resource.school || resource.build_school).class_rooms,
                                                   :id,
                                                   :name,
                                                   resource.class_room),
                {},
                class: 'form-control', data: {target: 'select-school.classRoomSelect'}, disabled: !resource.class_room.present? %>
```
*/

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
    const startAutocompleteAtLength = 1
    if (searchValue.length > startAutocompleteAtLength) {

    }
    $.ajax({ type: "POST", url: '/api/schools/search', data: {query: searchValue}})
     .done((result) => {
        const $root = $(this.listCitiesTarget);
        let $element = null;

        $root.empty()
        $.map(result, (schools, cityName) => {
          $element = $(`
              <a class="list-group-item"
                 data-city="${cityName}"
                 data-action="click->select-school#onSelectCity"
                 data-target="select-school.cityItem"
              </a>
          `)
          $element.append(`<span>${cityName}</span>`)
          $element.data('schools', JSON.stringify(schools))
          $root.append($(`<li></li>`).append($element))
        })
        this.showCitiesList();
     })
     .fail((error) => {
     })
  }

  onSelectCity(event, availableSchools) {
    const $sourceTarget = $(event.currentTarget)
    const cityName = $sourceTarget.text()

    this.selectCity(cityName, JSON.parse($sourceTarget.data('schools')));
    this.resetSchoolsList();
    this.resetClassRoomList([]);
  }

  onSelectSchool(event) {
    const $sourceTarget = $(event.target) // clicked radio school

    this.resetClassRoomList(JSON.parse($sourceTarget.data('classRoomAvailable')))
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
  selectCity(cityName, availableSchools) {
    this.hideCitiesList()
    this.showSchoolsList()
    $(this.inputSearchCityTarget).val(cityName)
    const $root = $(this.listSchoolsTarget);
    let $element;
    let $radio;
    let $label;
    $root.empty()

    $.map(availableSchools, (school) => {

      $radio = $(`<input type="radio"
                   id="select-school-${school.id}"
                   name="user[school_id]"
                   value="${school.id}"
                   id="select-school-${school.id}"
                   required
                   class="custom-control-input" />`)

      $radio.data('classRoomAvailable', JSON.stringify(school.class_rooms))
      $radio.on('change', (event) => {
        this.onSelectSchool(event);
      })
      $label = $(`
        <label for="select-school-${school.id}"
               class="custom-control-label" >
          ${school.name}
        </label>
      `)
      $element = $(`
        <div class="custom-control custom-radio"
             data-target="select-school.schoolItem">
        </div>
      `)
      $element.append($radio)
      $element.append($label)
      $root.append($element)
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
      // this.selectCity(currentCityName);
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
