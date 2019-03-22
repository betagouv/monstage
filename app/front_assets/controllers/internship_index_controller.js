import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';
import { setElementVisibility } from "../utils/dom";

// should be a link, but have to check with Brice why ...
export default class extends Controller {
  static targets = [ "offer", 'title' ];

  filterOffersBySectors(event) {
    // let sector = event.target.options[event.target.selectedIndex].value;
    let sectors = $("#internship-offer-sector-filter option:selected").map(function() { return this.value }).get();
    let visibleCount = 0
    $(this.offerTargets).each(function (index, offer) {
      let shouldBeHidden = sectors.length > 0 && !sectors.includes($(offer).data('sector'));
      if (!shouldBeHidden) {
        visibleCount += 1
      }
      setElementVisibility($(offer), shouldBeHidden)
    });
    $(this.titleTarget).text(`
      ${visibleCount} ${visibleCount > 1 ? 'offres' : 'offre'} de stage
    `)
  }

}
