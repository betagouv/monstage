import { Controller } from 'stimulus';
import { enableInput, disableInput } from  '../utils/dom';

const PLACEHOLDER_NO_WEEK_SELECTED_OR_NOT_TROISIEME_GENERALE = '';

export default class extends Controller {

  static targets = [
    'inputCheckboxes', // many checkboxes, references all inputs
    'inputPlaceholder',// a placeholder for inline view with a popover
    'badgeList'        // list of weeks always visible when calendar view
  ]


  onCheckboxChange(changeEvent){
    this.toggleActiveOnParentNode(changeEvent.currentTarget)
  }


  enableCheckboxes(newValue) {
    $(this.inputCheckboxesTargets).map((i, element) => {
      enableInput($(element));
      element.parentNode.classList.remove('disabled')
    });
  }

  remove(clickEvent) {
    const $badgeRemoveButton = $(clickEvent.currentTarget);
    $(this.inputCheckboxesTargets).map((i, element) => {
      if (element.value ==  $badgeRemoveButton.data('week-id')) {
        element.checked = false;
        this.toggleActiveOnParentNode(element);
      }
    })
  }

  // private utils
  connect(){
    $(this.inputCheckboxesTargets).map((i, element) => {
      if (element.checked) {
        element.parentNode.classList.add('active')
      }
    })
    this.propagateChangesToPlaceholder()
    this.propagateChangesToBadgeList()
    this.enableCheckboxes()
  }

  toggleActiveOnParentNode(input) {
   const nodeClassList = input.parentNode.classList

    input.checked ? nodeClassList.add('active') : nodeClassList.remove('active')
    this.propagateChangesToPlaceholder()
    this.propagateChangesToBadgeList()
  }

  // private, ui complexity... do not like this kind of complexe dom manipulation
  propagateChangesToPlaceholder() {
    const selectedWeeksCount = this.getSelectedInputs().length
    const placeholderValue = selectedWeeksCount == 0 ?
                             PLACEHOLDER_NO_WEEK_SELECTED_OR_NOT_TROISIEME_GENERALE:
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
  getSelectedInputs() { return $(this.inputCheckboxesTargets).filter((i, el) => el.checked) }
}
