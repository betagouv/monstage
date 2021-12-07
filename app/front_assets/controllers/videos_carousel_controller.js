import { Controller } from 'stimulus';
import { isMobile } from '../utils/responsive';

export default class extends Controller {

  static targets = ['slide', 'pill', 'inViewPort', 'player'];
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

  handleIntersect(entries, observer) {
    if (!this.playerWasLaunched) {
      // one time only
      if (entries[0].isIntersecting) {
        this.launchPlayer();
        this.playerWasLaunched = true
      } else {
        this.pausePlayer();
      }
    }
  }

  launchPlayer() {
  }

  pausePlayer() {
  }

  createObserver() {
  }

  connect() {
    this.showCurrentSlide();
  }

  initialize() {
    this.index = 0;
    this.observer = null
    this.player = null;
    this.playerWasLaunched = false
    this.showCurrentSlide();
  }

  disconnect() { }
}