import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['submitButton'];

  checkPassword(){
    const submitButton = this.submitButtonTarget;
    const password = $("#user_password").val();
    const confirmation = $("#user_password_confirmation").val();
    if (password.length > 0 && password === confirmation) {
      $(submitButton).prop("disabled", false);
    } else {
      $(submitButton).prop("disabled", true);
    }
  }

  connect(){
  }

  initialize(){
  }

  disconnect(){  
  }
}