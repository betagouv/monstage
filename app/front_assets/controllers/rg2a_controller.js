import $ from 'jquery';
import { Controller } from 'stimulus';

// see: https://github.com/turbolinks/turbolinks#making-transformations-idempotent
// since we add a FA icon by hand,
// avoid re-adding the icon on back-button hit which re-use a snapshot version of turbolink
const TURBOLINK_IDEMPOTENT_CLASSNAME = 'rg2a-external';

export default class extends Controller {
  connect() {
    $('a[target="_blank"]').each((i, el) => {
      const $el = el;

      if (!$(el).hasClass(TURBOLINK_IDEMPOTENT_CLASSNAME)) {
        $(el).addClass(TURBOLINK_IDEMPOTENT_CLASSNAME);
        $(el).prepend('<i class="fas fa-external-link-alt fa-fw fa-xs ml-1"></i> ');
      }
    });
  }
}
