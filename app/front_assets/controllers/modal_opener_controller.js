import { Controller } from 'stimulus';
export default class extends Controller {
  static targets = ['dialog', 'button']
  static values = { initialState: Boolean }

  dialogTargetConnected() {
    if (this.initialStateValue) {
      setTimeout(() => { this.buttonTarget.click(); }, 500);
    }
  }
}
