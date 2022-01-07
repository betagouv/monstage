import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = ['source', 'goal']
  static classes = ['selected']

  colorizeParent() {
    const goalList = this.goalTargets
    this.sourceTargets.forEach((element, index) => {
      if (element.checked) {
        goalList[index].classList.add(this.selectedClass)
      }
      else {
        goalList[index].classList.remove(this.selectedClass)
      }
    })
  }

  connect() {
    this.colorizeParent();
  }
}
