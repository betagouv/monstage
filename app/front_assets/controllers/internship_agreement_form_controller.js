import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = ['displayButton',
                    'hideButton',
                    'employerEvent',
                    'schoolManagerEvent',
                    'form',
                    'textField']

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
    this.removeRequiredAttributes();
    this.formTarget.submit();
  }

  saveAndQuitBySchoolManager() {
    this.schoolManagerEventTarget.value = 'start_by_school_manager';
    this.removeRequiredAttributes();
    this.formTarget.submit();
  }

  completeByEmployer() {
    this.employerEventTarget.value = 'complete';
    $('#submit').click();
  }

  validate() {
    this.schoolManagerEventTarget.value = 'finalize';
    $('#submit').click();
  }

  removeRequiredAttributes() {
    this.textFieldTargets.map(tField => {
      if (tField.getAttribute('required') == 'required') {
        tField.removeAttribute('required')
      }
    });
  }
}
