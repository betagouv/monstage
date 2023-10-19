import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['applyButton'];

  applyCount() {
    const userId = this.applyButtonTarget.dataset.userid;
    const internshipOfferId = this.applyButtonTarget.dataset.internshipofferid;
    $.ajax({
      url: '/offres-de-stage/' + internshipOfferId + '/apply_count',
      type: 'POST',
      data: { user_id: userId }
    });
  }

  connect() {}
}
