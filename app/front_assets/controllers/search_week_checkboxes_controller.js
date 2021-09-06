import { Controller } from 'stimulus';
import { enableInput, disableInput } from  '../utils/dom';

export default class extends Controller {

  static targets = [ 'input',           // many checkboxes, references all inputs
                     'inputPlaceholder',// a placeholder for inline view with a popover
                     'badgeList' ]      // list of weeks always visible when calendar view


  onCheckboxChange(changeEvent){
    this.toggleActiveOnParentNode(changeEvent.currentTarget)
  }

  onSchoolTrackChange(changeEvent) {
   this.updateOnSchoolTrackChange(changeEvent.currentTarget.value)
  }

  updateOnSchoolTrackChange(newValue) {
     if (newValue == 'troisieme_generale') {
      $(this.inputTargets).map((i, element) => {
        enableInput($(element));
        element.parentNode.classList.remove('disabled')
      });
    } else {
      $(this.inputTargets).map((i, element) => {
        disableInput($(element));
        element.parentNode.classList.add('disabled')
      });
    }
  }

  // private utils
  connect(){
    $(this.inputTargets).map((i, element) => {
      if (element.checked) {
        element.parentNode.classList.add('active')
      }
    })
    this.propagateChangesToPlaceholder()
    this.propagateChangesToBadgeList()
  }

  toggleActiveOnParentNode(input) {
    if (input.checked) {
      input.parentNode.classList.add('active')
    } else {
      input.parentNode.classList.remove('active')
    }
    this.propagateChangesToPlaceholder()
    this.propagateChangesToBadgeList()
  }

  // private, ui complexity... do not like this kind of complexe dom manipulation
  propagateChangesToPlaceholder() {
    const selectedWeeksCount = this.getSelectedInputs().length
    const placeholderValue = selectedWeeksCount == 0 ?
                             'Dates de stage' :
                             `${selectedWeeksCount} semaine${selectedWeeksCount > 1 ? 's' : ''}`
    $(this.inputPlaceholderTarget).attr("placeholder", placeholderValue)
  }

  propagateChangesToBadgeList() {
    $(this.badgeListTarget).empty();
    this.getSelectedInputs().map((i, weekInput) => {
      const weekStr = $(weekInput).data('text-week-str')
      $(this.badgeListTarget).append(`<div class="badge badge-pill badge-search mt-2" >${weekStr}<a class="ml-1" data-action="click->search-week-checkboxes#remove" data-week-id="${weekInput.value}">&times;<a></div>`)
    })
  }

  // dom selectors
  getSelectedInputs() { return $(this.inputTargets).filter((i, el) => el.checked) }
}
