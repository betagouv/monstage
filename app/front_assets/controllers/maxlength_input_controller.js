import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['trixElement', 'trixElementCharCount'];
  static values = {
    limit: Number
  }
  connect() {
    const limit = this.limitValue;
    const $trixElementCharCount = $(this.trixElementCharCountTarget);

    this.trixElementTarget.addEventListener('trix-change', event => {
      const { editor } = event.target;
      const string = editor.getDocument().toString();
      const characterCount = string.length - 1;
      $trixElementCharCount.text(`${characterCount}/${limit}`);
      if (characterCount > limit) {
        $trixElementCharCount.addClass('text-danger');
      } else {
        $trixElementCharCount.removeClass('text-danger');
      }
    });
  }
}
