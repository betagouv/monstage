import { Controller } from 'stimulus';
import SignaturePad from 'signature_pad/dist/signature_pad';

export default class extends Controller {
  static targets = ['pad', 'clear', 'save', 'submitter', 'signature'];

  padTargetConnected(element) {
    const options = {
      minWidth: 1,
      maxWidth: 2,
      penColor: "rgb(0,0,91)"
    }
    this.signaturePad = new SignaturePad(element, options)
  }

  clear(event) {
    event.preventDefault();
    this.signaturePad.clear();
    this.signatureTarget.value = '';
    this.submitterTarget.setAttribute('disabled', true);
  }

  save(event) {
    event.preventDefault();
    this.signatureTarget.value = JSON.stringify(this.signaturePad.toData());
    this.submitterTarget.removeAttribute('disabled');
  }
}