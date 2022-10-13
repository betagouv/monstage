import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['button' , 'hint', 'selectField'];
  static values = { forbidden: String };

  handleChange(e) {
    if (this.getSelectedText(this.selectFieldTarget) === this.forbiddenValue) {
      this.hintTarget.classList.remove('d-none');
      this.buttonTargets.forEach(btn => {
        btn.classList.add('disabled');
        btn.href = '#';
      });
    } else {
      this.hintTarget.classList.add('d-none');
      this.buttonTargets.forEach(btn => {
        btn.classList.remove('disabled');
      });
    }
  }

  getSelectedText(field) {
    const options = field.options
    return options[options.selectedIndex].innerText
  }

  selectFieldTargetConnected(e) {
    this.handleChange(e)
  }
}