import { Controller } from 'stimulus';
import SignaturePad from 'signature_pad/dist/signature_pad';

export default class extends Controller {
  static targets = ['pad', 'clear', 'submitter', 'signature'];

  padTargetConnected(element) {
    const options = {
      minWidth: 1,
      maxWidth: 2,
      penColor: "rgb(0,0,91)"
    }
    this.signaturePad = new SignaturePad(element, options)
    this.signaturePad.addEventListener("beginStroke", () => {
      this.submitterTarget.removeAttribute('disabled');
    });
  }



  clear(event) {
    event.preventDefault();
    this.signaturePad.clear();
    this.signatureTarget.value = '';
    this.submitterTarget.setAttribute('disabled', true);
  }

  save(event) {
    this.signatureTarget.value = this.signaturePad.toDataURL(); // default is png
    this.submitterTarget.removeAttribute('disabled');
  }
}