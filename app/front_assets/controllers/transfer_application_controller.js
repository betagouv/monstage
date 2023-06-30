import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'requiredField',
    'submitButton',
    'container'
  ];

  addDestinataire() {
    event.preventDefault();

    const input = document.createElement('input');
    input.type = 'text';
    input.name = 'formulaire[destinataires][]';
    input.className = 'fr-input destinataire-input fr-my-3w';

    // const removeButton = document.createElement('span');
    // removeButton.textContent = 'Supprimer';
    // removeButton.dataset.action = 'click->destinataire#supprimerDestinataire';

    const formGroup = document.createElement('div');
    formGroup.className = 'form-group ';
    formGroup.appendChild(input);
    // formGroup.appendChild(removeButton);

    this.containerTarget.appendChild(formGroup);

    this.updateHiddenRecipients();
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

  connect() {}
  disconnect() {}
}