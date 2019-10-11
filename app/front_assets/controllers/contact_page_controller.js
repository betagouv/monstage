import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    $('#feedback-form').ZammadForm({
      messageTitle: 'Formulaire de Contact',
      messageSubmit: 'Envoyer',
      messageThankYou: 'Merci pour votre requête  (#%s) ! Nous vous recontacterons dans les meilleurs délais.',
      showTitle: true,
      attachmentSupport: true
    });
  }
}
