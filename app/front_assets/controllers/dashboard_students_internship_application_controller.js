import $ from 'jquery';
import { Controller } from 'stimulus';
import {
  setElementVisibility,
  toggleElement,
  hideElement,
  showElement,
  isVisible,
} from '../utils/dom';

const MENU_ITEM_ACTIVE_CLASS_NAME = 'active';

export default class extends Controller {
  static targets = [
    'internshipOfferDetail',
    'internshipApplicationDetail',
    'conventionDetail',
    'linkInternshipOfferDetail',
    'linkInternshipApplicationDetail',
    'linkConventionDetail',
    'internshipApplicationContent',
    'linkIconContainer',
  ];

  static values = {
    state: String,
  };

  stopEventPropagation(event) {
    if (event) {
      event.preventDefault();
    }
  }

  updateMenu(enabledTarget) {
    $(this.linkInternshipOfferDetailTarget).removeClass(MENU_ITEM_ACTIVE_CLASS_NAME);
    $(this.linkInternshipApplicationDetailTarget).removeClass(MENU_ITEM_ACTIVE_CLASS_NAME);
    $(this.linkConventionDetailTarget).removeClass(MENU_ITEM_ACTIVE_CLASS_NAME);

    $(enabledTarget).addClass(MENU_ITEM_ACTIVE_CLASS_NAME);
  }

  updateTab(enabledTab) {
    hideElement($(this.internshipApplicationDetailTarget));
    hideElement($(this.internshipOfferDetailTarget));
    hideElement($(this.conventionDetailTarget));

    showElement($(enabledTab));
  }

  enableInternshipOfferDetail(event) {
    this.updateTab(this.internshipOfferDetailTarget);
    this.updateMenu(this.linkInternshipOfferDetailTarget);
    this.stopEventPropagation(event);
  }

  enableInternshipApplicationDetail(event) {
    this.updateTab(this.internshipApplicationDetailTarget);
    this.updateMenu(this.linkInternshipApplicationDetailTarget);
    this.stopEventPropagation(event);
  }

  enableConventionDetail(event) {
    this.updateTab($(this.conventionDetailTarget));
    this.updateMenu(this.linkConventionDetailTarget);
    this.stopEventPropagation(event);
  }

  initWithLocationHash() {
    switch (window.location.hash) {
      case '#tab-internship-offer-detail':
        this.enableInternshipOfferDetail();
        break;
      case '#tab-internship-application-detail':
        this.enableInternshipApplicationDetail();
        break;
      case '#tab-convention-detail':
        this.enableConventionDetail();
        break;
      default:
        this.enableInternshipApplicationDetail();
    }
  }

  initWithDataState() {
    switch (this.stateValue) {
      case 'submitted':
      case 'rejected':
        this.enableInternshipApplicationDetail();
        break;
      case 'approved':
      case 'convention_signed':
        this.enableConventionDetail();
        break;
      default:
        this.enableInternshipApplicationDetail();
    }
  }

  connect() {
    // if (window.location.hash) {
    //   this.initWithLocationHash();
    // } else {
    //   this.initWithDataState();
    // }
  }
}
