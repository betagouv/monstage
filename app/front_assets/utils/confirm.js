import { Turbo } from "@hotwired/turbo-rails";

Turbo.setConfirmMethod((message, element) => {
  console.log('message');
  console.log('element');
  let dialog = document.getElementById("turbo-confirm");
  dialog.querySelector('p').textContent = message;
  dialog.showModal();

  return new Promise((resolve, reject) => {
    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue == 'confirm')
    }, { once: true })
  });
});
// to be used with Turbo and button_to with following attribute :
// `form: { data: {turbo_confirm: 'En êtes-vous sûr'}}`
// eg: <%= button_to "Destroy this post", @post, method: : delete, form: { data: { turbo_confirm: "Are you sure?" } } %>