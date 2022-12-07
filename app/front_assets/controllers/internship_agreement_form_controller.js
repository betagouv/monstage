import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = ['displayButton', 'hideButton', 'employerEvent', 'schoolManagerEvent', 'form' ];

  toggleToolnote() {
    $('.tool-note').toggleClass('invisible');
    $(this.displayButtonTarget).toggleClass('d-none');
    $(this.hideButtonTarget).toggleClass('d-none');
  }

  checkFormValidity() {
    if ($('.form-offset-header')[0].checkValidity()) {
      $('.modal').modal();
    } else {
      var invalidField = document.querySelectorAll(':invalid')[0];
      invalidField.scrollIntoView();
    };
  }

  saveAndQuit() {
    this.employerEventTarget.value = 'start_by_employer';
    this.formTarget.submit();
  }

  saveAndQuitBySchoolManager() {
    this.schoolManagerEventTarget.value = 'start_by_school_manager';
    this.formTarget.submit();
  }

  completeByEmployer() {
    this.employerEventTarget.value = 'complete';
    $('#submit').click();
  }

  validate() {
    this.schoolManagerEventTarget.value = 'validate';
    $('#submit').click();
  }
}
