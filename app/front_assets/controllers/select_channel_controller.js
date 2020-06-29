import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['emailInput',
                    'phoneInput', 
                    'emailBloc', 
                    'phoneBloc', 
                    'selectChannel'];
  
  connect() {
    console.log("Hello controller")
  }

  disconnect() {
  }

  checkEmail() {
    this.displayField(this.phoneInputTarget, this.phoneBlocTarget, this.emailBlocTarget)
  }
  
  chooseEmail() {
    $('#channel-phone').attr('checked', false)
    $('#channel-email').attr('checked', true)
    this.checkEmail()
  }

  checkPhone() {
    this.displayField(this.emailInputTarget, this.emailBlocTarget, this.phoneBlocTarget)
  }
  
  choosePhone() {
    $('#channel-email').attr('checked', false)
    $('#channel-phone').attr('checked', true)
    this.checkPhone()
  }

  displayField(fielfToClean, fieldToHide, fieldToDisplay) {
    $(fielfToClean).val('')
    $(fieldToHide).hide()
    $(fieldToHide).addClass('d-none')
    $(fieldToDisplay).hide()
    $(fieldToDisplay).removeClass('d-none')
    $(fieldToDisplay).slideDown()
  }

  focusPhone() {
    $('#phone-input').focus()
  }
}
