import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';

export default class extends Controller {

  filterByDepartment(event) {
    this.changeURLFromEvent(event, "department")
  }

  filterByGroupName(event) {
    this.changeURLFromEvent(event, "group_name")
  }

  filterByAcademy(event) {
    this.changeURLFromEvent(event, "academy_name")
  }

  changeURLFromEvent(event, param) {
    const paramValue = $(event.target).val()
    const searchParams = new URLSearchParams(window.location.search)
    if (paramValue.length > 0) {
      searchParams.set(param, paramValue);
    } else {
      searchParams.delete(param)
    }
    Turbolinks.visit(`${window.location.origin}${window.location.pathname}?${searchParams.toString()}`)
  }
}
