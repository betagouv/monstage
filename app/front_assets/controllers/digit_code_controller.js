import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['code', 'button'];
  static values = { position: Number }

  onKeyUp(event) {
    event.preventDefault();
    (event.key == 'Backspace' || event.key == 'ArrowLeft') ?
      this.eraseBack(event) : this.enterKey(event);
    this.setFocus(event);
  }

  // private

  eraseBack(event) {
    if (this.positionValue >= this.codeTargets.length) { this.positionMove(-1) }
    this.eraseCurrentKey(event)
    if (this.firstPosition()) { return; }

    this.positionMove(-1);
    this.enableCurrent(event);
    this.eraseCurrentKey(event);
  }

  enterKey(event) {
    this.isNumericKeyOrShiftKey(event) ? this.withNumericKey(event) : this.eraseCurrentKey();
  }

  withNumericKey(event) {
    if (!event.shiftKey) { this.validateEnteredValue(event); }
    this.positionMove(+1); //trick to keep last digit
    if (this.pastLastPosition()) {
      this.enableAll();
      this.enableForm();
    } else {
      this.enableCurrent(event);
      this.setFocus(event);
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
  pastLastPosition() { return this.positionValue == this.codeTargets.length; }
  positionMove(val) { this.positionValue += val; }

  isNumericKeyOrShiftKey(event) {
    const isInteger = /^\d+$/.test(event.key);
    const isShiftKey = event.shiftKey;
    const capitals = /^[A-Z]$/.test(event.key);
    return (isInteger || isShiftKey) && !capitals;
  }

  enableForm() {
    this.buttonTarget.removeAttribute('disabled');
  }

  codeTargetConnected() {
    this.codeTargets.forEach((element, index) => {
      element.value = '';
      index === 0 ? element.focus() : element.setAttribute('disabled', true); 
    });
    this.buttonTarget.setAttribute('disabled', true);
    this.connect();
  }
}