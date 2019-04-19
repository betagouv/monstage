import { Controller } from "stimulus"
import { hideElement, showElement } from "../utils/dom";

export default class extends Controller {
  static targets = ["internshipOfferDetail",
                    "internshipApplicationDetail",
                    "conventionDetail",
                    "linkInternshipOfferDetail",
                    "linkInternshipApplicationDetail",
                    "linkConventionDetail", ];

  updateMenu(enabledTarget){
    $(this.linkInternshipOfferDetailTarget).removeClass('active')
    $(this.linkInternshipApplicationDetailTarget).removeClass('active')
    $(this.linkConventionDetailTarget).removeClass('active')

    $(enabledTarget).addClass('active')
  }

  updateTab(enabledTab) {
    hideElement($(this.internshipApplicationDetailTarget));
    hideElement($(this.internshipOfferDetailTarget));
    hideElement($(this.conventionDetailTarget));

    showElement($(enabledTab))
  }

  enableInternshipOfferDetail(event) {
    this.updateTab(this.internshipOfferDetailTarget);
    this.updateMenu(this.linkInternshipOfferDetailTarget);
  }

  enableInternshipApplicationDetail(event) {
    this.updateTab(this.internshipApplicationDetailTarget);
    this.updateMenu(this.linkInternshipApplicationDetailTarget);
  }

  enableConventionDetail(event) {
    this.updateTab($(this.conventionDetailTarget));
    this.updateMenu(this.linkConventionDetailTarget);
  }

  initWithLocationHash() {
    switch(window.location.hash) {
      case '#tab-internship-offer-detail':
        this.enableInternshipOfferDetail();
        break;
      case '#tab-internship-application-detail':
        this.enableInternshipApplicationDetail()
        break;
      case '#tab-convention-detail':
        this.enableConventionDetail();
        break;
      default:
        this.enableInternshipApplicationDetail();
    }
  }

  initWithDataState() {
    switch(this.data.get('state')) {
      case 'submitted':
      case 'approved':
      case 'rejected':
        this.enableInternshipApplicationDetail();
        break;
      case 'convention_signed':
        this.enableConventionDetail();
        break;
      default:
        this.enableInternshipApplicationDetail();
    }
  }

  connect() {
    if (window.location.hash) {
      this.initWithLocationHash()
    } else {
      this.initWithDataState()
    }
  }
}
