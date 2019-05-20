import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';

export default class extends Controller {

  filterByDepartment(event) {
    this.changeURLFromEvent(event, "department")
  }

  filterByGroupName(event) {
    this.changeURLFromEvent(event, "group_name")
  }

  changeURLFromEvent(event, param) {
    const param_value = $(event.target).val()
    const search_params = new URLSearchParams(window.location.search)
    search_params.set(param, param_value)

    Turbolinks.visit(`${window.location.origin}${window.location.pathname}?${search_params.toString()}`)

  }
}
