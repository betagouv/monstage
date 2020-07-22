// rails stack
import '@stimulus/polyfills';
import Rails from 'rails-ujs';
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
const ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);


