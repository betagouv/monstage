import { Controller } from 'stimulus';
import { visitURLWithParam } from '../utils/urls';

export default class extends Controller {
  static targets = ['direction'];
  static values = {
    criterium: String
  }

  handleChange(event) {
    event.stopPropagation();
    const chosen_option = this.directionTarget.value;
    const criterium = this.criteriumValue;
    visitURLWithParam(criterium, chosen_option);
  }
}