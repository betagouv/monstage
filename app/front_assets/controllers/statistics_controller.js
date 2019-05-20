import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';

export default class extends Controller {

  filterByDepartment(event) {
    const department = $(event.target).val()
    const search_params = new URLSearchParams(window.location.search)
    search_params.set('department', department)

    Turbolinks.visit(`${window.location.origin}${window.location.pathname}?${search_params.toString()}`)
  }
}
