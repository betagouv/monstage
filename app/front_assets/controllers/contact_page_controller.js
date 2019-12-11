import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    const $formContainer = $('#feedback-form');

    $formContainer.ZammadForm({
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
