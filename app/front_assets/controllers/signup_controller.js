import { Controller } from "stimulus"
import { toggleElement } from "../utils/dom"

export default class extends Controller {
  static targets = [ 'handicapGroup' ]

  toggleHandicap() {
    toggleElement($(this.handicapGroupTarget))
  }
}
