import { Controller } from "stimulus"
import { toggleElement, showElement, hideElement } from "../utils/dom"
import ActionCable from 'actioncable'

export default class extends Controller {
  static targets = [ 'handicapGroup', 'emailHint', 'emailInput' ]

  toggleHandicap() {
    toggleElement($(this.handicapGroupTarget))
  }

  onBlurEmailInput(event) {
    const email = event.target.value;
    if (email.length > 2) {
      this.validator.perform("validate", {
        email: email,
        uid: this.channelParams.uid
      });
    }
  }

  connect() {
    const _that = this;
    const emailHintElement = this.emailHintTarget
    const emailInputElement = this.emailInputTarget
    const $hint = $(emailHintElement);
    const $input = $(emailInputElement);

    this.channelParams = { channel: "MailValidationChannel", uid: Math.random().toString(36) };
    this.wssClient = ActionCable.createConsumer("/cable")
    this.validator = this.wssClient.subscriptions.create(this.channelParams, {
      received: (data) => {
        showElement($hint)

        switch (data.status) {
          case 'valid':
            $hint.attr('class','valid-feedback')
            $input.attr('class', 'form-control is-valid')
            emailHintElement.innerText = "Parfait!"
            break;
          case 'invalid':
            $hint.attr('class','invalid-feedback')
            $input.attr('class', 'form-control is-invalid')

            emailHintElement.innerText = "Cette adresse éléctronique ne nous semble pas valide, veuillez vérifier"
            break;
          case 'hint':
            $hint.attr('class','invalid-feedback')
            $input.attr('class', 'form-control is-invalid')
            emailHintElement.innerText = `Peut être avez-vous fait une typo ? ${data.replacement}`
            break;
          default:
            hideElement($hint)
        }
      },
    })
  }

  disconnect() {
    try {
      this.wssClient.disconnect()
    } catch (e) {

    }
  }
}
