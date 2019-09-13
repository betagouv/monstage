import { Controller } from 'stimulus';
import Hammer from 'hammerjs';
import Turbolinks from 'turbolinks';

export default class extends Controller {
  connect() {
    this.hammer = new Hammer(document.body, {});

    if (this.data.get('previousUrl').length > 0) {
      this.hammer.on('swipeLeft', this.previous.bind(this));
    }
    if (this.data.get('nextUrl').length > 0) {
      this.hammer.on('swipeRight', this.next.bind(this));
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
