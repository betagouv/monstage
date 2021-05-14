import React from "react";
import ReactDOM from "react-dom";
import SearchSchool from '../components/SearchSchool';
import { Controller } from 'stimulus';
import { changeURLFromEvent, visitURLWithParam } from '../utils/urls';

export default class extends Controller {
  static values = {
    reactComponentName: String,
  }

  initialize() {
    if (this.reactComponentNameValue !== '') {
      if (!this.data.get("initialized")) {
        this.initReactComponent();
      }
    } else {
      const nodeToSilence= document.querySelector(".extra-react-component")
      nodeToSilence.classList.add('d-none')
    }
  }

  initReactComponent() {
    const reactSearchElem = document.createElement("div");
    const parentNode = document.querySelector(".extra-react-component").firstChild;
    parentNode.insertBefore(reactSearchElem, null)
    ReactDOM.render(
      <SearchSchool
        classes = 'col-12'
        label = "Ville ou établissement"
        required = {false}
        resourceName = 'user'
        existingSchool = {false}
        existingClassRoom={false}
        injectedOnChange={this.filterBySchoolId}
      />, reactSearchElem )
    this.data.set("initialized", true);
  }

  filterByDepartment(event) {
    changeURLFromEvent(event, 'department');
  }

  filterByAcademy(event) {
    changeURLFromEvent(event, 'academy');
  }

  filterByPublicy(event) {
    changeURLFromEvent(event, 'is_public');
  }

  filterBySchoolTrack(event) {
    changeURLFromEvent(event, 'school_track');
  }

  filterBySchoolYear(event) {
    changeURLFromEvent(event, 'school_year');
  }

  filterBySubscribedSchool(event) {
    changeURLFromEvent(event, 'subscribed_school');
  }

  filterBySchoolId(id) {
    visitURLWithParam('school_id', id);
  }

  useDimension(event) {
    changeURLFromEvent(event, 'dimension');
  }

  disconnect() {
    if (this.reactComponentNameValue !== '') {
      const parentNode = document.querySelector(".extra-react-component").firstChild;
      ReactDOM.unmountComponentAtNode(parentNode)
      console.log('finished')
    }
  }
}