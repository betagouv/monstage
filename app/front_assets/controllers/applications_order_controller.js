import { Controller } from 'stimulus';
import $ from 'jquery';
import { visitURLWithParam, getParamValueFromUrl } from '../utils/urls';

export default class extends Controller {
  static targets = [
    'applicationDate',
    'internshipDate'
  ];
  initialize(){
    const isInternshipDateOrdered = (getParamValueFromUrl('order') == 'internshipDate');
    const isApplicationDateOrdered = (getParamValueFromUrl('order') == 'internshipDate');
    $("#order_applicationDate").checked = isInternshipDateOrdered;
    $("#order_internshipDate").checked = isApplicationDateOrdered;
  }

  applicationOrderHandle() {
    (this.applicationDateTarget.checked) ? visitURLWithParam('order','internshipDate')
                                           :
                                           visitURLWithParam('order','applicationDate') ;
  }
}