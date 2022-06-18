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
    if (!this.firstPosition()) { this.positionMove(-1); }
    this.enableCurrent();
    this.eraseCurrentKey();
    this.setFocus();
  }

  enterKey(event) {
    this.validKey(event.key) ? this.withGoodKey(event.key) : this.eraseCurrentKey();
  }

  withGoodKey(key) {
    this.validateEnteredValue(key);
    if (this.lastPosition()) {
      this.enableAll();
      this.validateForm();
    } else {
      this.positionMove(+1);
      this.enableCurrent();
    }
    this.setFocus();
  }

  parseCodes(fn, key = '') {
    this.codeTargets.forEach((element, index) => {
      if (index === this.positionValue) { fn(element, key); }
    });
    return;
  }

  assignKey(element, key) { element.value = key; }
  validateEnteredValue(key) { this.parseCodes(this.assignKey, key); }

  clearKey(element) { element.value = ''; }
  eraseCurrentKey() { this.parseCodes(this.clearKey); }

  enableField(element) { element.removeAttribute('disabled'); }
  enableCurrent() { this.disableAll(); this.parseCodes(this.enableField); }

  fieldFocus(element) { element.focus(); }
  setFocus() { this.parseCodes(this.fieldFocus); }

  disableAll() {
    this.codeTargets.forEach(element => { element.setAttribute('disabled', true); });
  }

  enableAll() {
    this.codeTargets.forEach(element => { element.removeAttribute('disabled') });
  }
  positionMove(i) { this.positionValue += i }
  firstPosition() { return this.positionValue == 0; }
  lastPosition() { return this.positionValue == this.codeTargets.length - 1; }
  validKey(val) { return (parseInt(val, 10) >= 0 && parseInt(val, 10) <= 9) }

  validateForm() { this.codeTargets[0].closest('form').submit(); }

  connect() {
    this.codeTargets.forEach((element, index) => {
      element.value = '';
      index === 0 ? element.focus() : element.setAttribute('disabled', true);
    });
  }
}