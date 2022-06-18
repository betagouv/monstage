import { Controller } from 'stimulus';
export default class extends Controller {
  static targets = ['code'];
  static values = { position: Number }

  onKeyUp(event) {
    event.preventDefault();
    (event.key == 'Backspace') ? this.eraseBack() : this.enterKey(event);
  }

  // private

  eraseBack() {
    this.eraseCurrentKey()
    if (!this.isFirst()) { this.positionMove(-1); }
    this.enableCurrent();
    this.eraseCurrentKey()
    this.setFocus();
  }
  enterKey(event) {
    this.validKey(event.key) ? this.withGoodKey(event.key) : this.eraseCurrentKey();
  }
  withGoodKey(key) {
    this.validateEnteredValue(key);
    if (this.isLast()) {
      this.enableAll();
      this.validateForm();
    } else {
      this.positionMove(+1);
      this.enableCurrent();
    }
    this.setFocus();
  }

  validateEnteredValue(key) {
    this.codeTargets.forEach((element, index) => {
      if (index === this.positionValue) { element.value = key; }
    })
    return;
  }

  eraseCurrentKey() {
    this.codeTargets.forEach((element, index) => {
      if (index === this.positionValue) { element.value = ''; }
    })
  }

  disableAll() { this.codeTargets.forEach(element => { element.setAttribute('disabled', true); }); }
  enableAll() { this.codeTargets.forEach(element => { element.removeAttribute('disabled') }); }
  positionMove(i) { this.positionValue += i }
  isFirst() { return this.positionValue == 0; }
  isLast() { return this.positionValue == this.codeTargets.length - 1; }
  validKey(val) { return (parseInt(val, 10) >= 0 && parseInt(val, 10) <= 9) }
  setFocus() {
    this.codeTargets.forEach((element, index) => {
      if (index === this.positionValue) { element.focus(); }
    });
  }

  enableCurrent() {
    this.disableAll();
    this.codeTargets.forEach((element, index) => {
      if (index === this.positionValue) { element.removeAttribute('disabled') }
    });
  }

  validateForm() { }

  connect() {
    this.codeTargets.forEach((element, index) => {
      element.value = '';
      index === 0 ? element.focus() : element.setAttribute('disabled', true);
    });
  }
}