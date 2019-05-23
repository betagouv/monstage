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

  filterByPublicy(event) {
    this.changeURLFromEvent(event, "is_public")
  }

  changeURLFromEvent(event, param) {
    const paramValue = $(event.target).val()
    const searchParams = new URLSearchParams(window.location.search)
    if (paramValue.length === 0) {
      searchParams.delete(param)
    } else {
      searchParams.set(param, paramValue);
    }
    Turbolinks.visit(`${window.location.origin}${window.location.pathname}?${searchParams.toString()}`)
  }
}
