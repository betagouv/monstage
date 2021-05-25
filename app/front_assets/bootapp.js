// rails stack
import '@stimulus/polyfills';
import Rails from 'rails-ujs';
import ReactOnRails from 'react-on-rails';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';
import Turbolinks from 'turbolinks';

// icons
import 'fonts/fontawesome';

Rails.start();
Turbolinks.start();
const application = Application.start()

const context = require.context('controllers', true, /.js$/)
application.load(definitionsFromContext(context))

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true);

import SearchInternshipOffer from "components/SearchInternshipOffer";
import ReservedSchoolInput from "components/ReservedSchoolInput";
import FilterInternshipOffer from "components/FilterInternshipOffer";
import SearchSchool from "components/SearchSchool";
import SearchSchoolByName from "components/SearchSchoolByName";
import CountryPhoneSelect from "components/inputs/CountryPhoneSelect";
import AddressInput from "components/inputs/AddressInput";
import DistanceIcon from "components/icons/DistanceIcon";


ReactOnRails.register({
  SearchInternshipOffer,
  ReservedSchoolInput,
  FilterInternshipOffer,
  SearchSchool,
  SearchSchoolByName,
  DistanceIcon,
  CountryPhoneSelect,
  AddressInput,
});
