import { Controller } from 'stimulus';
import $ from 'jquery';
import { visitURLWithParam, getParamValueFromUrl } from '../utils/urls';

export default class extends Controller {
  static targets = [
    'applicationDate',
    'internshipDate'
  ];
  connect(){
    const radioApplicationDate = $("#order_applicationDate");
    const radioInternshipDate = $("#order_internshipDate");
    radioApplicationDate.checked = (getParamValueFromUrl('order') == 'applicationDate');
    radioInternshipDate.checked = (getParamValueFromUrl('order') == 'internshipDate');
  }
  applicationOrderHandle() {
    (this.applicationDateTarget.checked) ? visitURLWithParam('order','internshipDate')
                                           :
                                           visitURLWithParam('order','applicationDate') ;
  }
}