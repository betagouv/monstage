import '@stimulus/polyfills';
import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';
import { dom, library } from "@fortawesome/fontawesome-svg-core";
import { fas } from "@fortawesome/free-solid-svg-icons";

Rails.start();
Turbolinks.start();
const application = Application.start()
const context = require.context('controllers', true, /.js$/)
application.load(definitionsFromContext(context))
dom.watch()
library.add(fas)

