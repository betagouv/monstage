import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";
export default class extends Controller {
  static targets = ['code', 'button'];

  connect() {
    Turbo.setConfirmMethod((message, element) => {
      let dialog = document.getElementById("turbo-confirm")
      dialog.querySelector('p').textContent = message;
      dialog.showModal();

      return new Promise((resolve, reject) => {
        dialog.addEventListener("close", () => {
          resolve(dialog.returnValue == 'confirm')
        }, { once: true })
      });
    });
  }
}