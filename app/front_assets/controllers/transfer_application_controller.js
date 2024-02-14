import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'requiredField',
    'submitButton',
    'container'
  ];

  addDestinataire(event) {
    event.preventDefault();

    const input = document.createElement('input');
    input.type = 'text';
    input.name = 'application_transfer[destinataires][]';
    input.className = 'fr-input destinataire-input fr-my-3w';

    const formGroup = document.createElement('div');
    formGroup.className = 'form-group ';
    formGroup.appendChild(input);
    this.containerTarget.appendChild(formGroup);

    this.addListeners();
    this.updateHiddenRecipients();
  }

  addListeners() {
    const destinataireInputs = this.element.querySelectorAll('.destinataire-input');
    destinataireInputs.forEach(input => {
      input.addEventListener('input', this.updateHiddenRecipients.bind(this));
    });
  }

  updateHiddenRecipients() {
    const destinataires = this.containerTarget.querySelectorAll('.destinataire-input');
    const hiddenInput = document.querySelector('.hidden-destinataires-input');
    hiddenInput.value = Array.from(destinataires).map(input => input.value).join(',');
  }

  checkForm() {
    const requiredFields = this.requiredFieldTargets;
    const submitButton = this.submitButtonTarget;

    requiredFields.forEach(field => {
      field.addEventListener('input', () => {
        for (const requiredField of requiredFields) {
          if (requiredField.value === '') {
            submitButton.disabled = true;
            return;
          }
        }
        submitButton.disabled = false;
      });
    });
  }

  connect() {
    this.addListeners();
  }
  disconnect() {}
}