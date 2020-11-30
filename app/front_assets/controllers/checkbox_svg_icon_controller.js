import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'border', 'option' ]

  connect(){
    this.optionTarget.checked = false
  }

  onCheck(e){
    const is_checked = e.target.checked;
    e.preventDefault();
    const classList  = this.borderTarget.classList;
    (is_checked) ? classList.add('active') : classList.remove('active');
    return true;
  }
}
