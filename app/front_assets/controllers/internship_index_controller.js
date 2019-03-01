import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';

// should be a link, but have to check with Brice why ...
export default class extends Controller {
  static targets = [ "offer" ];
  visit(event) {
    Turbolinks.visit(event.currentTarget.dataset["internshipIndexHref"])
  }

  filterOffersBySectors(event) {
    // let sector = event.target.options[event.target.selectedIndex].value;
    let sectors = $("#internship-offer-sector-filter option:selected").map(function() { return this.value }).get();

    $(this.offerTargets).each(function (index, offer) {
      let shouldBeHidden = sectors.length > 0 && !sectors.includes($(offer).data('sector'));
      $(offer).toggleClass('d-none', shouldBeHidden);
    });
  }

}
