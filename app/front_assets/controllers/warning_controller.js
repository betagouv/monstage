import $ from 'jquery';
import { Controller } from 'stimulus';
import { hideElement } from '../utils/dom';

export default class extends Controller {

  static targets = ['covidModal'];

  onClick(e) {
    e.preventDefault();
    localStorage.setItem('modalShown', true);
    this.checkPreviousAction();
  }

  checkPreviousAction() {
    if (localStorage.getItem('modalShown')) {
      hideElement($(this.covidModalTarget));
    }
  }

  connect() {
    this.checkPreviousAction();
  }
}