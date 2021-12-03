import { Controller } from 'stimulus';
import { isMobile } from '../utils/responsive';

export default class extends Controller {

  static targets = ['slide', 'pill'];
  static values = { index: Number }

  showCurrentSlide() {
    this.slideTargets.forEach((element, index) => {
      if (!isMobile()) {
        element.hidden = (index != this.indexValue);
      }
    });
    this.pillTargets.forEach((element, index) => {
      (index == this.indexValue) ? element.classList.add('active') : element.classList.remove('active')
    });
  }

  slidesNumber() {
    return this.slideTargets.length;
  }


  show() {
    this.indexValue = (this.indexValue == (this.slidesNumber() - 1)) ? 0 : this.indexValue + 1
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