import $ from 'jquery';
import { Controller } from 'stimulus';
import { hideElement } from '../utils/dom';

export default class extends Controller {

  saveAndQuit() {
    $('#internship_agreement_event').val('start_by_employer');
    $('#save_and_quit').click();
  }
  
  saveAndQuitBySchoolManager() {
    $('#internship_agreement_event').val('start_by_school_manager');
    $('#school_manager_saves_and_quit').click();
  }

  checkFormValidity() {
    if ($('.form-offset-header')[0].checkValidity()) {
      $('.modal').modal();
    } else {
      var invalidField = document.querySelectorAll(':invalid')[0];
      invalidField.scrollIntoView();
    };
  }

}
