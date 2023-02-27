// rails stack
import '@stimulus/polyfills';
import Rails from 'rails-ujs';
import ReactOnRails from 'react-on-rails';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';

Rails.start();
const application = Application.start()

const context = require.context('controllers', true, /.js$/)
application.load(definitionsFromContext(context))

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true);

import ReservedSchoolInput from "components/ReservedSchoolInput";
import InternshipOfferResults from "components/InternshipOfferResults";
import InternshipOfferFavorites from "components/InternshipOfferFavorites";
import InternshipOfferCard from "components/InternshipOfferCard";
import FlashMessage from "components/FlashMessage";
import SearchSchool from "components/SearchSchool";
import SearchSchoolByName from "components/SearchSchoolByName";
import CompanySummary from "components/CompanySummary";
import SimpleAddressInput from "components/inputs/SimpleAddressInput";

import CityInput from "components/search_internship_offer/CityInput";
import KeywordInput from "components/search_internship_offer/KeywordInput";

import DistanceIcon from "components/icons/DistanceIcon";

import SirenInput from "components/inputs/SirenInput";
import CountryPhoneSelect from "components/inputs/CountryPhoneSelect";
import AddressInput from "components/inputs/AddressInput";
import AltAddressInput from "components/inputs/AltAddressInput";

ReactOnRails.register({
  ReservedSchoolInput,
  InternshipOfferResults,
  InternshipOfferFavorites,
  InternshipOfferCard,
  FlashMessage,
  SearchSchool,
  SearchSchoolByName,
  CompanySummary,
  DistanceIcon,
  CityInput,
  KeywordInput,
  CountryPhoneSelect,
  AddressInput,
  AltAddressInput,
  SirenInput,
  SimpleAddressInput,
});
