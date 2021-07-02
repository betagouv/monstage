import {
  Controller
} from 'stimulus';
import Hammer from 'hammerjs';
import Turbolinks from 'turbolinks';

export default class extends Controller {
  static values = {
    previousUrl: String,
    nextUrl: String,
  };

  connect() {
    // see: http://hammerjs.github.io/tips/#i-cant-select-my-text-anymore
    delete Hammer.defaults.cssProps.userSelect;
    this.hammer = new Hammer(document.body, {});
    if (navigator.userAgent.toLowerCase().match(/mobile/i)) {
      if (this.previousUrlValue.length > 0) {
        this.hammer.on('swipeleft', this.previous.bind(this));
      }
      if (this.nextUrlValue.length > 0) {
        this.hammer.on('swiperight', this.next.bind(this));
      }
    }
  }

  previous() {
    const url = this.previousUrlValue;
    Turbolinks.visit(url);
  }

  next() {
    const url = this.nextUrlValue;
    Turbolinks.visit(url);
  }

  disconnect() {
    this.hammer.destroy();
  }
}