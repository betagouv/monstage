import { Controller } from 'stimulus';
import { visitURLWithParam , clearParamAndVisits} from '../utils/urls';

export default class extends Controller {
  static targets = ['filter'];
  static values = {
    field: String
  }

  handleChange(event) {
    event.stopPropagation()
    const chosen_option = this.filterTarget.value
    const field = this.fieldValue
    if (chosen_option == 'all') {
      clearParamAndVisits(field)
    } else {
      visitURLWithParam(field, chosen_option)
    }
  }
}