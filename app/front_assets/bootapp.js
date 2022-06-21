// rails stack
import '@stimulus/polyfills';
import Rails from 'rails-ujs';
import ReactOnRails from 'react-on-rails';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';

// icons
import 'fonts/fontawesome';

Rails.start();
const application = Application.start()

const context = require.context('controllers', true, /.js$/)
application.load(definitionsFromContext(context))

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true);

import ReservedSchoolInput from "components/ReservedSchoolInput";
import InternshipOfferResults from "components/InternshipOfferResults";
import InternshipOfferCard from "components/InternshipOfferCard";
import SearchSchool from "components/SearchSchool";
import SearchSchoolByName from "components/SearchSchoolByName";
import CityInput from "components/search_internship_offer/CityInput";
import KeywordInput from "components/search_internship_offer/KeywordInput";
import CountryPhoneSelect from "components/inputs/CountryPhoneSelect";
import AddressInput from "components/inputs/AddressInput";
import FullAddressInput from "components/inputs/FullAddressInput";
import SirenInput from "components/inputs/SirenInput";
import DistanceIcon from "components/icons/DistanceIcon";


ReactOnRails.register({
  ReservedSchoolInput,
  InternshipOfferResults,
  InternshipOfferCard,
  SearchSchool,
  SearchSchoolByName,
  DistanceIcon,
  CityInput,
  KeywordInput,
  CountryPhoneSelect,
  AddressInput,
  FullAddressInput,
  SirenInput
});
