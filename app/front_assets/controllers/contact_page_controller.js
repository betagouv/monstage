import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $formContainer = $('#feedback-form');
    $('#feedback-form').ZammadForm({
      messageTitle: 'Formulaire de Contact',
      messageSubmit: 'Envoyer',
      messageThankYou:
        'Merci pour votre requête  (#%s) ! Nous vous recontacterons dans les meilleurs délais.',
      showTitle: true,
      attachmentSupport: true,
    });

    $formContainer.find('button[type="submit"]').addClass('btn-primary');
  }
}
