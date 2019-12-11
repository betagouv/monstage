import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    $('a[target="_blank"]').each((i, el) => {
      $(el).append('<i class="fas fa-external-link-alt fa-xs mx-1"></i>');
    });
  }
}
