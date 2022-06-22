import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['code', 'button'];
  static values = { position: Number }

  onKeyUp(event) {
    event.preventDefault();
    (event.key == 'Backspace') ? this.eraseBack(event) : this.enterKey(event);
    this.setFocus(event);
  }

  // private

  eraseBack(event) {
    this.eraseCurrentKey(event)
    if (!this.firstPosition()) { this.positionMove(-1); }
    this.enableCurrent(event);
    this.eraseCurrentKey(event);
  }

  enterKey(event) {
    this.validKey(event.key) ? this.withGoodKey(event) : this.eraseCurrentKey();
  }

  withGoodKey(event) {
    this.validateEnteredValue(event);
    if (this.lastPosition()) {
      this.enableAll();
      this.validateForm();
    } else {
      this.positionMove(+1);
      this.enableCurrent(event);
    }
  }

  currentCodeTarget() { return this.codeTargets[parseInt(this.positionValue, 10)]; }
  parseCodes(fn, event = undefined) { fn(this.currentCodeTarget(), event); }

  assignKey(element, event) { element.value = event.key; }
  validateEnteredValue(event) { this.parseCodes(this.assignKey, event); }

  clearKey(element) { element.value = ''; }
  eraseCurrentKey(event) { this.parseCodes(this.clearKey, event); }

  enableField(element) { element.removeAttribute('disabled'); }
  enableCurrent(event) {
    this.disableAll(); this.parseCodes(this.enableField, event);
  }

  fieldFocus(element) { element.focus(); }
  setFocus(event) { this.parseCodes(this.fieldFocus, event); }

  disableAll() {
    this.codeTargets.forEach(element => { element.setAttribute('disabled', true); });
  }
  enableAll() {
    this.codeTargets.forEach(element => { element.removeAttribute('disabled') });
  }

  firstPosition() { return this.positionValue == 0; }
  lastPosition() { return this.positionValue == this.codeTargets.length - 1; }
  positionMove(val) { this.positionValue += val; }

  validKey(val) { return (parseInt(val, 10) >= 0 && parseInt(val, 10) <= 9) }
  validateForm() {
    this.buttonTarget.removeAttribute('disabled');
    this.codeTarget.form.submit();
  }

  connect() {
    this.codeTargets.forEach((element, index) => {
      element.value = '';
      index === 0 ? element.focus() : element.setAttribute('disabled', true);
    });
    this.buttonTarget.setAttribute('disabled', true);
  }
}