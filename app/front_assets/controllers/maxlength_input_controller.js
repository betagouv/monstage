import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['trixElement', 'trixElementCharCount','maxLengthMessage'];
  static values = {
    limit: Number
  }
  connect() {
    const limit = this.limitValue;
    const $trixElementCharCount = $(this.trixElementCharCountTarget);

    this.trixElementTarget.addEventListener('trix-change', event => {
      const { editor } = event.target;
      let string = editor.getDocument().toString();
      const characterCount = string.length - 1;
      $trixElementCharCount.text(`${characterCount}/${limit}`);
      if (characterCount >= limit) {
        $trixElementCharCount.addClass('text-danger');
        string = editor.getDocument().toString().substring(0, limit);
        this.trixElementTarget.editor.loadHTML(string);
        this.maxLengthMessageTarget.classList.remove('d-none');
      } else {
        $trixElementCharCount.removeClass('text-danger');
        this.maxLengthMessageTarget.classList.add('d-none');
      }
    });
  }
}
