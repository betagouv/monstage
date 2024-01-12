import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['code', 'button', 'codeContainer'];
  static values = { position: Number }

  onKeyUp(event) {
    event.preventDefault();
    if (event.key == 'Shift') { return; } 
    const isBackKey = (event.key == 'Backspace' || event.key == 'ArrowLeft');
    (isBackKey) ? this.eraseBack(event) : this.enterKey(event);
    this.setFocus(event);
  }

  // private

  eraseBack(event) {
    this.eraseCurrentKey(event)
    if (this.firstPosition()) { return; }
    this.moveBackward(event);
  }

  enterKey(event) {
    this.isNumericKeyOrShiftKey(event) ? this.withNumericKey(event) : this.eraseCurrentKey();
  }

  withNumericKey(event) {
    this.validateEnteredValue(event);
    if (this.lastPosition()) {
      this.enableAll();
      this.enableForm();
    } else {
      this.moveForward(event);
    }
  }

  moveForward(event) { this.move(event, +1) }
  moveBackward(event) {
    this.move(event, -1);
    this.codeContainerTarget.classList.remove('finished');
  }
  move(event, val) { this.positionValue += val; this.enableCurrent(event); }
  firstPosition() { return this.positionValue == 0; }
  lastPosition() { return this.positionValue == this.codeTargets.length - 1; }

  currentCodeTarget() { return this.codeTargets[this.positionValue]; }
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

  isNumericKeyOrShiftKey(event) {
    const isInteger = /^\d+$/.test(event.key);
    const isShiftKey = event.shiftKey;
    const capitals = /^[A-Z]$/.test(event.key);
    return (isInteger || isShiftKey) && !capitals;
  }

  enableForm() {
    this.buttonTarget.removeAttribute('disabled');
    this.codeContainerTarget.classList.add('finished');
    // window.setTimeout(() => {this.buttonTarget.focus()}, 150);
  }

  codeTargetConnected() {
    this.codeTargets.forEach((element, index) => {
      element.value = '';
      index === 0 ? element.focus() : element.setAttribute('disabled', true); 
    });
    this.buttonTarget.setAttribute('disabled', true);
  }
}