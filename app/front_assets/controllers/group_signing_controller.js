import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'generalCta',
    'signingButton',
    'addCheckBox',
  ];

  static values = {
    counter: Number
  };

  connect() {
    this.addCheckBoxTargets.forEach(element => {
      element.checked = false;
      (element.getAttribute('data-group-signing-signed-param') === 'readyToSign') ? this.enable(element) : this.disable(element)
    });
    this.onCheckboxChecked();
  }

  toggle(event) {
    this.commonToggle(event, this.withCheckbox.bind(this));
  }

  toggleFromButton(event) {
    this.commonToggle(event, this.withButton.bind(this));
  }

  // private functions

  commonToggle(event, fnRef) {
    const agreementId = event.params.id;
    this.addCheckBoxTargets.forEach(element => {
      if (element.getAttribute('data-group-signing-id-param') == agreementId) {
        fnRef(element, agreementId);
      }
    });
    this.onCheckboxChecked(event);
  }

  withCheckbox(element, agreementId) {
    (element.checked) ? this.addToList(agreementId) : this.removeFromList(agreementId);
  }

  withButton(element, agreementId) {
    if (element.getAttribute('data-group-signing-id-param') == agreementId) {
      if (element.checked) { //let's uncheck it
        element.checked = false
        this.removeFromList(agreementId);
      } else {
        element.checked = true;
        this.addToList(agreementId);
      }
    }
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

  onCheckboxChecked() {
    const target = this.generalCtaTarget;
    (this.counterValue === 0) ? this.disable(target) : this.enable(target)

    //paintButtonLabel
    const extraHTML = (this.counterValue > 1) ? " en groupe (" + this.counterValue + ")" : '';
    this.generalCtaTarget.innerHTML = "Signer" + extraHTML;
  }

  disable(el) { el.setAttribute('disabled', 'disabled'); }

  enable(el) { el.removeAttribute('disabled'); }

  addCounter(val) { this.counterValue += val }
}