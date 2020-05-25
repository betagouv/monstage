import { Controller } from 'stimulus';
import Hammer from 'hammerjs';
import Turbolinks from 'turbolinks';

export default class extends Controller {
  connect() {
    // see: http://hammerjs.github.io/tips/#i-cant-select-my-text-anymore
    delete Hammer.defaults.cssProps.userSelect;
    this.hammer = new Hammer(document.body, { });

    if (this.data.get('previousUrl').length > 0) {
      this.hammer.on('swipeleft', this.previous.bind(this));
    }
    if (this.data.get('nextUrl').length > 0) {
      this.hammer.on('swiperight', this.next.bind(this));
    }
  }

  previous() {
    const url = this.data.get('previousUrl');
    Turbolinks.visit(url);
  }

  next() {
    const url = this.data.get('nextUrl');
    Turbolinks.visit(url);
  }

  disconnect() {
    this.hammer.destroy();
  }
}
