import $ from 'jquery';
import { Controller } from 'stimulus';
import { hideElement } from '../utils/dom';
import { visitURLWithParam } from '../utils/urls';

export default class extends Controller {
  static targets = ['schoolYearField' ,'schoolYearSubmit'];

  handleChange(event){
    event.stopPropagation()
    visitURLWithParam('school_year', this.schoolYearFieldTarget.value)
  }

  connect() {
    hideElement($(this.schoolYearSubmitTarget))
  }
}
