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
    this.addCheckBoxTargets.forEach(element => {
      if (element.getAttribute('data-group-signing-id-param') == event.params.id) {
        (element.checked) ? this.addCounter(1) : this.addCounter(-1);
      }
    });
    this.onCheckboxChecked();
  }

  addCounter(val) { this.counterValue += val }

  paintButtonLabel() {
    const extraHML = (this.counterValue === 0) ? '' : " (" + this.counterValue + ")";
    this.generalCtaTarget.innerHTML = "Signer en groupe" + extraHML;
  }

  toggleSigningButtons(value) {
    if (value == 'disable') {
      this.signingButtonTargets.forEach((el) => { el.setAttribute('disabled', 'disabled'); })
    } else {
      this.signingButtonTargets.forEach((el) => { el.removeAttribute('disabled'); })
    }
  }

  onCheckboxChecked() {
    if (this.counterValue === 0) {
      this.generalCtaTarget.setAttribute('disabled', 'disabled')
      this.toggleSigningButtons('enable');
    } else {
      this.generalCtaTarget.removeAttribute('disabled')
      this.toggleSigningButtons('disable');
    }
    this.paintButtonLabel();
  }

  connect() {
    this.addCheckBoxTargets.forEach(element => {
      if (element.getAttribute('data-group-signing-signed-param') === 'readyToSign') {
        element.removeAttribute('disabled');
      } else {
        element.setAttribute('disabled', 'disabled');
      }
      if (element.checked) { this.addCounter(1); }
    });
    this.onCheckboxChecked();
  }
}