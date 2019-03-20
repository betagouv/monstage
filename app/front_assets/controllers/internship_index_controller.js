import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';

// should be a link, but have to check with Brice why ...
export default class extends Controller {
  static targets = [ "offer",
                     "filterOption" ];

  filterOffersBySectors(event) {
    const sectors = Array.from(this.filterOptionTargets)
                         .filter((element) => element.selected )
                         .map((element) => element.value)

    Array.from(this.offerTargets).forEach((offerElement) => {
      let shouldBeHidden = sectors.length > 0 && !sectors.includes(offerElement.dataset.sector);
      setElementVisibility(offerElement, !shouldBeHidden)
    });
  }
}
