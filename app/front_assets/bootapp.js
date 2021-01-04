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

// from https://github.com/hotwired/stimulus/issues/347
// load definitions from app/javascript/controllers
const controllerContext = require.context("controllers", true, /_controller\.js$/)
let controllerDefinitions = definitionsFromContext(controllerContext)

// load definitions from app/components/*
const componentContext = require.context("components", true, /.*controller\.js$/)
function getComponentControllerDefinitions(context) {
  return context.keys().map(key => {
    const identifier = key
      .replace("controller.js", "")
      .replace(/[\W_]/g, "-")
      .replace(/^-+/,"")
      .replace(/-+$/, "");
    return { identifier, controllerConstructor: context(key).default }
  })
}
let componentControllerDefinitions = getComponentControllerDefinitions(componentContext);

application.load([...controllerDefinitions, ...componentControllerDefinitions])

import SearchInternshipOffer from "components/SearchInternshipOffer";
import ReservedSchoolInput from "components/ReservedSchoolInput";
import FilterInternshipOffer from "components/FilterInternshipOffer";
import SearchSchool from "components/SearchSchool";
import CountryPhoneSelect from "components/inputs/CountryPhoneSelect";
import AddressInput from "components/inputs/AddressInput";
import DistanceIcon from "components/icons/DistanceIcon";


ReactOnRails.register({
  SearchInternshipOffer,
  ReservedSchoolInput,
  FilterInternshipOffer,
  SearchSchool,
  DistanceIcon,
  CountryPhoneSelect,
  AddressInput,
});
