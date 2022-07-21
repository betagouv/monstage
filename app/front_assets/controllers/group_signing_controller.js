import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'generalCta',
    'signingButton',
    'addCheckBox',
  ];

  static values = {
    id: String,
    counter: Number
  };

  toggle(event) {
    const agreementId = event.params.id;
    this.addCheckBoxTargets.forEach(element => {
      if (element.getAttribute('data-group-signing-id-param') == agreementId) {
        (element.checked) ? this.addToList(agreementId) : this.removeFromList(agreementId);
      }
    });
    this.onCheckboxChecked(event);
  }

  toggleFromButton(event) {
    const agreementId = event.params.id;
    this.addCheckBoxTargets.forEach(element => {
      if (element.getAttribute('data-group-signing-id-param') == agreementId) {
        if (element.checked) { //let's uncheck it
          element.checked = false
          this.removeFromList(agreementId);
        } else {
          element.checked = true;
          this.addToList(agreementId);
        }
      }
    });
    this.onCheckboxChecked(event);
  }

  addToList(agreementId) {
    this.addCounter(1);
    this.signingButtonsAction(agreementId, this.disable);
  }
  removeFromList(agreementId) {
    this.addCounter(-1);
    this.signingButtonsAction(agreementId, this.enable);
  }

  signingButtonsAction(agreementId, fn) {
    this.signingButtonTargets.forEach(element => {
      if (element.getAttribute('data-group-signing-id-param') == agreementId) {
        fn(element);
      }
    });
  }

  disable(el) {
    el.setAttribute('disabled', 'disabled');
  }

  enable(el) {
    el.removeAttribute('disabled');
  }

  addCounter(val) { this.counterValue += val }

  onCheckboxChecked() {
    if (this.counterValue === 0) {
      this.generalCtaTarget.setAttribute('disabled', 'disabled')
    } else {
      this.generalCtaTarget.removeAttribute('disabled')
    }
    this.paintButtonLabel();
  }

  paintButtonLabel() {
    const extraHTML = (this.counterValue > 1) ? " en groupe (" + this.counterValue + ")" : '';
    this.generalCtaTarget.innerHTML = "Signer" + extraHTML;
  }

  connect() {
    this.addCheckBoxTargets.forEach(element => {
      element.checked = false;
      if (element.getAttribute('data-group-signing-signed-param') === 'readyToSign') {
        element.removeAttribute('disabled');
      } else {
        element.setAttribute('disabled', 'disabled');
      }
    });
    this.onCheckboxChecked();
  }
}