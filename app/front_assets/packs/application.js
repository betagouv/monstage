/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/front_assets and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
// rails pollyfills (ie<11), see: https://github.com/rails/webpacker/issues/1963
import "core-js/stable";
import "regenerator-runtime/runtime";

// react polyfills (ie<11), see: https://reactjs.org/docs/javascript-environment-requirements.html
import 'raf/polyfill';
import 'core-js/es/map';
import 'core-js/es/set';

import '@gouvfr/dsfr/dist/dsfr.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-system/icons-system.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-user/icons-user.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-business/icons-business.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-design/icons-design.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-document/icons-document.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-media/icons-media.css';
import '@gouvfr/dsfr/dist/utility/colors/colors.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-map/icons-map.css';

import '@gouvfr/dsfr/dist/dsfr.module.js';

import '../stylesheets/screen.scss';
import '../stylesheets/print.scss';

import '@popperjs/core';

import '@hotwired/turbo-rails';

import Alert from 'bootstrap'
import Dropdown from 'bootstrap'
import Modal from 'bootstrap'
import Tooltip from 'bootstrap'

import "trix";
import "@rails/actiontext";

import 'url-search-params-polyfill';

import '../bootapp';
import '../leaflet-providers';

import '../utils/zammad_form';

import '../utils/confirm';
