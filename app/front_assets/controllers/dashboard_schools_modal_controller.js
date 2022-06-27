import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  openModal() {
    $('#notice-school-manager-empty-weeks').modal({ show: true, backdrop: false });
  }

  closeNotice() {
    localStorage.setItem('close_school_manager', true);
  }

  connect() {
    setTimeout(() => {
      var notice = localStorage.getItem('close_school_manager');
      if (notice == null) {
        this.openModal();
      }
    }, 300);
  }
}
