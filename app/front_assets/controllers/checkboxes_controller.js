import { Controller } from 'stimulus';

export default class extends Controller {

  static targets = [ 'input',
                     'inputPlaceholder',
                     'badgeList' ]


  onChange(changeEvent){
    this.toggleActiveOnParentNode(changeEvent.currentTarget)
  }


  remove(clickEvent) {
    const $badgeRemoveButton = $(clickEvent.currentTarget);
    $(this.inputTargets).map((i, element) => {
      if (element.value ==  $badgeRemoveButton.data('week-id')) {
        element.checked = false;
        this.toggleActiveOnParentNode(element);
      }
    })
  }

  clear(clickEvent) {
    console.log('click')
    this.getSelectedInputs().map((i, element) => {
      element.checked = false
      this.toggleActiveOnParentNode(element);
    })
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
      $(this.badgeListTarget).append(`<div class="badge badge-pill badge-search mt-2" >${weekStr}<a class="ml-1" data-action="click->checkboxes#remove" data-week-id="${weekInput.value}">&times;<a></div>`)
    })
  }

  // dom selectors
  getSelectedInputs() { return $(this.inputTargets).filter((i, el) => el.checked) }
}
