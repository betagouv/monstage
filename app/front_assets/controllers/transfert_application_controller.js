import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'groupBlock',
    'groupLabel',
    'groupNamePublic',
    'groupNamePrivate',
    'selectGroupName',
    'requiredField',
    'submitButton'
  ];

  updateHiddenDestinataires() {
    const destinataires = this.containerTarget.querySelectorAll('.destinataire-input');
    const hiddenInput = document.querySelector('.hidden-destinataires-input');
    hiddenInput.value = Array.from(destinataires).map(input => input.value).join(',');
  }

  connect() {
    // this.element.addEventListener('submit', this.validateForm, false);
    setTimeout( () => {
      console.log('coucou');
      // this.toggleGroupNames(false);
      // this.checkForm();
    }, 100);
  }

  disconnect() {}
}