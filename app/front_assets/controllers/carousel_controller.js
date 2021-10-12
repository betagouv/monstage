import {
  Controller
} from 'stimulus';
import isMobile from 'utils/responsive';

export default class extends Controller {

  static targets = ['slide'];
  static values = { index: Number }

  showCurrentSlide() {
    this.slideTargets.forEach((element, index) => {
      console.log('isMobile : ' + isMobile())
      if (!isMobile()) {
        element.hidden = (index != this.indexValue);
      }
    })
  }

  next() {
    this.indexValue = (this.indexValue == 2) ? 0 : this.indexValue + 1
    this.showCurrentSlide();
  }

  previous() {
    this.indexValue = (this.indexValue == 0) ? 2 : this.indexValue - 1
    this.showCurrentSlide();
  }

  connect() {
    this.showCurrentSlide();
  }


  initialize() {
    this.index = 0;
    this.showCurrentSlide();
  }

  disconnect() {
  }
}