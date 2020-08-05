import { Controller } from 'stimulus';
import $ from 'jquery';
import Turbolinks from 'turbolinks';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [ "application", "internship" ]

  hideSortingDirections() {
    hideElement($(this.internshipTarget));
    hideElement($(this.applicationTarget));
  }

  initialize() {
    showElement($(this.applicationTarget));
    hideElement($(this.internshipTarget));
  }

  connect() {
    const searchParams = new URLSearchParams(window.location.search);
    this.hideSortingDirections()
    switch (searchParams.get('order')){
      case 'applicationDate':
        showElement($(this.applicationTarget));
        break;
      case 'internshipDate':
        showElement($(this.internshipTarget));
    }
  }

  changeURLWithDirection(direction) {
    const searchParams = new URLSearchParams(window.location.search);
    searchParams.set('order', direction);
    return searchParams
  }

  internshipDate() {
    this.changeOrderKey('internshipDate')
  }

  applicationDate() {
    this.changeOrderKey('applicationDate')
  }

  changeOrderKey(key){
    const url = `${window.location.pathname}?${this.changeURLWithDirection(key)}`
    Turbolinks.visit(url);
  }
}

